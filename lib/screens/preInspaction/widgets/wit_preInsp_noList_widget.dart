import 'package:flutter/material.dart';

class PreInspactionNoListUI extends StatelessWidget {
  final List<dynamic> preinspactionNoList;
  final Function(int, bool) onToggle;
  final int? expandedIndex;
  final Function(int) onExpand;

  const PreInspactionNoListUI({
    Key? key,
    required this.preinspactionNoList,
    required this.onToggle,
    required this.expandedIndex,
    required this.onExpand,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: preinspactionNoList.length,
      itemBuilder: (context, index) {
        bool isExpanded = expandedIndex == index; // 현재 항목이 확장되었는지 확인

        return Card(
          margin: EdgeInsets.symmetric(vertical: 7, horizontal: 15),
          elevation: 3,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(3),
          ),
          child: GestureDetector(
            onTap: () {
              onExpand(index);
            },
            child: Container(
              width: double.infinity, // 부모의 너비에 맞게 확장
              padding: EdgeInsets.symmetric(vertical: 8), // Card 높이 및 패딩 조정
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    color: Colors.yellow[100], // 배경색 설정
                    width: double.infinity, // 좌우로 꽉 차게 설정
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8), // 텍스트 여백 설정
                    child: Text(
                      preinspactionNoList[index]["inspDetlNm"].split('\n')[0],
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    duration: Duration(milliseconds: 300), // 애니메이션 시간 설정
                    curve: Curves.easeInOut, // 애니메이션 곡선 설정
                    height: isExpanded ? 250 : 0, // 확장된 상태의 높이 설정
                    padding: isExpanded ? const EdgeInsets.only(top: 10) : EdgeInsets.zero, // 패딩 조정
                    child: isExpanded
                        ? Text(
                      preinspactionNoList[index]["inspDetlNm"], // 확장된 상태에서 보여줄 내용
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    )
                        : SizedBox.shrink(), // 비어있을 때는 빈 위젯 반환
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // 양쪽 끝으로 정렬
                    children: [
                      Transform.scale(
                        scale: 0.7,
                        child: Switch(
                          value: preinspactionNoList[index]["checkYn"] == "N",
                          onChanged: (value) {
                            onToggle(index, value);
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
