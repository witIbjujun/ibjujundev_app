import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../util/wit_api_ut.dart';
import '../models/userInfo.dart';
import '../wit_home_theme.dart';

class WitUserLoginStep1 extends StatefulWidget {
  @override
  _WitUserLoginStep1State createState() => _WitUserLoginStep1State();
}

class _WitUserLoginStep1State extends State<WitUserLoginStep1> {
  String selectedApt = "";
  Map<String, String> options = {}; // aptName과 aptNo를 매핑한 데이터
  String selectedOption = ""; // 선택된 옵션
  UserInfo? userInfo; // 사용자 정보를 저장할 변수

  @override
  void initState() {
    super.initState();
    getAptList();
  }

  /**
   * 아파트 조회
   */
  Future<void> getAptList() async {
    String restId = "getAptList";
    final param = jsonEncode({"categoryId": ''});
    try {
      final response = await sendPostRequest(restId, param);
      setState(() {
        if (response is Map<String, dynamic>) {
          userInfo = UserInfo.fromJson(response);

          // aptName과 aptNo 분리
          List<String> aptNames = userInfo?.aptName ?? [];
          List<String> aptNos = userInfo?.aptNo ?? [];

          // aptName과 aptNo를 options에 저장
          for (int i = 0; i < aptNames.length; i++) {
            options[aptNames[i]] = aptNos[i];
          }

          // 기본 선택값 설정
          if (options.isNotEmpty) {
            selectedOption = options.keys.first;
          }

          // Select Box 데이터 업데이트
          selectedApt = options.keys.first;
        }
      });
    } catch (e) {
      print('Failed to fetch apartment list: $e');
    }
  }

  void _showSelectBox(BuildContext context) {
    List<String> sortedOptions = [
      selectedApt,
      ...options.keys.where((option) => option != selectedApt)
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20.0),
          height: 250,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '내 APT',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              Expanded(
                child: ListView(
                  children: sortedOptions.map((String option) {
                    return ListTile(
                      title: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          border: option == selectedApt
                              ? Border.all(
                            color: Colors.blue,
                            width: 2.0,
                          )
                              : null,
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: Text(
                          option,
                          style: const TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          selectedApt = option;
                        });
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("사용자 등록"),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "입주할 아파트를 선택해 주세요",
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            GestureDetector(
              onTap: () {
                _showSelectBox(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedApt.isEmpty ? "아파트 선택" : selectedApt,
                      style: const TextStyle(fontSize: 16.0),
                    ),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: 50.0,
              decoration: BoxDecoration(
                color: WitHomeTheme.nearlyslowBlue,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: ElevatedButton(
                onPressed: () {
                  if (selectedApt.isNotEmpty) {
                    String selectedAptNo = options[selectedApt] ?? "";
                    print("선택된 아파트: $selectedApt (No: $selectedAptNo)");
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("아파트를 선택해 주세요."),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                ),
                child: const Text(
                  "선택",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
