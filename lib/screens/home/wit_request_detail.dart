import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:witibju/screens/home/widgets/wit_home_widgets.dart';
import 'package:witibju/screens/home/wit_home_theme.dart';
import '../../util/wit_api_ut.dart';
import '../chat/CustomChatScreen.dart';
import '../seller/wit_seller_profile_child_view_sc.dart';
import '../seller/wit_seller_profile_view_sc.dart';
import 'models/requestInfo.dart';

/**
 * 비교견적 상세
 */
class RequestDetailScreen extends StatefulWidget {
  final String categoryId;
  final String reqNo;
  final String companyCnt;

  const RequestDetailScreen({
    Key? key,
    required this.categoryId,
    required this.reqNo,
    required this.companyCnt,
  }) : super(key: key);

  @override
  State<RequestDetailScreen> createState() => _RequestDetailScreenState();
}

class _RequestDetailScreenState extends State<RequestDetailScreen> {
  List<RequestInfo> requests = [];
  RequestInfo? _selectedRequest;
  final secureStorage = FlutterSecureStorage();
  bool isLoading = true; // 조회 구분
  bool isExpanded = false; // 접시 / 상세보기
  @override
  void initState() {
    super.initState();
    fetchRequestDetailList();
  }

  Future<void> fetchRequestDetailList() async {
    print("📡 데이터 조회 시작");
    String restId = "getRequesDetailtList";
    String? clerkNo = await secureStorage.read(key: 'clerkNo');

    final param = jsonEncode({
      "categoryId": widget.categoryId,
      "reqNo": widget.reqNo,
      "reqUser": clerkNo,
    });

    try {
      final response = await sendPostRequest(restId, param);
      print("📡 응답 받음: ${jsonEncode(response)}");

      final parsed = RequestInfo().parseRequestList(response) ?? [];
      setState(() {
        requests = parsed;
        _selectedRequest = parsed.isNotEmpty ? parsed.first : null;
        isLoading = false;
        print("🔎 UI 업데이트 완료");
      });

      print("📡 requests 업데이트됨, 길이: ${requests.length}");
    } catch (e) {
      print("❌ 신청 목록 조회 중 오류 발생: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text(
            '비교 견적 상세',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              fontFamily: 'NotoSansKR',
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // 로딩이 끝난 이후의 화면
    return Scaffold(
      backgroundColor: Colors.white, // 🔹 전체 배경 흰색으로 변경
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          '비교 견적 상세',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'NotoSansKR',
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔹 AppBar와 상단 영역 사이의 간격
            const SizedBox(height: 16),
            /// 🔹 상단 영역
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${requests[0].categoryNm}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // 설명
                  Text(
                    requests[0].reqContents,
                    style: const TextStyle(fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildTag('# 총 ${requests.length}건 견적 도착'),
                      _buildTag('# 요청일: ${_selectedRequest?.estimateDate ?? '-'}'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Divider(
              color: Colors.grey, // 🔹 색상: 회색
              thickness: 1,       // 🔹 두께: 1px
              indent: 16,         // 🔹 왼쪽 간격
              endIndent: 16,      // 🔹 오른쪽 간격
            ),

            /// 🔹 중단 영역 - 가로 스크롤 유지
            Container(
              color: Colors.white,
              height: MediaQuery.of(context).size.height * 0.28,
              padding: const EdgeInsets.all(13.0),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: requests.length,
                itemBuilder: (BuildContext context, int index) {
                  final request = requests[index];
                  final isSelected = _selectedRequest == request;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedRequest = request;
                      });
                    },
                    child: Container(
                      height: MediaQuery.of(context).size.width * 0.35,
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
                      child: _buildTagInfoOverlay(request, isSelected),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),
            const Divider(
              color: Colors.grey, // 🔹 색상: 회색
              thickness: 1,       // 🔹 두께: 1px
              indent: 16,         // 🔹 왼쪽 간격
              endIndent: 16,      // 🔹 오른쪽 간격
            ),

            /// 🔹 하단 영역 - 상세 정보
            Container(
              color: Colors.white,
              //margin: const EdgeInsets.symmetric(horizontal: 16.0), // 🔹 좌우폭 상단과 동일하게 설정
              child: _buildRequestDetail(_selectedRequest ?? requests.first),
            ),
          ],
        ),
      ),
      // ✅ 2025-05-28: 메시지로 진행하기 버튼을 하단에 고정
      bottomNavigationBar: _selectedRequest != null
          ? SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13.0, vertical: 1.0), // 🔹 높이 줄임
          color: Colors.white,
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _selectedRequest!.reqState != '10'
                  ? () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CustomChatScreen(
                      _selectedRequest!.reqNo,
                      _selectedRequest!.seq,
                      "userView",
                    ),
                  ),
                );
              }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedRequest!.reqState == '70'
                    ? Colors.grey[400] // 🔹 상태가 70이면 회색
                    : Colors.black,    // 🔹 그 외엔 검정
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 48.0),
                    child: Text(
                      _selectedRequest!.reqState == '70'
                          ? '메시지로 진행하기(진행완료)' // 🔹 진행완료일 경우 텍스트 변경
                          : '메시지로 진행하기',        // 🔹 그 외는 기본 문구
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
    );
  }

  /// 🔹 이미지 위에 정보 오버레이
  Widget _buildTagInfoOverlay(RequestInfo request, bool isSelected) {
    String companyName = request.companyNm.length > 8
        ? request.companyNm.substring(0, 8) + '...'
        : request.companyNm;

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
                Text(
                  companyName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: Colors.black,
                    /*shadows: const [
                      Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 2.0,
                        color: Colors.black45,
                      ),
                    ],*/
                  ),
                  overflow: TextOverflow.ellipsis,
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

          /// 🔹 왼쪽 하단: 별점 + 인증 아이콘
          Positioned(
            bottom: 0,
            left: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ⭐️ 별 + 평점 한 줄
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
                const SizedBox(height: 4), // 별점과 인증 사이 간격
                // ✅ 인증완료 아이콘
                Image.asset(
                  'assets/home/confirmok.png',
                  height: 13,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }



  /**
   * 테두리 글씨
   */
  Widget _buildTag(String text) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/home/estimateback_detail1.png'),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          color: Colors.black,
          fontWeight: FontWeight.normal,
          shadows: [
            Shadow(
              offset: Offset(0.5, 0.5),
              blurRadius: 2,
              color: Colors.black26,
            ),
          ],
        ),
      ),
    );
  }

  /**
   * 최하단 상세보기
   */
  Widget _buildRequestDetail(RequestInfo request) {
    // 🔹 companyNm과 estimateContents 값 확인 로그 추가
    print("🔹 Company Name: ${request.companyNm}");
    print("🔹 Estimate Contents: ${request.estimateContents}");

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

          SizedBox(height: 10),

          // 👉 아래처럼 수정 (2025-05-31)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            //child: SellerProfileContent(sllrNo: request.companyId),
            child: SellerProfileChildView(sllrNo: request.companyId, appbarYn: "N"),

          ),
        ],
      ),
    );
  }

  // 2025.04.16: 진행 요청 시 updateRequestState 호출 후 CustomChatScreen 이동 처리
  void _handleRequestAction(RequestInfo request) async {
    String? clerkNo = await secureStorage.read(key: 'clerkNo'); // 🔹 스토리지에서 clerkNo 읽기
    print('🧪 선택된 request.seq: ${request.seq}');
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          title: Text(
            '작업 진행',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            '${request.companyNm} 업체에 작업을 진행하시겠습니까?',
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                '취소',
                style: TextStyle(color: Colors.white),
              ),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onPressed: () async {
                //Navigator.pop(context); // 다이얼로그 닫기

                /// ✅ Chat 화면으로 이동
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CustomChatScreen(
                      request.reqNo,
                      request.seq,
                      "userView",
                    ),
                  ),
                );
              },
              child: const Text(
                '확인',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}

// 2025-03-25 추가: SectionWidget에서 사용하는 데이터 클래스
class ListItem {
  final String categoryId;
  final String reqNo;
  final String reqContents;
  final List<RequestInfo> receivedEstimates;

  ListItem({
    required this.categoryId,
    required this.reqNo,
    required this.reqContents,
    required this.receivedEstimates,
  });
}

