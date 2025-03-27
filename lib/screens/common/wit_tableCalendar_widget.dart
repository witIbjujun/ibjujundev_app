import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:witibju/screens/common/wit_tableCalendar_sc.dart';

import '../home/wit_home_theme.dart';
import '../seller/wit_seller_estimaterequest_detail_sc.dart';

/**
 * 달력 클릭 이벤트
 */
/*List<Widget> buildEventList(List<Event> events) {
  List<Widget> eventWidgets = [];
  DateTime? lastDisplayedDate;

  for (var event in events) {
    if (lastDisplayedDate == null ||
        event.dateTime.year != lastDisplayedDate.year ||
        event.dateTime.month != lastDisplayedDate.month ||
        event.dateTime.day != lastDisplayedDate.day) {
      // 일자 위젯
      eventWidgets.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(15.0, 5.0, 0, 5.0),
          child: Row(
            children: [
              Text('○',
                style: WitHomeTheme.caption.copyWith(color: WitHomeTheme.wit_black),
              ),
              SizedBox(width: 10),
              Text(
                '${event.dateTime.month}월 ${event.dateTime.day}일 ${DateFormat.E("ko_KR").format(event.dateTime)}요일',
                style: WitHomeTheme.subtitle.copyWith(color: WitHomeTheme.wit_black),
              ),
            ],
          ),
        ),
      );
      lastDisplayedDate = event.dateTime;
    }

    // 일자별 리스트 위젯
    eventWidgets.add(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Row(
          children: [
            Container(
              width: 1,
              height: 80,
              color: WitHomeTheme.wit_lightgray,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: WitHomeTheme.wit_lightGreen,
                  borderRadius: BorderRadius.circular(45),
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color: WitHomeTheme.wit_lightGreen,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: WitHomeTheme.wit_white,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          event.dateTime.hour.toString().padLeft(2, '0') + ":" + event.dateTime.minute.toString().padLeft(2, '0'),
                          style: WitHomeTheme.caption.copyWith(color: WitHomeTheme.wit_white),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.title,
                              style: WitHomeTheme.subtitle.copyWith(color: WitHomeTheme.wit_white, fontWeight: FontWeight.bold),
                            ),
                            if (event.subtitle != "")
                              Text(
                                event.subtitle,
                                style: WitHomeTheme.caption.copyWith(color: WitHomeTheme.wit_white),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
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
    );
  }

  return eventWidgets;
}*/

List<Widget> buildEventList(List<Event> events, BuildContext context) {
  List<Widget> eventWidgets = [];
  DateTime? lastDisplayedDate;

  for (var event in events) {

    print("11☆★☆★☆★☆★☆★☆★");
    print(event.data);
    print("22☆★☆★☆★☆★☆★☆★");
    print(event.data["statName"]);
    print("33☆★☆★☆★☆★☆★☆★");
    print(event.data["statName"]);
    print("44☆★☆★☆★☆★☆★☆★");

    if (lastDisplayedDate == null ||
        event.dateTime.year != lastDisplayedDate.year ||
        event.dateTime.month != lastDisplayedDate.month ||
        event.dateTime.day != lastDisplayedDate.day) {
      // 일자 위젯
      eventWidgets.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(15.0, 5.0, 0, 5.0),
          child: Row(
            children: [
              Text('○',
                style: WitHomeTheme.caption.copyWith(color: WitHomeTheme.wit_black),
              ),
              SizedBox(width: 10),
              Text(
                '${event.dateTime.month}월 ${event.dateTime.day}일 ${DateFormat.E("ko_KR").format(event.dateTime)}요일',
                style: WitHomeTheme.subtitle.copyWith(color: WitHomeTheme.wit_black),
              ),
            ],
          ),
        ),
      );
      lastDisplayedDate = event.dateTime;
    }

    // 일자별 리스트 위젯
    eventWidgets.add(
      Padding(
        padding: EdgeInsets.all(16), // 내부 여백 추가
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
          children: [
            Row(
              children: [
                // 왼쪽에 사진
                Container(
                  width: 50,
                  height: 50, // 이미지 높이 설정
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25), // 둥근 프로필 사진
                    image: DecorationImage(
                      image: AssetImage('assets/images/profile1.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: 10), // 이미지와 텍스트 사이의 간격 추가
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 날짜를 이름 위로 배치
                      Text('${event.dateTime}', // 날짜
                        style: WitHomeTheme.title.copyWith(fontSize: 12, color: WitHomeTheme.wit_gray),
                      ),
                      SizedBox(height: 4), // 날짜와 이름 사이의 간격
                      Text(event.data["prsnName"] ?? '요청자명 없음', // 요청자명
                        style: WitHomeTheme.title.copyWith(fontSize: 18),
                      ),
                      SizedBox(height: 1), // 이름과 아파트명 사이의 간격
                      Text(event.data["aptName"],
                        style: WitHomeTheme.title.copyWith(fontSize: 12, color: WitHomeTheme.wit_gray),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 10), // 상태 텍스트와의 간격
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EstimateRequestDetail(
                          estNo: event.data["estNo"].toString(),
                          seq: event.data["seq"].toString(),
                          sllrNo: event.data["sllrNo"].toString(),
                        ),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero, // 패딩을 0으로 설정하여 간격 줄이기
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0), // 테두리 없애기
                    ),
                  ),
                  child: Text(event.data["stat"] ?? "", // 상태
                    style: WitHomeTheme.title.copyWith(fontSize: 14, color: WitHomeTheme.wit_lightBlue),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10), // 텍스트와 내용 사이의 간격
            Container(
              padding: EdgeInsets.all(12), // 내용의 내부 여백
              decoration: BoxDecoration(
                color: Colors.grey[300], // 회색 배경
                borderRadius: BorderRadius.circular(8), // 둥근 모서리
              ),
              child: Align(
                alignment: Alignment.centerLeft, // 왼쪽 정렬
                child: Text(event.data["content"] ?? "", // 내용
                  style: WitHomeTheme.subtitle.copyWith(fontSize: 14),
                  textAlign: TextAlign.left, // 텍스트 왼쪽 정렬
                  maxLines: 3, // 기본 3줄 표시
                  overflow: TextOverflow.ellipsis, // 줄 넘침 처리
                ),
              ),
            ),
          ],
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
  final Function(DateTime) onPageChanged;

  CalendarWidget({
    required this.focusedDay,
    required this.selectedDate,
    required this.events,
    required this.onDaySelected,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      locale: 'ko_KR',
      daysOfWeekHeight: 25,
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
        markerMargin: const EdgeInsets.symmetric(horizontal: 0.0),
        todayDecoration: BoxDecoration(
          color: WitHomeTheme.wit_lightgray, // 현재 날짜 원형 색깔
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: WitHomeTheme.wit_lightBlue, // 선택한 날짜 원형 색깔
          shape: BoxShape.circle,
        ),
      ),
      onDaySelected: onDaySelected,
      selectedDayPredicate: (day) {
        return isSameDay(selectedDate, day);
      },
      onPageChanged: onPageChanged,
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, day, events) {
          // events는 List<dynamic> 형태로 들어올 수 있으므로, List<Event>로 변환
          final eventList = (this.events[day] ?? []) as List<Event>;
          final eventCount = eventList.length;
          if (eventCount > 0) {
            return Positioned(
              bottom: 4,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  eventCount > 4 ? 4 : eventCount,
                      (index) => const Text('.',
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

