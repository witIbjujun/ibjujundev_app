import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:witibju/screens/home/widgets/wit_home_bottom_nav_bar.dart';
import 'package:witibju/screens/home/widgets/wit_home_widgets.dart';
import 'package:witibju/screens/home/widgets/wit_home_widgets2.dart';
import 'package:witibju/screens/home/wit_home_sc.dart';
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
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text(
            '견적 요청 화면',
            style: TextStyle(
              color: Colors.white,             // 텍스트 색상
              fontSize: 20.0,                  // 폰트 크기
              fontWeight: FontWeight.bold,     // 굵기
              fontFamily: 'NotoSansKR',        // 폰트 지정 (선택)
            ),
          ),
          iconTheme: IconThemeData(color: Colors.white), // ← 아이콘 색상도 검정으로 맞추려면 추가
        ),
        body: Column(
          children: [
            // 광고 영역
            Container(
              height: 180,
              color: WitHomeTheme.white,
              child: CommonImageBanner(
                imagePath: 'assets/home/gongguBanner.png',
                heightRatio: 0.18,
                widthRatio: 0.85,
              ),
            ),

            // 견적 및 알림 탭
            WitHomeWidgets.getTabBarUI(_tabController, ['견적', '알림']),

            // 탭 내용
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // 📌 견적탭
                  requestList.isEmpty
                      ? showEmptyImage()   // 🔥 조회 결과가 없을 때
                      : SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: 8.0),
                        ..._buildReqNoSections(),
                      ],
                    ),
                  ),
                  // 📌 알림탭
                  WitEstimateNoticeScreen(),
                ],
              ),
            )
          ],
        ),
        bottomNavigationBar: BottomNavBar(selectedIndex: _selectedIndex),
      ),
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
                      categoryId: entry.value.first.categoryId,
                      reqNo: entry.value.first.reqNo,
                      companyNm: entry.value.first.companyNm,
                      time: entry.value.first.reqDate ?? '',
                      rate: entry.value.first.rate,
                      companyCnt: entry.value.first.companyCnt, // 🔥 여기 꼭 추가해야 해!
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
    print('📡 상세 조회 응답: 실행 중...');

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

  /// 빈 화면 이미지 보여주기 (견적탭 아래 중앙 정렬)
  Widget showEmptyImage({double width = 200, double height = 200}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/home/emptyInfo.png',
            width: width,
            height: height,
          ),
        ],
      ),
    );
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
        if (items.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RequestDetailScreen(
                categoryId: items.first.categoryId,
                reqNo: items.first.reqNo,
                companyCnt: items.first.companyCnt
              ),
            ),
          );
        }
      },
      child: Container(
        width: width,
        padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0), // 🔥 패딩 수정 (위아래 넓힘)
        margin: EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          image: DecorationImage(
            image: AssetImage('assets/home/estimateback2.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var item in items) ...[
              // 실제 받은 견적이 존재할 경우 테이블로 출력
              if (item.receivedEstimates.isNotEmpty) ...[
                SizedBox(height: 5.0),
                // 2025-03-22 수정: 총 견적 수 텍스트 클릭 시 상세화면 이동
                GestureDetector(
                  onTap: () {
                    print('SectionWidget tapped');
                    if (items.isNotEmpty && items.first.companyCnt != "0") {
                      // 🔥 companyCnt가 "0"이 아니어야 이동
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RequestDetailScreen(
                            categoryId: items.first.categoryId,
                            reqNo: items.first.reqNo,
                            companyCnt: items.first.companyCnt,
                          ),
                        ),
                      );
                    } else {
                      // 이동은 막고 아무것도 안함 (또는 토스트만 띄워도 됨)
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('받은 견적이 없습니다.')),
                      );
                    }
                  },
                  child: Container(
                    width: width,
                    padding: EdgeInsets.all(8.0),
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      image: DecorationImage(
                        image: AssetImage('assets/home/estimateback2.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 16.0),
                        Text(
                          items.first.reqContents,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15.0,
                            fontFamily: 'NotoSansKR',
                          ),
                          maxLines: 2,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 16.0),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: EdgeInsets.all(6.0),
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/home/estimateback_detail1.png'),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: Text(

                              items.first.reqState == "10"
                                  ? '# 견적대기중'
                                  : '# 총 ${items.first.companyCnt}건 견적 도착',
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'NotoSansKR',
                                color: Colors.grey[800],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
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
  final String categoryId;
  final String reqNo;
  final String time;
  final String rate;
  final String estimateContents;
  final String reqDateInfo;
  final String reqState;
  final String reqStateNm;
  final String estimateAmount;
  final String reqContents;
  final String companyCnt;

  final List<EstimateItem> receivedEstimates; // 받은 견적 리스트 추가
  ListItem({
    required this.companyId,
    required this.companyNm,
    required this.categoryId,
    required this.reqNo,
    required this.time,
    required this.rate,
    required this.companyCnt,
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
