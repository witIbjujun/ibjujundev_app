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
import '../common/wit_calendarDialog.dart';
import 'models/category.dart';

/// 다건 견적진행
dynamic companyInfo = {};

class getEstimate extends StatefulWidget {
  final String type; // 파라미터 추가

  const getEstimate(this.type, {super.key});

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
  String? _selectedDate; // ✅ 선택한 날짜 저장 변수

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // 2025-01-12: getCategoryList 호출 후 로딩 상태 업데이트
    getCategoryList(widget.type).then((_) {
      setState(() {
        isLoading = false;
      });
    });

    print("Passed Type Parameter: ${widget.type}");
  }

  @override
  void dispose() {
    _tabController.dispose();
    _additionalRequirementsController.dispose(); // 컨트롤러 해제
    super.dispose();
  }

  Future<void> getCategoryList(String type) async {
    String restId = "getCategoryList";

    final param = jsonEncode({
      "type": type,
    });

    print('호출인건가??===${type}');
    final _categoryList = await sendPostRequest(restId, param);

    setState(() {
      categoryList = Category().parseCategoryList(_categoryList)!;
      selectedList = List<bool>.filled(categoryList.length, false); // categoryList의 길이에 맞춰 selectedList를 초기화
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('견적받기'),
      ),
      body: SafeArea(
        child: isLoading
            ? Center(child: CircularProgressIndicator()) // 로딩 상태 표시
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: getPopularCourseUI(widget.type), // 인기 코스 UI만 스크롤 가능
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  SizedBox(height: 16.0), // 날짜 선택과 추가 요청 사항 사이 간격

                  Column(
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
                            color: WitHomeTheme.wit_lightGreen,
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
                ],
              ),
            )
          ],
        ),
      ),
    );
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
    final param = jsonEncode({
      "reqGubun": 'T',
      "aptNo": aptNo,
      "reqUser": clerkNo,
      "categoryIds": selectedItems,
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('견적 요청에 실패했습니다. 다시 시도해 주세요.')),
      );
    }
  }

  int findCategoryIndex(String categoryId) {
    return categoryList.indexWhere((category) => category.categoryId == categoryId);
  }

  Widget getPopularCourseUI(String type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Flexible(
            fit: FlexFit.loose,
            child: PopularCourseListHorizontalView(
              type: type,
              callBack: (Category category, bool isSelected) {
                // 2025-01-12: 선택 상태와 카운트 동기화
                print('Category selected: ${category.categoryId}, isSelected: $isSelected');
                setState(() {
                  int index = findCategoryIndex(category.categoryId);

                  if (index != -1) {
                    selectedList[index] = isSelected;
                    _selectedItemCount = selectedList.where((isSelected) => isSelected).length;
                  } else {
                    print('Index not found for category ID: ${category.categoryId}');
                  }
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
