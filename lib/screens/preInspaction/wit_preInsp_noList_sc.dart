import 'package:flutter/material.dart';
import 'package:witibju/screens/preInspaction/widgets/wit_preInsp_noList_widget.dart';
import 'dart:convert';
import '../../util/wit_api_ut.dart';

class PreInspactionNoList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PreInspactionNoListState();
  }
}

class PreInspactionNoListState extends State<PreInspactionNoList> {
  List<dynamic> preinspactionNoList = [];
  int? expandedIndex = 0;

  @override
  void initState() {
    super.initState();
    // 사전 점검 미완료 리스트 조회
    getPreinspactionNoList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            "미완료 체크리스트",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              letterSpacing: 1.5,
              color: Colors.black,
            ),
          ),
        ),
        body: PreInspactionNoListUI(
          preinspactionNoList: preinspactionNoList,
          onToggle: (index, value) {
            setState(() {
              preinspactionNoList[index]["checkYn"] = value ? "N" : "Y";
              savePreinspactionInfo(preinspactionNoList[index], value ? "N" : "Y");
            });
            setState(() {
              expandedIndex = expandedIndex == index ? null : index; // 클릭 시 상태 변경
            });
          },
          expandedIndex: expandedIndex,
          onExpand: (index) {
            setState(() {
              expandedIndex = expandedIndex == index ? null : index; // 클릭 시 상태 변경
            });
          },
        ),
      ),
    );
  }

  // [서비스] 사전 점검 미완료 리스트 조회
  Future<void> getPreinspactionNoList() async {
    // REST ID
    String restId = "getPreinspactionNoList";

    // PARAM
    final param = jsonEncode({});

    // API 호출 (사전 점검 미완료 리스트 조회)
    final _preinspactionNoList = await sendPostRequest(restId, param);

    // 결과 셋팅
    setState(() {
      preinspactionNoList = _preinspactionNoList;
    });
  }

  // [서비스] 사전 점검 상세 저장
  Future<void> savePreinspactionInfo(dynamic item, String newCheckYn) async {
    // REST ID
    String restId = "savePreinspactionInfo";

    // PARAM
    final param = jsonEncode({
      "inspId": item["inspId"],
      "inspDetlId": item["inspDetlId"],
      "checkYn": newCheckYn
    });

    // API 호출 (사전점검 상세 항목 리스트 조회)
    final result = await sendPostRequest(restId, param);

    print("결과2 ::: " + result.toString());
  }
}