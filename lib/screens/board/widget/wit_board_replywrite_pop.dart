import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../util/wit_api_ut.dart';
import '../../common/wit_common_widget.dart';
import '../../home/wit_home_theme.dart';

/**
 * 업체 후기 댓글 작성 팝업
 */
class ReplyWritePopWidget extends StatefulWidget {

  final String bordNo;    // 게시판 번호

  // 생성자
  const ReplyWritePopWidget({required this.bordNo});

  @override
  _ReplyWritePopWidgetState createState() => _ReplyWritePopWidgetState();
  
}

class _ReplyWritePopWidgetState extends State<ReplyWritePopWidget> {

  // 세션 스토리지
  final secureStorage = FlutterSecureStorage();
  
  // 댓글 컨트롤러
  final TextEditingController replyController = TextEditingController();
  
  @override
  void initState() {

  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Column(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  height: 60,
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      color: WitHomeTheme.wit_white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 3, // 막대의 두께
                          width: 40, // 막대의 길이
                          color: WitHomeTheme.wit_lightgray, // 막대 색상
                        ),
                        SizedBox(height: 15), // 아이콘과 텍스트 사이의 간격
                        Text(
                          "업체 후기 관리자 댓글",
                          style: WitHomeTheme.title,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                height: 1,
                color: WitHomeTheme.wit_extraLightGrey,
              ),
              Container(
                color: WitHomeTheme.wit_white, // 전체 배경색을 흰색으로 설정
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 15),
                      Row( // '내용' 텍스트 라인은 그대로 둡니다.
                        children: [
                          Text("댓글",
                            style: WitHomeTheme.title,
                          ),
                        ],
                      ),
                      // TextField를 SizedBox로 감싸서 너비를 Column의 최대 너비로 설정합니다.
                      SizedBox( // 또는 Container(
                        //height: 200.0, // 원하는 높이 값 지정
                        child: TextField(
                          controller: replyController,
                          decoration: InputDecoration(
                            // border: InputBorder.none, // 필요에 따라 주석 처리하거나 제거하여 테두리 포함 높이 계산
                            hintText: "댓글을 입력해주세요",
                            hintStyle: WitHomeTheme.subtitle.copyWith(color: WitHomeTheme.wit_lightgray),
                          ),
                          style: WitHomeTheme.subtitle,
                          maxLines: 8, // 여러 줄 입력 가능하도록 설정. 이 경우 스크롤이 내부적으로 처리됩니다.
                          keyboardType: TextInputType.multiline, // 여러 줄 키보드 타입 설정 (선택 사항)
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Container(
                color: Colors.white, // 전체 배경색을 흰색으로 설정
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween, // 버튼 간격을 일정하게
                        children: [
                            Expanded(
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: WitHomeTheme.wit_lightCoral,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () async {
                                  Navigator.of(context).pop(); // 알림창 닫기
                                },
                                child: Text("취소",
                                  style: WitHomeTheme.subtitle.copyWith(fontWeight: FontWeight.bold, color: WitHomeTheme.white),
                                ),
                              ),
                            ),
                          SizedBox(width: 10),
                            Expanded(
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: WitHomeTheme.wit_lightBlue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () async {
                                  saveCommentInfo();
                                },
                                child: Text("등록",
                                  style: WitHomeTheme.subtitle.copyWith(fontWeight: FontWeight.bold, color: WitHomeTheme.white),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 댓글 저장
  Future<void> saveCommentInfo() async {

    // 로그인 사번
    String? loginClerkNo = await secureStorage.read(key: 'clerkNo');
    

    String replyContent = replyController.text;

    if (replyContent.isEmpty) {
      alertDialog.show(context, "댓글을 입력해주세요.");
      return;
    }
    
    // 댓글 내용이 비어있지 않은 경우에만 추가
    if (replyContent.isNotEmpty) {
      // REST ID
      String restId = "saveCommentInfo";

      // PARAM
      final param = jsonEncode({
        "bordNo": widget.bordNo,
        "cmmtContent": replyContent,
        "creUser": loginClerkNo,
      });

      // API 호출 (댓글 추가)
      final _commentList = await sendPostRequest(restId, param);

      // 팝업 닫기
      setState(() {

        if (_commentList.length > 0) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("저장되었습니다.")));

        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("저장 실패하였습니다.")));
        }

        Navigator.pop(context);
      });
    }
  }

}