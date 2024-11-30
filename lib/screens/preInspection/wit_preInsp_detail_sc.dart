import 'package:app/screens/preInspection/widgets/wit_preInsp_detail_widget.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:app/util/wit_api_ut.dart';
import 'package:flutter/services.dart';

dynamic preinspactionInfo = {}; // 선택한 체크리스트 객체

/**
 * 사전 체크리스트 상세
 */
class PreInspactionDetail extends StatefulWidget {
  final dynamic param;

  const PreInspactionDetail({Key? key, required this.param}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    preinspactionInfo = this.param;
    return PreInspactionDetailState();
  }
}

/**
 * 사전 체크리스트 상세 State
 */
class PreInspactionDetailState extends State<PreInspactionDetail> with TickerProviderStateMixin {

  List<dynamic> preinspactionListByLv2 = [];  // 사전 점검 항목 리스트 (레벨2)
  List<dynamic> preinspactionListByLv3 = [];  // 사전 점검 항목 리스트 (레벨3)
  TabController? _tabController;              // TAB 컨트롤러

  /*****************************************************************************************
   * 초기화
   *****************************************************************************************/
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    // 사전 점검 상세 조회 (Lv2)
    getPreinspactionListByLv2();
  }

  /*****************************************************************************************
   * UI 영역
   *****************************************************************************************/
  @override
  Widget build(BuildContext context) {
    return PreInspactionDetailUI(
      inspNm: preinspactionInfo["inspNm"],
      preinspactionListByLv2: preinspactionListByLv2,
      preinspactionListByLv3: preinspactionListByLv3,
      tabController: _tabController ?? TabController(length: 0, vsync: this), // null 체크
      onTabChanged: (inspId) {
        getPreinspactionListByLv3(inspId);
      },
      onSwitchChanged: (item, newCheckYn) {
        setState(() {
          item["checkYn"] = newCheckYn;
          savePreinspactionInfo(item, newCheckYn);
        });
      },
    );
  }

  // [서비스] 사전 점검 상세 조회 (Lv2)
  Future<void> getPreinspactionListByLv2() async {
    String restId = "getPreinspactionListByLv2";
    final param = jsonEncode({
      "inspId": preinspactionInfo["inspId"],
    });
    final _preinspactionListByLv2 = await sendPostRequest(restId, param);

    setState(() {
      preinspactionListByLv2 = _preinspactionListByLv2;
      _tabController = TabController(length: preinspactionListByLv2.length, vsync: this);

      if (preinspactionListByLv2.isNotEmpty) {
        getPreinspactionListByLv3(preinspactionListByLv2[0]["inspId"]);
      }
    });
  }

  // [서비스] 사전 점검 상세 조회 (Lv3)
  Future<void> getPreinspactionListByLv3(String inspId) async {
    String restId = "getPreinspactionListByLv3";
    final param = jsonEncode({
        "parentsInspId": preinspactionInfo["inspId"],
      "inspId": inspId,
    });

    // API 호출 (사전 점검 상세 조회 (Lv3))
    final _preinspactionListByLv3 = await sendPostRequest(restId, param);

    // 데이터 셋팅
    setState(() {
      preinspactionListByLv3 = _preinspactionListByLv3;
    });
  }

  // [서비스] 사전 점검 상세 저장
  Future<void> savePreinspactionInfo(dynamic item, String newCheckYn) async {
    // REST ID
    String restId = "savePreinspactionInfo";

    // PARAM
    final param = jsonEncode({
      "inspId": preinspactionInfo["inspId"],
      "inspDetlId": item["inspId"],
      "checkYn": newCheckYn,
    });

    // API 호출 (사전점검 상세 항목 저장)
    final result = await sendPostRequest(restId, param);

    print(result);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }
}

