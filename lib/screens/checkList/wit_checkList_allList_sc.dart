import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:witibju/screens/checkList/widget/wit_checkList_detail_widget.dart';
import 'package:witibju/util/wit_api_ut.dart';
import 'package:witibju/screens/common/wit_common_widget.dart';

/**
 * 하자 전체 리스트
 */
class CheckAllList extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return CheckAllListState();
  }

}

/**
 * 하자 전체 리스트 State
 */
class CheckAllListState extends State<CheckAllList> with TickerProviderStateMixin {

  List<dynamic> checkAllList = [];      // 하자 전체 리스트

  int? expandedIndex = 0; // 클릭된 항목의 인덱스를 저장
  final ScrollController _scrollController = ScrollController();

  /**
   * 화면 초기화
   */
  @override
  void initState() {
    super.initState();

    // 하자 전체 조회
    getCheckAllList();
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
          "하자 전체 리스트",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: checkAllList.length,
                itemBuilder: (context, index) {
                  bool isExpanded = expandedIndex == index;
                  return ExpandableItem(
                    checkInfoLv3: checkAllList[index],
                    isExpanded: isExpanded,
                    onSwitchChanged: (value) {
                      setState(() {
                        checkAllList[index]["checkYn"] = value ? "N" : "Y";
                        saveCheckInfo(checkAllList[index], value ? "N" : "Y");
                      });
                    },
                    onTap: () {
                      setState(() {
                        expandedIndex = isExpanded ? null : index;
                        if (!isExpanded) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _scrollController.animateTo(
                              (index - 1) * 82.5,
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          });
                        }
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }


  // [서비스] 하자 전체 조회
  Future<void> getCheckAllList() async {

    // REST ID
    String restId = "getPreinspactionNoList";

    // API 호출 (하자 전체 조회)
    final _checkAllList = await sendPostRequest(restId, null);

    // 데이터 셋팅
    setState(() {
      checkAllList = _checkAllList;
    });
  }

  // [서비스] 사전 점검 상세 저장
  Future<void> saveCheckInfo(dynamic item, String newCheckYn) async {

    // REST ID
    String restId = "savePreinspactionInfo";

    // PARAM
    final param = jsonEncode({
      "inspId": item["inspId"],
      "inspDetlId": item["inspDetlId"],
      "checkYn": newCheckYn,
      "checkDate": item["checkDate"],
      "reprDate": item["reprDate"],
      "checkComt": item["checkComt"],
      "checkImg1": item["checkImg1"],
      "checkImg2": item["checkImg2"],
    });

    // API 호출 (사전점검 상세 항목 저장)
    final result = await sendPostRequest(restId, param);

    // 결과값이 0보다 크면 카운트 업데이트
    if (result > 0) {

      if (newCheckYn == "N") {
        alertDialog.show(context, "하자완료 되었습니다.");
      } else {
        alertDialog.show(context, "하자등록 되었습니다.");
      }
    }
  }
}