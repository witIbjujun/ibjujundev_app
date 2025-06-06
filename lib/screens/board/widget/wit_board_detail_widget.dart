import 'package:flutter/material.dart';
import 'package:witibju/util/wit_code_ut.dart';
import 'package:witibju/screens/common/wit_ImageViewer_sc.dart';
import 'package:witibju/screens/common/wit_common_widget.dart';
import 'package:witibju/screens/board/wit_board_write_sc.dart';
import 'package:witibju/screens/home/wit_home_theme.dart';

import '../../home/widgets/wit_home_widgets.dart';
import '../wit_board_report_sc.dart';

// 타이틀 및 수정/삭제 영역
class TitleAndMenu extends StatelessWidget {
  final Map<String, dynamic> boardDetailInfo;
  final List<dynamic> boardDetailImageList;
  final Function endBoardInfo;
  final BuildContext context;
  final String loginClerkNo;
  final Function callBack;
  final String bordKeyGbn;

  TitleAndMenu({
    required this.boardDetailInfo,
    required this.boardDetailImageList,
    required this.endBoardInfo,
    required this.context,
    required String this.loginClerkNo,
    required this.callBack,
    required this.bordKeyGbn,
  });

  @override
  Widget build(BuildContext context) {

    print(bordKeyGbn);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            boardDetailInfo["bordTitle"] ?? "",
            style: WitHomeTheme.title,
          ),
        ),
        if (bordKeyGbn != "GJ") ...[
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: WitHomeTheme.wit_gray, size: 20,),
            color: WitHomeTheme.wit_white,
            onSelected: (value) async {
              if (value == 'edit') {
                await Navigator.push(
                  context,
                  SlideRoute(page: BoardWrite(
                    boardInfo: boardDetailInfo,
                    imageList: boardDetailImageList,
                    bordNo: boardDetailInfo["bordNo"] ?? "",
                    bordType: boardDetailInfo["bordType"],
                    bordKey: boardDetailInfo["bordKey"] ?? "",
                    aptNo: boardDetailInfo["aptNo"] ?? "",
                    sllrNo: boardDetailInfo["sllrNo"] ?? "",
                    reqNo: boardDetailInfo["reqNo"] ?? "",
                    ctgrId: boardDetailInfo["ctgrId"] ?? "",
                    creUserId: boardDetailInfo["creUser"] ?? "",
                  )),
                ).then((_) {
                  callBack();
                });
              } else if (value == 'delete') {
                bool isConfirmed = await ConfimDialog.show(context: context, title: "확인", content: "삭제하시겠습니까?");
                if (isConfirmed == true) {
                  endBoardInfo();
                }

              } else if (value == 'report') {

                if (boardDetailInfo["reportYn"] == "Y") {
                  alertDialog.show(context: context, title: "알림", content: "이미 신고한 게시글입니다.");
                  return;
                }

                await Navigator.push(
                  context,
                  SlideRoute(page: BoardReport(boardInfo: boardDetailInfo)),
                );
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                if (boardDetailInfo["creUser"] == loginClerkNo && (bordKeyGbn != "UH" && bordKeyGbn != "GJ"))...[
                  PopupMenuItem<String>(
                    value: 'edit',
                    child: Row( // 아이콘과 텍스트를 가로로 배치하기 위해 Row 사용
                      children: [
                        Icon(
                          Icons.edit_note_rounded, // 신고 아이콘
                          color: WitHomeTheme.wit_lightBlue, // 아이콘 색상
                          size: 20, // 아이콘 크기 (조절 가능)
                        ),
                        SizedBox(width: 8), // 아이콘과 텍스트 사이 간격
                        Text(
                          '수정하기',
                          style: WitHomeTheme.caption, // 텍스트 스타일
                        ),
                      ],
                    ),
                  ),
                ],
                if (boardDetailInfo["creUser"] == loginClerkNo) ...[
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Row( // 아이콘과 텍스트를 가로로 배치하기 위해 Row 사용
                      children: [
                        Icon(
                          Icons.delete, // 신고 아이콘
                          color: WitHomeTheme.wit_lightBlue, // 아이콘 색상
                          size: 20, // 아이콘 크기 (조절 가능)
                        ),
                        SizedBox(width: 8), // 아이콘과 텍스트 사이 간격
                        Text(
                          '삭제하기',
                          style: WitHomeTheme.caption, // 텍스트 스타일
                        ),
                      ],
                    ),
                  ),
                ],
                if (boardDetailInfo["creUser"] != loginClerkNo) ...[
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
                ]
              ];
            },
          ),
        ] else ...[
          Row(
            children: [
              SizedBox(width: 0.0, height: 50.0)
            ],
          )
        ],
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
        CircleAvatar(
            radius: 20,
            backgroundImage: proFlieImage.getImageProvider(boardDetailInfo["profileImg"] ?? ""),
        ),
        SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${boardDetailInfo["creUserNm"] ?? "익명"}",
              style: WitHomeTheme.subtitle,
            ),
            SizedBox(height: 3),
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
                radius: 20,
                backgroundImage: proFlieImage.getImageProvider(commentList[index]["profileImg"] ?? ""),
              ),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      commentList[index]["cmmtContent"] ?? "",
                      style: WitHomeTheme.subtitle,
                    ),
                    SizedBox(height: 4),
                    Text(
                      (commentList[index]["creUserNm"] ?? "익명") + "  " + (commentList[index]["creDateTxt"] ?? ""),
                      style: WitHomeTheme.caption.copyWith(color: WitHomeTheme.wit_gray),
                    ),
                  ],
                ),
              ),
              if (commentList[index]["creUser"] == loginClerkNo)...[
                IconButton(
                  icon: Icon(Icons.delete, color: WitHomeTheme.wit_lightBlue), // 휴지통 아이콘
                  tooltip: "삭제하기",
                  onPressed: () async {
                    bool isConfirmed = await ConfimDialog.show(context: context, title: "확인", content: "댓글을 삭제하시겠습니까?");
                    if (isConfirmed == true) {
                      endCommentInfo(commentList[index]);
                    }
                  },
                ),
              ] else ...[
                IconButton(
                  icon: Icon(Icons.report_rounded, color: WitHomeTheme.wit_lightCoral),
                  tooltip: "신고하기",
                  onPressed: () async {
                    
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
            maxLength: 100,
            decoration: InputDecoration(
              hintText: isEmpty ? "첫 댓글을 남겨보세요" : "댓글을 남겨보세요",
              hintStyle: WitHomeTheme.title.copyWith(fontWeight: FontWeight.normal),
              border: InputBorder.none,
              filled: true,
              fillColor: WitHomeTheme.wit_white,
              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
              counterText: "",
            ),
          ),
        ),
        SizedBox(width: 5),
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