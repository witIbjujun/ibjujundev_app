import 'package:flutter/material.dart';
import 'package:witibju/util/wit_code_ut.dart';
import 'package:witibju/screens/common/wit_ImageViewer_sc.dart';
import 'package:witibju/screens/common/wit_common_widget.dart';
import 'package:witibju/screens/board/wit_board_write_sc.dart';
import 'package:witibju/screens/home/wit_home_theme.dart';

import '../wit_board_report_sc.dart';

// 타이틀 및 수정/삭제 영역
class TitleAndMenu extends StatelessWidget {
  final Map<String, dynamic> boardDetailInfo;
  final List<dynamic> boardDetailImageList;
  final Function endBoardInfo;
  final BuildContext context;
  final String loginClerkNo;
  final Function callBack;

  TitleAndMenu({
    required this.boardDetailInfo,
    required this.boardDetailImageList,
    required this.endBoardInfo,
    required this.context,
    required String this.loginClerkNo,
    required this.callBack,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            boardDetailInfo["bordTitle"] ?? "",
            style: WitHomeTheme.title,
          ),
        ),
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: WitHomeTheme.wit_gray),
          color: WitHomeTheme.wit_white,
          onSelected: (value) async {
            if (value == 'edit') {
              await Navigator.push(
                context,
                SlideRoute(page: BoardWrite(
                  boardInfo: boardDetailInfo,
                  imageList: boardDetailImageList,
                  bordNo: boardDetailInfo["bordNo"],
                  bordType: boardDetailInfo["bordType"],
                )),
              ).then((_) {
                callBack();
              });
            } else if (value == 'delete') {
              ConfimDialog.show(context,
                  "삭제",
                  "삭제하시겠습니까?",
                  () async {
                    endBoardInfo();
                  }
              );
            } else if (value == 'report') {

              if (boardDetailInfo["reportYn"] == "Y") {
                alertDialog.show(context, "이미 신고한 게시글입니다.");
                return;
              }

              await Navigator.push(
                context,
                SlideRoute(page: BoardReport(boardInfo: boardDetailInfo)),
              ).then((_) {
                callBack();
              });
            }
          },
          itemBuilder: (BuildContext context) {
            return [
              if (boardDetailInfo["creUser"] == loginClerkNo)...[
                PopupMenuItem<String>(
                  value: 'edit',
                  child: Text('수정하기',
                    style: WitHomeTheme.subtitle,
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Text('삭제하기',
                    style: WitHomeTheme.subtitle,
                  ),
                ),
              ]
              else ...[
                PopupMenuItem<String>(
                  value: 'report',
                  child: Text('신고하기',
                    style: WitHomeTheme.subtitle,
                  ),
                ),
              ]
            ];
          },
        ),
      ],
    );
  }
}

// 유저 영역
class UserInfo extends StatelessWidget {
  final Map<String, dynamic> boardDetailInfo;

  UserInfo({
    required this.boardDetailInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(radius: 20, backgroundColor: WitHomeTheme.wit_lightBlue),
        SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${boardDetailInfo["creUserNm"] ?? "익명"}",
              style: WitHomeTheme.subtitle,
            ),
            Row(
              children: [
                Text(
                  '${boardDetailInfo["creDateTxt"] ?? ""}',
                  style: WitHomeTheme.caption.copyWith(color: WitHomeTheme.wit_gray),
                ),
                SizedBox(width: 8),
                Text(
                  '조회 ${boardDetailInfo["bordRdCnt"] ?? 0}',
                  style: WitHomeTheme.caption.copyWith(color: WitHomeTheme.wit_gray),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

// 내용 영역
class ContentDisplay extends StatelessWidget {
  final String content;
  final int imgCnt;

  ContentDisplay({
    required this.content,
    required this.imgCnt,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minHeight: imgCnt == 0 ? 540 : 340,
      ),
      child: Text(content,
        style: WitHomeTheme.subtitle,
      ),
    );
  }
}

// 이미지 리스트 영역
class ImageListDisplay extends StatelessWidget {
  final List<dynamic> boardDetailImageList;

  ImageListDisplay({
    required this.boardDetailImageList,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: boardDetailImageList.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                SlideRoute(page: ImageViewer(
                  imageUrls: boardDetailImageList.map((item) => apiUrl + item["imagePath"]).toList(),
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
                  image: NetworkImage(apiUrl + boardDetailImageList[index]["imagePath"]),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// 댓글 숫자 영역
class CommentCount extends StatelessWidget {
  final int count;

  CommentCount({
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          "댓글 ",
          style: WitHomeTheme.subtitle,
        ),
        Text(
          count.toString(),
          style: WitHomeTheme.subtitle,
        ),
      ],
    );
  }
}

// 댓글 리스트 영역
class CommentList extends StatelessWidget {
  final List<dynamic> commentList;
  final String loginClerkNo;
  final Function endCommentInfo;

  CommentList({
    required this.commentList,
    required this.loginClerkNo,
    required this.endCommentInfo,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: commentList.length,
      itemBuilder: (context, index) {
        return ListTile(
          contentPadding: EdgeInsets.all(0),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20, backgroundColor: WitHomeTheme.wit_lightBlue
              ),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 4),
                    Text(
                      commentList[index]["cmmtContent"] ?? "",
                      style: WitHomeTheme.subtitle,
                    ),
                    SizedBox(height: 4),
                    Text(
                      (commentList[index]["creUserNm"] ?? "") + " | " + (commentList[index]["creDateTxt"] ?? ""),
                      style: WitHomeTheme.caption.copyWith(color: WitHomeTheme.wit_gray),
                    ),
                  ],
                ),
              ),
              if (commentList[index]["creUser"] == loginClerkNo)...[
                IconButton(
                  icon: Icon(Icons.delete, color: WitHomeTheme.wit_gray), // 휴지통 아이콘
                  onPressed: () {
                    ConfimDialog.show(context,
                        "삭제",
                        "선택하신 댓글을 삭제하시겠습니까?",
                        () async {
                          endCommentInfo(commentList[index]);
                        }
                    );
                  },
                ),
              ]
            ],
          ),
        );
      },
    );
  }
}

// 댓글 입력 영역
class CommentInput extends StatelessWidget {
  final TextEditingController commentController;
  final Function saveCommentInfo;
  final bool isEmpty;

  CommentInput({
    required this.commentController,
    required this.saveCommentInfo,
    required this.isEmpty,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: commentController,
            decoration: InputDecoration(
              hintText: isEmpty ? "첫 댓글을 남겨보세요" : "댓글을 남겨보세요",
              border: InputBorder.none,
              filled: true,
              fillColor: WitHomeTheme.wit_white,
              contentPadding: EdgeInsets.symmetric(vertical: 13, horizontal: 16),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: WitHomeTheme.wit_gray,
            borderRadius: BorderRadius.circular(10),
          ),
          child: IconButton(
            icon: Icon(Icons.send, size: 25, color: WitHomeTheme.wit_white),
            onPressed: () => saveCommentInfo(),
            tooltip: '댓글 보내기',
          ),
        ),
      ],
    );
  }
}