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
  List<dynamic> cashHistoryList = [];
  Map cashInfo = {};
  String storeName = "";

  @override
  void initState() {
    super.initState();
    getSellerInfo(widget.sllrNo);
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
          children: [
            _buildItem('24년 8월', [
              _buildSubItem('616세대', '동탄 숨마데시안', '구독중'),
              _buildSubItem('640세대', '동탄 어울림 파밀리에', '구독중'),
            ]),
            _buildItem('24년 9월', [
              _buildSubItem('916세대', '편한세상 평택 하이센트(4BL)', '구독하기'),
              _buildSubItem('1063세대', '편한세상 평택 라시엣(2-1BL)', '구독하기'),
            ]),
            _buildItem('24년 10월', [
              _buildSubItem('492세대', '외국인치지구 대방 디에트르 센터럴(B1BL)', '구독하기'),
              _buildSubItem('250세대', '남양주 빌리브세트하이', '구독하기'),
            ]),
          ],
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(unit, style: TextStyle(fontSize: 16)),
              Text(description, style: TextStyle(color: Colors.grey)),
            ],
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