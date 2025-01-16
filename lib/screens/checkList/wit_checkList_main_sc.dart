import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ibjujundev_admin_app/screens/checkList/widget/wit_checkList_main_widget.dart';
import 'package:ibjujundev_admin_app/util/wit_api_ut.dart';
import 'package:shared_preferences/shared_preferences.dart';

/**
 * 사전 체크리스트 메인
 */
class CheckListMain extends StatefulWidget {

  // 생성자
  const CheckListMain({super.key});

  // 상태 생성
  @override
  State<StatefulWidget> createState() {
    return CheckListMainState();
  }
}

/**
 * 사전 체크리스트 UI
 */
class CheckListMainState extends State<CheckListMain> {

  bool isEditing = false; // 수정 모드 상태 변수
  List<dynamic> checkList = []; // 사전 체크리스트 목록 리스트

  /**
   * 화면 초기화
   */
  @override
  void initState() {
    super.initState();

    // 사전 체크리스트 목록 조회 (Lv1)
    getCheckListByLv1();
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
          isEditing == false ? "입주전 체크리스트" : "입주전 체크리스트 설정",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (isEditing)
          IconButton(
            icon: Icon(Icons.refresh),
            color: Colors.black,
            onPressed: () {
              setState(() {
                // 체크리스트 설정 초기화
                initSwitchStates();
              });
            },
          ),
          IconButton(
            icon: Icon(isEditing ? Icons.check : Icons.settings),
            color: Colors.black,
            onPressed: () {
              setState(() {
                if (isEditing) {
                  // 체크 아이콘 클릭 시 상태 저장
                  _saveAllSwitchStates();
                }
                isEditing = !isEditing;
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: checkList.isEmpty
            ? Center(
          child: Text("조회된 데이터가 없습니다.",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        )
            : CheckListView(
          listData: isEditing ? checkList : checkList.where((item) => item["isSelected"]).toList(),
          callback: getCheckListByLv1,
          edited: isEditing,
        ),
      ),
    );
  }

  // [서비스] 사전 체크리스트 목록 조회
  Future<void> getCheckListByLv1() async {

    // 데이터 초기화
    checkList = [];

    // REST ID
    String restId = "getPreinspactionListByLv1";

    // API 호출 (사전 체크리스트 목록 조회)
    final _checkList = await sendPostRequest(restId, null);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString("WIT_PRE_SWITCH_STATES");

    setState(() {
      if (jsonString != null && jsonString != "") {
        List<dynamic> jsonList = jsonDecode(jsonString);
        List<Map<String, dynamic>> checkSaveData = List<Map<String, dynamic>>.from(jsonList);

        for (Map<String, dynamic> item in checkSaveData) {
          for (dynamic item2 in _checkList) {
            if (item2["inspId"] == item["inspId"]) {
              item2["isSelected"] = item["isSelected"];
            }
          }
        }
      } else {
        for (dynamic item in _checkList) {
          item["isSelected"] = true;
        }
      }
      checkList = _checkList;
    });
  }

  // [유틸] 전체 스위치 상태를 SharedPreferences에 저장
  Future<void> _saveAllSwitchStates() async {

    List<Map<String, dynamic>> stateList = [];

    for (var item in checkList) {
      String inspId = item["inspId"];
      bool isSelected = item["isSelected"] ?? true;
      stateList.add({"inspId": inspId, "isSelected": isSelected});
    }

    // JSON 문자열로 변환
    String jsonString = jsonEncode(stateList);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("WIT_PRE_SWITCH_STATES", jsonString);

  }

  // [유틸] 전체 스위치 상태를 SharedPreferences값 초기화
  Future<void> initSwitchStates() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("WIT_PRE_SWITCH_STATES", "");

    setState(() {
      for (dynamic item in checkList) {
        item["isSelected"] = true;
      }
    });
  }

}