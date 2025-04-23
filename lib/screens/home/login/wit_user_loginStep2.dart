import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:witibju/screens/home/login/wit_kakaoLogin.dart';
import 'package:witibju/screens/home/login/wit_user_login.dart';
import 'package:witibju/screens/home/login/wit_user_loginStep3.dart';

import '../../../util/wit_api_ut.dart';
import '../models/main_view_model.dart';
import '../models/userInfo.dart';
import '../widgets/wit_home_widgets2.dart';
import '../wit_home_sc.dart';
import '../wit_home_theme.dart';

class WitUserLoginStep2 extends StatefulWidget {
  @override
  _WitUserLoginStep1State createState() => _WitUserLoginStep1State();
}

class _WitUserLoginStep1State extends State<WitUserLoginStep2> {
  final TextEditingController _nicknameController = TextEditingController(); // 닉네임 입력 컨트롤러
  final FlutterSecureStorage secureStorage = FlutterSecureStorage(); // SecureStorage 인스턴스
  int _currentStep = 1; // 현재 스텝 인덱스

  String selectedApt = "선택"; // 초기값 "선택"
  String selectedPyung = "선택"; // 평수 초기값
  Map<String, String> options = {}; // aptName과 aptNo를 매핑한 데이터
  List<String> pyungOptions = []; // 평수 옵션 데이터
  UserInfo? userInfo; // 사용자 정보를 저장할 변수

  @override
  void initState() {
    super.initState();
    getAptList(); // APT 조회
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
        }
      });
    } catch (e) {
      print('Failed to fetch apartment list: $e');
    }
  }

  /**
   * 평수 조회
   */
  Future<void> getAptPyoung(String aptNo) async {
    String restId = "getAptPyoungList";
    final param = jsonEncode({"aptNo": aptNo});
    try {
      final response = await sendPostRequest(restId, param);
      setState(() {
        if (response is List<dynamic>) {
          pyungOptions = response
              .where((e) => e['mainAptPyoung'] != null)
              .map((e) => "${e['mainAptPyoung']}평")
              .toList();
        }
      });
    } catch (e) {
      print('Failed to fetch apartment pyoung list: $e');
    }
  }

  void _showSelectBox(BuildContext context, List<String> options, String title, Function(String) onSelected) {
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
                  Text(
                    title,
                    style: const TextStyle(
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
                  children: options.where((option) => option != "선택").map((String option) {
                    return ListTile(
                      title: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          border: option == (title == '내 APT' ? selectedApt : selectedPyung)
                              ? Border.all(
                            color: WitHomeTheme.wit_lightGreen,
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
                        onSelected(option);
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
    final mainViewModel = Provider.of<MainViewModel>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text("사용자 등록"),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 1,
      ),
      body: Container(
        color: Colors.white, // 배경색 설정
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Custom Horizontal Stepper
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(2, (index) {
                return Expanded(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 18.0,
                        backgroundColor: _currentStep >= index ? WitHomeTheme.wit_lightGreen : Colors.grey,
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 8.0),
                    ],
                  ),
                );
              }),
            ),
            const Divider(height: 32.0),
            const Text(
              "내APT를 등록해서 좋은 파트너에 도움을 받으세요~",
              style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            GestureDetector(
              onTap: () {
                _showSelectBox(context, ["선택", ...options.keys], '내 APT', (String selected) {
                  setState(() {
                    selectedApt = selected;
                    if (selected != "선택") {
                      String aptNo = options[selected] ?? "";
                      getAptPyoung(aptNo); // 평수 데이터 조회
                    }
                    pyungOptions = [];
                    selectedPyung = "선택";
                  });
                });
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
            if (selectedApt != "선택") ...[
              const SizedBox(height: 16.0),
              const Text(
                "평수를 선택해 주세요",
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0),
              GestureDetector(
                onTap: () {
                  _showSelectBox(context, ["선택", ...pyungOptions], '평수', (String selected) {
                    setState(() {
                      selectedPyung = selected;
                    });
                  });
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
                        selectedPyung.isEmpty ? "평수 선택" : selectedPyung,
                        style: const TextStyle(fontSize: 16.0),
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
            ],
            SizedBox(height: 20.0),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9, // 버튼 너비 조정
                height: 50.0, // 버튼 높이 설정
                decoration: BoxDecoration(
                  color: WitHomeTheme.wit_lightGreen, // 버튼 배경색 설정
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: ElevatedButton(
                  onPressed: () async {
                    if (selectedApt == "선택" || selectedPyung == "선택") {
                      // 2025-04-22: 아파트 또는 평수 미선택 시 경고 팝업
                      await DialogUtils.showCustomDialog(
                        context: context,
                        title: '알림',
                        content: '아파트와 평수를 모두 선택해 주세요.',
                        confirmButtonText: '확인',
                      );
                      return; // 더 이상 진행하지 않음
                    }
                    String? nickname = await secureStorage.read(key: 'nickName');
                    String selectedAptNo = options[selectedApt] ?? "";
                    String selectedPyungNo = pyungOptions.contains(selectedPyung) ? selectedPyung.replaceAll('평', '') : "";

                    mainViewModel.userInfo = UserInfo(
                      nickName: nickname,
                      mainAptNo: selectedAptNo,
                      mainAptPyoung: selectedPyungNo,
                    );
                    await getCreateUser(mainViewModel, '');
                    // SecureStorage에 authToken 저장
                    await secureStorage.write(key: 'authToken', value: "11111");

                    await DialogUtils.showCustomDialog(
                      context: context,
                      title: '알림',
                      content: '로그인 되었습니다.',
                      confirmButtonText: '확인',
                      onConfirm: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => HomeScreen()),
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent, // 버튼 자체는 투명
                    shadowColor: Colors.transparent,
                  ),
                  child: const Text(
                    "저장",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
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
