import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:app/screens/preInspection/wit_preInsp_main_sc.dart';
import 'package:app/screens/preInspection/wit_preInsp_detail_sc.dart';

class CardList extends StatefulWidget {

  // 사전점검 항목
  final dynamic preinspactionInfo;

  CardList({required this.preinspactionInfo});

  @override
  cardTileState createState() => cardTileState();
}

/**
 * 사전점검 항목 1건 정보
 */
class cardTileState extends State<CardList> {

  @override
  Widget build(BuildContext context) {

    // 사전점검 전체 건수
    int totalCount = int.tryParse(widget.preinspactionInfo["inspDetlAllCnt"] ?? '0') ?? 0;
    // 완료 건수
    int checkedCount = int.tryParse(widget.preinspactionInfo["inspDetlChoiceCnt"] ?? '0') ?? 0;
    // 미선택 건수
    int inspDetlNoCnt = int.tryParse(widget.preinspactionInfo["inspDetlNoCnt"] ?? '0') ?? 0;
    // 진행률
    double percentage = totalCount > 0 ? checkedCount / totalCount : 0.0;
    // 진행률에 따른 컬러
    Color choiceColor = getChoiceColor(percentage);

    return GestureDetector(
      onTap: () => goToDetail(context), // 클릭 시 goToDetail 호출
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 1.0, horizontal: 0.0),
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
        color: Colors.white,
        child: Row(
          children: [
            // 좌측 진행률 항목
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: CircularPercentIndicator(
                radius: 30.0,
                lineWidth: 4.0,
                animation: true,
                percent: percentage,
                center: Text(
                  "${(percentage * 100).toStringAsFixed(0)}%",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12.0,
                  ),
                ),
                circularStrokeCap: CircularStrokeCap.round,
                progressColor: choiceColor,
              ),
            ),
            // 중앙 사전점검 항목
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.preinspactionInfo["inspNm"],
                      style: TextStyle(
                        color: Colors.black,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "전체 : $totalCount건 / 완료 : $checkedCount건",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
            // 우측 띠 항목
            Container(
              width: 50, // 필요에 따라 너비 조정
              decoration: BoxDecoration(
                color: choiceColor,
              ),
              child: Center(
                child: Text(
                  totalCount == 0 ? "" : totalCount == checkedCount ? "완료" : "$inspDetlNoCnt건",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void goToDetail(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => PreInspactionDetail(param: widget.preinspactionInfo),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    ).then((_) {
      // 상세화면에서 돌아왔을 때 리스트 재조회
      if (context.findAncestorStateOfType<PreInspactionState>() != null) {
        context.findAncestorStateOfType<PreInspactionState>()?.getPreinspactionList();
      }
    });
  }

  // [유틸] 진행률에 따른 색깔 선택
  Color getChoiceColor(double percentage) {
    if (percentage == 0) {
      return Colors.grey;
    } else if (percentage <= 0.999) {
      return Colors.orange;
    } else {
      return Colors.blue;
    }
  }
}


/**
 * 사전점검 항목 수정 모드
 */
class EditableCardList extends StatefulWidget {

  final dynamic preinspactionInfo;

  EditableCardList({required this.preinspactionInfo});

  @override
  _EditableCardState createState() => _EditableCardState();
}

class _EditableCardState extends State<EditableCardList> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {}, // 클릭 시 아무 동작하지 않음
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 1.0, horizontal: 0.0),
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
        color: Colors.white,
        child: Row(
            children: [
        Expanded(
        child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.preinspactionInfo["inspNm"],
              style: TextStyle(
                color: Colors.black,
                letterSpacing: 1.2,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    ),
    Transform.scale(
      scale: 0.7,
      child: Switch(
        value: widget.preinspactionInfo["isSelected"] ?? true, // 스위치 상태
        onChanged: (value) {
          setState(() {
            widget.preinspactionInfo["isSelected"] = value;
          });
        },
        activeColor: Colors.blue, // 활성화 색상
      ),
    )
            ],
        ),
      ),
    );
  }
}