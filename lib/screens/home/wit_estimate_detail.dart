import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:witibju/screens/home/widgets/wit_home_bottom_nav_bar.dart';
import 'package:witibju/screens/home/widgets/wit_home_widgets.dart';
import 'package:witibju/screens/home/widgets/wit_home_widgets2.dart';
import 'package:witibju/screens/home/wit_home_theme.dart';
import 'package:witibju/screens/home/wit_request_detail.dart';

import '../../util/wit_api_ut.dart';
import '../chat/chatMain.dart';
import '../common/wit_common_util.dart';
import 'models/requestInfo.dart';
import 'wit_estimate_notice.dart'; // 알림 화면 연결

/// 견적요청화면
class EstimateScreen extends StatefulWidget {
  @override
  State<EstimateScreen> createState() => _EstimateScreenState();
}

class _EstimateScreenState extends State<EstimateScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<RequestInfo> requestList = [];
  List<RequestInfo> requestDetailList = [];
  RequestInfo? _selectedRequest; // 선택된 요청 정보를 저장할 변수 추가

  int _selectedIndex = 1; // ✅ "내정보" 탭이 기본 선택

  final secureStorage = FlutterSecureStorage(); // Flutter Secure Storage 인스턴스

  // formatCurrency 함수 추가
  String formatCurrency(String amount) {
    if (amount.isEmpty || amount == "-") {
      return "-";
    }

    // 금액을 정수로 변환한 후 3자리마다 콤마를 찍음
    final formatter = NumberFormat('#,###');
    int intAmount = int.parse(amount);
    return formatter.format(intAmount);
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // 견적목록 조회
    getRequestAsisList();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: WitHomeTheme.white,
        title: Text('견적 요청 화면'),
      ),
      body: Column(
        children: [
          // 광고 영역
          Container(
            height: 180, // 높이를 고정하여 Overflow 방지]
            color:WitHomeTheme.white,
            child:  CommonImageBanner(
              imagePath: 'assets/home/gongguBanner.png', // 원하는 이미지 파일명
              heightRatio: 0.18,  // 화면 높이의 15% (기본값 10%)
              widthRatio: 0.85,   // 화면 너비의 85% (기본값 90%)
            ),
          ),
         // SizedBox(height: 2.0),

          // 견적 및 알림 탭
          WitHomeWidgets.getTabBarUI(_tabController, ['견적', '알림']),

          // 탭 내용
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 8.0),
                      ..._buildReqNoSections(),
                    ],
                  ),
                ),
                WitEstimateNoticeScreen(),
              ],
            ),
          ),
        ],
      ),

      bottomNavigationBar: BottomNavBar(selectedIndex: _selectedIndex),
    );
  }

  // 2025-03-22 수정: requestList 만으로 받은 견적 테이블 구성
  List<Widget> _buildReqNoSections() {
    Map<String, List<RequestInfo>> reqNoGroupedRequests = {};

    for (var request in requestList) {
      String reqNo = request.reqNo;
      if (!reqNoGroupedRequests.containsKey(reqNo)) {
        reqNoGroupedRequests[reqNo] = [];
      }
      reqNoGroupedRequests[reqNo]!.add(request);
    }

    List<Widget> sectionWidgets = [];

    reqNoGroupedRequests.forEach((reqNo, requests) {
      Map<String, List<RequestInfo>> categoryGroupedRequests = {};
      for (var request in requests) {
        String categoryId = request.categoryId;
        if (!categoryGroupedRequests.containsKey(categoryId)) {
          categoryGroupedRequests[categoryId] = [];
        }
        categoryGroupedRequests[categoryId]!.add(request);
      }

      sectionWidgets.add(
        Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${requests.first.timeAgo} 요청 견적', style: WitHomeTheme.body2),
                  Text('${requests.first.formatReqNo}', style: WitHomeTheme.body2),
                ],
              ),
              SizedBox(height: 8.0),
              for (var entry in categoryGroupedRequests.entries) ...[
                SectionWidget(
                  title: entry.value.first.companyCnt == '-'
                      ? '${entry.value.first.categoryNm} '
                      : '${entry.value.first.categoryNm}',
                  items: [
                    ListItem(
                      companyId: entry.value.first.companyId,
                      companyNm: entry.value.first.companyNm,
                      time: entry.value.first.reqDate ?? '',
                      rate: entry.value.first.rate,
                      estimateContents: entry.value.first.estimateContents,
                      reqDateInfo: entry.value.first.reqDateInfo,
                      reqState: entry.value.first.reqState,
                      reqStateNm: entry.value.first.reqStateNm,
                      estimateAmount: entry.value.first.estimateAmount,
                      reqContents: entry.value.first.reqContents,
                      receivedEstimates: entry.value.map((r) => EstimateItem(
                        companyNm: r.companyNm,
                        estimateAmount: r.estimateAmount,
                        rate: r.rate,
                      )).toList(), // ✅ entry.value에 모든 업체 정보가 포함됨
                    ),
                  ],
                  onTap: () {
                    // 상세 팝업 제거하고 테이블만 리스트에 노출
                  },
                ),
                SizedBox(height: 8.0),
              ],
            ],
          ),
        ),
      );
    });

    return sectionWidgets;
  }



  void _showDetailPopup(BuildContext context, List<RequestInfo> requests) {
    if (requests.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('요청 정보가 없습니다.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RequestDetailScreen(  ///상세화면 이동
          requests: requests,
          selectedRequest: requests.first,
          categoryName: requests.first.categoryNm, // categoryNm 전달
        ),
      ),
    );
  }


  void _showDetailPopupAsIs(BuildContext context, List<RequestInfo> requests) {

    if (requests.isEmpty) {
      // 요청이 없을 경우 에러 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('요청 정보가 없습니다.')),
      );
      return;
    }

    setState(() {
      _selectedRequest = requests.first; // 첫 번째 요청을 기본 선택값으로 설정
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.5,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      alignment: Alignment.centerLeft,
                      child: Text("총 받은 견적 ${requests.length}개"),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.10,
                      padding: const EdgeInsets.all(13.0),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: requests.length,
                        itemBuilder: (BuildContext context, int index) {
                          final request = requests[index];
                          final isSelected = _selectedRequest == request; // 선택된 요청이 있는지 확인
                          String companyName = request.companyNm.length > 8
                              ? request.companyNm.substring(0, 8) + '...'
                              : request.companyNm;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedRequest = request; // 선택된 요청을 업데이트
                              });
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.3,
                              margin: const EdgeInsets.symmetric(horizontal: 8.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.0), // 모서리를 더 둥글게 설정
                                border: Border.all(
                                  color: isSelected ? Colors.blue : Colors.grey,
                                  width: isSelected ? 2.0 : 1.0,
                                ),
                                color: Colors.white,
                              ),
                              padding: EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    companyName,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, // 선택된 항목은 볼드 처리
                                    ),
                                  ),
                                  SizedBox(height: 10.0),
                                  Text(
                                    request.estimateAmount.isEmpty || request.estimateAmount == "-"
                                        ? '견적 금액: -'
                                        : '견적 금액: ${formatCurrency(request.estimateAmount)} 원',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, // 선택된 항목은 볼드 처리
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Divider(thickness: 1), // 구분선 추가
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          // 선택된 요청의 상세 정보 표시
                          child: _buildRequestDetail(_selectedRequest ?? requests.first),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// 팝업 하단
  Widget _buildRequestDetail(RequestInfo request) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '${request.companyNm}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 4.0),
            Image.asset(
              'assets/images/star.png',
              width: 16.0,
              height: 16.0,
            ),
            SizedBox(width: 4.0),
            Text('${request.rate} ', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8.0),
            Expanded(
              child: Container(), // 오른쪽으로 텍스트 밀기
            ),
            GestureDetector(
              onTap: request.reqState == '02'
                  ? () {
                _showConfirmationDialog(
                  context,
                  request.companyNm,
                  request.estimateAmount,
                  request.rate,
                  request.reqNo,
                  request.seq,
                  '72091587',
                );
              }
                  : null,
              child: Text(
                '${request.reqStateNm}',
                style: TextStyle(
                  fontSize: 14,
                  //진행중 상태값 진행
                  ///color: request.reqState != '02' ? Colors.grey : Colors.blue,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.0),
        Text(
          request.estimateAmount.isEmpty || request.estimateAmount == "-"
              ? '견적 금액: -'
              : '견적 금액: ${formatCurrency(request.estimateAmount)} 원',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8.0),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.white, // 배경색을 흰색으로 설정
            border: Border.all(color: WitHomeTheme.kTextColor), // 회색 테두리 추가
            borderRadius: BorderRadius.circular(8.0), // 모서리 둥글게
          ),
          child: Text(
            request.estimateContents,
            style: TextStyle(fontSize: 14),
          ),
        ),
        SizedBox(height: 8.0),
        Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatPage()),
              );
            },
            child: Text(
              "메시지 대화하기",
              style: TextStyle(color: Colors.blue),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white, // 기존 'primary'를 'backgroundColor'로 변경
              side: BorderSide(color: Colors.blue),
            ),
          ),
        ),
      ],
    );
  }

  void _showConfirmationDialog(BuildContext context, String companyNm, String estimateAmount, String rate, String reqNo, String seq, String reqUser) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("작업 요청"),
          content: RichText(
            text: TextSpan(
              text: companyNm,
              style: TextStyle(fontSize: 14, color: Colors.blue),
              children: <TextSpan>[
                TextSpan(
                  text: ' 업체에 작업을 요청할까요?',
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await updateRequestState(reqNo, seq, reqUser);
                Navigator.of(context).pop();
              },
              child: Text("보내기"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("취소"),
            ),
          ],
        );
      },
    );
  }

  Future<void> updateRequestState(String reqNo, String seq, String reqUser) async {
    String restId = "updateRequestState";
    final param = jsonEncode({
      "reqNo": reqNo,
      "seq": seq,
      "reqUser": reqUser,
      "reqState": '03'
    });

    try {
      final response = await sendPostRequest(restId, param);
      if (response != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('작업 요청을 완료했습니다.')),
        );
        await getRequestAsisList();
        Navigator.of(context).pop();
      } else {
        print("요청 상태 업데이트 실패: ${response['message']}");
      }
    } catch (e) {
      print('요청 상태 업데이트 중 오류 발생: $e');
    }
  }

  Future<void> getRequestAsisList() async {
    String restId = "getRequestAsisList";
    String? clerkNo = await secureStorage.read(key: 'clerkNo');

    final param = jsonEncode({"reqUser": clerkNo});
    print('📡 상세 조회 응답:등러간다!!!!!!!!! ');
    try {
      final _requestList = await sendPostRequest(restId, param);
      setState(() {
        requestList = RequestInfo().parseRequestList(_requestList) ?? [];
        print('📡 상세 조회 응답: ${requestList.length}');
      });
    } catch (e) {
      print('신청 목록 조회 중 오류 발생: $e');
    }
  }

  Future<void> getRequesDetailtList(RequestInfo request) async {
    String restId = "getRequesDetailtList";

    String? clerkNo = await secureStorage.read(key: 'clerkNo');

    final param = jsonEncode({
      "categoryId": request.categoryId,
      "reqNo": request.reqNo,
      "reqUser": clerkNo,
    });

    try {
      final _requestDetailList = await sendPostRequest(restId, param);
      setState(() {
        requestDetailList = RequestInfo().parseRequestList(_requestDetailList) ?? [];
        print('📡 상세 조회 응답: ${jsonEncode(_requestDetailList)}');
      });
    } catch (e) {
      print('신청 목록 조회 중 오류 발생: $e');
    }
  }
}

class SectionWidget extends StatelessWidget {
  final String title;
  final List<ListItem> items;
  final VoidCallback onTap;

  const SectionWidget({required this.title, required this.items, required this.onTap});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () {
        print('SectionWidget tapped');
        onTap();
      },
      child: Container(
        width: width,
        padding: EdgeInsets.all(8.0),
        margin: EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목 탭 시 동작 (예: 상세로 이동 등)
            GestureDetector(
              onTap: onTap,
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
            for (var item in items) ...[
              SizedBox(height: 8.0),

              // 요청 내용 요약 박스
              Container(
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black54),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Text(
                  '- ${item.reqContents}',
                  style: TextStyle(fontSize: 16),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              SizedBox(height: 8.0),

              // 받은 견적 안내 텍스트
              Text(
                '- 받은 견적',
                style: WitHomeTheme.body1.copyWith(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              // 실제 받은 견적이 존재할 경우 테이블로 출력
              if (item.receivedEstimates.isNotEmpty) ...[
                SizedBox(height: 8.0),

                // 총 견적 수 텍스트
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      '총 ${item.receivedEstimates.length}건 견적 도착',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ),
                ),

                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue),
                  ),
                  child: Table(
                    border: TableBorder.all(color: Colors.grey),
                    columnWidths: {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(3),
                      2: FlexColumnWidth(3),
                    },
                    children: [
                      // 업체 Row
                      TableRow(
                        decoration: BoxDecoration(color: Colors.grey[200]),
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text("업체", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(item.receivedEstimates[0].companyNm, textAlign: TextAlign.center),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              item.receivedEstimates.length > 1 ? item.receivedEstimates[1].companyNm : '-',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),

                      // 견적가 Row
                      TableRow(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text("견적가", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('${formatCash(item.receivedEstimates[0].estimateAmount)}원', textAlign: TextAlign.center),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              item.receivedEstimates.length > 1
                                  ? '${formatCash(item.receivedEstimates[1].estimateAmount)}원'
                                  : '-',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),

                      // 평점 Row
                      TableRow(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text("평점", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset('assets/images/star.png', width: 16.0, height: 16.0),
                                SizedBox(width: 4.0),
                                Text(item.receivedEstimates[0].rate),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: item.receivedEstimates.length > 1
                                ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset('assets/images/star.png', width: 16.0, height: 16.0),
                                SizedBox(width: 4.0),
                                Text(item.receivedEstimates[1].rate),
                              ],
                            )
                                : Text("-", textAlign: TextAlign.center),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              ],
              Divider(),
            ],
          ],
        ),
      ),
    );
  }
}

class ListItem {
  final String companyId;
  final String companyNm;
  final String time;
  final String rate;
  final String estimateContents;
  final String reqDateInfo;
  final String reqState;
  final String reqStateNm;
  final String estimateAmount;
  final String reqContents;
  final List<EstimateItem> receivedEstimates; // 받은 견적 리스트 추가
  ListItem({
    required this.companyId,
    required this.companyNm,
    required this.time,
    required this.rate,
    required this.estimateContents,
    required this.reqDateInfo,
    required this.reqState,
    required this.reqStateNm,
    required this.estimateAmount,
    required this.reqContents,
    required this.receivedEstimates, // 초기화
  });


}
class EstimateItem {
  final String companyNm;
  final String estimateAmount;
  final String rate;

  EstimateItem({
    required this.companyNm,
    required this.estimateAmount,
    required this.rate,
  });
}
