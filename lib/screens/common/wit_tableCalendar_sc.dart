import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:witibju/screens/common/wit_tableCalendar_widget.dart';
import 'package:witibju/screens/home/wit_home_theme.dart';
import 'package:witibju/util/wit_api_ut.dart';

class TableCalenderMain extends StatefulWidget {
  // 생성자
  const TableCalenderMain({super.key});

  // 상태 생성
  @override
  State<StatefulWidget> createState() {
    return TableCalenderMainState();
  }
}

class TableCalenderMainState extends State<TableCalenderMain> {

  final secureStorage = FlutterSecureStorage();

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDate;
  Map<DateTime, List<Event>> _events = {};

  @override
  void initState() {
    super.initState();

    // 월 스케쥴 조회
    getScheduleListByMonth(DateTime.now().year, DateTime.now().month);
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: WitHomeTheme.wit_white,
        title: Text("스케쥴 관리", style: WitHomeTheme.title),
      ),
      body: SafeArea(
        child: Container(
          color: Colors.white, // 배경색을 흰색으로 설정
          child: Column(
            children: [
              CalendarWidget(
                focusedDay: _focusedDay,
                selectedDate: _selectedDate,
                events: _events,
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDate = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onPageChanged: (focusedDay) {
                  setState(() {
                    // 현재 월인지 확인
                    if (focusedDay.year == DateTime.now().year && focusedDay.month == DateTime.now().month) {
                      _selectedDate = null;
                      _focusedDay = DateTime.now();
                      // 월 스케쥴 조회
                      getScheduleListByMonth(DateTime.now().year, DateTime.now().month);
                    } else {
                      _selectedDate = focusedDay;
                      _focusedDay = focusedDay;
                      // 월 스케쥴 조회
                      getScheduleListByMonth(focusedDay.year, focusedDay.month);
                    }
                  });
                },
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView(
                  children: _selectedDate != null
                      ? buildEventList(_getEventsForDay(_selectedDate!))
                      : buildEventList(_getEventsForToday()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 오늘의 이벤트만 가져오는 함수
  List<Event> _getEventsForToday() {
    DateTime today = DateTime.now();
    return _events[DateTime.utc(today.year, today.month, today.day)] ?? [];
  }

  // 해당 년/월/일에 걸리는 스케쥴 조회
  List<Event> _getEventsForDay(DateTime date) {
    return _events[date] ?? [];
  }

  // 해당 년/월에 걸리는 스케쥴 조회
  List<Event> _getEventsForMonth(DateTime date) {
    List<Event> events = [];
    _events.forEach((eventDate, eventList) {
      if (eventDate.year == date.year && eventDate.month == date.month) {
        events.addAll(eventList);
      }
    });
    return events;
  }

  // [서비스] 월 스케쥴 조회
  Future<void> getScheduleListByMonth(int year, int month) async {

    // 로그인 사번
    String? loginClerkNo = await secureStorage.read(key: "clerkNo");

    // REST ID
    String restId = "getEstimateRequestList";

    // PARAM
    final param = jsonEncode({
      "stat": "1",
      "date": month,
      "loginClerkNo": loginClerkNo,
    });

    // API 호출 (월 스케쥴 조회)
    //final scheduleList = await sendPostRequest(restId, param);

    // 데이터 셋팅
    /*setState(() {
      _events = scheduleList;
    });*/

    setState(() {
      _events = {
        DateTime.utc(2025, month, 01): [
          Event(DateTime(2025, month, 01, 10, 30), '줄눈1', '')
        ],
        DateTime.utc(2025, month, 18): [
          Event(DateTime(2025, month, 18, 10, 30), '줄눈2', '')
        ],
        DateTime.utc(2025, month, 19): [
          Event(DateTime(2025, month, 19, 10, 25), '탄성코트', ''),
          Event(DateTime(2025, month, 19, 12, 00), '입주청소', ''),
          Event(DateTime(2025, month, 19, 14, 00), '입주청소', ''),
          Event(DateTime(2025, month, 19, 16, 30), '입주청소', ''),
          Event(DateTime(2025, month, 19, 18, 30), '입주청소', ''),
        ],
        DateTime.utc(2025, month, 20): [
          Event(DateTime(2025, month, 20, 9, 00), '미세방충망', '경기도 화성시 병점역 병점역아이파크캐슬 118동 105호')
        ],
        DateTime.utc(2025, month, 22): [
          Event(DateTime(2025, month, 22, 14, 50), '커튼', '병점역아이파크캐슬 118동 105호')
        ],
      };
    });

  }
}


class Event {
  final DateTime dateTime; // 날짜 및 시간
  final String title;      // 스케줄 제목
  final String subtitle;     // 스케줄 제목

  Event(this.dateTime, this.title, this.subtitle);
}