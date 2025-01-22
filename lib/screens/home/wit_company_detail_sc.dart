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
  final List<String> tabNames = ['상품설명','견적서비스', '아파트 커뮤니티'];
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
    _communityTabController = TabController(length: 3, vsync: this);

    // 카테고리 정보 조회
    getCategoryInfo(widget.categoryId);

    // 회사 목록 조회
    getCompanyList(widget.categoryId);

    // 탭 변경 시 상태 업데이트
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _communityTabController.dispose();
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
                    SizedBox(height: MediaQuery.of(context).padding.top),
                    getAppBarUI(),
                    if (categoryInfo != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          children: [
                            Image.asset(
                              categoryInfo?.imagePath ?? '',
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                            SizedBox(width: 16.0),
                            Expanded(
                              child: Text(
                                categoryInfo?.detail ?? '',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                ),
                                textAlign: TextAlign.left,
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
                    getCommunityTabs(),
                  ],
                ),
              ),
            ],
          ),
        ),
        // 2025-01-16: _tabController.index가 1 (getEstimateService 탭)일 때만 buildBottomNavigationBar가 표시되도록 수정
        bottomNavigationBar: _tabController.index == 1
            ? buildBottomNavigationBar()
            : null,
      ),
    );
  }



  Widget getCategoryDetailInfo() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: categoryInfo != null && categoryInfo?.imagePath != null
          ? Column(
        children: [
          Text(
            categoryInfo!.categoryNm ?? '카테고리 이름',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.0),
          Image(
           /// image: NetworkImage(apiUrl + (categoryInfo!.imagePath ?? '')),
            image: NetworkImage(apiUrl + '/WIT/lineEye.jpg'),
            fit: BoxFit.cover,
          ),
          SizedBox(height: 16.0),
          Text(
            categoryInfo!.detail ?? '상세 설명이 없습니다.',
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      )
          : Center(
        child: Text(
          '카테고리 정보를 불러오는 중입니다.',
          style: TextStyle(fontSize: 16.0, color: Colors.grey),
        ),
      ),
    );
  }



  Widget buildBottomNavigationBar() {
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
    );
  }


  Widget getEstimateService() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Column(
          children: [
            ListView.builder(
              physics: NeverScrollableScrollPhysics(), // 내부 스크롤 비활성화
              shrinkWrap: true, // 높이를 자식에 맞게 조정
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
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            company.companyNm,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          if (index == 0) // 첫 번째 항목에만 왕관 추가
                            Padding(
                              padding: const EdgeInsets.only(left: 4.0),
                              child: Image.asset(
                                'assets/images/award.jpg', // 왕관 이미지 경로
                                width: 30,
                                height: 30,
                              ),
                            ),
                        ],
                      ),
                      if (index == 0) // 첫 번째 항목에만 추가 설명
                        const SizedBox(height: 4),
                      if (index == 0)
                        Text(
                          '고객 만족도: 95%', // 추가 설명
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                    ],
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
                          'assets/images/star.png',
                          width: 20,
                          height: 20,
                        ),
                        const SizedBox(width: 4),
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
          ],
        ),
      ),
    );
  }


  Widget getCommunityTabs() {
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
      title: Text(widget.title),
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
