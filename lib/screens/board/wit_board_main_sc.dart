import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:witibju/screens/board/widget/wit_board_main_widget.dart';
import 'package:witibju/util/wit_api_ut.dart';
import 'package:witibju/screens/board/wit_board_write_sc.dart';
import 'package:witibju/screens/common/wit_common_widget.dart';
import 'package:witibju/screens/home/wit_home_theme.dart';

// 게시판 메인
class Board extends StatefulWidget {

  final String bordType;    // CM0X : 커뮤니티, UH0X : 업체후기, JU0X : 자유게시판, GJ0X : 공지사항
  final String bordKey;     // 공용KEY
  final String aptNo;       // 아파트ID
  final String sllrNo;      // 판매자ID
  final String reqNo;       // 신청ID
  final String ctgrId;      // 카테고리ID
  final String creUserId;   // 생성유저ID
  final bool appBarFlag;    // APPBAR 생성 여부
  final String bordTitle;   // 게시판 타이틀

  const Board({super.key, required this.bordType, this.bordKey = ""
    , this.aptNo = "", this.sllrNo = "", this.reqNo = ""
    , this.ctgrId = "", this.creUserId = ""
    , this.bordTitle = "", this.appBarFlag = true, });

  @override
  State<StatefulWidget> createState() {
    return BoardState();
  }
}

class BoardState extends State<Board> {

  // 게시판 리스트
  List<dynamic> boardList = [];
  // 검색 여부
  bool _isSearching = false;
  // 검색 Text 컨트롤러
  TextEditingController _searchController = TextEditingController();
  // 페이징 컨트롤러
  ScrollController _scrollController = ScrollController();
  // 댓글 컨트롤러
  final TextEditingController replyController = TextEditingController();
  // 페이징 로딩 여부
  bool isLoading = false;
  // 페이징 시작 번호
  int currentPage = 1;
  // 페이징 1회 건수
  final int pageSize = 10;
  // 게시판 구분
  String bordTypeGbn = "";
  // 빈데이터 화면 출력여부
  bool emptyDataFlag = false;
  // 세션 정보 조회
  final secureStorage = FlutterSecureStorage();
  // 세션 판매자 번호
  String loginSllrNo = "";

  /**
   * 초기로딩
   */
  @override
  void initState() {
    super.initState();

    // 게시판 타입 앞 2자리 추출
    setState(() {
      bordTypeGbn = widget.bordType.substring(0, 2);
    });
    
    // 스크롤 이벤트 추가
    _scrollController.addListener(_onScroll);

    // 게시판 리스트 조회
    currentPage = 1;
    boardList = [];
    getBoardList();
  }

  /**
   * 화면 생성
   */
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: widget.appBarFlag ? CustomSearchAppBar(
        searchController: _searchController,
        refreshBoardList: refreshBoardList,
        bordTitle: widget.bordTitle,
      ) : null,
      body: Scrollbar(
        child: Container(
          color: WitHomeTheme.wit_white,
          child: BoardListView(
            boardList: boardList,
            refreshBoardList: refreshBoardList,
            scrollController: _scrollController,  // ScrollController 연결
            bordTitle: widget.bordTitle,
            bordTypeGbn: bordTypeGbn,
            loginSllrNo: loginSllrNo,
            emptyDataFlag: emptyDataFlag,
            saveCommentInfo: saveCommentInfo,
            replyController: replyController,
          ),
        ),
      ),
      // FloatingActionButton을 조건에 따라 표시하는 부분
      floatingActionButton: (bordTypeGbn != "UH" && bordTypeGbn != "GJ")
        ? Container( // 조건이 참일 때 표시할 위젯
        width: 60, // 원하는 너비
        height: 60, // 원하는 높이
        child: FloatingActionButton(
          onPressed: () async {
            await Navigator.push(
              context,
              SlideRoute(page: BoardWrite(bordNo: ""
                  , bordType: widget.bordType
                  , bordKey: widget.bordKey
                  , aptNo: widget.aptNo
                  , sllrNo: widget.sllrNo
                  , reqNo: widget.reqNo
                  , ctgrId: widget.ctgrId
                  , creUserId : widget.creUserId)),
            );
            await refreshBoardList();
          },
          backgroundColor: WitHomeTheme.wit_black,
          shape: CircleBorder(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.edit_note,
                color: WitHomeTheme.wit_white,
                size: 35,
              )
            ],
          ),
        ),
      ) : null, // 조건이 거짓일 때 (버튼 숨김)
    );
  }

  // [서비스] 게시판 리스트 조회
  Future<void> getBoardList() async {

    // 로그인 판매자 번호
    loginSllrNo = await secureStorage.read(key: 'sllrNo') ?? "";

    if (isLoading) return; // 이미 로딩 중이면 무시

    setState(() {
      isLoading = true;
    });

    // REST ID
    String restId = "getBoardList";

    // PARAM
    final param = jsonEncode({
      "bordType": widget.bordType,
      //"bordKey": widget.bordKey,
      "aptNo": widget.aptNo,
      "sllrNo": widget.sllrNo,
      "reqNo": widget.reqNo,
      "ctgrId": widget.ctgrId,
      "creUserId": widget.creUserId,
      "searchText" : _searchController.text.trim(),
      "currentPage": (currentPage - 1) * pageSize,
      "pageSize": pageSize,
    });


    // API 호출 (게시판 리스트 조회)
    final _boardList = await sendPostRequest(restId, param);

    // 결과 셋팅
    setState(() {
      boardList.addAll(_boardList);
      currentPage++; // 페이지 증가
      isLoading = false;

      if (boardList.isEmpty) {
        emptyDataFlag = true;
      } else {
        emptyDataFlag = false;
      }
    });
  }

  // [서비스] 게시판 리스트 새로고침
  Future<void> refreshBoardList() async {

    currentPage = 1;
    boardList = [];

    // REST ID
    String restId = "getBoardList";

    // PARAM
    final param = jsonEncode({
      "bordType": widget.bordType,
      //"bordKey": widget.bordKey,
      "aptNo": widget.aptNo,
      "sllrNo": widget.sllrNo,
      "reqNo": widget.reqNo,
      "ctgrId": widget.ctgrId,
      "creUserId": widget.creUserId,
      "searchText" : _searchController.text.trim(),
      "currentPage": (currentPage - 1) * pageSize,
      "pageSize": pageSize,
    });


    // API 호출 (게시판 리스트 조회)
    final _boardList = await sendPostRequest(restId, param);

    // 결과 셋팅
    setState(() {
      boardList.addAll(_boardList);
      currentPage++; // 페이지 증가
      isLoading = false;

      if (boardList.isEmpty) {
        emptyDataFlag = true;
      } else {
        emptyDataFlag = false;
      }
    });

  }

  // 댓글 저장
  Future<void> saveCommentInfo(String bordNo, String cmmtContent) async {

    // 로그인 사번
    String? loginClerkNo = await secureStorage.read(key: 'clerkNo');

    if (cmmtContent.isEmpty) {
      alertDialog.show(context: context, title: "알림", content: "댓글을 입력해주세요.");
      return;
    }

    bool isConfirmed = await ConfimDialog.show(context: context, title: "확인", content: "후기 댓글을 등록 하시겠습니까?");

    if (isConfirmed == true) {

      // 댓글 내용이 비어있지 않은 경우에만 추가
      // REST ID
      String restId = "saveCommentInfo";

      // PARAM
      final param = jsonEncode({
        "bordNo": bordNo,
        "cmmtContent": cmmtContent,
        "creUser": loginClerkNo,
      });

      // API 호출 (댓글 추가)
      final _commentList = await sendPostRequest(restId, param);

      // 팝업 닫기
      setState(() {

        if (_commentList.length > 0) {
          alertDialog.show(context: context, title: "알림", content: "저장 성공 하였습니다.");
        } else {
          alertDialog.show(context: context, title: "알림", content: "저장 실패 하였습니다.");
        }

        refreshBoardList();
      });

    }
  }

  // [이벤트] 스크롤 이벤트
  void _onScroll() {
    // 스크롤이 최하단에 도달하면 추가 데이터 로드
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      getBoardList();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
