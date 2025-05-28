import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:witibju/screens/checkList/widget/wit_checkList_main_widget.dart';
import 'package:witibju/screens/checkList/wit_checkList_allList_sc.dart';
import 'package:witibju/util/wit_api_ut.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:witibju/screens/common/wit_common_widget.dart';
import 'package:witibju/screens/home/wit_home_theme.dart';
import 'package:witibju/screens/home/widgets/wit_home_bottom_nav_bar.dart';

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

  int _selectedIndex = 0; // ✅ "내정보" 탭이 기본 선택
  final secureStorage = FlutterSecureStorage();

  bool isEditing = false; // 수정 모드 상태 변수
  List<dynamic> checkList = []; // 사전 체크리스트 목록 리스트
  int checkAllCnt = 0;          // 하자 전체 건수

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
        iconTheme: IconThemeData(color: WitHomeTheme.wit_white),
        backgroundColor: WitHomeTheme.wit_black,
        title: Text(
          isEditing == false ? "입주전 체크리스트" : "입주전 체크리스트 설정",
          style: WitHomeTheme.title.copyWith(color: WitHomeTheme.wit_white),
        ),
        actions: [
          if (isEditing)
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () async {
                bool isConfirmed = await ConfimDialog.show(context: context, title: "확인", content: "체크리스트 초기화를 진행하시겠습니까?");
                if (isConfirmed == true) {
                  initSwitchStates();
                }
              },
            ),
          IconButton(
            icon: Icon(isEditing ? Icons.check : Icons.settings),
            color: isEditing ? WitHomeTheme.wit_white : WitHomeTheme.wit_white,
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
          child: Text(
            "조회된 데이터가 없습니다.",
            style: WitHomeTheme.headline,
          ),
        )
            : CheckListView(
          listData: isEditing
              ? checkList
              : checkList.where((item) => item["isSelected"] == true).toList(),
          callback: getCheckListByLv1,
          edited: isEditing,
        ),
      ),
      bottomNavigationBar: BottomNavBar(
          selectedIndex: 0
      ),
      floatingActionButton: isEditing || checkAllCnt == 0 ? null :
      Container(
        width: 80, // 원하는 너비
        height: 70, // 원하는 높이
        child: FloatingActionButton(
          onPressed: () async {
            await Navigator.push(
              context,
              SlideRoute(page: CheckAllList()),
            );
            await getCheckListByLv1();
          },
          backgroundColor: WitHomeTheme.wit_black,
          shape: CircleBorder(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.warning, // 경고 아이콘
                size: 30, // 아이콘 크기 조정
                color: WitHomeTheme.wit_white,
              ),
              Text(
                "하자 ${checkAllCnt}건",
                textAlign: TextAlign.center,
                style: WitHomeTheme.caption.copyWith(color: WitHomeTheme.wit_white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // [서비스] 사전 체크리스트 목록 조회
  Future<void> getCheckListByLv1() async {

    // 로그인 사번
    String? loginClerkNo = await secureStorage.read(key: 'clerkNo');

    // 데이터 초기화
    checkList = [];

    // REST ID
    String restId = "getPreinspactionListByLv1";

    // PARAM
    final param = jsonEncode({
      "loginClerkNo": loginClerkNo,
    });

    // API 호출 (사전 체크리스트 목록 조회)
    final _checkList = await sendPostRequest(restId, param);

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

      // 하자 전체 건수 조회
      checkAllCnt = 0;
      for (dynamic item in _checkList) {
        int test = int.tryParse(item["inspDetlChoiceCnt"].toString()) ?? 0;
        checkAllCnt += test;
      }
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