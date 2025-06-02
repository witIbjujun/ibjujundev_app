import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:witibju/screens/home/widgets/wit_home_bottom_nav_bar.dart';
import 'package:witibju/screens/home/widgets/wit_home_widgets.dart';
import 'package:witibju/screens/home/wit_home_sc.dart';
import 'package:witibju/screens/home/wit_home_theme.dart';
import 'package:witibju/screens/home/wit_requestBest_detail.dart';
import 'package:witibju/screens/home/wit_request_detail.dart';

import '../../util/wit_api_ut.dart';
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
  bool _isLoading = true; // 2025-05-26: 로딩 상태
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
                  _isLoading
                      ? const Center(
                    child: CircularProgressIndicator(), // ✅ 로딩 중일 때만 표시
                  )
                      : (requestList.isEmpty
                      ? const EmptyImageWidget(width: 200, height: 200) // ✅ 로딩 끝났고 결과 없음
                      : SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 8.0),
                        ..._buildReqNoSections(), // ✅ 결과 있음
                      ],
                    ),
                  )
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
                      selCategoryNm: entry.value.first.selCategoryNm,
                      reqGubun: entry.value.first.reqGubun,
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
    await runWithLoading(
        setLoading: (bool val) => setState(() => _isLoading = val),
        action: () async {
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
        },
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

    // 🔸 reqContents 출력 내용 사전 계산 (삼항 연산 제거, if문 사용)
    String textToShow = '';
    if (items.first.reqGubun == "T") {
      textToShow = '[${items.first.selCategoryNm}]\n\n${items.first.reqContents}';
    } else {
      textToShow = items.first.reqContents;
    }
    return GestureDetector(
      onTap: () {
        print('SectionWidget tapped');
        if (items.isNotEmpty) {
          if (items.first.reqGubun == "T") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RequestBestDetailScreen(
                  categoryId: items.first.categoryId,
                  reqNo: items.first.reqNo,
                  companyCnt: items.first.companyCnt,
                ),
              ),
            );
          } else {
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
          }
        }
      },
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          image: const DecorationImage(
            image: AssetImage('assets/home/estimateback2.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var item in items) ...[
              // 🔸 실제 받은 견적이 존재할 경우 테이블 출력
              if (item.receivedEstimates.isNotEmpty) ...[
                const SizedBox(height: 5.0),

                // 🔸 전체 카드 클릭 영역
                GestureDetector(
                  // 2025-06-02: 받은 견적 없을 때 예외 처리 포함한 조건 분기
                  onTap: () {
                    print('SectionWidget tapped');
                    if (items.isNotEmpty && items.first.companyCnt != "0") {
                      if (items.first.reqGubun == "T") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RequestBestDetailScreen(
                              categoryId: items.first.categoryId,
                              reqNo: items.first.reqNo,
                              companyCnt: items.first.companyCnt,
                            ),
                          ),
                        );
                      } else {
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
                      }
                    } else {
                      DialogUtils.showIPhoneAlertDialog(
                        context: context,
                        title: '',
                        content: '받은 견적이 없습니다.',
                      );
                    }
                  },
                  child: Container(
                    width: width,
                    padding: const EdgeInsets.all(8.0),
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      image: const DecorationImage(
                        image: AssetImage('assets/home/estimateback2.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 🔹 제목
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),

                        const SizedBox(height: 16.0),

                        // 🔹 요청 내용 (reqGubun에 따라 다르게 출력됨)
                        Text(
                          textToShow,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 15.0,
                            fontFamily: 'NotoSansKR',
                          ),
                          maxLines: 3,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 16.0),

                        // 🔹 견적 상태 태그
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.all(6.0),
                            decoration: BoxDecoration(
                              image: const DecorationImage(
                                image: AssetImage('assets/home/estimateback_detail1.png'),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: Text(
                              item.reqState == "10"
                                  ? '# 견적대기중'
                                  : '# 총 ${item.companyCnt}건 견적 도착',
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
                ),
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
  final String reqGubun;
  final String reqContents;
  final String selCategoryNm;
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
    required this.reqGubun,
    required this.selCategoryNm,
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
