import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../util/wit_api_ut.dart';
import '../home/wit_home_theme.dart';

// 스케쥴 등록 팝업 위젯
class ScheduleWritePopWidget extends StatefulWidget {

  final String sllrNo;

  // 생성자
  const ScheduleWritePopWidget({super.key, required this.sllrNo});

  @override
  _ScheduleWritePopWidgetState createState() => _ScheduleWritePopWidgetState();
}

class _ScheduleWritePopWidgetState extends State<ScheduleWritePopWidget> {

  final secureStorage = FlutterSecureStorage();

  DateTime? startDate = DateTime.now();
  TimeOfDay? startTime = TimeOfDay(hour: 00, minute: 00);
  DateTime? endDate = DateTime.now();
  TimeOfDay? endTime = TimeOfDay(hour: 12, minute: 00);

  // 제목
  final TextEditingController _titleController = TextEditingController();
  // 내용
  final TextEditingController _contentController = TextEditingController();

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

    print(_titleController.text);
    print(startDate);
    print(startTime);
    print(endDate);
    print(endTime);
    print(_contentController.text);
    print(DateTime(startDate!.year,startDate!.month,startDate!.day,startTime!.hour,startTime!.minute));
    print(DateTime(endDate!.year,endDate!.month,endDate!.day,endTime!.hour,endTime!.minute));

    // 로그인 사번
    String? loginClerkNo = await secureStorage.read(key: "clerkNo");

    // REST ID
    String restId = "saveScheduleInfo";

    // PARAM
    final param = jsonEncode({
      "sllrNo": widget.sllrNo,
      "startDate": DateTime(startDate!.year,startDate!.month,startDate!.day,startTime!.hour,startTime!.minute).toString(),
      "endDate": DateTime(endDate!.year,endDate!.month,endDate!.day,endTime!.hour,endTime!.minute).toString(),
      "title" : _titleController.text,
      "contents" : _contentController.text,
      "loginClerkNo": loginClerkNo,
    });

    // API 호출 (스케쥴 저장)
    //final result = await sendPostRequest(restId, param);

    /*if (result > 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("저장 성공")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("저장 실패")));
    }*/

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
        if ("startDate" == dateGbn) {
          startTime = picked;
        } else if ("endDate" == dateGbn) {
          endTime = picked;
        }
      });
    }
  }
}
