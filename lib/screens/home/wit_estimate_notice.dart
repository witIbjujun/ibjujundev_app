import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert'; // JSON 인코딩을 위해 추가
import 'package:intl/intl.dart'; // 날짜 처리를 위한 패키지 추가
import 'package:witibju/screens/home/wit_home_theme.dart';
import 'package:witibju/screens/home/wit_request_detail.dart';
import '../../util/wit_api_ut.dart';
import 'models/requestInfo.dart';

class WitEstimateNoticeScreen extends StatefulWidget {
  @override
  _WitEstimateNoticeScreenState createState() => _WitEstimateNoticeScreenState();
}

class _WitEstimateNoticeScreenState extends State<WitEstimateNoticeScreen> {
  List<RequestInfo> estimateList = [];
  List<RequestInfo> todayEstimates = [];
  List<RequestInfo> previousEstimates = [];

  final secureStorage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    getNoticeList();
  }

  // 데이터를 조회하는 비동기 함수
  Future<void> getNoticeList() async {
    String restId = "getNoticeList";

    String? clerkNo = await secureStorage.read(key: 'clerkNo');

    final param = jsonEncode({"reqUser": clerkNo});

    try {
      final _noticeList = await sendPostRequest(restId, param);
      setState(() {
        estimateList = RequestInfo().parseRequestList(_noticeList) ?? [];
        groupEstimatesByDate();
      });
    } catch (e) {
      print('신청 목록 조회 중 오류 발생: $e');
    }
  }

  // 견적 데이터를 날짜별로 그룹화
  void groupEstimatesByDate() {
    DateTime today = DateTime.now();
    DateFormat formatter = DateFormat('yyyy-MM-dd');

    todayEstimates = [];
    previousEstimates = [];

    estimateList.forEach((estimate) {
      DateTime estimateDate = DateTime.parse(estimate.reqDate);
      if (formatter.format(estimateDate) == formatter.format(today)) {
        todayEstimates.add(estimate);
      } else {
        previousEstimates.add(estimate);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white, // ✅ 배경색 흰색 적용
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 오늘 받은 알림 제목
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 10.0), // 위아래 패딩
                decoration: BoxDecoration(
                  color: WitHomeTheme.wit_lightGreen, // ✅ 연두색 배경 적용
                  borderRadius: BorderRadius.circular(8.0), // ✅ 둥근 모서리
                ),
                child: Center(
                  child: Text(
                    '오늘 받은 알림',
                    style: TextStyle(
                      fontSize: 18, // ✅ 폰트 크기
                      fontWeight: FontWeight.bold, // ✅ 볼드 처리
                      color: Colors.white, // ✅ 텍스트 색상 흰색
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.0),

              // 오늘 받은 알림 리스트
              Expanded(
                child: todayEstimates.isEmpty
                    ? Center(child: Text('오늘 받은 알림이 없습니다.'))
                    : ListView.builder(
                  itemCount: todayEstimates.length,
                  itemBuilder: (context, index) {
                    final estimate = todayEstimates[index];
                    return GestureDetector(
                      onTap: () {
                        /*Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RequestDetailScreen(
                              requests: todayEstimates,
                              selectedRequest: estimate,
                              categoryName: estimate.categoryNm,
                            ),
                          ),
                        );*/
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${estimate.categoryNm} - ${estimate.companyNm} - ${estimate.timeAgo}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4.0),
                            Text(
                              '${estimate.estimateContents}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            Divider(thickness: 1.0),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 16.0),

              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 10.0), // 위아래 패딩
                decoration: BoxDecoration(
                  color: WitHomeTheme.wit_gray,
                  borderRadius: BorderRadius.circular(8.0), // ✅ 둥근 모서리
                ),
                child: Center(
                  child: Text(
                    '이전 알림',
                    style: TextStyle(
                      fontSize: 18, // ✅ 폰트 크기
                      fontWeight: FontWeight.bold, // ✅ 볼드 처리
                      color: Colors.white, // ✅ 텍스트 색상 흰색
                    ),
                  ),
                ),
              ),

              SizedBox(height: 16.0),

              // 이전 알림 리스트
              Expanded(
                child: previousEstimates.isEmpty
                    ? Center(child: Text('이전 알림이 없습니다.'))
                    : ListView.builder(
                  itemCount: previousEstimates.length,
                  itemBuilder: (context, index) {
                    final estimate = previousEstimates[index];
                    return GestureDetector(
                      onTap: () {
                        /*Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RequestDetailScreen(
                              requests: previousEstimates,
                              selectedRequest: estimate,
                              categoryName: estimate.categoryNm,
                            ),
                          ),
                        );*/
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${estimate.categoryNm} - ${estimate.companyNm} - ${estimate.timeAgo}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4.0),
                            Text(
                              '${estimate.estimateContents}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            Divider(thickness: 1.0),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
