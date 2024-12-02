import 'package:flutter/material.dart';
import '../wit_preInsp_detail_sc.dart';
import '../wit_preInsp_main_sc.dart';

class CustomSliverAppBar extends StatelessWidget {
  final bool isEditing;
  final VoidCallback onRefreshPressed;
  final VoidCallback onEditTogglePressed;

  const CustomSliverAppBar({
    Key? key,
    required this.isEditing,
    required this.onRefreshPressed,
    required this.onEditTogglePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 250.0, // AppBar의 확장 높이
      floating: false,
      pinned: true,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          // 스크롤 높이에 따라 배경색 결정
          Color backgroundColor = constraints.maxHeight < 200 ? Colors.lightBlue : Colors.transparent; // 하늘색

          return FlexibleSpaceBar(
            title: Text(
              isEditing ? "사전 체크리스트 설정" : "사전 체크리스트", // 텍스트 변경
              style: TextStyle(
                color: constraints.maxHeight < 200 ? Colors.black : Colors.white, // 텍스트 색상 결정
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            titlePadding: EdgeInsets.all(16.0), // 제목의 패딩 설정
            background: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  'https://images.unsplash.com/photo-1521747116042-5a810fda9664', // 밝고 화사한 배경 이미지 URL
                  fit: BoxFit.cover, // 이미지 크기를 조정
                ),
                Container(
                  color: backgroundColor.withOpacity(0.7), // 배경색에 반투명 처리
                ),
              ],
            ),
          );
        },
      ),
      actions: [
        if (isEditing) // 수정 모드일 때만 초기화 버튼 표시
          IconButton(
            icon: Icon(Icons.refresh), // 초기화 아이콘
            color: Colors.black,
            onPressed: onRefreshPressed,
          ),
        IconButton(
          icon: Icon(isEditing ? Icons.check : Icons.settings), // 상태에 따라 아이콘 변경
          color: Colors.white,
          onPressed: onEditTogglePressed,
        ),
      ],
    );
  }
}

class ScrollToTopButton extends StatelessWidget {
  final bool isVisible;
  final VoidCallback onPressed;

  const ScrollToTopButton({
    Key? key,
    required this.isVisible,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isVisible, // 버튼 가시성 제어
      child: Container(
        alignment: Alignment.bottomCenter, // 중앙 하단에 배치
        padding: EdgeInsets.only(left: 30.0), // 오른쪽 여백 추가
        child: SizedBox(
          width: 45.0,
          height: 45.0,
          child: Material(
            color: Colors.white, // 배경 색상
            shape: CircleBorder(side: BorderSide(color: Colors.black, width: 2)), // 테두리 설정
            child: InkWell(
              borderRadius: BorderRadius.circular(22.5), // 원형 효과
              onTap: onPressed, // 버튼 클릭 시 동작
              child: Center(
                child: Icon(Icons.arrow_upward, color: Colors.black), // 위로 가는 아이콘
              ),
            ),
          ),
        ),
      ),
    );
  }
}


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
                  ],
                ),
              ),
            ),
            // 우측 띠 항목
            Container(
              width: 80, // 필요에 따라 너비 조정
              decoration: BoxDecoration(
                color: choiceColor,
              ),
              child: Center(
                child: Text(
                  "$totalCount / $checkedCount건",
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