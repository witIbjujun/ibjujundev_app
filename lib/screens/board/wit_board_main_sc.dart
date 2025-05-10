import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:witibju/screens/board/widget/wit_board_main_widget.dart';
import 'package:witibju/util/wit_api_ut.dart';
import 'package:witibju/screens/board/wit_board_write_sc.dart';
import 'package:witibju/screens/common/wit_common_widget.dart';
import 'package:witibju/screens/home/wit_home_theme.dart';

// 게시판 메인
class Board extends StatefulWidget {

  final String? bordType;   // C00X : 커뮤니티, U00X : 업체후기, J00X : 자유게시판, G00X : 공지사항
  final String? bordKey;    // 아파트 번호, 판매자 번호등 고유 번호
  final String bordTitle;
  final bool appBarFlag;

  const Board(this.bordType, this.bordKey, {this.bordTitle = "", this.appBarFlag = true, super.key});

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
  // 페이징 로딩 여부
  bool isLoading = false;
  // 페이징 시작 번호
  int currentPage = 1;
  // 페이징 1회 건수
  final int pageSize = 10;

  /**
   * 초기로딩
   */
  @override
  void initState() {
    super.initState();

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
          ),
        ),
      ),
      floatingActionButton: Container(
        width: 60, // 원하는 너비
        height: 60, // 원하는 높이
        child: FloatingActionButton(
          onPressed: () async {
            await Navigator.push(
              context,
              SlideRoute(page: BoardWrite(bordNo: "", bordType: widget.bordType, bordKey: widget.bordKey)),
            );
            await refreshBoardList();
          },
          backgroundColor: WitHomeTheme.wit_black,
          shape: CircleBorder(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add,
                color: WitHomeTheme.wit_white,
                size: 35,
              )
            ],
          ),
        ),
      ),
    );
  }

  // [서비스] 게시판 리스트 조회
  Future<void> getBoardList() async {

    if (isLoading) return; // 이미 로딩 중이면 무시

    setState(() {
      isLoading = true;
    });

    // REST ID
    String restId = "getBoardList";

    // PARAM
    final param = jsonEncode({
      "bordType": widget.bordType,
      "bordKey": widget.bordKey,
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
      "bordKey": widget.bordKey,
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
    });

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
