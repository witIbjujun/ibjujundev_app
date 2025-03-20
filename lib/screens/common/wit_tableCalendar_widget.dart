import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:witibju/screens/common/wit_tableCalendar_sc.dart';

/**
 * 달력 클릭 이벤트
 */
List<Widget> buildEventList(List<Event> events) {
  List<Widget> eventWidgets = [];
  DateTime? lastDisplayedDate;

  for (var event in events) {
    if (lastDisplayedDate == null ||
        event.dateTime.year != lastDisplayedDate.year ||
        event.dateTime.month != lastDisplayedDate.month ||
        event.dateTime.day != lastDisplayedDate.day) {
      eventWidgets.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            '${event.dateTime.year}년 ${event.dateTime.month}월 ${event.dateTime.day}일',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      );
      lastDisplayedDate = event.dateTime;
    }
    eventWidgets.add(
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white, // 배경색
            borderRadius: BorderRadius.circular(10), // 둥근 테두리
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2), // 그림자 색
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3), // 그림자 위치
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10.0), // 내용 여백
                  child: Text(
                    event.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold, // 글자 두껍게
                      color: Colors.black, // 글자 색
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

  }

  return eventWidgets;
}

/**
 * 달력 위젯
 */
class CalendarWidget extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDate;
  final Map<DateTime, List<Event>> events; // Event 타입으로 정의
  final Function(DateTime, DateTime) onDaySelected;

  CalendarWidget({
    required this.focusedDay,
    required this.selectedDate,
    required this.events,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      locale: 'ko_KR',
      daysOfWeekHeight: 30,
      focusedDay: focusedDay,
      firstDay: DateTime.utc(2023, 01, 01),
      lastDay: DateTime.utc(2030, 12, 31),
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
      ),
      calendarStyle: CalendarStyle(
        canMarkersOverflow: false,
        markersAutoAligned: true,
        markersAlignment: Alignment.bottomCenter,
        markersMaxCount: 4,
        markerDecoration: BoxDecoration(
          color: Colors.black,
          shape: BoxShape.circle,
        ),
        markerMargin: const EdgeInsets.symmetric(horizontal: 2.0),
      ),
      onDaySelected: onDaySelected,
      selectedDayPredicate: (day) {
        return isSameDay(selectedDate, day);
      },
      onPageChanged: (focusedDay) {
        print(focusedDay);
      },
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, day, events) {
          // events는 List<dynamic> 형태로 들어올 수 있으므로, List<Event>로 변환
          final eventList = (this.events[day] ?? []) as List<Event>;
          final eventCount = eventList.length; // 안전하게 길이 가져오기

          if (eventCount > 0) {
            return Positioned(
              bottom: 4,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  eventCount > 4 ? 4 : eventCount,
                      (index) => const Text(
                    '.',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
            );
          }
          return const SizedBox(); // 이벤트가 없을 경우 빈 위젯 반환
        },
      ),
    );
  }
}

