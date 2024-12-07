import 'dart:convert';
import 'package:flutter/material.dart';
import '../../util/wit_api_ut.dart';

// 게시판 메인
class Board extends StatefulWidget {

  Board(String boardType);


  @override
  State<StatefulWidget> createState() {
    return BoardState();
  }
}

class BoardState extends State<Board> {
  // 게시판 리스트
  List<dynamic> boardList = [];

  @override
  void initState() {
    super.initState();


    getBoardList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('게시판 조회'),
      ),
      body: SafeArea(
        child: ListView.builder(
          itemCount: boardList.length,
          itemBuilder: (context, index) {
            final boardItem = boardList[index];
            return ListTile(
              contentPadding: EdgeInsets.all(10),
              title: Text(boardItem["bordTitle"], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('작성자: ${boardItem["creUser"]}'),
                  Text('작성 시간: ${boardItem["creDateTxt"]}'),
                  Text('조회 수: ${boardItem["bordRdCnt"]}회'),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // [서비스] 게시판 리스트 조회
  Future<void> getBoardList() async {

    // REST ID
    String restId = "getBoardList";

    final param = jsonEncode({
      "bordNo": "1",
      "bordType": "C1",
      "searchText": "",
      "currentPage": 0,
      "pageSize": 1,
    });

    // API 호출 (게시판 리스트 조회)
    final _boardList = await sendPostRequest(restId, param);

    // 결과 셋팅
    setState(() {
      boardList.addAll(_boardList);
    });
  }
}
