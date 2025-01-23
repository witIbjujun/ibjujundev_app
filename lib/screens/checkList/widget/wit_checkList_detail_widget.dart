import 'package:flutter/material.dart';
import 'package:witibju/util/wit_code_ut.dart';
import 'package:witibju/screens/checkList/wit_checkList_write_pop.dart';

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
                              (index - 1) * 82.5,
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
        color: Colors.white,
        child: TabBar(
          controller: tabController,
          isScrollable: false,
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
      margin: EdgeInsets.fromLTRB(10, 6, 10, 6),
      decoration: BoxDecoration(
        color: Colors.white, // 배경색 설정
        borderRadius: BorderRadius.circular(10), // 라운드 처리
        border: Border.all(
          color: isExpanded == false ? Colors.grey[200]! : Colors.grey[400]!, // 찐한 회색 테두리 색상
          width: 2, // 테두리 두께
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onTap, // 클릭 이벤트 처리
            child: Container(
              height: 70,
              width: double.infinity,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isExpanded ? Colors.white : Colors.white,
                borderRadius: isExpanded ?
                  BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10),)
                    : BorderRadius.all(Radius.circular(10)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: isExpanded ? Colors.blue : Colors.black,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      checkInfoLv3["inspNm"],
                      style: isExpanded ?
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)
                      : TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    child: IconButton(
                      icon: Text(
                        checkInfoLv3["checkYn"] == "Y" ? "🔴"  // 축하 이모티콘
                            : checkInfoLv3["checkYn"] == "D" ? "⚪️"  // 손握기 이모티콘
                            : "🔵",  // 빨간 따봉 뒤집힌 것
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white, // 텍스트 색상
                        ),
                      ),
                      // 사용할지 확인 필요
                      onPressed: () {
                        //onSwitchChanged(checkInfoLv3["checkYn"] == "Y"); // Y일 경우 false, 나머지 경우 true
                      },
                    ),
                  ),
                  /*Transform.scale(
                    scale: 0.5,
                    child: Switch(
                      value: checkYn == "N" || checkYn == "D",
                      onChanged: onSwitchChanged,
                      activeTrackColor: checkYn == "D" ? Colors.grey[400] : Colors.blue[200],
                      inactiveTrackColor: Colors.red[200],
                    ),
                  ),*/
                ],
              ),
            ),
          ),
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: isExpanded ? 500 : 0,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(height: 0),
                  Container(
                    height: 320,
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
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
                                color: Colors.grey[200], // 빈 이미지의 배경색
                                child: Center(
                                  child: Text(
                                    '이미지 없음',
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    height: 120,
                    alignment: Alignment.topLeft,
                    color: Colors.white,
                    padding: EdgeInsets.all(20),
                    child: Text(checkInfoLv3["inspComt"] ?? "",
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  Container(height: 10),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) {
                          return ExamplePhotoPopup(
                              checkInfoLv3 : checkInfoLv3,
                              onSwitchChanged : onSwitchChanged
                          );
                        },
                      );
                    },
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.blue[200],
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(6),
                          bottomRight: Radius.circular(6),
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
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
