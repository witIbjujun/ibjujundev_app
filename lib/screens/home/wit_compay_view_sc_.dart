import 'package:witibju/screens/home/models/category.dart';
import 'package:witibju/screens/home/wit_home_theme.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:witibju/util/wit_api_ut.dart';

/// 메인의 하단
dynamic companyInfo = {};

class PopularCourseListView extends StatefulWidget {
  const PopularCourseListView({Key? key, this.callBack}) : super(key: key);

  // 콜백 함수, 사용자가 아이템을 선택했을 때 호출됨
  final Function(Category)? callBack;

  @override
  _PopularCourseListViewState createState() => _PopularCourseListViewState();
}

class _PopularCourseListViewState extends State<PopularCourseListView> {
  List<Category> categoryList = [];

  @override
  void initState() {
    super.initState();
    getCategoryList();
  }

  // 데이터를 비동기로 가져오는 메서드 (딜레이 200ms)
  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 200));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: FutureBuilder<bool>(
        future: getData(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator()); // 로딩 중 표시
          } else {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: GridView.builder(
                  shrinkWrap: true, // 스크롤 가능하도록 설정
                  padding: const EdgeInsets.all(8),
                  physics: const NeverScrollableScrollPhysics(), // 내부 스크롤 비활성화
                  itemCount: categoryList.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 2개의 열
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 1.2,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    return CategoryView(
                      callback: () {
                        if (widget.callBack != null) {
                          widget.callBack!(categoryList[index]);
                        }
                      },
                      category: categoryList[index],
                    );
                  },
                ),
              ),
            );
          }
        },
      ),
    );
  }

  // [서비스] 사전 점검 상세 항목 리스트 조회
  Future<void> getCategoryList() async {
    try {
      final param = jsonEncode({"inspId": companyInfo["inspId"]});
      final _categoryList = await sendPostRequest("getCategoryList", param);
      setState(() {
        categoryList = Category().parseCategoryList(_categoryList) ?? [];
      });
    } catch (error) {
      print("Error loading categories: $error");
    }
  }
}

// 각 카테고리 아이템의 뷰를 나타내는 StatelessWidget 클래스
class CategoryView extends StatelessWidget {
  const CategoryView({
    Key? key,
    this.category,
    this.callback,
  }) : super(key: key);

  final Function()? callback; // 아이템 클릭 시 호출될 콜백 함수
  final Category? category; // 카테고리 데이터

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      onTap: callback,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(16.0)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.grey.withOpacity(0.6),
              offset: const Offset(4, 4),
              blurRadius: 8.0,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(
                    height: 60,
                    width: 60,
                    child: Image.asset(category!.imagePath),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        category!.categoryNm,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          letterSpacing: 0.27,
                          color: WitHomeTheme.darkerText,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                category!.detail,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w200,
                  letterSpacing: 0.27,
                  color: WitHomeTheme.grey,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    '참여업체',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: WitHomeTheme.nearlyBlue,
                    ),
                  ),
                  Text(
                    ' (${category!.companyCnt})',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: WitHomeTheme.nearlyBlue,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
