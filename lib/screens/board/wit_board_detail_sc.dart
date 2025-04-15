import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:witibju/screens/board/widget/wit_board_detail_widget.dart';
import 'package:witibju/util/wit_api_ut.dart';
import 'package:witibju/screens/home/wit_home_theme.dart';

dynamic boardDetailInfo = {};

List<dynamic> boardDetailImageList = [];

List<dynamic> commentList = [];

class BoardDetail extends StatefulWidget {

  final dynamic param;

  const BoardDetail({super.key, required this.param});

  @override
  State<StatefulWidget> createState() {
    boardDetailInfo = this.param;
    return BoardDetailState();
  }
}

class BoardDetailState extends State<BoardDetail> {
  TextEditingController commentController = TextEditingController();

  final secureStorage = FlutterSecureStorage();

  String loginClerkNo = "";

  @override
  void initState() {
    super.initState();

    // 게시판 조회수 증가
    boardRdCntUp();

    // 게시판 상세 조회
    getBoardDetailList();

    // 게시판 상세 이미지 조회
    getBoardDetailImageList();

    // 댓글 리스트 조회
    getCommentList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("자유게시판", style: WitHomeTheme.title.copyWith(color: WitHomeTheme.wit_white)),
        iconTheme: IconThemeData(color: WitHomeTheme.wit_white),
        backgroundColor: WitHomeTheme.wit_black,
      ),
      backgroundColor: WitHomeTheme.wit_white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TitleAndMenu(
                        boardDetailInfo: boardDetailInfo,
                        boardDetailImageList: boardDetailImageList,
                        endBoardInfo: endBoardInfo,
                        context: context,
                        loginClerkNo : loginClerkNo,
                      ),
                      SizedBox(height: 20),
                      UserInfo(
                        boardDetailInfo: boardDetailInfo,
                      ),
                      SizedBox(height: 10),
                      Divider(),
                      SizedBox(height: 10),
                      ContentDisplay(
                        content: boardDetailInfo["bordContent"] ?? "",
                      ),
                      SizedBox(height: 10),
                      ImageListDisplay(
                        boardDetailImageList: boardDetailImageList,
                      ),
                      SizedBox(height: 10),
                      Divider(),
                      SizedBox(height: 10),
                      CommentCount(
                        count: commentList.length,
                      ),
                      SizedBox(height: 5),
                      CommentList(
                        commentList: commentList,
                        loginClerkNo : loginClerkNo,
                        endCommentInfo : endCommentInfo,
                      ),
                      CommentInput(
                        commentController: commentController,
                        saveCommentInfo: saveCommentInfo,
                        isEmpty: commentList.isEmpty,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // [서비스] 게시판 조회수 증가
  Future<void> boardRdCntUp() async {

    // 로그인 사번
    loginClerkNo = (await secureStorage.read(key: 'clerkNo'))!;

    // REST ID
    String restId = "boardRdCntUp";

    // PARAM
    final param = jsonEncode({
      "bordNo": boardDetailInfo["bordNo"],
      "bordType": boardDetailInfo["bordType"],
      "bordSeq": boardDetailInfo["bordSeq"],
    });

    // API 호출 (게시판 상세 조회)
    await sendPostRequest(restId, param);

    // 결과 셋팅
    setState(() {
      boardDetailInfo["bordRdCnt"] = boardDetailInfo["bordRdCnt"] + 1;
    });
  }

  // [서비스] 게시판 상세 조회
  Future<void> getBoardDetailList() async {
    // REST ID
    String restId = "getBoardDetailInfo";

    // PARAM
    final param = jsonEncode({
      "bordNo": boardDetailInfo["bordNo"],
      "bordType": boardDetailInfo["bordType"],
      "bordSeq": boardDetailInfo["bordSeq"],
    });

    // API 호출 (게시판 상세 조회)
    final _boardDetailInfo = await sendPostRequest(restId, param);

    // 결과 셋팅
    setState(() {
      boardDetailInfo = _boardDetailInfo;
    });
  }

  // [서비스] 게시판 상세 이미지 조회
  Future<void> getBoardDetailImageList() async {
    // REST ID
    String restId = "getBoardDetailImageList";

    // PARAM
    final param = jsonEncode({
      "bordNo": boardDetailInfo["bordNo"],
      "bordType": boardDetailInfo["bordType"],
    });

    // API 호출 (게시판 상세 조회)
    final _boardDetailImageList = await sendPostRequest(restId, param);

    // 결과 셋팅
    setState(() {
      boardDetailImageList = _boardDetailImageList;
    });
  }

  // [서비스] 댓글 리스트 조회
  Future<void> getCommentList() async {
    print("댓글 리스트 조회");

    // REST ID
    String restId = "getCommentList";

    // PARAM
    final param = jsonEncode({
      "bordNo": boardDetailInfo["bordNo"],
      "bordType": boardDetailInfo["bordType"],
      "bordSeq": boardDetailInfo["bordSeq"],
    });

    // API 호출 (게시판 상세 조회)
    final _commentList = await sendPostRequest(restId, param);

    // 결과 셋팅
    setState(() {
      commentList = _commentList;
    });
  }

  // 댓글 저장
  Future<void> saveCommentInfo() async {

    // 로그인 사번
    String? loginClerkNo = await secureStorage.read(key: 'clerkNo');

    String cmmtContent = commentController.text;

    // 댓글 내용이 비어있지 않은 경우에만 추가
    if (cmmtContent.isNotEmpty) {
      // REST ID
      String restId = "saveCommentInfo";

      // PARAM
      final param = jsonEncode({
        "bordNo": boardDetailInfo["bordNo"],
        "bordType": boardDetailInfo["bordType"],
        "bordSeq": boardDetailInfo["bordSeq"],
        "cmmtContent": cmmtContent,
        "creUser": loginClerkNo,
      });

      // API 호출 (댓글 추가)
      final _commentList = await sendPostRequest(restId, param);

      // 댓글 리스트 갱신
      setState(() {
        commentList = _commentList;
        commentController.clear();
      });
    }
  }

  // [서비스] 게시판 종료
  Future<void> endBoardInfo() async {
    // REST ID
    String restId = "endBoardInfo";

    // PARAM
    final param = jsonEncode({
      "bordNo": boardDetailInfo["bordNo"],
      "bordType": boardDetailInfo["bordType"],
      "bordSeq": boardDetailInfo["bordSeq"],
      "updUser": loginClerkNo,
    });

    // API 호출 (게시판 상세 조회)
    final result = await sendPostRequest(restId, param);

    if (result > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('삭제되었습니다.')),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류가 발생했습니다. 다시 시도해주세요.')),
      );
    }

  }
  
  // 댓글 삭제
  Future<void> endCommentInfo(dynamic data) async {

    // REST ID
    String restId = "endCommentInfo";

    print(boardDetailInfo["bordNo"]);
    print(boardDetailInfo["bordType"]);
    print(data["cmmtNo"]);
    print(data["cmmtSeq"]);

    // PARAM
    final param = jsonEncode({
      "bordNo": boardDetailInfo["bordNo"],
      "bordType": boardDetailInfo["bordType"],
      "cmmtNo": data["cmmtNo"],
      "cmmtSeq": data["cmmtSeq"],
      "updUser" : loginClerkNo,
    });

    // API 호출 (댓글 추가)
    final endResult = await sendPostRequest(restId, param);

    // 댓글 리스트 갱신
    setState(() {
      if (endResult > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('댓글 삭제 되었습니다.')),
        );
        getCommentList();
      }
    });
  }
}
