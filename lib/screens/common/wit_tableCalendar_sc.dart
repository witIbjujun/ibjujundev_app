import 'package:flutter/material.dart';
import 'package:witibju/screens/common/wit_tableCalendar_widget.dart';

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

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDate;
  Map<DateTime, List<Event>> _events = {};

  @override
  void initState() {
    super.initState();

    _events = {
      DateTime.utc(2025, 03, 18): [
        Event(DateTime(2025, 03, 18, 10, 0), '새해 첫날 기념일')
      ],
      DateTime.utc(2025, 03, 19): [
        Event(DateTime(2025, 03, 19, 12, 0), '친구와 점심'),
        Event(DateTime(2025, 03, 19, 15, 0), '회의 일정'),
      ],
      DateTime.utc(2025, 03, 20): [
        Event(DateTime(2025, 03, 20, 9, 0), '프로젝트 마감')
      ],
      DateTime.utc(2025, 03, 21): [
        Event(DateTime(2025, 03, 21, 14, 0), '팀 회의')
      ],
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("스케쥴"),
        centerTitle: true,
      ),
      body: Column(
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
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView(
              //children : buildEventList(_getEventsForDay(_selectedDate!)),
              children: _selectedDate != null
                  ? buildEventList(_getEventsForDay(_selectedDate!))
                  : buildEventList(_getEventsForMonth(_focusedDay)),
            ),
          ),
        ],
      ),
    );
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
}

class Event {
  final DateTime dateTime; // 날짜 및 시간
  final String title;      // 스케줄 제목

  Event(this.dateTime, this.title);
}