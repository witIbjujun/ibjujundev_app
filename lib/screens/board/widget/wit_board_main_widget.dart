import 'package:flutter/material.dart';
import 'package:witibju/screens/home/wit_home_theme.dart';
import 'package:witibju/util/wit_code_ut.dart';
import 'package:witibju/screens/common/wit_common_widget.dart';
import 'package:witibju/screens/board//wit_board_detail_sc.dart';

class CustomSearchAppBar extends StatefulWidget implements PreferredSizeWidget {
  final TextEditingController searchController;
  final Function refreshBoardList;
  final String bordTitle;

  CustomSearchAppBar({
    required this.searchController,
    required this.refreshBoardList,
    required this.bordTitle,
  });

  @override
  _CustomSearchAppBarState createState() => _CustomSearchAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _CustomSearchAppBarState extends State<CustomSearchAppBar> {
  bool _isSearching = false;

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
    });

    if (!_isSearching) {
      widget.searchController.clear();
      widget.refreshBoardList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      iconTheme: IconThemeData(color: WitHomeTheme.wit_white),
      backgroundColor: WitHomeTheme.wit_black,
      title: _isSearching
          ? TextField(
        controller: widget.searchController,
        autofocus: true,
        style: WitHomeTheme.subtitle.copyWith(color: WitHomeTheme.wit_white),
        decoration: InputDecoration(
          hintText: "검색어를 입력해주세요",
          hintStyle: WitHomeTheme.subtitle.copyWith(color: WitHomeTheme.wit_white),
          border: InputBorder.none,
        ),
        onSubmitted: (String value) {
          widget.refreshBoardList();
        },
      )
          : Text(
        (widget.bordTitle.isNotEmpty) ? widget.bordTitle : "게시판",
        style: WitHomeTheme.title.copyWith(color: WitHomeTheme.wit_white),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.search),
          color: WitHomeTheme.wit_white,
          onPressed: () {
            if (_isSearching) {
              if (widget.searchController.text.isEmpty) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('알림', style: WitHomeTheme.title),
                      content: Text('검색어를 입력해 주세요.', style: WitHomeTheme.subtitle),
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
                widget.refreshBoardList();
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
              color: WitHomeTheme.wit_white,
            ),
            onPressed: _toggleSearch, // 검색 취소
          ),
      ],
    );
  }
}

class BoardListView extends StatelessWidget {
  final List<dynamic> boardList;
  final Function refreshBoardList;
  final ScrollController scrollController;

  BoardListView({
    required this.boardList,
    required this.refreshBoardList,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scrollbar(
        thumbVisibility: true,
        controller: scrollController,
        child: RefreshIndicator(
          onRefresh: () async {
            await refreshBoardList();
          },
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              // 게시판 리스트
              if (boardList.isEmpty)
                SliverToBoxAdapter(
                  child: Container(
                    color: WitHomeTheme.wit_white,
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 48,
                            color: WitHomeTheme.wit_lightgray,
                          ),
                          SizedBox(height: 16),
                          Text(
                            "조회된 값이 없습니다",
                            style: WitHomeTheme.headline.copyWith(color: WitHomeTheme.wit_black),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "다른 조건으로 다시 검색해 보세요.",
                            style: WitHomeTheme.title.copyWith(color: WitHomeTheme.wit_black),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final boardInfo = boardList[index];
                      return Container(
                          color: WitHomeTheme.wit_white, // 배경색을 흰색으로 설정
                          child: Column(
                          children: [
                            ListTile(
                              contentPadding: EdgeInsets.fromLTRB(17, 7, 17, 7),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        boardInfo["bordTitle"],
                                                        maxLines: 2,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: WitHomeTheme.subtitle.copyWith(fontWeight: FontWeight.bold),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 10),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  "${boardInfo["creUserNm"]}  |  ${boardInfo["creDateTxt"]}  |  조회 ${boardInfo["bordRdCnt"]}",
                                                  style: WitHomeTheme.caption.copyWith(color: WitHomeTheme.wit_gray),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (boardInfo["imagePath"] != null && boardInfo["imagePath"] != "") ...[
                                    Row(
                                      children: [
                                        SizedBox(width: 10),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: Image.network(
                                            apiUrl + boardInfo["imagePath"],
                                            width: 55,
                                            height: 55,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return SizedBox(width: 0); // 오류 발생 시 빈 컨테이너
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  SizedBox(width: 10), // 이미지 영역 뒤에 추가된 SizedBox
                                  Container(
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                color: WitHomeTheme.wit_extraLightGrey,
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                                              child: Column(
                                                children: [
                                                  Center(
                                                    child: Text("${boardInfo["commentCnt"]}",
                                                      style: WitHomeTheme.subtitle.copyWith(fontWeight: FontWeight.bold),
                                                    ),
                                                  ),
                                                  SizedBox(height: 4),
                                                  Text("댓글",
                                                    style: WitHomeTheme.caption,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  SlideRoute(page: BoardDetail(param: boardInfo)),
                                );
                                await refreshBoardList();
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15.0),
                              child: Container(
                                height: 1,
                                color: WitHomeTheme.wit_extraLightGrey,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: boardList.length,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
