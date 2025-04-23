import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:witibju/screens/home/widgets/wit_home_widgets.dart';
import 'package:witibju/screens/home/widgets/wit_home_widgets2.dart';
import 'package:witibju/screens/home/wit_home_sc.dart';
import 'package:witibju/screens/home/wit_home_theme.dart';
import '../../util/wit_api_ut.dart';
import '../../util/wit_code_ut.dart';
import '../board/wit_board_main_sc.dart';
import '../common/wit_calendarDialog.dart';
import 'models/category.dart';
import 'models/company.dart';

/// `단건 견적상세
class DetailCompany extends StatefulWidget {
  final String title;
  final String categoryId;

  final secureStorage = FlutterSecureStorage(); // Flutter Secure Storage 인스턴스

  DetailCompany({super.key, required this.title, required this.categoryId});

  @override
  State<DetailCompany> createState() => _DetailCompanyState();
}

class _DetailCompanyState extends State<DetailCompany> with TickerProviderStateMixin {
  List<Company> companyList = [];
  Category? categoryInfo; // 한 건의 카테고리 정보를 저장
  final List<String> tabNames = ['상품설명 및 견적서비스','업체후기'];
  List<String> selectedItems = [];
  late TabController _tabController;
  bool isAllSelected = true;
  TextEditingController _additionalRequirementsController = TextEditingController();
  String? _selectedDate; // ✅ 선택한 날짜 저장 변수
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    //_communityTabController = TabController(length: 3, vsync: this);

    // 카테고리 정보 조회
    getCategoryInfo(widget.categoryId);

    // 회사 목록 조회
    //getCompanyList(widget.categoryId);

  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /**
   * 달력
   */
  Future<void> _selectDate(BuildContext context) async {
    DateTime? selectedDate = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) => CustomCalendarBottomSheet(title: "작업요청일"),
    );

    if (selectedDate != null) {
      setState(() {
        _selectedDate =
        "${selectedDate.year}.${selectedDate.month.toString().padLeft(2, '0')}.${selectedDate.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> getCategoryInfo(String categoryId) async {
    String restId = "getCategoryInfo";
    categoryInfo = null;
    print("카테고리 번호가?? = "+categoryId);
    final param = jsonEncode({"categoryId": categoryId});
    try {
      final response = await sendPostRequest(restId, param);

      if (response != null && response is List<dynamic> && response.isNotEmpty) {
        setState(() {
          categoryInfo = Category().parseCategoryList(response)?.first; // 서버에서 넘어온 첫 번째 데이터를 Category 객체로 변환
          print('카테고리 정보: ${categoryInfo?.categoryNm}');
        });
      } else {
        print('카테고리 정보가 없습니다.');
      }
    } catch (e) {
      print('카테고리 정보 조회 중 오류 발생: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      color: WitHomeTheme.nearlyWhite,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text(
            '견적서비스',
            style: TextStyle(
              color: Colors.white,             // 텍스트 색상
              fontSize: 20.0,                  // 폰트 크기
              fontWeight: FontWeight.bold,     // 굵기
              fontFamily: 'NotoSansKR',        // 폰트 지정 (선택)
            ),
          ),
          iconTheme: IconThemeData(color: Colors.white), // ← 아이콘 색상도 검정으로 맞추려면 추가
        ),
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    if (categoryInfo != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Stack(
                          alignment: Alignment.center, // 중앙 정렬
                          children: [
                            // 배경 이미지
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0), // 둥근 모서리 적용
                              child: Image.asset(
                                'assets/home/companyDetail.png',
                                width: 500, // 원하는 너비
                                height: 150, // 고정 높이
                                fit: BoxFit.fill, // 비율 유지하며 크기 조정
                              ),
                            ),

                            // 왼쪽 상단 카테고리 이름 버튼 스타일
                            Positioned(
                              top: 10, // 상단 여백 조정
                              left: 16, // 왼쪽 여백 조정
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                                child: Row(
                                  children: [
                                    Text(
                                      categoryInfo?.categoryNm ?? '카테고리', // categoryNm 표시
                                      style: WitHomeTheme.body1.copyWith(
                                        fontSize: 14.0, // 원하는 글자 크기
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white, // 글씨 색상
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // 중앙 텍스트
                            Positioned(
                              top: 60, // 이미지 중앙으로 이동
                              left: 16, // 왼쪽 정렬
                              right: 16, // 오른쪽 정렬
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
                                children: [
                                  Text(
                                    "30명 이상이면 5% 추가 할인",
                                    style: WitHomeTheme.body1.copyWith(
                                      fontSize: 20.0, // 크기 조정
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black, // 글씨 색상
                                    ),
                                  ),
                                  SizedBox(height: 8), // 간격 추가
                                  Text(
                                    "~2025.02.25까지 접수",
                                    style: WitHomeTheme.body1.copyWith(
                                      fontSize: 16.0,
                                      color: Colors.black87, // 글씨 색상
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    WitHomeWidgets.getTabBarUI(_tabController, tabNames),
                  ],
                ),
              ),
              SliverFillRemaining(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    getCategoryDetailInfo(),
                    //getEstimateService(),
                    getReviewBoard(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getReviewBoard() {
    return Board(1, 'C1'); // 탭 안에서 '업체후기' 화면을 표시
  }


  // 2025-04-22: 이미지 비율에 따라 fullHeight 자동 계산 + Semantics 오류 방지 적용
  Widget getCategoryDetailInfo() {
    double initialHeight = 250.0;
    double? fullHeight; // 이미지 로딩 후 계산된 높이 저장
    bool _isExpanded = true;
    bool imageLoaded = false; // 이미지 중복 처리 방지

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        final imageUrl = apiUrl + '/WIT/lineEye.jpg';

        // 2025-04-22: 이미지 비율을 기반으로 fullHeight 계산
        if (!imageLoaded) {
          final imageProvider = NetworkImage(imageUrl);
          final imageStream = imageProvider.resolve(const ImageConfiguration());
          imageStream.addListener(
            ImageStreamListener((ImageInfo info, bool _) {
              final imageWidth = info.image.width.toDouble();
              final imageHeight = info.image.height.toDouble();
              final screenWidth = MediaQuery.of(context).size.width;
              final calculatedHeight = screenWidth * imageHeight / imageWidth;

              setState(() {
                fullHeight = calculatedHeight;
                imageLoaded = true;
              });
            }),
          );
        }

        return ListView(
          primary: true,
          shrinkWrap: true,
          physics: AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          children: [
            if (categoryInfo != null)
              Text(
                categoryInfo!.categoryNm,
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
            SizedBox(height: 16.0),

            // 🔽 자동 높이 이미지 영역
            ClipRect(
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                width: MediaQuery.of(context).size.width,
                height: _isExpanded
                    ? (fullHeight ?? initialHeight)
                    : initialHeight,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),
            SizedBox(height: 8.0),

            Center(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: WitHomeTheme.white,
                  padding:
                  EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text(
                  _isExpanded ? "상품정보 접기 △" : "상품정보 펼쳐보기 ▽",
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                    color: WitHomeTheme.wit_lightGreen,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.0),

            Divider(thickness: 1, color: Colors.grey),
            SizedBox(height: 16.0),

            Row(
              children: [
                Container(
                  padding:
                  EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: WitHomeTheme.white,
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: Text(
                    "작업요청 예상일",
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      color: WitHomeTheme.wit_mediumSeaGreen,
                    ),
                  ),
                ),
                SizedBox(width: 12.0),

                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectDate(context),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          vertical: 12.0, horizontal: 12.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedDate ?? "날짜 선택",
                            style: TextStyle(fontSize: 16.0),
                          ),
                          Icon(Icons.keyboard_arrow_down,
                              color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 16.0),

            Text("추가조건/요구사항",
                style:
                TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
            SizedBox(height: 8.0),
            TextField(
              controller: _additionalRequirementsController,
              maxLines: 3,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Ex) 안방과 거실만 70,000원 가능할까요?",
                contentPadding:
                EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
              ),
            ),
            SizedBox(height: 14.0),

            GestureDetector(
              onTap: () async {
                bool isConfirmed = await DialogUtils.showConfirmationDialog(
                  context: context,
                  title: '견적 요청 확인',
                  content: '견적 요청을 진행하시겠습니까?',
                  confirmButtonText: '진행',
                  cancelButtonText: '취소',
                );

                if (isConfirmed) {
                  sendRequestInfo();
                }
              },
              child: Container(
                width: double.infinity,
                height: 50.0,
                decoration: BoxDecoration(
                  color: WitHomeTheme.wit_lightGreen,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Center(
                  child: Text(
                    '견적 요청하기',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }


  Widget buildBottomNavigationBar1() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "추가조건/요구사항",
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.0),
          TextField(
            controller: _additionalRequirementsController,
            maxLines: 3,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Ex) 안방과 거실만 70,000원 가능할까요?",
              contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
            ),
          ),
          SizedBox(height: 14.0),
          GestureDetector(
            onTap: () async {
              bool isConfirmed = await DialogUtils.showConfirmationDialog(
                context: context,
                title: '견적 요청 확인',
                content: '견적 요청을 진행하시겠습니까?',
                confirmButtonText: '진행',
                cancelButtonText: '취소',
              );

              if (isConfirmed) {
                sendRequestInfo();
              }
            },
            child: Container(
              width: double.infinity,
              height: 50.0,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Center(
                child: Text(
                  '견적 요청하기',
                  style: TextStyle(
                    color: Color(0xFFAFCB54),
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget getEstimateService() {
    return ListView(
      primary: true,
      shrinkWrap: true,
      physics: AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(6.0),
      children: [
        /// ✅ 작업요청 예상일 UI 수정 (입력창 대신 버튼 사용)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              // "작업요청 예상일" 라벨
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: WitHomeTheme.wit_lightGreen,
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: Text(
                  "작업요청 예상일",
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: 12.0),

              // ✅ 날짜 선택 버튼
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectDate(context),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedDate ?? "날짜 선택", // 선택한 날짜가 없으면 빈 값
                          style: TextStyle(fontSize: 16.0),
                        ),
                        Icon(Icons.keyboard_arrow_down, color: Colors.grey), // ▼ 아이콘 추가
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 16.0),

        /// ✅ 추가조건/요구사항
        Text("추가조건/요구사항", style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
        SizedBox(height: 8.0),
        TextField(
          controller: _additionalRequirementsController,
          maxLines: 3,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: "Ex) 안방과 거실만 70,000원 가능할까요?",
            contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
          ),
        ),
        SizedBox(height: 14.0),

        /// ✅ 견적 요청 버튼
        GestureDetector(
          onTap: () async {
            bool isConfirmed = await DialogUtils.showConfirmationDialog(
              context: context,
              title: '견적 요청 확인',
              content: '견적 요청을 진행하시겠습니까?',
              confirmButtonText: '진행',
              cancelButtonText: '취소',
            );

            if (isConfirmed) {
              sendRequestInfo();
            }
          },
          child: Container(
            width: double.infinity,
            height: 50.0,
            decoration: BoxDecoration(
              color: WitHomeTheme.wit_lightGreen,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Center(
              child: Text(
                '견적 요청하기',
                style: TextStyle(color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),

        SizedBox(height: 400),
      ],
    );
  }



  Widget getCommunityTabs() {
    // '업체후기' 탭을 선택하면 즉시 Board(1, 'C1')로 이동
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Board(1, 'C1')),
      );
    });

    return Container(); // 화면 이동 후 기존 위젯은 필요 없으므로 빈 컨테이너 반환
  }

  /**
   * 견적 요청하기
   */
  Future<void> sendRequestInfo() async {
    if (_selectedDate == null) {
      // 사용자가 날짜를 선택하지 않았을 경우 알림
      await DialogUtils.showCustomDialog(
        context: context,
        title: '날짜 선택 필요',
        content: '작업 요청 예정일을 선택해 주세요.',
        confirmButtonText: '확인',
      );
      return;
    }

    String restId = "saveRequestInfo";
    String? aptNo = await widget.secureStorage.read(key: 'mainAptNo');
    String? clerkNo = await widget.secureStorage.read(key: 'clerkNo');
    String reqContents = _additionalRequirementsController.text.replaceAll("\n", " ");
    aptNo = aptNo ?? '1';

    final param = jsonEncode({
      "reqGubun": 'S',
      "reqUser": clerkNo,
      "aptNo": aptNo,
      "categoryId": widget.categoryId,
    // "companyIds": selectedItems,
      "reqContents": reqContents,
      "expectedDate": _selectedDate, // ✅ 작업요청예정일 추가
    });

    try {
      final response = await sendPostRequest(restId, param);

      if (response != null) {
        await DialogUtils.showCustomDialog(
          context: context,
          title: '견적 요청 완료',
          content: '견적 요청이 성공적으로 완료되었습니다.',
          confirmButtonText: '확인',
          onConfirm: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          },
        );
      } else {
        throw Exception('응답 없음');
      }
    } catch (e) {
      print('견적 요청 실패: $e');
      await DialogUtils.showCustomDialog(
        context: context,
        title: '요청 실패',
        content: '견적 요청에 실패했습니다. 다시 시도해 주세요.',
        confirmButtonText: '확인',
        onConfirm: () => Navigator.pop(context),
      );
    }
  }
}
