import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:witibju/screens/board/widget/wit_board_report_widget.dart'; // 현재 사용되지 않음

import '../../util/wit_api_ut.dart';
import '../common/wit_common_widget.dart';
import '../home/wit_home_theme.dart'; // WitHomeTheme 정의가 필요합니다.

class BoardReport extends StatefulWidget {

  final dynamic boardInfo;

  const BoardReport({super.key, this.boardInfo});

  @override
  BoardReportState createState() => BoardReportState();
}

class BoardReportState extends State<BoardReport> {

  final secureStorage = FlutterSecureStorage();

  final List<String> _reportReasons = [
    '스팸홍보/도배입니다.',
    '음란물입니다.',
    '불법정보를 포함하고 있습니다.',
    '청소년에게 유해한 내용입니다.',
    '욕설/생명경시/혐오/차별적 표현입니다.',
    '개인정보가 노출되었습니다.',
    '불쾌한 표현이 있습니다.',
    '기타'
  ];

  String? _selectedReason;
  String bordTypeGbn = "";
  final TextEditingController _detailController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // 게시판 타입 앞 2자리 추출
    setState(() {
      bordTypeGbn = widget.boardInfo["bordType"].substring(0, 2);
    });
  }

  @override
  void dispose() {
    _detailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("신고하기",
            style: WitHomeTheme.title.copyWith(color: WitHomeTheme.wit_white)),
        iconTheme: IconThemeData(color: WitHomeTheme.wit_white),
        backgroundColor: WitHomeTheme.wit_black,
      ),
      backgroundColor: WitHomeTheme.wit_white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제목과 작성자 정보 표시 영역
              if (bordTypeGbn != "UH") ...[
                Text(
                  '제목  :  ' + widget.boardInfo["bordTitle"], // 작성자 정보 표시
                  style: WitHomeTheme.title,
                  maxLines: 1,
                ),
              ] else ...[
                Text(
                  '내용  :  ' + widget.boardInfo["bordContent"], // 작성자 정보 표시
                  style: WitHomeTheme.title,
                  maxLines: 1,
                ),
              ],
              SizedBox(height: 5), // 제목과 작성자 사이 간격
              Text(
                '작성자  :  ' + widget.boardInfo["creUserNm"], // 작성자 정보 표시
                style: WitHomeTheme.subtitle,
                maxLines: 1,
              ),

              Divider(height: 30, thickness: 1), // 정보와 신고 사유 사이 구분선

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 신고 사유 선택 영역
                      Text(
                        '* 사유 선택 (필수)',
                        style: WitHomeTheme.title,
                      ),
                      SizedBox(height: 10),

                      // RadioListTile에 dense: true 속성 추가
                      ..._reportReasons.map((reason) {
                        return RadioListTile<String>(
                          title: Text(reason),
                          value: reason,
                          groupValue: _selectedReason,
                          onChanged: (value) {
                            setState(() {
                              _selectedReason = value;
                            });
                          },
                          dense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                        );
                      }).toList(),
                      SizedBox(height: 10),
                      Text(
                        '상세 사유',
                        style: WitHomeTheme.title,
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: _detailController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: '신고 내용을 자세히 입력해 주세요.',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: submitReport,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: WitHomeTheme.wit_lightGreen,
                            // horizontal: 0으로 설정하거나 완전히 제거하여 가로 패딩 제거
                            // vertical 값을 줄여 세로 높이 조절 (예: 15 -> 10)
                            padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: Text(
                            '신고하기',
                            style: TextStyle(
                                fontSize: 18,
                                color: WitHomeTheme.wit_white
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 신고하기
  Future<void> submitReport() async {

    // 로그인 사번
    String? loginClerkNo = await secureStorage.read(key: 'clerkNo');
    String? reason = _selectedReason;
    String details = _detailController.text;

    // 사유 선택 체크
    if (reason == null || reason == "") {
      alertDialog.show(context: context, title: "알림", content: "신고 사유를 선택해주세요.");
      return;
    }

    if (reason == "기타" && details == "") {
      alertDialog.show(context: context, title: "알림", content: "기타 선택시 상세 사유를 입력해주세요.");
      return;
    }

    var restId = "boardSendReport";

    print(widget.boardInfo["bordNo"]);

    var param = jsonEncode({
      "bordNo": widget.boardInfo["bordNo"],
      "reportReason": reason,
      "reportCont": details,
      "creUser": loginClerkNo
    });

    final result = await sendPostRequest(restId, param);

    if (result == 1) {
      Navigator.pop(context);
      alertDialog.show(context: context, title: "알림", content: "신고 성공 하였습니다.");
    } else if (result == -2) {
      alertDialog.show(context: context, title: "알림", content: "이미 신고한 게시글입니다.");
      return;
    } else {
      Navigator.pop(context);
      alertDialog.show(context: context, title: "알림", content: "신고 신고 하였습니다.");
    }
  }

}