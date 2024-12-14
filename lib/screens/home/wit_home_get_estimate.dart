import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:witibju/screens/home/widgets/wit_home_widgets.dart';
import 'package:witibju/screens/home/widgets/wit_home_widgets2.dart';
import 'package:witibju/screens/home/wit_company_detail_sc.dart';
import 'package:witibju/screens/home/wit_compay_view_sc_horizontal.dart';
import 'package:witibju/screens/home/wit_home_sc.dart';
import 'package:witibju/screens/home/wit_home_theme.dart';
import 'package:witibju/screens/home/wit_compay_view_sc_.dart';
import 'package:witibju/screens/home/wit_estimate_detail.dart';

import '../../util/wit_api_ut.dart';
import 'models/category.dart';

/// 다건 견적진행
dynamic companyInfo = {};

class getEstimate extends StatefulWidget {
  const getEstimate({super.key});

  @override
  State<getEstimate> createState() => _getEstimateState();
}

class _getEstimateState extends State<getEstimate> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedItemCount = 0; // 선택된 아이템의 갯수를 추적하는 변수 추가
  List<Category> categoryList = [];
  List<bool> selectedList = [];
  bool isLoading = true;
  final secureStorage = FlutterSecureStorage(); // Flutter Secure Storage 인스턴스
  TextEditingController _additionalRequirementsController = TextEditingController(); // 추가조건/요구사항 컨트롤러

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // 회사 목록 조회
    getCategoryList();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _additionalRequirementsController.dispose(); // 컨트롤러 해제
    super.dispose();
  }

  Future<void> getCategoryList() async {
    String restId = "getCategoryList";

    final param = jsonEncode({
      "inspId": companyInfo["inspId"],
    });

    final _categoryList = await sendPostRequest(restId, param);

    setState(() {
      categoryList = Category().parseCategoryList(_categoryList)!;
      selectedList = List<bool>.filled(categoryList.length, false); // categoryList의 길이에 맞춰 selectedList를 초기화
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('견적받기'),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 12/14: getPopularCourseUI 영역만 스크롤 가능하도록 설정
            Expanded(
              child: SingleChildScrollView(
                child: getPopularCourseUI(), // 인기 코스 UI만 스크롤 가능
              ),
            ),
            // 12/14: 추가조건/요구사항은 고정
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
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
                    maxLines: 4,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Ex) 안방과 거실만 70,000원 가능할까요?",
                    ),
                    style: TextStyle(fontSize: 14.0),
                  ),
                  SizedBox(height: 8.0),
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
                          sendRequestInfo(); // 버튼 클릭 시 견적 요청 메서드 호출
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
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '견적 요청하기 ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: '(${_selectedItemCount})',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> sendRequestInfo() async {
    String restId = "saveTotalRequestInfo";

    String? aptNo = await secureStorage.read(key: 'mainAptNo'); // 아파트 번호
    String? clerkNo = await secureStorage.read(key: 'clerkNo');
    String reqContents = _additionalRequirementsController.text.replaceAll("\n", " ");
    List<String> selectedItems = [];
    for (int i = 0; i < categoryList.length; i++) {
      if (selectedList[i]) {
        selectedItems.add(categoryList[i].categoryId); // 선택된 카테고리 ID 수집
      }
    }
    aptNo = aptNo ?? '1'; // aptNo가 null일 경우 기본값 1을 할당
    print("내용이 뭣인가??????$reqContents");
    print("내용이 뭣인가??????$reqContents");
    print("내용이 뭣인가??????$reqContents");
    final param = jsonEncode({
      "reqGubun": 'T',
      "aptNo": aptNo,
      "reqUser": clerkNo, // 사용자의 정보 또는 ID를 넣을 수 있음
      "categoryIds": selectedItems, // 선택된 카테고리 ID 목록
      "reqContents": reqContents // 추가 조건/요구 사항
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('견적 요청에 실패했습니다. 다시 시도해 주세요.')),
      );
    }
  }

  int findCategoryIndex(String categoryId) {
    return categoryList.indexWhere((category) => category.categoryId == categoryId);
  }

  Widget getPopularCourseUI() {
    return Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0), // 좌우 패딩
        child: Column(
          mainAxisSize: MainAxisSize.min, // 최소 크기만 차지
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Flexible(
              fit: FlexFit.loose,
              child: PopularCourseListHorizontalView(
                callBack: (Category category, bool isSelected) {
                  setState(() {
                    int index = findCategoryIndex(category.categoryId);

                    if (index != -1) {
                      if (isSelected) {
                        _selectedItemCount++;
                        selectedList[index] = true;
                      } else {
                        _selectedItemCount--;
                        selectedList[index] = false;
                      }
                      if (_selectedItemCount < 0) _selectedItemCount = 0;
                    }
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
