import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:witibju/screens/home/widgets/wit_home_widgets.dart';
import 'package:witibju/screens/home/widgets/wit_home_widgets.dart';
import 'package:witibju/screens/home/wit_company_detail_sc.dart';
import 'package:witibju/screens/home/wit_compay_view_sc_horizontal.dart';
import 'package:witibju/screens/home/wit_home_sc.dart';
import 'package:witibju/screens/home/wit_home_theme.dart';


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

  // 텍스트 필드에 대한 FocusNode 추가
  final FocusNode _additionalFocusNode = FocusNode();

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

      // 2025-04-15: 모든 항목 선택 및 선택된 갯수 설정
      selectedList = List<bool>.filled(categoryList.length, true);
      _selectedItemCount = selectedList.length;

      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          '견적받기',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'NotoSansKR',
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 🔹 인기 코스 UI (가로 스크롤)
                getPopularCourseUI(widget.type),
                const SizedBox(height: 1.0),

                /// 🔹 필요한 견적 설명
                Container(
                  height: 50.0,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: WitHomeTheme.white,
                    border: Border.all(color: WitHomeTheme.wit_lightGreen, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '필요한 것만 견적을 받아보세요',
                    style: WitHomeTheme.title.copyWith(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 16.0),

                /// 🔹 작업 요청 예상일 입력
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                      decoration: BoxDecoration(
                        color: WitHomeTheme.white,
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      child: const Text(
                        "작업요청 예상일",
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: WitHomeTheme.wit_mediumSeaGreen,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _selectDate(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedDate ?? "날짜 선택",
                                style: const TextStyle(fontSize: 16.0),
                              ),
                              const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),

                /// 🔹 추가조건 / 요구사항 입력
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "추가조건/요구사항",
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    TextField(
                      controller: _additionalRequirementsController,
                      focusNode: _additionalFocusNode,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Ex) 안방과 거실만 70,000원 가능할까요?",
                        contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.green, width: 2.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 1.0),
                        ),
                      ),
                      style: const TextStyle(fontSize: 14.0),
                    ),
                    const SizedBox(height: 16.0),
                  ],
                ),

                /// 🔹 견적 요청하기 버튼
                GestureDetector(
                  onTap: () async {
                    if (_selectedDate == null) {
                      await DialogUtils.showCustomDialog(
                        context: context,
                        title: '날짜 선택 필요',
                        content: '작업 요청 예정일을 선택해 주세요.',
                        confirmButtonText: '확인',
                      );
                      return;
                    }

                    if (_additionalRequirementsController.text.isEmpty) {
                      await DialogUtils.showCustomDialog(
                        context: context,
                        title: '요청사항 입력 필요',
                        content: '추가 조건 또는 요구 사항을 입력해 주세요.',
                        confirmButtonText: '확인',
                      );
                      _additionalFocusNode.requestFocus();
                      return;
                    }

                    bool isConfirmed = await DialogUtils.showIPhoneConfirmDialog(
                      context: context,
                      title: '견적 요청 확인',
                      content: '견적 요청을 진행하시겠습니까?',
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
                      child: RichText(
                        text: TextSpan(
                          children: [
                            const TextSpan(
                              text: '견적 요청하기 ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: '(${_selectedItemCount})',
                              style: const TextStyle(
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
                const SizedBox(height: 24.0),
              ],
            ),
          ),
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
      "type": widget.type,
      "aptNo": aptNo,
      "reqUser": clerkNo,
      "categoryIds": selectedItems,
      "reqContents": reqContents,
      "expectedDate": _selectedDate, // ✅ 작업요청예정일 추가
    });

    try {
      final response = await sendPostRequest(restId, param);

      if (response != null) {
        await DialogUtils.showIPhoneAlertDialog(
          context: context,
          title: '견적 요청 완료',
          content: '성공적으로 완료되었습니다.',
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
