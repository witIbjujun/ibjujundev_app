import 'package:flutter/material.dart';
import 'package:witibju/screens/board/widget/wit_board_replywrite_pop.dart';
import 'package:witibju/screens/home/wit_home_theme.dart';
import 'package:witibju/util/wit_code_ut.dart';
import 'package:witibju/screens/common/wit_common_widget.dart';
import 'package:witibju/screens/board//wit_board_detail_sc.dart';

import '../../common/wit_ImageViewer_sc.dart';
import '../wit_board_report_sc.dart';

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
  final String bordTitle;
  final String bordTypeGbn;

  BoardListView({
    required this.boardList,
    required this.refreshBoardList,
    required this.scrollController,
    required this.bordTitle,
    required this.bordTypeGbn,
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
              if (boardList.isEmpty)...[
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
              ] else ...[
                  if (bordTypeGbn != "UH")...[
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {

                        final boardInfo = boardList[index];

                        String imgStr = boardInfo["imagePath"] ?? "";
                        List<String> imgList = imgStr.split(",").where((s) => s.isNotEmpty).toList();

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
                                                    // 사용자 이름, 날짜, 조회수만 표시 (별 문자열 없음)
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
                                    if (imgList.isNotEmpty) ...[
                                      Row(
                                        children: [
                                          SizedBox(width: 10),
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: Image.network(
                                              apiUrl + imgList.first,
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
                                    if (bordTypeGbn != "UH" && bordTypeGbn != "GJ")...[
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
                                    ]
                                  ],
                                ),
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    SlideRoute(page: BoardDetail(param: boardInfo, bordTitle : bordTitle)),
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
                ] else ... [
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {

                      final boardInfo = boardList[index];
                      int starCount = int.tryParse((boardInfo["stsfRate"]?.toString() ?? '0')) ?? 0;
                      String starString = "";
                      if (starCount != 0) {
                        starString = "    " + ("⭐" * starCount);
                      }

                      String imgStr = boardInfo["imagePath"] ?? "";
                      List<String> imgList = imgStr.split(",").where((s) => s.isNotEmpty).toList();

                      return Padding(
                        padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10), // Container 자체 패딩
                                decoration: BoxDecoration(
                                  color: WitHomeTheme.wit_extraLightGrey,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(width: 5),
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                          image: AssetImage('assets/images/profile1.png'),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded( // Text가 남은 공간을 모두 차지하도록 하여 PopupMenuButton을 오른쪽으로 밉니다.
                                                child: Text(
                                                  // 'bordKeyGbn' 변수를 사용하는 것으로 가정하고 수정했습니다.
                                                  (boardInfo['aptNm'] ?? "") + " - " + (boardInfo['ctgrNm'] ?? ""), // null 처리 추가
                                                  style: WitHomeTheme.title.copyWith(
                                                    fontSize: 14,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ),
                                              if (bordTypeGbn == "UH")
                                                PopupMenuButton<String>(
                                                  icon: Icon(Icons.more_vert, color: WitHomeTheme.wit_gray),
                                                  color: WitHomeTheme.wit_white,
                                                  iconSize: 25.0,
                                                  onSelected: (value) async {
                                                    if (value == "Detail") {

                                                    } else if (value == 'reply') {
                                                      showModalBottomSheet(
                                                        context: context,
                                                        isDismissible: true,
                                                        isScrollControlled: true,
                                                        builder: (context) {
                                                          return Padding(
                                                            padding: MediaQuery.of(context).viewInsets,
                                                            child: Container(
                                                              height: 341,
                                                              child: ReplyWritePopWidget(bordNo: boardInfo["bordNo"]),
                                                            ),
                                                          );
                                                        },
                                                      ).then((result) async {
                                                        refreshBoardList();
                                                      });
                                                    } else if (value == 'report') {
                                                      await Navigator.push(
                                                        context,
                                                        SlideRoute(page: BoardReport(boardInfo: boardInfo)),
                                                      ).then((_) {
                                                        refreshBoardList();
                                                      });
                                                    }
                                                  },
                                                  itemBuilder: (BuildContext context) {
                                                    return [
                                                      PopupMenuItem<String>(
                                                        value: 'Detail',
                                                        child: Text('상세보기', style: WitHomeTheme.subtitle),
                                                      ),
                                                      if(boardInfo['commentCnt'] == 0)...[
                                                        PopupMenuItem<String>(
                                                          value: 'reply',
                                                          child: Text('댓글작성', style: WitHomeTheme.subtitle),
                                                        ),
                                                      ],
                                                      PopupMenuItem<String>(
                                                        value: 'report',
                                                        child: Text('신고하기', style: WitHomeTheme.subtitle),
                                                      ),
                                                    ];
                                                  },
                                                ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                boardInfo['creUserNm'] + "    " + boardInfo['creDateTxt'],
                                                style: WitHomeTheme.subtitle.copyWith(fontSize: 14),
                                              ),
                                              Text(
                                                "${starString}",
                                                style: WitHomeTheme.title.copyWith(fontSize: 18),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 10),

                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            boardInfo['bordContent'].trim() ?? '',
                                            style: WitHomeTheme.subtitle.copyWith(fontSize: 14),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (imgList.isNotEmpty) ...[
                                      SizedBox(height: 10),
                                      Container(
                                        height: 80,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: imgList.length,
                                          itemBuilder: (context, index) {
                                            return GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  SlideRoute(page: ImageViewer(
                                                    imageUrls: imgList.map((item) => apiUrl + imgList[index]).toList(),
                                                    initialIndex: index,
                                                  )),
                                                );
                                              },
                                              child: Container(
                                                width: 80,
                                                height: 80,
                                                margin: EdgeInsets.only(right: 8),
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(8),
                                                  image: DecorationImage(
                                                    image: NetworkImage(apiUrl + imgList[index]),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                    SizedBox(height: 10),

                                    if(boardInfo['commentCnt'] > 0)...[
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: WitHomeTheme.wit_extraLightGrey,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  "사장님 - ",
                                                  style: WitHomeTheme.title,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    boardInfo['cmmtcreDateTxt'] ?? "",
                                                    style: WitHomeTheme.subtitle.copyWith(color: WitHomeTheme.wit_gray),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 10),
                                            Row(
                                              children: [
                                                Text(
                                                  boardInfo['cmmtContent'].trim(),
                                                  style: WitHomeTheme.subtitle.copyWith(fontSize: 14),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                      childCount: boardList.length,
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
