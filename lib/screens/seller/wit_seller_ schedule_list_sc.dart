import 'dart:convert';
import 'package:flutter/material.dart';
import '../../util/wit_api_ut.dart';
import 'package:witibju/screens/home/wit_home_theme.dart';
import '../home/widgets/wit_home_widgets.dart'; // WitHomeTheme 경로 확인
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class SellerScheduleList extends StatefulWidget {
  final String sllrNo; // 판매자 번호

  const SellerScheduleList({Key? key, required this.sllrNo}) : super(key: key);

  @override
  State<StatefulWidget> createState() => SellerScheduleListState();
}

class SellerScheduleListState extends State<SellerScheduleList> {
  List<dynamic> scheduleList = []; // 스케줄 목록

  @override
  void initState() {
    super.initState();
    getSellerScheduleList(); // 스케줄 목록 조회
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 배경색을 흰색으로 설정
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /*Text(
              '> 스케줄 관리',
              style: WitHomeTheme.title.copyWith(fontSize: 20, color: WitHomeTheme.wit_lightGreen),
            ),
            SizedBox(height: 8),*/
            Container(
              padding: const EdgeInsets.all(8.0), // 내부 여백
              decoration: BoxDecoration(
                color: Colors.grey[400], // 회색 배경
                borderRadius: BorderRadius.circular(5), // 모서리 둥글게
              ),
              child: Center( // 텍스트를 가운데 정렬
                child: Text(
                  '범석방충망 님',
                  style: WitHomeTheme.title.copyWith(fontSize: 18, color: WitHomeTheme.wit_black), // 글자 색상을 검은색으로 설정
                ),
              ),
            ),
            SizedBox(height: 8), // 카드 내 요소 간격
            Center(
              child: Text(
                '< 2025.03 >',
                style: WitHomeTheme.title.copyWith(fontSize: 20, color: WitHomeTheme.wit_lightGreen),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: scheduleList.length,
                itemBuilder: (context, index) {
                  return buildScheduleItem(scheduleList[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildScheduleItem(dynamic schedule) {
    return Card(
      color: Colors.grey[100], // 회색 배경 추가
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 날짜와 상태를 추가하는 Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  schedule['estDt'] ?? '날짜 없음', // 추가된 날짜
                  style: WitHomeTheme.title.copyWith(fontSize: 16),
                ),
                Text(
                  schedule['stat'] ?? '상태 없음', // 추가된 상태
                  style: WitHomeTheme.title.copyWith(fontSize: 16),
                ),
              ],
            ),
            SizedBox(height: 8), // 카드 내 요소 간격
            // 사용자 사진 및 이름, 아파트명
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage('assets/images/profile1.png'), // 사용자 사진
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        schedule['estDt'], // 날짜
                        style: WitHomeTheme.title.copyWith(fontSize: 12, color: WitHomeTheme.wit_gray),
                      ),
                      SizedBox(height: 4),
                      Text(
                        schedule['prsnName'] ?? '신청자명 없음', // 신청자 이름
                        style: WitHomeTheme.title.copyWith(fontSize: 18),
                      ),
                      SizedBox(height: 1),
                      Text(
                        schedule['aptName'] ?? '아파트명 없음', // 아파트명
                        style: WitHomeTheme.title.copyWith(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                TextButton(
                  onPressed: () {
                    // 신청 버튼 클릭 시 로직 추가
                  },
                  child: Text(
                    schedule['stat'] == '진행대기' ? '견적진행' :
                    schedule['stat'] == '작업진행' ? '인테리어진행' :
                    schedule['stat'] ?? '상태 없음', // 기본값
                    style: WitHomeTheme.title.copyWith(fontSize: 14, color: WitHomeTheme.wit_lightBlue),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }



  Future<void> getSellerScheduleList() async {
    String restId = "getEstimateRequestList"; // API ID
    final param = jsonEncode({
      "sllrNo": widget.sllrNo,
    });

    final response = await sendPostRequest(restId, param);
    setState(() {
      scheduleList = response; // 스케줄 목록 저장
    });
  }
}