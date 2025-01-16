import 'package:flutter/material.dart';
import 'package:ibjujundev_admin_app/util/wit_code_ut.dart';
import 'package:ibjujundev_admin_app/screens/common/widget/wit_common_widget.dart';
import 'package:ibjujundev_admin_app/screens/checkList/wit_checkList_detail_sc.dart';

/**
 * 사전 체크리스트 리스트 뷰
 */
class CheckListView extends StatelessWidget {

  final List<dynamic> listData;
  final Future<void> Function() callback;
  final bool edited;


  const CheckListView({
    required this.listData,
    required this.callback,
    required this.edited,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: listData.length,
      itemBuilder: (context, index) {
        final item = listData[index];
        return CheckListCard(
          item: item,
          edited : edited,
          onTap: () async {
            if (edited == false)
            await Navigator.push(
              context,
              SlideRoute(page: CheckListDetail(checkInfoLv1: item)),
            );
            await callback();
          },
        );
      },
    );
  }
}

/**
 * 포인트 관리 요청 카드
 */
class CheckListCard extends StatefulWidget {

  final dynamic item;
  final bool edited;
  final VoidCallback onTap;

  const CheckListCard({required this.item, required this.edited, required this.onTap});

  @override
  _CheckListCardState createState() => _CheckListCardState();
}

class _CheckListCardState extends State<CheckListCard> {

  Color _backgroundColor = Colors.white; // 초기 배경 색상

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _backgroundColor = Colors.grey[200]!;
        });
      },
      onTapUp: (_) {
        setState(() {
          _backgroundColor = Colors.white;
        });
      },
      onTapCancel: () {
        setState(() {
          _backgroundColor = Colors.white;
        });
      },
      onTap: widget.onTap,
      child: Container(
        color: _backgroundColor,
        child: Column(
          children: [
            SizedBox(height: 20),
            Row(
              children: [
                SizedBox(width: 30),
                Container(
                  width: 35,
                  height: 35,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5), // 모서리 둥글게
                    child: Image.network(
                      apiUrl + widget.item["inspImg"],
                      width: 35,
                      height: 35,
                      fit: BoxFit.cover,
                      errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                        return Image.network(
                          apiUrl + "/WIT/checkList/없음.png",
                          width: 35,
                          height: 35,
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(width: 30),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item["inspNm"],
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                if (widget.edited == true)
                  Container(
                    height: 35, // 고정 높이 설정
                    child: Transform.scale(
                      scale: 0.6, // 스위치 크기 조정
                      child: Switch(
                        value: widget.item["isSelected"] ?? true, // 스위치 상태
                        onChanged: (value) {
                          setState(() {
                            widget.item["isSelected"] = value;
                          });
                        },
                        activeColor: Colors.blue, // 활성화 색상
                      ),
                    ),
                  ),
                if (widget.edited == false)
                  Container(
                    height: 35, // 고정 높이 설정
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 8, 30, 0), // 오른쪽 패딩 설정
                      child: widget.item["inspDetlChoiceCnt"] == "0"
                          ? SizedBox.shrink() // 0일 경우 빈 공간
                          : RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "${widget.item["inspDetlChoiceCnt"]} ", // 숫자
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red),
                            ),
                            TextSpan(
                              text: "건", // "건" 텍스트
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black), // 검정색
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

              ],
            ),
            SizedBox(height: 20),
            Container(
              height: 1,
              color: Colors.grey[200],
            ),
          ],
        ),
      ),
    );
  }
}