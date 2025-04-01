import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../util/wit_api_ut.dart';
import '../home/wit_home_theme.dart';

// 스케쥴 등록 팝업 위젯
class ScheduleWritePopWidget extends StatefulWidget {

  final String sllrNo;
  final String reqNo;
  final DateTime startDate;
  final TimeOfDay startTime;
  final DateTime endDate;
  final TimeOfDay endTime;
  final String title;
  final String content;
  final String popGbn;

  // 생성자
  const ScheduleWritePopWidget({required this.sllrNo, required this.reqNo
    , required this.startDate, required this.startTime
    , required this.endDate, required this.endTime
    , required this.title, required this.content, required this.popGbn});

  @override
  _ScheduleWritePopWidgetState createState() => _ScheduleWritePopWidgetState();
}

class _ScheduleWritePopWidgetState extends State<ScheduleWritePopWidget> {

  final secureStorage = FlutterSecureStorage();

  late String sllrNo;
  late String reqNo;
  late DateTime startDate;
  late TimeOfDay startTime;
  late DateTime endDate;
  late TimeOfDay endTime;
  late String popGbn;

  // 제목
  final TextEditingController _titleController = TextEditingController();
  // 내용
  final TextEditingController _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();

    sllrNo = widget.sllrNo;
    reqNo = widget.reqNo;
    startDate = widget.startDate;
    startTime = widget.startTime;
    endDate = widget.endDate;
    endTime = widget.endTime;
    _titleController.text = widget.title;
    _contentController.text = widget.content;
    popGbn = widget.popGbn;
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
                      color: WitHomeTheme.wit_lightGreen,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 3, // 막대의 두께
                          width: 60, // 막대의 길이
                          color: WitHomeTheme.wit_white, // 막대 색상
                        ),
                        SizedBox(height: 15), // 아이콘과 텍스트 사이의 간격
                        Text(
                          "스케쥴 등록",
                          style: WitHomeTheme.title.copyWith(color: WitHomeTheme.wit_white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text("* ",
                          style: WitHomeTheme.title.copyWith(color: WitHomeTheme.wit_lightCoral),
                        ),
                        Text("제목",
                          style: WitHomeTheme.title,
                        ),
                      ],
                    ),
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "제목을 입력하세요",
                        hintStyle: WitHomeTheme.subtitle.copyWith(color: WitHomeTheme.wit_lightgray),
                      ),
                      style: WitHomeTheme.subtitle,
                      maxLines: 1,
                    ),
                    Divider(),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        Text("* ",
                          style: WitHomeTheme.title.copyWith(color: WitHomeTheme.wit_lightCoral),
                        ),
                        Text("날짜",
                          style: WitHomeTheme.title,
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  _selectDate(context, "startDate");
                                },
                                child: Text(
                                  "${startDate!.toLocal()}".split(' ')[0],
                                  style: WitHomeTheme.title.copyWith(fontWeight: FontWeight.normal),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text("~",
                          style: WitHomeTheme.title,
                        ),
                        // 오른쪽 종료일자 영역
                        Expanded(
                          child: Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  _selectDate(context, "endDate");
                                },
                                child: Text(
                                  "${endDate!.toLocal()}".split(' ')[0],
                                  style: WitHomeTheme.title.copyWith(fontWeight: FontWeight.normal),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Divider(),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        Text("* ",
                          style: WitHomeTheme.title.copyWith(color: WitHomeTheme.wit_lightCoral),
                        ),
                        Text("시간",
                          style: WitHomeTheme.title,
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  _selectTime(context, "startTime");
                                },
                                child: Text(
                                  startTime!.format(context),
                                  style: WitHomeTheme.title.copyWith(fontWeight: FontWeight.normal),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text("~",
                          style: WitHomeTheme.title,
                        ),
                        // 오른쪽 종료일자 영역
                        Expanded(
                          child: Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  _selectTime(context, "endTime");
                                },
                                child: Text(
                                  endTime!.format(context),
                                  style: WitHomeTheme.title.copyWith(fontWeight: FontWeight.normal),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Divider(),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        Text(
                          "내용",
                          style: WitHomeTheme.title,
                        ),
                      ],
                    ),
                    TextField(
                      controller: _contentController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "내용을 입력하세요",
                        hintStyle: WitHomeTheme.subtitle.copyWith(color: WitHomeTheme.wit_lightgray),
                      ),
                      style: WitHomeTheme.subtitle,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20), // 텍스트 필드와 버튼 사이의 간격
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 버튼 간격을 일정하게
                  children: [
                    // 하자등록 버튼
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: WitHomeTheme.wit_lightBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () async {
                          saveScheduleInfo();
                        },
                        child: Text("등록",
                          style: WitHomeTheme.subtitle.copyWith(fontWeight: FontWeight.bold, color: WitHomeTheme.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 스케쥴 저장
  Future<void> saveScheduleInfo() async {

    // 로그인 사번
    String? loginClerkNo = await secureStorage.read(key: "clerkNo");

    // REST ID
    String restId = "";

    if (widget.popGbn == "U") {
      restId = "updateScheduleInfo";
    } else {
      restId = "insertScheduleInfo";
    }

    // PARAM
    final param = jsonEncode({
      "sllrNo": widget.sllrNo,
      "reqNo": widget.reqNo,
      "reqGbn": "MY",
      "startDate": startDate!.year.toString()  + startDate!.month.toString().padLeft(2, '0')  + startDate!.day.toString().padLeft(2, '0') ,
      "startYm": startTime!.hour.toString().padLeft(2, '0') + startTime!.minute.toString().padLeft(2, '0') ,
      "endDate": endDate!.year.toString()  + endDate!.month.toString().padLeft(2, '0')  + endDate!.day.toString().padLeft(2, '0') ,
      "endYm": endTime!.hour.toString().padLeft(2, '0')  + endTime!.minute.toString().padLeft(2, '0') ,
      "cldrTitle" : _titleController.text,
      "cldrTxt" : _contentController.text,
      "regUser": loginClerkNo,
      "udtUser": loginClerkNo,
    });

    // API 호출 (스케쥴 저장)
    final result = await sendPostRequest(restId, param);

    if (result > 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("저장 성공")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("저장 실패")));
    }

    // Snackbar가 표시된 후 BottomSheet 닫기
    Navigator.of(context).pop();

  }

  // DatePicker
  Future<void> _selectDate(BuildContext context, dateGbn) async {

    DateTime? date;

    if ("startDate" == dateGbn) {
      date = startDate;
    } else if ("endDate" == dateGbn) {
      date = endDate;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: date ?? DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
      locale: Locale("ko"),
    );
    if (picked != null && picked != date) {
      setState(() {
        if ("startDate" == dateGbn) {
          startDate = picked;
        } else if ("endDate" == dateGbn) {
          endDate = picked;
        }
      });
    }
  }

  // TimePicker
  Future<void> _selectTime(BuildContext context, dateGbn) async {

    TimeOfDay? time;

    if ("startTime" == dateGbn) {
      time = startTime;
    } else if ("endTime" == dateGbn) {
      time = endTime;
    }

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: time ?? TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.input,
    );
    if (picked != null && picked != time) {
      setState(() {
        if ("startTime" == dateGbn) {
          startTime = picked;
        } else if ("endTime" == dateGbn) {
          endTime = picked;
        }
      });
    }
  }
}
