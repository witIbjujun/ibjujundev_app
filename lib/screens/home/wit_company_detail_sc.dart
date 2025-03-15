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
  final List<String> tabNames = ['상품설명','견적서비스', '업체후기'];
  final List<String> communityTabNames = ['내 APT', 'HOT 정보', '업체후기'];
  List<String> selectedItems = [];
  late TabController _tabController;
  late TabController _communityTabController;
  bool isAllSelected = true;
  TextEditingController _additionalRequirementsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    //_communityTabController = TabController(length: 3, vsync: this);

    // 카테고리 정보 조회
    getCategoryInfo(widget.categoryId);

    // 회사 목록 조회
    getCompanyList(widget.categoryId);

  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

  Future<void> getCompanyList(String categoryId) async {
    String restId = "getCompanyList";
    final param = jsonEncode({"categoryId": widget.categoryId});
    try {
      final _companyList = await sendPostRequest(restId, param);
      setState(() {
        companyList = Company().parseCompanyList(_companyList) ?? [];
        selectedItems = companyList.map((company) => company.companyId).toList();
        isAllSelected = true;
      });
    } catch (e) {
      print('회사 목록 조회 중 오류 발생: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: WitHomeTheme.nearlyWhite,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                  ///  SizedBox(height: MediaQuery.of(context).padding.top),
                    getAppBarUI(),
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
                                height: 174, // 고정 높이
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
                    getEstimateService(),
                    getReviewBoard(),
                  ],
                ),
              ),
            ],
          ),
        ),
        // 2025-01-16: _tabController.index가 1 (getEstimateService 탭)일 때만 buildBottomNavigationBar가 표시되도록 수정
       /// bottomNavigationBar: _tabController.index == 1
       ///     ? buildBottomNavigationBar()
        ///    : null,
      ),
    );
  }

  Widget getReviewBoard() {
    return Board(1, 'C1'); // 탭 안에서 '업체후기' 화면을 표시
  }


  Widget getCategoryDetailInfo() {
    double initialHeight = 200.0; // 초기 이미지 높이
    double fullHeight = 800.0; // 전체 이미지 높이
    bool _isExpanded = false;

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.pixels > 300 && _tabController.index == 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _tabController.animateTo(1); // 300px 이상 스크롤 시 자동 이동
          });
        }
        return false;
      },
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return ListView(
            primary: true, // 🔥 스크롤 이벤트가 제대로 전달되도록 설정
            shrinkWrap: true,
            physics: AlwaysScrollableScrollPhysics(), // 항상 스크롤 가능하도록 설정
            padding: const EdgeInsets.all(16.0),
            children: [
              if (categoryInfo != null)
                Text(
                  categoryInfo!.categoryNm,
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
              SizedBox(height: 16.0),

              // 이미지 영역
              ClipRect(
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  width: MediaQuery.of(context).size.width,
                  height: _isExpanded ? fullHeight : initialHeight,
                  child: Image.network(
                    apiUrl + '/WIT/lineEye.jpg',
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                ),
              ),

              SizedBox(height: 8.0),

              // "상품정보 펼쳐보기 ▽" / "상품정보 접기 △" 버튼
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFAFCB54),
                    padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Text(
                    _isExpanded ? "상품정보 접기 △" : "상품정보 펼쳐보기 ▽",
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 16.0),

              // 설명 텍스트
              Text(
                categoryInfo?.detail ?? '상세 설명이 없습니다.',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 400), // 스크롤을 테스트할 수 있도록 더미 공간 추가
            ],
          );
        },
      ),
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
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (scrollInfo.metrics.pixels < 50 && _tabController.index == 1) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _tabController.animateTo(0);
                setState(() {}); // 🔥 UI를 강제 업데이트하여 새로운 탭의 내용 반영
              });
            }
            return false;
          },
          child: ListView(
            primary: true, // 🔥 스크롤 이벤트 감지를 확실히 하기 위해 설정
            shrinkWrap: true,
            physics: AlwaysScrollableScrollPhysics(), // 항상 스크롤 가능하게 설정
            padding: const EdgeInsets.all(6.0),
            children: [

              SizedBox(height: 16.0),
              Text("추가조건/요구사항",
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
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
                    color: WitHomeTheme.wit_lightGreen,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Center(
                    child: Text('견적 요청하기',
                        style: TextStyle(color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              SizedBox(height: 400), // 🔥 스크롤 테스트용 여백 추가
            ],
          ),
        );
      },
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


  Widget getCommunityTabs1() {
    return Column(
      children: [
        TabBar(
          controller: _communityTabController,
          tabs: communityTabNames.map((name) => Tab(text: name)).toList(),
          indicatorColor: Colors.blue,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
        ),
        Expanded(
          child: TabBarView(
            controller: _communityTabController,
            children: [
              Board(1, 'B1'),
              Board(1, 'H1'),
              Board(1, 'C1'),
            ],
          ),
        ),
      ],
    );
  }

  Widget getAppBarUI() {
    return AppBar(
      backgroundColor: WitHomeTheme.nearlyWhite,
      title: Text(
        "견적서비스",
        style: WitHomeTheme.body1.copyWith(
          fontSize: 20.0, // 원하는 폰트 크기로 조절
          fontWeight: FontWeight.bold, // 폰트 굵기 설정 (선택)
          color: Colors.black, // 글자 색상 설정 (선택)
        ),
      ),
    );
  }


  /**
   * 견적 요청하기
   */
  Future<void> sendRequestInfo() async {
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
      "companyIds": selectedItems,
      "reqContents": reqContents,
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
