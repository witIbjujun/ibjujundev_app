import 'dart:convert';
import 'package:witibju/screens/seller/wit_seller_cash_recharge_sc.dart';
import 'package:witibju/screens/seller/wit_seller_esitmaterequest_directsetModify_sc.dart';
import 'package:witibju/screens/seller/wit_seller_esitmaterequest_directset_sc.dart';
import 'package:flutter/material.dart';
import 'package:witibju/screens/seller/wit_seller_profile_appbar_sc.dart';
import '../../util/wit_api_ut.dart';
import '../home/wit_home_theme.dart';

class EstimateRequestDirectList extends StatefulWidget {
  final dynamic sllrNo;
  const EstimateRequestDirectList({Key? key, required this.sllrNo}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return EstimateRequestDirectListState();
  }
}

class EstimateRequestDirectListState extends State<EstimateRequestDirectList> {
  dynamic sellerInfo;
  String storeName = "";
  List<dynamic> directEstimateSetList = [];

  @override
  void initState() {
    super.initState();
    getSellerInfo(widget.sllrNo);
    getDirectEstimateSetList(widget.sllrNo);
  }

  Future<void> getSellerInfo(dynamic sllrNo) async {
    String restId = "getSellerInfo";
    final param = jsonEncode({"sllrNo": sllrNo});
    final response = await sendPostRequest(restId, param);

    if (response != null) {
      setState(() {
        sellerInfo = response;
        storeName = sellerInfo['storeName'];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("사업자 프로필 조회가 실패하였습니다.")),
      );
    }
  }

  Future<void> getDirectEstimateSetList(dynamic sllrNo) async {
    String restId = "getDirectEstimateSetList";
    final param = jsonEncode({"sllrNo": widget.sllrNo});
    final response = await sendPostRequest(restId, param);

    if (response != null) {
      setState(() {
        directEstimateSetList = response;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("바로견적 설정 목록 조회가 실패하였습니다.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*appBar: SellerAppBar(
        sllrNo: widget.sllrNo,
      ),*/
      appBar: AppBar(
        backgroundColor: WitHomeTheme.wit_gray,
        iconTheme: const IconThemeData(color: WitHomeTheme.wit_white),
        title: Text(
          '바로견적',
          style: WitHomeTheme.title.copyWith(color: WitHomeTheme.wit_white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '바로견적을 활용하는 방법이 궁금하신가요?',
              style: WitHomeTheme.title.copyWith(fontSize: 16),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EstimateRequestDirectSet(
                      sllrNo: widget.sllrNo,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF63A566),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('+ 바로 견적 등록하기',
                style: WitHomeTheme.title.copyWith(fontSize: 16, color: WitHomeTheme.wit_white),
              ),
            ),
            Divider(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: directEstimateSetList.length,
                itemBuilder: (context, index) {
                  final estimate = directEstimateSetList[index];

                  /*print("todaySendCash: ${estimate['todaySendCash']}");
                  print("todaySendCnt: ${estimate['todaySendCnt']}");
                  print("esdrSendCnt: ${estimate['esdrSendCnt']}");*/
                  return GestureDetector(
                    onTap: () {
                      // EstimateRequestDirect로 페이지 이동
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EstimateRequestDirectSetModify(
                            sllrNo: int.tryParse(estimate['sllrNo'].toString()),
                            esdrNo: estimate['esdrNo'],
                          ),
                        ),
                      );
                    },
                    child: InfoCard(
                      title: estimate['categoryNm'], // categoryNm을 제목으로 사용
                      current: int.tryParse(estimate['todaySendCnt']?.toString() ?? '0') ?? 0, // 오늘 발송 개수
                      total: int.tryParse(estimate['esdrSendCnt']?.toString() ?? '0') ?? 0,   // 발송 설정 개수
                      //todayCash: int.tryParse(estimate['todaySendCash']?.toString() ?? '0') ?? 0, // 오늘 사용 캐시 (예시로 0으로 설정)
                      todayCash: estimate['todaySendCash'].toString(), // 오늘 사용 캐시 (예시로 0으로 설정)
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final int current;
  final int total;
  final String todayCash;

  InfoCard({
    required this.title,
    required this.current,
    required this.total,
    required this.todayCash,
  });

  @override
  Widget build(BuildContext context) {
    double progressValue = total > 0 ? current / total : 0.0; // total이 0일 경우 0으로 설정
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: WitHomeTheme.title.copyWith(fontSize: 20),
            ),
            SizedBox(height: 10),
            LinearProgressIndicator(
              value: progressValue,
            ),
            SizedBox(height: 10),
            Text('오늘 견적 발송: $current/$total개',
              style: WitHomeTheme.subtitle.copyWith(fontSize: 16),
            ),
            Text('오늘 사용 캐시: $todayCash 캐시',
              style: WitHomeTheme.subtitle.copyWith(fontSize: 16),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          CashRecharge(sllrNo: 17)),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: WitHomeTheme.wit_lightSteelBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('캐시 충전하기',
                style: WitHomeTheme.title.copyWith(fontSize: 16, color: WitHomeTheme.wit_white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}