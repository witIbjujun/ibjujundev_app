import 'dart:convert';
import 'package:flutter/material.dart';
import '../../util/wit_api_ut.dart';

class EstimateRequestAreaPop extends StatefulWidget {
  final dynamic sllrNo;
  const EstimateRequestAreaPop({Key? key, required this.sllrNo}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return EstimateRequestAreaPopState();
  }
}

class EstimateRequestAreaPopState extends State<EstimateRequestAreaPop> {
  // 초기 선택된 지역 (cd 값 저장)
  List<String> selectedRegions = [];

  // 선택 가능한 지역 목록 (각 지역의 cd와 cdNm 포함)
  List<Map<String, dynamic>> regions = [];

  // [서비스] 공통코드 조회
  Future<void> getCodeList() async {
    // REST ID
    String restId = "getCodeList";

    // PARAM
    final param = jsonEncode({
      "cdCls": "AREA01", // 지역 코드 클래스
    });

    // API 호출 (바로견적 설정 정보 조회)
    final _codeList = await sendPostRequest(restId, param);

    // 결과 셋팅
    if (_codeList != null) {
      setState(() {
        regions = List<Map<String, dynamic>>.from(
            _codeList.map((item) => Map<String, dynamic>.from(item)));
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("공통코드 조회가 실패하였습니다.")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    getCodeList(); // 초기화 시 코드 목록 조회
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.all(16.0), // 다이얼로그 여백 설정
      child: Container(
        width: MediaQuery
            .of(context)
            .size
            .width, // 화면의 전체 너비 사용
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('지역 선택', style: TextStyle(fontSize: 20)),
            ),
            Divider(),
            Expanded(
              child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return SingleChildScrollView(
                    child: Column(
                      children: regions.map((region) {
                        return CheckboxListTile(
                          title: Text(region["cdNm"].toString()),
                          // cdNm을 텍스트로 표시
                          value: selectedRegions.contains(region["cd"]),
                          // cd 값을 기준으로 선택 여부 결정
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                selectedRegions.add(
                                    region["cd"]); // 선택 시 cd 값 추가
                              } else {
                                selectedRegions.remove(
                                    region["cd"]); // 선택 해제 시 cd 값 제거
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                TextButton(
                  child: Text('확인'),
                  onPressed: () {
                    // 선택된 지역의 cd와 cdNm을 반환
                    List<Map<String, String>> selectedRegionData = regions
                        .where((region) => selectedRegions.contains(region["cd"]))
                        .map((region) => {
                      "cdNm": region["cdNm"].toString(),
                      "cd": region["cd"].toString()
                    })
                        .toList();

                    // Navigator.pop 호출 시 타입을 명확히 지정
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop(selectedRegionData); // 올바른 타입 반환
                    }
                  },
                ),
                TextButton(
                  child: Text('취소'),
                  onPressed: () {
                    // Navigator.pop을 호출하기 전에 비동기 작업을 사용하여 중복 호출 방지
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop(); // 다이얼로그 닫기
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}