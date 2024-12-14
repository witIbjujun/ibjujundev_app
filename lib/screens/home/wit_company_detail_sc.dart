import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:witibju/screens/home/widgets/wit_home_widgets.dart';
import 'package:witibju/screens/home/widgets/wit_home_widgets2.dart';
import 'package:witibju/screens/home/wit_home_sc.dart';
import 'package:witibju/screens/home/wit_home_theme.dart';
import '../../util/wit_api_ut.dart';
import '../board/wit_board_main_sc.dart';
import 'models/company.dart';

/// 단건 견적상세
dynamic companyInfo = {};

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
  final List<String> tabNames = ['견적서비스', '아파트 커뮤니티'];
  final List<String> communityTabNames = ['내 APT', 'HOT 정보', '업체후기']; // 10/21
  List<String> selectedItems = []; // 선택된 항목 리스트
  late TabController _tabController;
  late TabController _communityTabController; // 10/21 아파트 커뮤니티 탭 컨트롤러
  bool isAllSelected = true;
  TextEditingController _additionalRequirementsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _communityTabController = TabController(length: 3, vsync: this); // 10/21 아파트 커뮤니티 탭 컨트롤러 초기화

    // 회사 목록 조회
    getCompanyList(widget.categoryId);

    // 탭 변경 시 상태 업데이트
    _tabController.addListener(() {
      setState(() {}); // 탭 변경 시 상태 업데이트
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _communityTabController.dispose(); // 10/21 커뮤니티 탭 컨트롤러 해제
    super.dispose();
  }

  // Board 화면으로 이동하는 메서드 - 10/21 (이제 사용하지 않음)
  void navigateToBoard(String boardType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Board(1,boardType),
      ),
    );
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
                    SizedBox(height: MediaQuery.of(context).padding.top),
                    getAppBarUI(),
                    WitHomeWidgets.getTabBarUI(_tabController, tabNames),
                  ],
                ),
              ),
              SliverFillRemaining(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    getEstimateService(),
                    getCommunityTabs(), // 10/21 아파트 커뮤니티 탭 뷰 호출
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _tabController.index == 0 // 견적서비스 탭일 때만 표시
            ? Container(
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
                  contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0), // 여백 조정
                ),
              ),
              SizedBox(height: 14.0),
              GestureDetector(
                onTap: () async {
                  // "견적 요청하기" 버튼 클릭 시
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
                        color: Colors.white,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
            : null,
      ),
    );
  }

  // 10/21 아파트 커뮤니티 탭 뷰 위젯 생성
  Widget getCommunityTabs() { // 10/21
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
              Board(1,'B1'), // "내 APT" 탭
              Board(1,'H1'), // "HOT 정보" 탭
              Board(1,'C1'), // "업체후기" 탭
            ],
          ),
        ),
      ],
    );
  } // 10/21

  // 회사 목록 조회 메서드 - 2024-10-19
  Future<void> getCompanyList(String categoryId) async {
    String restId = "getCompanyList";
    final param = jsonEncode({"categoryId": widget.categoryId});
    try {
      final _companyList = await sendPostRequest(restId, param);
      setState(() {
        companyList = Company().parseCompanyList(_companyList) ?? [];
        // 기본적으로 모든 회사가 선택되도록 selectedItems 초기화 - 2024-10-19
        selectedItems = companyList.map((company) => company.companyId).toList();
        isAllSelected = true;  // 처음에는 전체 선택 상태로 설정 - 2024-10-19
      });
    } catch (e) {
      print('회사 목록 조회 중 오류 발생: $e');
    }
  }

    Widget getAppBarUI() {
    return AppBar(
      backgroundColor: WitHomeTheme.nearlyWhite,
      title: Text(widget.title),
    );
  }

  Widget getEstimateService() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                if (isAllSelected) {
                  selectedItems.clear();
                } else {
                  selectedItems = companyList.map((company) => company.companyId).toList();
                }
                isAllSelected = !isAllSelected;
              });
            },
            child: Container(
              width: double.infinity,
              height: 50.0,
              decoration: BoxDecoration(
                color: isAllSelected ? Colors.grey : Colors.blue,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Center(
                child: Text(
                  isAllSelected ? '전체 해제' : '전체 선택',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 16.0),
          Expanded(
            child: ListView.builder(
              itemCount: companyList.length,
              itemBuilder: (context, index) {
                final company = companyList[index];
                bool isSelected = selectedItems.contains(company.companyId);

                return ListTile(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        selectedItems.remove(company.companyId);
                      } else {
                        selectedItems.add(company.companyId);
                      }
                    });
                  },
                  leading: GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          selectedItems.remove(company.companyId);
                        } else {
                          selectedItems.add(company.companyId);
                        }
                      });
                    },
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? Colors.blue : Colors.transparent,
                        border: Border.all(
                          color: Colors.grey,
                          width: 2.0,
                        ),
                      ),
                      child: isSelected
                          ? Icon(Icons.check, color: Colors.white, size: 18)
                          : null,
                    ),
                  ),
                  title: Text(
                    company.companyNm,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Board(1, 'C1'),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/star.png', // star.png 파일 경로
                          width: 20,
                          height: 20,
                        ),
                        SizedBox(width: 4),
                        SizedBox(
                          width: 30,
                          child: Text(
                            company.rateNum,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: WitHomeTheme.nearlyBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }


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
