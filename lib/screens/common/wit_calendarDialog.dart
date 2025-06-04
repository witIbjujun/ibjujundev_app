import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../home/wit_home_theme.dart';

class CustomCalendarBottomSheet extends StatefulWidget {
  final String title; // ✅ 제목을 동적으로 받을 수 있도록 추가
  final bool allowPastDates; // 👈 이걸 추가!

  CustomCalendarBottomSheet(
      {required this.title,
        this.allowPastDates = false, // 기본값은 false
      }
  );

  @override
  _CustomCalendarBottomSheetState createState() => _CustomCalendarBottomSheetState();
}

class _CustomCalendarBottomSheetState extends State<CustomCalendarBottomSheet> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 제목
          Text(
            widget.title,
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),

          // TableCalendar 적용
          TableCalendar(
            firstDay: DateTime.utc(2023, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            locale: 'ko_KR',
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              if (widget.allowPastDates || !isBeforeToday(selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              }
            },
            enabledDayPredicate: (day) {
              return widget.allowPastDates || !isBeforeToday(day);
            },
            calendarFormat: CalendarFormat.month,
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(color: Colors.grey),
              weekendStyle: TextStyle(color: Colors.grey),
            ),
            calendarStyle: CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: WitHomeTheme.wit_lightGreen,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              outsideDaysVisible: false,
              disabledTextStyle: TextStyle(color: Colors.grey.shade400), // 비활성화된 날 스타일
            ),
          ),

          SizedBox(height: 10),

          // 확인 버튼
          ElevatedButton(
            onPressed: () {
              if (_selectedDay != null /* && (widget.allowPastDates || !isBeforeToday(_selectedDay!)) */) {
                Navigator.pop(context, _selectedDay);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: WitHomeTheme.wit_lightGreen,
              minimumSize: Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: Text(
              "확인",
              style: TextStyle(color: Colors.white, fontSize: 16.0),
            ),
          ),
        ],
      ),
    );
  }

  bool isBeforeToday(DateTime day) {
    final today = DateTime.now();
    // 년/월/일 비교만 하려면 시간 정보 제거 필요
    final justDate = DateTime(day.year, day.month, day.day);
    final todayDate = DateTime(today.year, today.month, today.day);

    return justDate.isBefore(todayDate);
  }
}
