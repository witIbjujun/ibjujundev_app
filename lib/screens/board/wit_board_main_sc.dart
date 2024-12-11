import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:witibju/util/wit_api_ut.dart';
import 'package:witibju/util/wit_code_ut.dart';
import 'package:witibju/screens/board/wit_board_detail_sc.dart';
import 'package:witibju/screens/board/wit_board_write_sc.dart';

// 게시판 메인
class Board extends StatefulWidget {

  final int? bordNo;
  final String? bordType;

  const Board(this.bordNo, this.bordType, {super.key});

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
      // 화면 안전 영역
      body: SafeArea(
        child: Scrollbar(
        thumbVisibility: true, // 스크롤바를 항상 보이게 설정
        // 사용자 정의 스크롤뷰
        child: RefreshIndicator(
          // 스와이프시 새로고침
          onRefresh: refreshBoardList,
            child: CustomScrollView(
              // 스크롤 컨트롤러 추가
              controller: _scrollController,
              // slivers : 스크롤시 헤드 사라지고 나오게 하는 객체
              slivers: [
                // Appbar 정의
                SliverAppBar(
                  floating: true,
                  snap: true,
                  expandedHeight: 40.0,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      color: Colors.blue,
                    ),
                  ),
                  title: _isSearching ?
                  // 검색 INPUT
                  TextField(
                    controller: _searchController,
                    autofocus: true,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "검색...",
                      hintStyle: TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                    ),
                    // 엔터시 검색
                    onSubmitted: (String value) {
                      refreshBoardList();
                    },
                  // TITLE TEXT
                  ) : Text(
                    "자유게시판",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24, // 글자 크기 증가
                      letterSpacing: 1.5,
                      color: Colors.white,
                    ),
                  ),
                  // 이벤트
                  actions: [
                    // 돋보기 버튼
                    IconButton(
                      icon: Icon(
                        Icons.search,
                        color: Colors.white,
                      ),
                      // 돋보기 버튼 이벤트
                      onPressed: () {
                        if (_isSearching) {
                          if (_searchController.text.isEmpty) {
                            // 검색어가 비어있을 경우 알림창 표시
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('알림',
                                    style: TextStyle(
                                      fontSize: 18,
                                    )
                                  ),
                                  content: Text('검색어를 입력해 주세요.',
                                      style: TextStyle(
                                        fontSize: 14,
                                      )
                                  ),
                                  actions: [
                                    TextButton(
                                      child: Text('확인'),
                                      onPressed: () {
                                        Navigator.of(context).pop(); // 알림창 닫기
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            // 검색 버튼 클릭 시 동작
                            refreshBoardList();
                          }
                        } else {
                          // 검색 모드로 전환
                          _toggleSearch();
                        }
                      },
                    ),
                    if (_isSearching)
                      IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: Colors.white,
                        ),
                        onPressed: _toggleSearch,
                      ),
                  ],
                ),
                // 게시판 리스트
                if (boardList.isEmpty) // 리스트가 비어 있을 때
                  SliverToBoxAdapter(
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.5, // 화면의 절반 높이
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.info_outline, // 정보 아이콘 추가
                              size: 48,
                              color: Colors.grey[600],
                            ),
                            SizedBox(height: 16), // 아이콘과 텍스트 사이의 간격
                            Text(
                              "조회된 값이 없습니다",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            SizedBox(height: 8), // 텍스트 아래 간격
                            Text(
                              "다른 조건으로 다시 검색해 보세요.",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else // 리스트에 아이템이 있을 때
                  SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                      final boardInfo = boardList[index];
                      return Column(
                        children: [
                          ListTile(
                            title: Row(
                              children: [
                                // 이미지가 존재할 경우에만 표시
                                if (boardInfo["imagePath"] != null) ...[
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey.withOpacity(0.5), // 연한 회색 테두리
                                        width: 1, // 테두리 두께
                                      ),
                                      borderRadius: BorderRadius.circular(4), // 모서리 둥글게
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4), // 이미지 모서리 둥글게
                                      child: Image.network(
                                        apiUrl + boardInfo["imagePath"],
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 15), // 이미지와 텍스트 사이 여백
                                ],

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Row(
                                              children: [
                                                // 오늘 작성한 글인지 확인
                                                if (isToday(boardInfo["creDate"])) // 오늘 작성된 글일 경우
                                                  Container(
                                                    width: 18, // 원의 너비
                                                    height: 18, // 원의 높이
                                                    decoration: BoxDecoration(
                                                      color: Colors.transparent, // 내부 투명
                                                      shape: BoxShape.circle, // 원형
                                                      border: Border.all(color: Colors.red, width: 1), // 빨간색 테두리
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        'N', // N 텍스트
                                                        style: TextStyle(
                                                          color: Colors.red, // N 텍스트 빨간색
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 11, // N 텍스트 크기 조정
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                if (isToday(boardInfo["creDate"]))
                                                SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    boardInfo["bordTitle"], // 제목
                                                    maxLines: 1, // 최대 한 줄
                                                    overflow: TextOverflow.ellipsis, // 넘칠 경우 ... 처리
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // 댓글 수 표시 부분
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.grey[200], // 회색 배경색
                                              borderRadius: BorderRadius.circular(8), // 모서리 둥글게
                                            ),
                                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5), // 패딩 설정
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min, // 최소 크기로 설정
                                              children: [
                                                Center(
                                                  child: Text(
                                                    "${boardInfo["commentCnt"]}", // 댓글 수
                                                    style: TextStyle(
                                                      color: Colors.black, // 텍스트 색상
                                                      fontSize: 16, // 숫자 크기 증가
                                                      fontWeight: FontWeight.bold, // 볼드체
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: 4), // 숫자와 "댓글" 사이의 간격
                                                Text(
                                                  "댓글", // "댓글" 텍스트
                                                  style: TextStyle(
                                                    color: Colors.grey, // 텍스트 색상
                                                    fontSize: 12, // 텍스트 크기
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                "${boardInfo["creUser"]}  |  ${boardInfo["creDateTxt"]}  |  조회 ${boardInfo["bordRdCnt"]}",
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.of(context).push(
                                PageRouteBuilder(
                                  pageBuilder: (context, animation, secondaryAnimation) => BoardDetail(param: boardInfo),
                                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    );
                                  },
                                ),
                              ).then((_) {
                                refreshBoardList();
                              });
                            },
                          ),
                          // 각 리스트 항목 사이에 줄 추가
                          Divider(),
                        ],
                      );
                    },
                    childCount: boardList.length,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Container(
        width: 50.0,
        height: 50.0,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => BoardWrite(bordNo: widget.bordNo, bordType: widget.bordType),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
              ),
            ).then((result) {
              refreshBoardList();
            });
          },
          child: Icon(Icons.add),
          backgroundColor: Colors.red[100],
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
      "bordNo": widget.bordNo,
      "bordType": widget.bordType,
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
      "bordNo": widget.bordNo,
      "bordType": widget.bordType,
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

  // [이벤트] 게시판 검색 토글 이벤트
  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
    });

    if (!_isSearching) {
      _searchController.clear();
      refreshBoardList();
    }
  }

  // [유틸] 오늘 날짜인지 확인하는 함수
  bool isToday(String dateString) {
    DateTime createdDate = DateTime.parse(dateString); // 글 작성 날짜를 DateTime으로 변환
    DateTime today = DateTime.now();
    return createdDate.year == today.year && createdDate.month == today.month && createdDate.day == today.day;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
