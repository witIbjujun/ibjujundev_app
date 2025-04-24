import 'dart:convert';
import 'package:witibju/screens/seller/wit_seller_cash_recharge_sc.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:witibju/screens/seller/wit_seller_profile_appbar_sc.dart';
import '../../util/wit_api_ut.dart';
import '../home/wit_home_theme.dart';
import '../tosspayments/home.dart';

class SellerAptSubscribe extends StatefulWidget {
  final dynamic sllrNo;

  const SellerAptSubscribe({Key? key, required this.sllrNo}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SellerAptSubscribeState();
  }
}

class SellerAptSubscribeState extends State<SellerAptSubscribe> {
  dynamic sellerInfo;
  String storeName = "";
  String? selectedCash; // 선택된 캐시 금액을 저장할 변수

  // 아파트구독 리스트
  List<dynamic> subscribeAptList = [];

  @override
  void initState() {
    super.initState();
    getSellerInfo(widget.sllrNo);
    getSubscribeAptList();
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
        print('Store Name: $storeName');
      });
    } else {
      // 오류 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("사업자 프로필 조회가 실패하였습니다.")),
      );
    }

  }

  // 아파트 구독 리스트
  Future<void> getSubscribeAptList() async {
    String restId = "getSubscribeAptList";

    // PARAM
    final param = jsonEncode({
      "sllrNo": widget.sllrNo,
      "searchType": "",
    });

    // API 호출
    final response = await sendPostRequest(restId, param);

    if (response != null) {
      setState(() {
        subscribeAptList = response;
      });
    } else {
      // 오류 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("아파트 구독 리스트 조회가 실패하였습니다.")),
      );
    }
  }

  // 아파트 구독
  Future<void> insertSubscribeApt(dynamic aptNo) async {
    String restId = "insertSubscribeApt";

    // PARAM
    final param = jsonEncode({
      "sllrNo": widget.sllrNo,
      "aptNo": aptNo,
    });

    // API 호출
    final response = await sendPostRequest(restId, param);

    if (response != null) {
      // 성공 후 리스트 다시 가져오기
      getSubscribeAptList();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("아파트 구독이 성공하였습니다.")),
      );
    } else {
      // 오류 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("아파트 구독이 실패하였습니다.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: WitHomeTheme.wit_white,
        body: ListView.builder(
          padding: EdgeInsets.all(16.0),
          itemCount: getItemCount(), // 아이템 개수 계산
          itemBuilder: (context, index) {
            return _buildItem(context, index);
          },
        ),
      ),
    );
  }

  int getItemCount() {
    if (subscribeAptList.isEmpty) return 0;

    // 중복된 month를 제외한 개수 계산
    String? currentMonth;
    int count = 0;

    for (int i = 0; i < subscribeAptList.length; i++) {
      String month = subscribeAptList[i]['moveinScjDate'] ?? '미정';
      if (currentMonth != month) {
        count++;
        currentMonth = month;
      }
    }
    return count;
  }

  Widget _buildItem(BuildContext context, int index) {
    String? currentMonth;
    int dataIndex = 0; // subscribeAptList의 실제 index

    // index에 해당하는 month 찾기
    for (int i = 0; i <= index; i++) {
      String month = subscribeAptList[dataIndex]['moveinScjDate'] ?? '미정';
      if (currentMonth != month) {
        currentMonth = month;
      } else {
        i--; // month가 같으면 index 유지
      }
      if (dataIndex < subscribeAptList.length - 1) {
        dataIndex++;
      }
    }

    // 해당 month의 데이터 필터링
    List<dynamic> itemsForMonth = subscribeAptList
        .where((item) => (item['moveinScjDate'] ?? '미정') == currentMonth)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(currentMonth!,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        ...itemsForMonth
            .map((item) => _buildCardItem(
          item['moveinScjDate'] ?? '미정',
          item['splSize'] + ' 세대',
          item['aptName'],
          item['stat'],
          item['aptNo'], // aptNo 추
          item['sscAmt'], // aptNo 추
          item['saleAmt'], // aptNo 추
        ))
            .toList(),
        SizedBox(height: 16), // 그룹 간 간격
      ],
    );
  }

  Widget _buildCardItem(
      String month, String unit, String description, String action, dynamic aptNo, dynamic sscAmt, dynamic saleAmt) {
    return Card(
      elevation: 0,
      color: Colors.grey[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      margin: EdgeInsets.symmetric(vertical: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.apartment, size: 24, color: Colors.grey[600]),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(unit, style: WitHomeTheme.title.copyWith(fontSize: 14)),
                  Text(description, style: WitHomeTheme.title.copyWith(fontSize: 14)),
                  Row(
                    children: [
                      Text(
                        sscAmt.toString() + '원',
                        style: TextStyle(
                          color: WitHomeTheme.wit_gray,
                          decoration: TextDecoration.lineThrough,
                          decorationColor: Colors.red,
                          fontSize: 13,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        ' -> ' + saleAmt.toString().split('.')[0] + '원',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(width: 6),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.local_offer, size: 14, color: Colors.white), // 🎯 세일 아이콘
                            SizedBox(width: 2),
                            Text(
                              'SALE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () async {
                if (action == '구독하기') {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TossHome(
                        selectedCash: saleAmt.toString().split('.')[0],
                        storeName: storeName,
                        email: sellerInfo['email'],
                        sllrNo: widget.sllrNo,
                        aptNo: aptNo,
                      ),
                    ),
                  );

                  if (result == 'success') {
                    insertSubscribeApt(aptNo); // ✅ 결제 성공 후 구독 처리
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("구독이 완료되었습니다.")),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("구독이 취소되었거나 실패했습니다.")),
                    );
                  }
                }
              },

              style: TextButton.styleFrom(
                backgroundColor: action == '구독하기' ? WitHomeTheme.wit_lightGreen : WitHomeTheme.wit_lightgray,
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                minimumSize: Size(80.0, 36.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              child: Text(
                action,
                style: WitHomeTheme.subtitle.copyWith(fontSize: 14, color: WitHomeTheme.wit_black),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
