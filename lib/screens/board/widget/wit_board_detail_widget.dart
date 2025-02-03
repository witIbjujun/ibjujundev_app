import 'package:flutter/material.dart';
import 'package:witibju/util/wit_code_ut.dart';
import 'package:witibju/screens/common/wit_ImageViewer_sc.dart';
import 'package:witibju/screens/common/wit_common_widget.dart';
import 'package:witibju/screens/board/wit_board_write_sc.dart';

// 타이틀 및 수정/삭제 영역
class TitleAndMenu extends StatelessWidget {
  final Map<String, dynamic> boardDetailInfo;
  final List<dynamic> boardDetailImageList;
  final BuildContext context;

  TitleAndMenu({
    required this.boardDetailInfo,
    required this.boardDetailImageList,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            boardDetailInfo["bordTitle"] ?? "",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: Colors.black),
          color: Colors.white,
          onSelected: (value) {
            if (value == 'edit') {
              Navigator.push(
                context,
                SlideRoute(page: BoardWrite(
                  boardInfo: boardDetailInfo,
                  imageList: boardDetailImageList,
                  bordNo: boardDetailInfo["bordNo"],
                  bordType: boardDetailInfo["bordType"],
                )),
              );
            } else if (value == 'delete') {
              _showConfirmDialog(context, '삭제하시겠습니까?');
            }
          },
          itemBuilder: (BuildContext context) {
            return [
              PopupMenuItem<String>(
                value: 'edit',
                child: Text('수정하기'),
              ),
              PopupMenuItem<String>(
                value: 'delete',
                child: Text('삭제하기'),
              ),
            ];
          },
        ),
      ],
    );
  }

  void _showConfirmDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("확인"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
              child: Text("취소"),
            ),
            TextButton(
              onPressed: () {
                // 삭제 로직 구현
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
              child: Text("확인"),
            ),
          ],
        );
      },
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
        CircleAvatar(radius: 20),
        SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${boardDetailInfo["creUser"] ?? "익명"}",
              style: TextStyle(fontSize: 14),
            ),
            Row(
              children: [
                Text(
                  '${boardDetailInfo["creDateTxt"] ?? ""}',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                SizedBox(width: 8),
                Text(
                  '조회 ${boardDetailInfo["bordRdCnt"] ?? 0}',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
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

  ContentDisplay({
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minHeight: 300,
      ),
      child: Text(content,
        style: TextStyle(fontSize: 16),
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
      height: 120,
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
              width: 120,
              height: 120,
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
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        Text(
          count.toString(),
          style: TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}

// 댓글 리스트 영역
class CommentList extends StatelessWidget {
  final List<dynamic> commentList;

  CommentList({
    required this.commentList,
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
                // backgroundImage: NetworkImage(""), // 이미지 URL
              ),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 4),
                    Text(
                      commentList[index]["cmmtContent"] ?? "",
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 4),
                    Text(
                      (commentList[index]["creUser"] ?? "") + " | " + (commentList[index]["creDateTxt"] ?? ""),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
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
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.blue,
          ),
          child: IconButton(
            icon: Icon(Icons.send, size: 24, color: Colors.white),
            onPressed: () => saveCommentInfo(),
            tooltip: '댓글 보내기',
          ),
        ),
      ],
    );
  }
}