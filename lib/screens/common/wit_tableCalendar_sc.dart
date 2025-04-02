import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:witibju/screens/common/wit_tableCalendar_widget.dart';
import 'package:witibju/screens/common/wit_tableCalender_write_pop.dart';
import 'package:witibju/screens/home/wit_home_theme.dart';
import 'package:witibju/util/wit_api_ut.dart';

class TableCalenderMain extends StatefulWidget {

  final String stat; // stat을 멤버 변수로 추가
  final String sllrNo; // sllrNo를 멤버 변수로 추가

  // 생성자
  const TableCalenderMain({super.key, required this.stat, required this.sllrNo});

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
    getEstimateRequestList(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: WitHomeTheme.wit_white),
        backgroundColor: WitHomeTheme.wit_black,
        title: Text("스케쥴 관리", style: WitHomeTheme.title.copyWith(color: WitHomeTheme.wit_white)),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: WitHomeTheme.wit_white), // 아이콘으로 '+'를 사용
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isDismissible: true,
                isScrollControlled: true,
                builder: (context) {
                  return Padding(
                    padding: MediaQuery.of(context).viewInsets,
                    child: Container(
                      height: 530,
                      child: ScheduleWritePopWidget(
                        sllrNo: widget.sllrNo,
                        reqNo: "",
                        startDate: _selectedDate ?? DateTime.now(),
                        startTime: TimeOfDay(hour: 09, minute: 00),
                        endDate: _selectedDate ?? DateTime.now(),
                        endTime: TimeOfDay(hour: 18, minute: 00),
                        title: "",
                        content: "",
                        popGbn: "I",
                      ),
                    ),
                  );
                },
              ).then((_) {
                // BottomSheet가 닫힌 후 새로고침
                getEstimateRequestList(_focusedDay.year, _focusedDay.month, _focusedDay.day);
              });
            },
          ),
        ],
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
                      getEstimateRequestList(DateTime.now().year, DateTime.now().month, DateTime.now().day);
                    } else {
                      _selectedDate = focusedDay;
                      _focusedDay = focusedDay;
                      // 월 스케쥴 조회
                      getEstimateRequestList(focusedDay.year, focusedDay.month, focusedDay.day);
                    }
                  });
                },
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView(
                  children: _selectedDate != null
                      ? buildEventList(_getEventsForDay(_selectedDate!), context, getEstimateRequestList)
                      : buildEventList(_getEventsForToday(), context, getEstimateRequestList),
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

  // [서비스] 견적리스트 조회
  Future<void> getEstimateRequestList(int year, int month, int day) async {
    // REST ID
    String restId = "getEstimateRequestList";

    // PARAM
    final param = jsonEncode({
      "stat": widget.stat, // stat을 사용하여 API에 전달
      "sllrNo": widget.sllrNo,
      "basDate" : year.toString() + month.toString().padLeft(2, '0'),
    });

    _events = {};

    // API 호출 (사전 점검 미완료 리스트 조회)
    final _estimateRequestList = await sendPostRequest(restId, param);

    // 결과 셋팅
    setState(() {

      // 데이터 가공
      for (var item in _estimateRequestList) {
        DateTime estDate = DateTime.parse(item['estDt']);

        // 이벤트 생성
        Event event = Event(estDate, item);

        // 맵에 추가
        if (_events[DateTime.utc(estDate.year, estDate.month, estDate.day)] == null) {
          _events[DateTime.utc(estDate.year, estDate.month, estDate.day)] = [];
        }
        _events[DateTime.utc(estDate.year, estDate.month, estDate.day)]!.add(event);
      }

      // 개인 스케쥴 조회
      getScheduleList(year, month, day);
      
    });
  }

  // [서비스] 스케쥴 조회
  Future<void> getScheduleList(int year, int month, int day) async {

    // REST ID
    String restId = "selectScheduleList";
    
    // PARAM
    final param = jsonEncode({
      "sllrNo": widget.sllrNo,
      "reqGbn": "MY",
      "searchDate" : year.toString() + month.toString().padLeft(2, '0'),
    });

    // API 호출 (사전 점검 미완료 리스트 조회)
    final _scheduleList = await sendPostRequest(restId, param);

    // 결과 셋팅
    setState(() {

      // 데이터 가공
      for (var item in _scheduleList) {

        // 날짜와 시간을 결합하여 DateTime 문자열 생성
        String dateTimeString = '${item['startDate'].substring(0, 4)}-${item['startDate'].substring(4, 6)}-${item['startDate'].substring(6, 8)} ${item['startYm'].substring(0, 2)}:${item['startYm'].substring(2, 4)}';


        DateTime scheduleDate = DateTime.parse(dateTimeString);

        // 이벤트 생성
        Event event = Event(scheduleDate, item);

        // 맵에 추가
        if (_events[DateTime.utc(scheduleDate.year, scheduleDate.month, scheduleDate.day)] == null) {
          _events[DateTime.utc(scheduleDate.year, scheduleDate.month, scheduleDate.day)] = [];
        }
        _events[DateTime.utc(scheduleDate.year, scheduleDate.month, scheduleDate.day)]!.add(event);
      }

      _selectedDate = DateTime.utc(year, month, day);

    });
  }


  // [서비스] 월 스케쥴 조회
  /*Future<void> getScheduleListByMonth(int year, int month) async {

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
    *//*setState(() {
      _events = scheduleList;
    });*//*

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

  }*/
}

// 스케쥴 이벤트 객체
class Event {
  final DateTime dateTime;    // 날짜 및 시간
  final dynamic data;

  Event(this.dateTime, this.data);
}