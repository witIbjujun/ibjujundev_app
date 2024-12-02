import 'package:flutter/material.dart';

class PreInspactionDetailUI extends StatefulWidget {
  final String inspNm;
  final List<dynamic> preinspactionListByLv2;
  final List<dynamic> preinspactionListByLv3;
  final TabController tabController;
  final Function(String) onTabChanged;
  final Function(dynamic, String) onSwitchChanged;

  const PreInspactionDetailUI({
    Key? key,
    required this.inspNm,
    required this.preinspactionListByLv2,
    required this.preinspactionListByLv3,
    required this.tabController,
    required this.onTabChanged,
    required this.onSwitchChanged,
  }) : super(key: key);

  @override
  _PreInspactionDetailUIState createState() => _PreInspactionDetailUIState();
}

class _PreInspactionDetailUIState extends State<PreInspactionDetailUI> {
  int? expandedIndex = 0; // 클릭된 항목의 인덱스를 저장

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            widget.inspNm,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              letterSpacing: 1.5,
              color: Colors.black,
            ),
          ),
          bottom: widget.preinspactionListByLv2.isNotEmpty
              ? TabBar(
            controller: widget.tabController,
            isScrollable: false,
            onTap: (index) {
              widget.onTabChanged(widget.preinspactionListByLv2[index]["inspId"]);
            },
            tabs: widget.preinspactionListByLv2.map((item) {
              return Tab(
                child: Container(
                  alignment: Alignment.center,
                  width: double.infinity,
                  child: Text(item["inspNm"] + " (" + (item["checkCnt"] ?? 0).toString() + ")"), // checkCnt를 문자열로 변환
                ),
              );
            }).toList(),
          )
              : null,
        ),
        body: ListView.builder(
          itemCount: widget.preinspactionListByLv3.length,
          itemBuilder: (context, index) {
            bool isExpanded = expandedIndex == index; // 현재 항목이 확장되었는지 확인

            return Card(
              margin: EdgeInsets.symmetric(vertical: 7, horizontal: 15),
              elevation: 3,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    expandedIndex = isExpanded ? null : index; // 클릭 시 상태 변경
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(8),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween, // 양쪽 끝으로 정렬
                        children: [
                          Expanded(
                            child: Text(
                              widget.preinspactionListByLv3[index]["inspNm"].split('\n')[0],
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Transform.scale(
                            scale: 0.7,
                            child: Switch(
                              value: widget.preinspactionListByLv3[index]["checkYn"] == "N",
                              onChanged: (value) {
                                // Switch 상태 변경 시 호출되는 이벤트
                                setState(() {
                                  // 상태 업데이트
                                  widget.preinspactionListByLv3[index]["checkYn"] = value ? "N" : "Y";
                                });
                                // onSwitchChanged 콜백 호출
                                widget.onSwitchChanged(widget.preinspactionListByLv3[index], value ? "N" : "Y");
                              },
                              activeTrackColor: Colors.blue[200],
                              inactiveTrackColor: Colors.red[200],
                            ),
                          ),
                          Icon(
                            isExpanded ? Icons.expand_less : Icons.expand_more,
                            color: Colors.grey,
                          ), // 펼치기/닫기 아이콘
                        ],
                      ),
                      AnimatedContainer(
                        duration: Duration(milliseconds: 300), // 애니메이션 시간 설정
                        curve: Curves.easeInOut, // 애니메이션 곡선 설정
                        height: isExpanded ? 250 : 0, // 확장된 상태의 높이 설정
                        padding: isExpanded ? const EdgeInsets.only(top: 10) : EdgeInsets.zero, // 패딩 조정
                        child: isExpanded
                            ? Text(
                          widget.preinspactionListByLv3[index]["inspNm"], // 확장된 상태에서 보여줄 내용
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        )
                            : SizedBox.shrink(), // 비어있을 때는 빈 위젯 반환
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
