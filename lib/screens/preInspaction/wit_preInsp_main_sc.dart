import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:witibju/screens/preInspaction/widgets/wit_preInsp_main_widget.dart';

import '../../util/wit_api_ut.dart';

/**
 * 사전점검
 */
class PreInspaction extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: PreInspactionList(),
        ),
      ),
    );
  }
}

/**
 * 사전점검 리스트
 */
class PreInspactionList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PreInspactionState();
  }

}

/**
 * 사전점검 항목
 */
class PreInspactionState extends State<PreInspactionList> {

  // 사전검검 리스트
  List<dynamic> preinspactionList = [];
  bool isEditing = false; // 수정 모드 상태 변수
  late final ScrollController _scrollController; // 스크롤 컨트롤러
  bool _isButtonVisible = false;

  /*****************************************************************************************
   * 초기화
   *****************************************************************************************/

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // 사전점검 항목 리스트 조회
    getPreinspactionList();

    _scrollController.addListener(() {
      setState(() {
        // 스크롤 위치가 100 이상일 때 버튼을 보이게 함
        _isButtonVisible = _scrollController.offset >= 100;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // isSelected가 true인 항목만 필터링
    final filteredList = preinspactionList.where((item) => item["isSelected"] == true).toList();

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController, // 스크롤 컨트롤러 연결
        slivers: [
          CustomSliverAppBar(
            isEditing: isEditing,
            onRefreshPressed: () {
              // 확인 다이얼로그 표시
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text("초기화 확인"),
                    content: Text("모든 항목을 초기화 하시겠습니까?"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // 다이얼로그 닫기
                        },
                        child: Text("취소"),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            // 초기화 동작 구현
                            for (var item in preinspactionList) {
                              item["isSelected"] = true; // 모든 항목의 isSelected를 true로 초기화
                            }
                            // 저장값 초기화
                            initSwitchStates();
                          });
                          Navigator.of(context).pop(); // 다이얼로그 닫기
                        },
                        child: Text("확인"),
                      ),
                    ],
                  );
                },
              );
            },
            onEditTogglePressed: () {
              if (isEditing) {
                _saveAllSwitchStates(); // 체크 아이콘 클릭 시 상태 저장
              }
              setState(() {
                isEditing = !isEditing; // 수정 모드 토글
                _scrollController.jumpTo(0); // 스크롤을 상단으로 이동
              });
            },
          ),
          SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              mainAxisSpacing: 0,
              crossAxisSpacing: 2,
              childAspectRatio: 4.3,
            ),
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                return isEditing
                    ? EditableCardList(preinspactionInfo: preinspactionList[index]) // 전체 리스트
                    : CardList(preinspactionInfo: filteredList[index]); // 필터링된 리스트
              },
              childCount: isEditing ? preinspactionList.length : filteredList.length, // 수정 모드에 따라 아이템 수 결정
            ),
          ),
        ],
      ),
      floatingActionButton: ScrollToTopButton(
        isVisible: _isButtonVisible, // 버튼 가시성 제어
        onPressed: () {
          _scrollController.animateTo(
            0, // 최상단으로 이동
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
      ),
    );
  }

  // [서비스] 사전점검 항목 리스트 조회
  Future<void> getPreinspactionList() async {
    String restId = "getPreinspactionListByLv1";
    final _preinspactionList = await sendPostRequest(restId, null);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString("WIT_PRE_SWITCH_STATES");

    setState(() {

      if (jsonString != null) {
        List<dynamic> jsonList = jsonDecode(jsonString);
        List<Map<String, dynamic>> checkSaveData = List<Map<String, dynamic>>.from(jsonList);

        for (Map<String, dynamic> item in checkSaveData) {
          for (dynamic item2 in _preinspactionList) {
            if (item2["inspId"] == item["inspId"]) {
              item2["isSelected"] = item["isSelected"];
            }
          }
        }

      } else {
        for (dynamic item in _preinspactionList) {
          item["isSelected"] = true;
        }
      }

      preinspactionList = _preinspactionList;
    });
  }

  // [유틸] 전체 스위치 상태를 SharedPreferences에 저장
  Future<void> _saveAllSwitchStates() async {

    List<Map<String, dynamic>> stateList = [];

    for (var item in preinspactionList) {
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
  }
}