import 'package:flutter/material.dart';
import 'package:witibju/util/wit_code_ut.dart';
import 'package:witibju/screens/checkList/wit_checkList_write_pop.dart';
import 'package:witibju/screens/home/wit_home_theme.dart';

/**
 * 체크리스트 상세 화면 UI
 */
class CheckListDetailView extends StatefulWidget {
  final dynamic checkInfoLv1;
  final List<dynamic> checkListByLv2;
  final List<dynamic> checkListByLv3;
  final TabController tabController;
  final Function(String) onTabChanged;
  final Function(dynamic, String) onSwitchChanged;

  const CheckListDetailView({
    Key? key,
    required this.checkInfoLv1,
    required this.checkListByLv2,
    required this.checkListByLv3,
    required this.tabController,
    required this.onTabChanged,
    required this.onSwitchChanged,
  }) : super(key: key);

  @override
  _CheckListDetailViewState createState() => _CheckListDetailViewState();
}

class _CheckListDetailViewState extends State<CheckListDetailView> {
  int? expandedIndex = -1; // 클릭된 항목의 인덱스를 저장
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose(); // ScrollController 메모리 해제
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            TabBarWidget(
              checkListByLv2: widget.checkListByLv2,
              tabController: widget.tabController,
              onTabChanged: (inspId) {
                setState(() {
                  expandedIndex = -1;
                });
                widget.onTabChanged(inspId);
              },
            ),
            Expanded(
              child: Container(
                color: WitHomeTheme.wit_white, // 배경색을 흰색으로 설정
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: widget.checkListByLv3.length,
                  itemBuilder: (context, index) {
                    bool isExpanded = expandedIndex == index;
                    return ExpandableItem(
                      checkInfoLv3: widget.checkListByLv3[index],
                      isExpanded: isExpanded,
                      onSwitchChanged: (value) {
                        setState(() {
                          widget.checkListByLv3[index]["checkYn"] = value ? "N" : "Y";
                        });
                        widget.onSwitchChanged(widget.checkListByLv3[index], value ? "N" : "Y");
                      },
                      onTap: () {
                        setState(() {
                          expandedIndex = isExpanded ? null : index;
                          if (!isExpanded) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _scrollController.animateTo(
                                (index - 1) * 73,
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            });
                          }
                        });
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/**
 * 체크리스트 상세 TabBar Widget
 */
class TabBarWidget extends StatelessWidget {
  final List<dynamic> checkListByLv2;
  final TabController tabController;
  final Function(String) onTabChanged;

  const TabBarWidget({
    Key? key,
    required this.checkListByLv2,
    required this.tabController,
    required this.onTabChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (checkListByLv2.isNotEmpty) {
      return Container(
        color: WitHomeTheme.wit_white,
        child: TabBar(
          controller: tabController,
          isScrollable: false,
          indicatorColor: WitHomeTheme.wit_lightGreen,
          indicatorWeight: 4.0, // 줄의 두께 조정
          onTap: (index) {
            onTabChanged(checkListByLv2[index]["inspId"]);
          },
          tabs: checkListByLv2.map((item) {
            return Tab(
              child: Container(
                alignment: Alignment.center,
                width: double.infinity,
                child: Text(
                  item["inspNm"] + " (" + (item["checkCnt"] ?? 0).toString() + ")",
                  style: WitHomeTheme.subtitle,
                ),
              ),
            );
          }).toList(),
        ),
      );
    } else {
      return SizedBox.shrink(); // 리스트가 비어있을 경우 빈 위젯 반환
    }
  }
}

/**
 * 체크리스트 상세 TabBar 상세 Widget
 */
class ExpandableItem extends StatelessWidget {
  final dynamic checkInfoLv3;
  final bool isExpanded;
  final Function(bool) onSwitchChanged;
  final VoidCallback onTap;

  const ExpandableItem({
    Key? key,
    required this.checkInfoLv3,
    required this.isExpanded,
    required this.onSwitchChanged,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(14, 7, 14, 7),
      decoration: BoxDecoration(
        color: WitHomeTheme.wit_white, // 배경색 설정
        borderRadius: BorderRadius.circular(5), // 라운드 처리
        boxShadow: [
          BoxShadow(
            color: WitHomeTheme.wit_gray.withOpacity(0.2), // 그림자 색상
            spreadRadius: 2, // 그림자 퍼짐 정도
            blurRadius: 3, // 그림자 흐림 정도
            offset: Offset(1, 2), // 그림자 위치
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onTap, // 클릭 이벤트 처리
            child: Container(
              height: 60,
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(20, 10, 10, 10),
              decoration: BoxDecoration(
                color: WitHomeTheme.wit_white,
                borderRadius: isExpanded ?
                  BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5),)
                    : BorderRadius.all(Radius.circular(5)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: isExpanded ? WitHomeTheme.wit_lightBlue : WitHomeTheme.wit_black,
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      checkInfoLv3["inspNm"],
                      style: isExpanded ?
                      WitHomeTheme.subtitle.copyWith(fontWeight: FontWeight.bold) : WitHomeTheme.subtitle,
                    ),
                  ),
                  if (checkInfoLv3["checkYn"] == 'Y') // 'Y'일 때 연필 아이콘 추가
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isDismissible: true, // 바깥을 클릭해도 닫히지 않도록 설정
                          isScrollControlled: true, // 스크롤 가능하게 설정
                          builder: (context) {
                            return Container(
                              height: 510,
                              child: ExamplePhotoPopup(
                                checkInfoLv3: checkInfoLv3,
                                onSwitchChanged: onSwitchChanged,
                              ),
                            );
                          },
                        );
                      },
                      child: Image.network(
                        apiUrl + "/WIT/checkList/글쓰기.png",
                        width: 30,
                        height: 30,
                        fit: BoxFit.cover,
                        errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                          return Image.network(
                            apiUrl + "/WIT/checkList/없음.png",
                            width: 30,
                            height: 30,
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),
                  Container(
                    child: IconButton(
                      icon: Text(
                        checkInfoLv3["checkYn"] == "Y" ? "🔴"  // 축하 이모티콘
                            : checkInfoLv3["checkYn"] == "D" ? "⚪️"  // 손握기 이모티콘
                            : "️⚪️",  // 빨간 따봉 뒤집힌 것
                        style: TextStyle(fontSize: 18),
                      ),
                      // 사용할지 확인 필요
                      onPressed: () {
                        onSwitchChanged(checkInfoLv3["checkYn"] == "Y"); // Y일 경우 false, 나머지 경우 true
                      },
                    ),
                  ),
                  /*Transform.scale(
                    scale: 0.7,
                    child: Switch(
                      value: checkInfoLv3["checkYn"] == "N" || checkInfoLv3["checkYn"] == "D",
                      onChanged: (value) {
                        onSwitchChanged(value);
                        if (!value) {
                          showModalBottomSheet(
                            context: context,
                            isDismissible: true, // 바깥을 클릭해도 닫히지 않도록 설정
                            isScrollControlled: true, // 스크롤 가능하게 설정
                            builder: (context) {
                              return Container(
                                height: MediaQuery.of(context).size.height * 0.38,
                                child: ExamplePhotoPopup(
                                  checkInfoLv3: checkInfoLv3,
                                  onSwitchChanged: onSwitchChanged,
                                ),
                              );
                            },
                          );
                        }
                      },
                      activeTrackColor: checkInfoLv3["checkYn"] == "D" ? Colors.grey[400] : Colors.blue[200],
                      inactiveTrackColor: Color(0xFFE5767B),
                    ),
                  ),*/
                ],
              ),
            ),
          ),
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: isExpanded ? 450 : 0,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // 선택했을떄만 이미지 출력 (데이터 사용량 이슈)
                  if (isExpanded == true)
                  Container(
                    height: 320,
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: PageView.builder(
                      itemCount: 3,
                      itemBuilder: (context, imageIndex) {
                        final inspImg = checkInfoLv3["inspImg"] ?? ""; // null 체크 및 디폴트 값 설정
                        final imageUrlList = [
                          apiUrl + "/WIT/checkList/" + inspImg + "1.png", // 첫 번째 이미지
                          apiUrl + "/WIT/checkList/" + inspImg + "2.png", // 두 번째 이미지
                          apiUrl + "/WIT/checkList/" + inspImg + "3.png", // 세 번째 이미지
                        ];
                        return Container(
                          width: double.infinity,
                          margin: EdgeInsets.symmetric(horizontal: 0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(0),
                          ),
                          child: Image.network(
                            imageUrlList[imageIndex],
                            fit: BoxFit.cover,
                            errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                              // 이미지 로드 실패 시 빈 이미지 또는 대체 이미지를 표시
                              return Container(
                                color: WitHomeTheme.wit_lightgray,
                                child: Center(
                                  child: Text(
                                    '이미지 없음',
                                    style: WitHomeTheme.subtitle,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      /*Padding(
                        padding: EdgeInsets.fromLTRB(20, 15, 0, 0),
                        child: Row(
                          children: [
                            Icon(Icons.favorite_border_outlined, size: 30), // 하트 아이콘
                            SizedBox(width: 30), // 아이콘 간격
                            Icon(Icons.comment_outlined, size: 30), // 말풍선 아이콘
                            SizedBox(width: 30), // 아이콘 간격
                            Icon(Icons.link_outlined, size: 30), // 링크 아이콘
                          ],
                        ),
                      ),*/
                      Container(
                        height: 120,
                        alignment: Alignment.topLeft,
                        color: WitHomeTheme.wit_white,
                        padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
                        child: Text(
                          checkInfoLv3["inspComt"] ?? "",
                          style: WitHomeTheme.subtitle,
                        ),
                      ),
                      Container(height: 10),
                    ],
                  ),

                  /*GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isDismissible: true, // 바깥을 클릭해도 닫히지 않도록 설정
                        isScrollControlled: true, // 스크롤 가능하게 설정
                        builder: (context) {
                          return Container(
                            height: MediaQuery.of(context).size.height * 0.38,
                            child: ExamplePhotoPopup(
                              checkInfoLv3: checkInfoLv3,
                              onSwitchChanged: onSwitchChanged,
                            ),
                          );
                        },
                      );
                    },
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: checkInfoLv3["checkYn"] == "Y" ? Color(0xFF91C58C) : Colors.grey,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(5),
                          bottomRight: Radius.circular(5),
                        ),
                      ),

                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.comment, color: Colors.white),
                            SizedBox(width: 8),
                            Text("COMMENT / 하자 작성",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),*/
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
