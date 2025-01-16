import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:witibju/screens/checkList/widget/wit_checkList_detail_widget.dart';
import 'package:witibju/util/wit_api_ut.dart';

/**
 * 사전 체크리스트 상세
 */
class CheckListDetail extends StatefulWidget {

  final dynamic checkInfoLv1;

  const CheckListDetail({Key? key, required this.checkInfoLv1}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return CheckListDetailState();
  }
}

/**
 * 사전 체크리스트 상세 State
 */
class CheckListDetailState extends State<CheckListDetail> with TickerProviderStateMixin {

  List<dynamic> checkListByLv2 = [];      // 사전 점검 항목 리스트 (레벨2)
  List<dynamic> checkListByLv3 = [];      // 사전 점검 항목 리스트 (레벨3)
  TabController? _tabController;          // TAB 컨트롤러

  /**
   * 화면 초기화
   */
  @override
  void initState() {
    super.initState();

    // 사전 점검 상세 조회 (Lv2)
    getCheckListByLv2();
  }

  /**
   * 화면 UI
   */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          widget.checkInfoLv1["inspNm"],
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: CheckListDetailView(
        checkInfoLv1: widget.checkInfoLv1,
        checkListByLv2: checkListByLv2,
        checkListByLv3: checkListByLv3,
        tabController: _tabController ?? TabController(length: 0, vsync: this), // null 체크
        onTabChanged: (inspId) {
          getCheckListByLv3(inspId);
        },
        onSwitchChanged: (item, newCheckYn) {
          setState(() {
            item["checkYn"] = newCheckYn;
            saveCheckInfo(item, newCheckYn);
          });
        },
      ),
    );
  }

  // [서비스] 사전 점검 상세 조회 (Lv2)
  Future<void> getCheckListByLv2() async {

    // REST ID
    String restId = "getPreinspactionListByLv2";

    // PARAM
    final param = jsonEncode({
      "inspId": widget.checkInfoLv1["inspId"],
    });

    final _preinspactionListByLv2 = await sendPostRequest(restId, param);

    setState(() {
      checkListByLv2 = _preinspactionListByLv2;
      _tabController = TabController(length: checkListByLv2.length, vsync: this);

      if (checkListByLv2.isNotEmpty) {
        getCheckListByLv3(checkListByLv2[0]["inspId"]);
      }
    });
  }

  // [서비스] 사전 점검 상세 조회 (Lv3)
  Future<void> getCheckListByLv3(String inspId) async {

    // REST ID
    String restId = "getPreinspactionListByLv3";

    // PARAM
    final param = jsonEncode({
      "parentsInspId": widget.checkInfoLv1["inspId"],
      "inspId": inspId,
    });

    // API 호출 (사전 점검 상세 조회 (Lv3))
    final _preinspactionListByLv3 = await sendPostRequest(restId, param);

    // 데이터 셋팅
    setState(() {
      checkListByLv3 = _preinspactionListByLv3;
    });
  }

  // [서비스] 사전 점검 상세 저장
  Future<void> saveCheckInfo(dynamic item, String newCheckYn) async {

    // REST ID
    String restId = "savePreinspactionInfo";

    // PARAM
    final param = jsonEncode({
      "inspId": widget.checkInfoLv1["inspId"],
      "inspDetlId": item["inspId"],
      "checkYn": newCheckYn,
      "checkDate": item["checkDate"],
      "reprDate": item["reprDate"],
      "checkComt": item["checkComt"],
    });

    // API 호출 (사전점검 상세 항목 저장)
    final result = await sendPostRequest(restId, param);

    // 결과값이 0보다 크면 카운트 업데이트
    if (result > 0) {
      updateCheckCountInLv2();
    }
  }

  // [서비스] 체크 카운트 업데이트
  void updateCheckCountInLv2() {

    // "Y" 값 카운트
    int yCount = checkListByLv3.where((item) => item["checkYn"] == "Y").length;

    // 현재 활성화된 탭의 인덱스
    var currentTabIndex = _tabController?.index;

    if (currentTabIndex != null && currentTabIndex < checkListByLv2.length) {

      // 해당 탭의 checkCnt 업데이트
      setState(() {
        checkListByLv2[currentTabIndex]["checkCnt"] = yCount;
      });

    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }
}
