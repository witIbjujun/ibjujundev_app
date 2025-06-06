import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:witibju/screens/board/widget/wit_board_replywrite_pop.dart';
import 'package:witibju/screens/home/wit_home_theme.dart';
import 'package:witibju/util/wit_code_ut.dart';
import 'package:witibju/screens/common/wit_common_widget.dart';
import 'package:witibju/screens/board//wit_board_detail_sc.dart';

import '../../common/wit_ImageViewer_sc.dart';
import '../../home/widgets/wit_home_widgets.dart';
import '../../seller/wit_seller_estimaterequest_detail_sc.dart';
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
  final String loginSllrNo;
  final bool emptyDataFlag;
  final Function saveCommentInfo;
  final TextEditingController replyController;

  BoardListView({
    required this.boardList,
    required this.refreshBoardList,
    required this.scrollController,
    required this.bordTitle,
    required this.bordTypeGbn,
    required this.loginSllrNo,
    required this.emptyDataFlag,
    required this.saveCommentInfo,
    required this.replyController,
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
              if (emptyDataFlag == true)...[
                SliverToBoxAdapter(
                  child: Container(
                    color: WitHomeTheme.wit_white,
                    height: MediaQuery.of(context).size.height * 0.5,
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
                              style: WitHomeTheme.title.copyWith(color: WitHomeTheme.wit_black),
                            ),
                          ],
                        ),
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
                                contentPadding: EdgeInsets.fromLTRB(15, 1, 15, 1),
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
                                            SizedBox(height: 7),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    // 사용자 이름, 날짜, 조회수만 표시 (별 문자열 없음)
                                                    "${boardInfo["creUserNm"] ?? "익명"}  |  ${boardInfo["creDateTxt"]}  |  조회 ${boardInfo["bordRdCnt"]}",
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
                        starString = ("⭐" * starCount);
                      }

                      String imgStr = boardInfo["imagePath"] ?? "";
                      List<String> imgList = imgStr.split(",").where((s) => s.isNotEmpty).toList();

                      return Padding(
                        padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                        child: Container(
                          padding: const EdgeInsets.all(0),
                          decoration: BoxDecoration(
                            color: WitHomeTheme.wit_white,
                            borderRadius: BorderRadius.circular(0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10), // Container 자체 패딩
                                decoration: BoxDecoration(
                                  color: WitHomeTheme.wit_white,
                                  borderRadius: BorderRadius.circular(0),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 20,
                                                backgroundImage: proFlieImage.getImageProvider(boardInfo["profileImg"] ?? ""),
                                              ),
                                              SizedBox(width: 10),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      (boardInfo['aptNm'] ?? "") + " - " + (boardInfo['ctgrNm'] ?? ""),
                                                      style: WitHomeTheme.subtitle.copyWith(
                                                          overflow: TextOverflow.ellipsis,
                                                          fontWeight: FontWeight.bold
                                                      ),
                                                    ),
                                                    SizedBox(height: 5),
                                                    Text(
                                                      boardInfo['creUserNm'] + "    " + boardInfo['creDateTxt'] + "    " + "${starString}",
                                                      style: WitHomeTheme.caption,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              if (bordTypeGbn == "UH")
                                                PopupMenuButton<String>(
                                                  icon: Icon(Icons.more_vert, color: WitHomeTheme.wit_gray),
                                                  color: WitHomeTheme.wit_white,
                                                  iconSize: 20.0,
                                                  onSelected: (value) async {
                                                    if (value == "Detail") {
                                                      await Navigator.push(
                                                        context,
                                                        SlideRoute(page: EstimateRequestDetail(estNo : boardInfo["reqNo"], seq: "1", )),
                                                      );
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
                                                      if(boardInfo["sllrNo"] == loginSllrNo)...[
                                                        PopupMenuItem<String>(
                                                          value: 'Detail',
                                                          child: Row( // 아이콘과 텍스트를 가로로 배치하기 위해 Row 사용
                                                            children: [
                                                              Icon(
                                                                Icons.sticky_note_2_outlined, // 신고 아이콘
                                                                color: WitHomeTheme.wit_lightGreen, // 아이콘 색상
                                                                size: 20, // 아이콘 크기 (조절 가능)
                                                              ),
                                                              SizedBox(width: 8), // 아이콘과 텍스트 사이 간격
                                                              Text(
                                                                '상세보기',
                                                                style: WitHomeTheme.caption, // 텍스트 스타일
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                      if(boardInfo["sllrNo"] == loginSllrNo)...[
                                                        PopupMenuItem<String>(
                                                          value: 'report',
                                                          child: Row( // 아이콘과 텍스트를 가로로 배치하기 위해 Row 사용
                                                            children: [
                                                              Icon(
                                                                Icons.report_rounded, // 신고 아이콘
                                                                color: WitHomeTheme.wit_lightCoral, // 아이콘 색상
                                                                size: 20, // 아이콘 크기 (조절 가능)
                                                              ),
                                                              SizedBox(width: 8), // 아이콘과 텍스트 사이 간격
                                                              Text(
                                                                '신고하기',
                                                                style: WitHomeTheme.caption, // 텍스트 스타일
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ];
                                                  },
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      constraints: BoxConstraints(
                                        minHeight: 70,
                                      ),
                                      child: Text(
                                        boardInfo['bordContent'].trim() ?? '',
                                        style: WitHomeTheme.caption,
                                      ),
                                    ),
                                    if (imgList.isNotEmpty) ...[
                                      SizedBox(height: 10),
                                      Container(
                                        height: 55,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: imgList.length,
                                          itemBuilder: (context, index) {
                                            return GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  SlideRoute(page: ImageViewer(
                                                    imageUrls: imgList.map((item) => apiUrl + item).toList(),
                                                    initialIndex: index,
                                                  )),
                                                );
                                              },
                                              child: Container(
                                                width: 55,
                                                height: 55,
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
                                    if (boardInfo['commentCnt'] > 0)...[
                                      SizedBox(height: 5),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                "사장님 - ",
                                                style: WitHomeTheme.subtitle.copyWith(fontWeight: FontWeight.bold),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  boardInfo['cmmtcreDateTxt'] ?? "",
                                                  style: WitHomeTheme.caption.copyWith(color: WitHomeTheme.wit_gray),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 10),
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  boardInfo['cmmtContent'].trim(),
                                                  style: WitHomeTheme.caption,
                                                  softWrap: true,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                    ] else if (boardInfo["sllrNo"] == loginSllrNo)... [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: WitHomeTheme.wit_white, // 배경색
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(5, 2, 0, 0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  Expanded(
                                                    child: TextField(
                                                      controller: replyController,
                                                      decoration: InputDecoration(
                                                        hintText: "후기 댓글을 입력해주세요",
                                                        hintStyle: WitHomeTheme.subtitle.copyWith(color: WitHomeTheme.wit_gray),
                                                        border: InputBorder.none,
                                                        contentPadding: EdgeInsets.symmetric(vertical: 12.0),
                                                        counterText: "",
                                                      ),
                                                      maxLength: 1000,
                                                      maxLengthEnforcement: MaxLengthEnforcement.enforced,
                                                      style: WitHomeTheme.subtitle,
                                                      maxLines: null,
                                                    ),
                                                  ),
                                                  TextButton(
                                                    style: TextButton.styleFrom(
                                                      backgroundColor: WitHomeTheme.wit_lightBlue,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(5),
                                                      ),
                                                      padding: EdgeInsets.symmetric(horizontal: 15),
                                                      minimumSize: Size(0, 40),
                                                    ),
                                                    onPressed: () async {
                                                      saveCommentInfo(boardInfo['bordNo'], replyController.text);
                                                    },
                                                    child: Text(
                                                      "등록",
                                                      style: WitHomeTheme.subtitle.copyWith(fontWeight: FontWeight.bold, color: WitHomeTheme.white),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              Container( // 추가하려는 구분선 부분 시작
                                height: 1,
                                color: WitHomeTheme.wit_lightgray,
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
