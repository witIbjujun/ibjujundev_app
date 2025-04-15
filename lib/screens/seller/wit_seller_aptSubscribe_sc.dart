import 'dart:convert';
import 'package:witibju/screens/seller/wit_seller_cash_recharge_sc.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:witibju/screens/seller/wit_seller_profile_appbar_sc.dart';
import '../../util/wit_api_ut.dart';
import '../home/wit_home_theme.dart';

dynamic sllrNo;

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
  // 아파트구독 리스트
  List<dynamic> subscribeAptList= [];

  @override
  void initState() {
    super.initState();
    // getSellerInfo(widget.sllrNo);
    getSubscribeAptList(widget.sllrNo);
  }

 /* Future<void> getSellerInfo(dynamic sllrNo) async {

    String restId = "getSellerInfo";
    // PARAM
    final param = jsonEncode({
      //"sllrNo": sllrNo,
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

  }*/

  // 아파트 구독 리스트
  Future<void> getSubscribeAptList(dynamic sllrNo) async {
    String restId = "getSubscribeAptList";

    // PARAM
    final param = jsonEncode({
      "sllrNo": sllrNo,
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: WitHomeTheme.wit_black,
          iconTheme: const IconThemeData(color: WitHomeTheme.wit_white),
          title: Text(
            '입주 APT',
            style: WitHomeTheme.title.copyWith(color: WitHomeTheme.wit_white),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: ListView(
          padding: EdgeInsets.all(16.0),
          children: subscribeAptList.map((item) {
            String month = item['moveinScjDate'] ?? '미정'; // moveinScjDate가 null이면 "미정"을 사용
            String aptName = item['aptName']; // 아파트 이름은 'aptName' 키에서 가져옴
            String splSize = item['splSize'] + ' 세대';
            String stat = item['stat'];

            // 각 아파트 정보를 _buildSubItem으로 전달
            Widget subItem = _buildSubItem(splSize, aptName, stat);

            // 월 정보와 아파트 정보를 함께 _buildItem으로 전달
            return _buildItem(month, [subItem]); // subItems는 List<Widget> 형태여야 함
          }).toList(),
        ),


      ),
    );
  }

  Widget _buildItem(String month, List<Widget> subItems) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(month, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        ...subItems,
        Divider(),
      ],
    );
  }

  Widget _buildSubItem(String unit, String description, String action) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded( // Expanded로 감싸서 공간을 나누어 가지도록 함
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(unit, style: TextStyle(fontSize: 16)),
                Text(description, style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              // 버튼 클릭 시 행동 정의
            },
            child: Text(action, style: TextStyle(color: action == '구독하기' ? Colors.blue : Colors.green)),
          ),
        ],
      ),
    );
  }
}