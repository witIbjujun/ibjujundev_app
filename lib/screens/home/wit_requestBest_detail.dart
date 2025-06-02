// 2025-06-02: getRequesMainList 조회 후 categoryNm 별로 탭 구성
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../util/wit_api_ut.dart';
import '../chat/CustomChatScreen.dart';
import '../seller/wit_common_imageViewer_sc.dart';
import '../seller/wit_seller_profile_child_view_sc.dart';
import '../seller/wit_seller_profile_view_sc.dart';
import 'models/requestMainInfo.dart';
import 'models/requestInfo.dart';
import 'widgets/wit_home_widgets.dart';
import 'wit_home_theme.dart';

class RequestBestDetailScreen extends StatefulWidget {
  final String categoryId; // 요청 카테고리 ID
  final String reqNo; // 요청 번호
  final String companyCnt; // 업체 수

  const RequestBestDetailScreen({
    Key? key,
    required this.categoryId,
    required this.reqNo,
    required this.companyCnt,
  }) : super(key: key);

  @override
  State<RequestBestDetailScreen> createState() => _RequestBestDetailScreenState();
}

class _RequestBestDetailScreenState extends State<RequestBestDetailScreen> with TickerProviderStateMixin {
  final secureStorage = FlutterSecureStorage(); // 보안 저장소 인스턴스
  List<RequestMainInfo> requests = []; // 조회된 견적 데이터 리스트
  List<RequestInfo> detailRequests = []; // 탭 클릭 시 조회된 상세 데이터 리스트

  RequestMainInfo? _selectedMainRequest;  // 상단 탭 및 카드용
  RequestInfo? _selectedDetailRequest;    // 하단 상세 내용용
  bool isLoading = true; // 로딩 상태 여부
  late TabController _tabController; // 탭 컨트롤러

  @override
  void initState() {
    super.initState();
    mainRequestDetailList(); // 초기 데이터 요청
  }

  /// 서버에서 비교 견적 목록을 가져오는 함수
  Future<void> mainRequestDetailList() async {
    String restId = "getRequesMainList";
    String? clerkNo = await secureStorage.read(key: 'clerkNo');

    final param = jsonEncode({
      "categoryId": widget.categoryId,
      "reqNo": widget.reqNo,
      "reqUser": clerkNo,
    });

    try {
      final response = await sendPostRequest(restId, param);
      final parsed = RequestMainInfo().parseMainRequestList(response) ?? [];

      setState(() {
        requests = parsed;
        // ✅ 탭 컨트롤러 초기화와 동시에 탭 변경 리스너 연결
        _tabController = TabController(
          length: _getCategoryList().length,
          vsync: this,
        )..addListener(_handleTabSelection); // 체이닝으로 안전하게 연결
        isLoading = false;
      });

      // ✅ 최초 진입 시 첫 번째 탭에 대한 데이터 미리 조회
      if (parsed.isNotEmpty) {
        fetchRequestDetailList(parsed.first.categoryId);
      }
    } catch (e) {
      print("❌ 신청 목록 조회 중 오류 발생: $e");
    }
  }


  /// 탭 선택 시 해당 categoryId에 대한 상세 목록 조회
  void _handleTabSelection() {
    // ✅ 조건 제거: 무조건 실행
    final selectedCategory = _getCategoryList()[_tabController.index];
    final selectedId = requests.firstWhere((r) => r.categoryNm == selectedCategory).categoryId;
    fetchRequestDetailList(selectedId);
  }
  /// 서버에서 선택된 categoryId에 대한 상세 견적 리스트 조회
  Future<void> fetchRequestDetailList(String categoryId) async {
    print("📡 데이터 조회 시작");
    String restId = "getRequesDetailtList";
    String? clerkNo = await secureStorage.read(key: 'clerkNo');

    final param = jsonEncode({
      "categoryId": categoryId,
      "reqNo": widget.reqNo,
      "reqUser": clerkNo,
    });

    try {
      final response = await sendPostRequest(restId, param);
      print("📡 응답 받음: ${jsonEncode(response)}");

      final parsed = RequestInfo().parseRequestList(response) ?? [];
      setState(() {
        detailRequests = parsed;
        _selectedDetailRequest = parsed.isNotEmpty ? parsed.first : null; // ✅ 여기 수정됨
        print("🔎 UI 업데이트 완료 - 상세 리스트 길이: ${parsed.length}");
      });
    } catch (e) {
      print("❌ 신청 목록 조회 중 오류 발생: $e");
    }
  }

  /// 중복 제거된 categoryNm 리스트 반환 (탭 이름 용)
  List<String> _getCategoryList() {
    return requests.map((r) => r.categoryNm).toSet().toList();
  }

  /// 탭 선택에 따라 해당 견적 리스트를 보여주는 UI
  /// 탭 선택에 따라 해당 견적 리스트를 보여주는 UI
  // 2025-06-02: 상세카드 → 구분선 → 가로스크롤 카드 순서로 변경 및 구분선 추가
  // 2025-06-02: 탭 전환 시 categoryId 기준으로 _selectedDetailRequest 동기화 추가
  Widget _buildTabView(List<String> categories) {
    return TabBarView(
      controller: _tabController,
      children: categories.map((category) {
        final tabRequests = requests.where((r) => r.categoryNm == category).toList();

        if (_selectedMainRequest == null || !tabRequests.contains(_selectedMainRequest)) {
          _selectedMainRequest = tabRequests.isNotEmpty ? tabRequests.first : null;
        }

        // ✅ 탭 변경 시 현재 카테고리에 해당하는 detailRequest를 재설정
        if (detailRequests.any((r) => r.categoryId == tabRequests.first.categoryId)) {
          _selectedDetailRequest = detailRequests.firstWhere(
                (r) => r.categoryId == tabRequests.first.categoryId,
          );
        } else if (detailRequests.isNotEmpty) {
          _selectedDetailRequest = detailRequests.first;
        } else {
          _selectedDetailRequest = null;
        }


        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 1. 상세 카드 먼저 출력
              if (_selectedDetailRequest != null) _buildDetailCard(_selectedDetailRequest!),

              // 🔹 2. 구분선 추가
              const SizedBox(height: 12),
              const Divider(
                color: Colors.grey,
                thickness: 1,
                indent: 16,
                endIndent: 16,
              ),

              // 🔹 3. 가로 스크롤 카드 리스트
              _buildHorizontalCardList(tabRequests),
              const SizedBox(height: 2),
              const Divider(
                color: Colors.grey,
                thickness: 1,
                indent: 16,
                endIndent: 16,
              ),

              // 🔹 하단 상세 정보
              Container(
                color: Colors.white,
                child: (_selectedDetailRequest != null)
                    ? _buildRequestDetail(_selectedDetailRequest!)
                    : const SizedBox(),
              ),

              const SizedBox(height: 4),
              const Divider(
                color: Colors.grey,
                thickness: 1,
                indent: 16,
                endIndent: 16,
              ),

              // 🔹 이미지
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  height: 120,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      CommonImageViewer(
                        key: ValueKey("${_selectedDetailRequest?.reqNo ?? ''}_${_selectedDetailRequest?.seq ?? ''}"),
                        estNo: _selectedDetailRequest?.reqNo ?? '',
                        seq: _selectedDetailRequest?.seq ?? '',
                        imageGubun: 'RQ01',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 4),
              const Divider(
                color: Colors.grey,
                thickness: 1,
                indent: 16,
                endIndent: 16,
              ),

              // 🔹 판매자 프로필
              Container(
                color: Colors.white,
                child: SellerProfileChildView(
                  key: ValueKey(_selectedDetailRequest?.companyId ?? ''),
                  sllrNo: _selectedDetailRequest?.companyId ?? '',
                  appbarYn: "N",
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }


  /**
   * 선택시 최하단 상세보기
   */
  Widget _buildRequestDetail(RequestInfo request) {
    // 🔹 companyNm과 estimateContents 값 확인 로그 추가
    print("🔹 Company Name: ${request.companyNm}");
    print("🔹 Company companyId: ${request.companyId}");
    print("🔹 Estimate Contents: ${request.estimateContents}");
    print("🔹 Estimate Contents: ${request.inProgress}");
    print("🔹🔹🔹 Estimate reqState: ${request.reqState}");
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔹 상단: 프로필 + 업체명 + 견적 금액
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: proFlieImage.getImageProvider(request.imageFilePath), // 기본 이미지 설정
                    backgroundColor: Color(0xFFF2F2F2),
                    onBackgroundImageError: (error, stackTrace) {
                      print('이미지 로드 실패: $error');
                    },
                  ),
                  SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      print("🔹 ${request.companyNm} 클릭됨");
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SellerProfileView(
                            sllrNo: request.companyId,  // 🔹 request의 sllrNo를 넘김
                            appbarYn: "Y",
                          ),
                        ),
                      );
                    },
                    child: Text(
                      '${request.companyNm}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black, // 🔹 클릭할 수 있다는 시각적 표현
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  request.estimateAmount.isEmpty || request.estimateAmount == "-"
                      ? '견적 금액: -'
                      : '견적 금액: ${FormatUtils.formatCurrency(request.estimateAmount)}',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),

          /// 🔹 밑에 estimateContents 표시
          SizedBox(height: 10),

          // 견적 상세 설명
          Text(
            request.estimateContents,
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  // 2025-06-02: 선택된 detailRequest 출력 카드
  Widget _buildDetailCard(RequestInfo detail) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            detail.categoryNm ?? '',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            detail.reqContents ?? '',
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              _buildTag('# 총 ${detailRequests.length}건 견적 도착'),
              _buildTag('# 요청일: ${detail.estimateDate ?? '-'}'),
            ],
          ),
        ],
      ),
    );
  }


  // 2025-06-02: 가로 스크롤 카드 리스트 UI
  Widget _buildHorizontalCardList(List<RequestMainInfo> tabRequests) {
    return Container(
      color: Colors.white,
      height: MediaQuery.of(context).size.height * 0.30,
      padding: const EdgeInsets.all(13.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tabRequests.length,
        itemBuilder: (BuildContext context, int index) {
          final request = tabRequests[index];
          final isSelected = _selectedMainRequest == request;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedMainRequest = request;
              });
            },
            child: Container(
              height: MediaQuery.of(context).size.width * 0.40,
              width: MediaQuery.of(context).size.width * 0.38,
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                  color: isSelected ? WitHomeTheme.wit_black : Colors.grey,
                  width: isSelected ? 2.0 : 1.0,
                ),
                image: DecorationImage(
                  image: AssetImage('assets/home/request${index + 1}.png'),
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
              ),
              child: (detailRequests.length > index)
                  ? _buildTagInfoOverlay(detailRequests[index], isSelected)
                  : const SizedBox(),
            ),
          );
        },
      ),
    );
  }


  /// 🔹 이미지 위에 정보 오버레이
  Widget _buildTagInfoOverlay(RequestInfo request, bool isSelected) {
    String companyName = request.companyNm.length > 8
        ? request.companyNm.substring(0, 8) + '...'
        : request.companyNm;

    final bool isInProgress = request.inProgress == "YES" &&
        int.tryParse(request.reqState) != null &&
        int.parse(request.reqState) > 20;

    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Stack(
        children: [
          /// 🔹 텍스트 내용 전체 영역
          Padding(
            padding: const EdgeInsets.only(bottom: 40.0), // 하단 아이콘 공간 확보
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      companyName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(width: 6.0),
                    if (isInProgress)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '진행중',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10.0),
                _buildTag('# 견적 ${request.estimateAmount.isEmpty || request.estimateAmount == "-" ? '-' : FormatUtils.formatCurrency(request.estimateAmount) + ' 원'}'),
                const SizedBox(height: 10.0),
                _buildTag('# 시공건수 11건'),
                const SizedBox(height: 10.0),
                _buildTag('# A/S 가능'),
              ],
            ),
          ),

          /// 🔹 왼쪽 하단: 인증 + 평점
          Positioned(
            bottom: 0,
            left: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/home/confirmok.png',
                  height: 13,
                ),
                const SizedBox(height: 4.0),
                Row(
                  children: [
                    Image.asset('assets/home/star.png', width: 16, height: 16),
                    const SizedBox(width: 4.0),
                    Text(
                      request.rate.isEmpty ? '-' : request.rate,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: Offset(1, 1),
                            blurRadius: 2.0,
                            color: Colors.black45,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 공통 태그 스타일 위젯
  Widget _buildTag(String text) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, color: Colors.black87),
      ),
    );
  }

  Color? _getButtonColor(String reqState, String inProgress) {
    print("🧾 버튼 상태 확인 - reqState: $reqState, inProgress: $inProgress"); // ✅ 로그 추가
    if (reqState == '70' || inProgress == 'NO') {
      print("🧾 버튼 상태 확인 요기111111");
      return Colors.grey[400];
    } else {
      print("🧾 버튼 상태 확인 요기222222222222");
      return Colors.black;
    }
  }


  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text('비교 견적 상세', style: TextStyle(color: Colors.white)),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final categories = _getCategoryList();

    return DefaultTabController(
      length: categories.length,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text('비교 견적 상세', style: TextStyle(color: Colors.white)),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Column(
          children: [
            WitHomeWidgets.getTabBarUI(_tabController, categories),
            Expanded(child: _buildTabView(categories)),
          ],
        ),

        // 🔻 하단 버튼 추가 (조건: _selectedRequest != null)
        bottomNavigationBar: _selectedDetailRequest != null
            ? SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 13.0, vertical: 1.0),
            color: Colors.white,
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _selectedDetailRequest!.inProgress == 'YES'
                    ? () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CustomChatScreen(
                        _selectedDetailRequest!.reqNo,
                        _selectedDetailRequest!.seq,
                        "userView",
                      ),
                    ),
                  );
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getButtonColor(
                    _selectedDetailRequest!.reqState,
                    _selectedDetailRequest!.inProgress,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 48.0),
                      child: Text(
                        '메시지로 진행하기',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(right: 16.0),
                      width: 36,
                      height: 27,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/home/message.png',
                          width: 36,
                          height: 27,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
            : null,
      ),
    );
  }
}