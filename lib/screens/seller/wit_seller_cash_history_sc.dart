import 'dart:convert';
import 'package:witibju/screens/seller/wit_seller_cash_recharge_sc.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:witibju/screens/seller/wit_seller_profile_appbar_sc.dart';
import '../../util/wit_api_ut.dart';
import '../home/wit_home_theme.dart';

dynamic sllrNo;

class SellerCashHistory extends StatefulWidget {
  final dynamic sllrNo;
  const SellerCashHistory({Key? key, required this.sllrNo}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SellerCashHistoryState();
  }

}

class SellerCashHistoryState extends State<SellerCashHistory> {
  dynamic sellerInfo;
  List<dynamic> cashHistoryList = [];
  Map cashInfo = {};
  String storeName = "";

  @override
  void initState() {
    super.initState();
    getSellerInfo(widget.sllrNo);
    getCashInfo();
    getCashHistoryList(); // 초기화 시 이력 목록을 가져옵니다.
  }

  Future<void> getSellerInfo(dynamic sllrNo) async {

    String restId = "getSellerInfo";
    // PARAM
    final param = jsonEncode({
      "sllrNo": sllrNo,
    });

    print("sllrNo :" + sllrNo.toString());

    // API 호출
    final response = await sendPostRequest(restId, param);

    if (response != null) {
      setState(() {
        sellerInfo = response;
        storeName = sellerInfo['storeName'];
      });
    } else {
      // 오류 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("사업자 프로필 조회가 실패하였습니다.")),
      );
    }

  }

  Future<void> getCashInfo() async {
    // REST ID
    String restId = "getCashInfo";

    // PARAM
    final param = jsonEncode({
      "sllrNo": widget.sllrNo,
    });

    // API 호출 (사전 점검 미완료 리스트 조회)
    final _cashInfo = await sendPostRequest(restId, param);

    // 결과 셋팅
    setState(() {
      cashInfo = _cashInfo;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SellerAppBar(
        sllrNo: widget.sllrNo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              /*decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2.0),
                color: Colors.white,
              ),*/
              child: Row(
                children: [
                  Container(
                    color: WitHomeTheme.wit_gray,
                    padding: EdgeInsets.symmetric(
                        vertical: 5, horizontal: 10),
                    child: Text(
                      "IBJU",
                      style: WitHomeTheme.title.copyWith(fontSize: 20, color: WitHomeTheme.wit_white),
                    ),

                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerRight,
                      color: Colors.grey[300],
                      padding: EdgeInsets.symmetric(
                          vertical: 5, horizontal: 10),
                      child: Text(
                        (cashInfo['cash'] != null && cashInfo['cash'] != '')
                            ? '${NumberFormat('#,###').format(int.parse(cashInfo['cash']))} C'
                            : '0 C',
                        style: WitHomeTheme.title.copyWith(fontSize: 20),

                      ),
                    ),
                  )
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                print("sllrNo: " + widget.sllrNo.toString());

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CashRecharge(sllrNo: 17)),
                );
              },
              child: Text('충전하러가기 >>',
                style: WitHomeTheme.title.copyWith(fontSize: 16),
              ),
            ),
            SizedBox(height: 20),
            Text(
              '* 캐시 사용이력',
              style: WitHomeTheme.title.copyWith(fontSize: 16),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: cashHistoryList.length,
                itemBuilder: (context, index) {
                  final item = cashHistoryList[index];
                  return _buildHistoryItem(
                    item['cash'].toString(),
                    item['cashGbn'].toString(),
                    item['creDt'].toString(),
                    item['itemName'].toString(), // itemName 추가
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(String cash, String cashGbn, String creDt, String itemName) {
    return Container(
      padding: EdgeInsets.all(8.0),
      margin: EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(itemName,
                style: WitHomeTheme.title.copyWith(fontSize: 16),
              ),
              Text('$cash $cashGbn',
                style: WitHomeTheme.subtitle.copyWith(fontSize: 16),
              ),
            ],
          ),
          Text(creDt,
            style: WitHomeTheme.title.copyWith(fontSize: 12, color: WitHomeTheme.wit_gray),
          ),
        ],
      ),
    );
  }

  // [서비스] 캐시 이력 목록 조회
  Future<void> getCashHistoryList() async {
    // REST ID
    String restId = "getCashHistoryList";

    // PARAM
    final param = jsonEncode({
      "sllrNo": widget.sllrNo, // stat을 사용하여 API에 전달
    });

    // API 호출 (사전 점검 미완료 리스트 조회)
    final _cashHistoryList = await sendPostRequest(restId, param);

    // 결과 셋팅
    setState(() {
      cashHistoryList = _cashHistoryList;
    });
  }
}
