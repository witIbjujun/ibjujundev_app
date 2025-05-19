import 'package:witibju/screens/home/models/category.dart';
import 'package:witibju/screens/home/wit_home_theme.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:witibju/util/wit_api_ut.dart';

//견적받으러가기 > 견적받기 화면

dynamic companyInfo = {};

class PopularCourseListHorizontalView extends StatefulWidget {
  const PopularCourseListHorizontalView({
    Key? key,
    this.callBack,
    required this.type, // type 매개변수를 추가
  }) : super(key: key);
  /// 2024-08-10: 콜백 함수가 선택 상태를 포함하도록 수정
  final Function(Category, bool)? callBack;

  final dynamic type;

  @override
  _PopularCourseListHorizontalViewState createState() => _PopularCourseListHorizontalViewState();
}

class _PopularCourseListHorizontalViewState extends State<PopularCourseListHorizontalView> {
  List<Category> categoryList = [];
  List<bool> selectedList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getCategoryList(widget.type);
  }

  Future<void> getCategoryList(String type) async {
    String restId = "getCategoryList";

    final param = jsonEncode({
      "type": type,
    });

    final _categoryList = await sendPostRequest(restId, param);

    setState(() {
      categoryList = Category().parseCategoryList(_categoryList)!;

      // 2025-04-15: 기본 모든 카테고리 선택 상태로 초기화
      selectedList = List<bool>.filled(categoryList.length, true);

      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (categoryList.isEmpty) {
      return const Center(child: Text('No companies available'));
    } else {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: SizedBox(
          height: 90 * categoryList.length.toDouble(), // 🔹 리스트 개수에 따른 높이 조정
          child: ListView.builder(
            padding: const EdgeInsets.all(1),
            physics: const BouncingScrollPhysics(),
            itemCount: categoryList.length, // 아이템 수
            itemBuilder: (BuildContext context, int index) {
              return CategoryView(
                callback: () {
                  setState(() {
                    selectedList[index] = !selectedList[index];
                    widget.callBack?.call(categoryList[index], selectedList[index]);
                    /// 2024-08-10: 선택 상태 전달을 위해 callBack에 두 인자 전달
                  });
                },
                category: categoryList[index],
                isSelected: selectedList[index],
              );
            },
          ),
        ),
      );
    }
  }
}

class CategoryView extends StatelessWidget {
  const CategoryView({Key? key, this.category, this.callback, this.isSelected})
      : super(key: key);

  final Function()? callback; // 🔸 클릭 시 호출될 콜백
  final Category? category;   // 🔸 카테고리 정보
  final bool? isSelected;     // 🔸 선택 여부

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkWell(
        splashColor: Colors.transparent,
        onTap: callback, // 🔸 클릭 시 콜백 호출
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8, // 🔸 화면의 80% 너비
          height: 80, // 🔸 높이 고정
          margin: const EdgeInsets.symmetric(vertical: 3.0), // 🔸 위아래 간격
          decoration: BoxDecoration(
            color: Colors.white, // ✅ 흰색 배경 유지
            border: Border.all(
              color: isSelected! ? Color(0xFFA4C639) : Colors.grey, // ✅ 선택 시 녹색 테두리, 미선택 시 회색 테두리
              width: isSelected! ? 2.0 : 1.0, // ✅ 두께 조정
            ),
            borderRadius: const BorderRadius.all(Radius.circular(16.0)), // ✅ 둥근 모서리
          ),
          child: Stack(
            children: [
              // 🔹 카테고리 정보 표시
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Container(
                      height: 60,
                      width: 60,
                      child: category!.imagePath != null &&
                          category!.imagePath.isNotEmpty
                          ? Image.asset(category!.imagePath + "Green.png")
                          : Icon(Icons.image, size: 60),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          category!.categoryNm ?? 'No Name',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            letterSpacing: 0.27,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          category!.detail ?? 'No Detail',
                          style: TextStyle(
                            fontWeight: FontWeight.w200,
                            fontSize: 12,
                            letterSpacing: 0.27,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // 🔹 선택된 경우 체크 아이콘 표시
              if (isSelected!)
                Positioned(
                  right: 20,
                  top: 30,
                  child: CircleAvatar(
                    backgroundColor: WitHomeTheme.wit_lightGreen,
                    radius: 12,
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
