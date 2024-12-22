import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:witibju/screens/home/login/wit_kakaoLogin.dart';
import 'package:witibju/screens/home/login/wit_user_login.dart';

import '../../../util/wit_api_ut.dart';
import '../models/main_view_model.dart';
import '../models/userInfo.dart';
import '../widgets/wit_home_widgets2.dart';
import '../wit_home_sc.dart';
import '../wit_home_theme.dart';

class WitUserLoginStep1 extends StatefulWidget {
  @override
  _WitUserLoginStep1State createState() => _WitUserLoginStep1State();
}

class _WitUserLoginStep1State extends State<WitUserLoginStep1> {
  final viewModel = MainViewModel(KaKaoLogin());
  final TextEditingController _idController = TextEditingController(); // 아이디 입력 컨트롤러

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
      body: Container(
        color: Colors.white, // 배경색 설정
        child: Padding(
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
              const Text(
                "소셜 로그인",
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20.0),
              GestureDetector(
                onTap: () async {
                  bool isLoginSuccessful = await viewModel.login(context);
                  if (isLoginSuccessful) {
                    // 현재 선택된 aptNo를 가져오기
                    String selectedAptNo = options[selectedApt] ?? "";

                    // aptNo를 getUserInfo에 전달
                    await getUserInfo(context,viewModel, selectedAptNo, '72091587');

                    print("이동가자자자자");
                    // HomeScreen으로 이동
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
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('로그인에 실패했습니다.')),
                    );
                  }
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: 50.0,
                  child: Image.asset(
                    'assets/home/kakao_login_large_narrow.png',
                    fit: BoxFit.contain,
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
                  onPressed: () async{
                    if (selectedApt.isNotEmpty) {

                      // 현재 선택된 aptNo를 가져오기
                      String selectedAptNo = options[selectedApt] ?? "";

                      // aptNo를 getUserInfo에 전달
                      await getUserInfo(context,viewModel, selectedAptNo, '72091587');

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

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreen()),
                      );


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
              Container(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // 버튼 "이"
                    ElevatedButton(
                      onPressed: () async {
                        if (selectedApt.isNotEmpty) {
                          String selectedAptNo = options[selectedApt] ?? "";
                          await getUserInfo(context, viewModel, selectedAptNo, '72091587');
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("알림"),
                                content: const Text("로그인 되었습니다."),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => HomeScreen()),
                                      );
                                    },
                                    child: const Text("확인"),
                                  ),
                                ],
                              );
                            },
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("아파트를 선택해 주세요."),
                            ),
                          );
                        }
                      },
                      child: const Text("이"),
                    ),

                    // 버튼 "우"
                    ElevatedButton(
                      onPressed: () async {
                        if (selectedApt.isNotEmpty) {
                          String selectedAptNo = options[selectedApt] ?? "";
                          await getUserInfo(context, viewModel, selectedAptNo, '72091584');
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("알림"),
                                content: const Text("로그인 되었습니다."),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => HomeScreen()),
                                      );
                                    },
                                    child: const Text("확인"),
                                  ),
                                ],
                              );
                            },
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("아파트를 선택해 주세요."),
                            ),
                          );
                        }
                      },
                      child: const Text("우"),
                    ),

                    // 버튼 "백"
                    ElevatedButton(
                      onPressed: () async {
                        if (selectedApt.isNotEmpty) {
                          String selectedAptNo = options[selectedApt] ?? "";
                          await getUserInfo(context, viewModel, selectedAptNo, '72091586');
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("알림"),
                                content: const Text("로그인 되었습니다."),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => HomeScreen()),
                                      );
                                    },
                                    child: const Text("확인"),
                                  ),
                                ],
                              );
                            },
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("아파트를 선택해 주세요."),
                            ),
                          );
                        }
                      },
                      child: const Text("백"),
                    ),

                    // 버튼 "조"
                    ElevatedButton(
                      onPressed: () async {
                        if (selectedApt.isNotEmpty) {
                          String selectedAptNo = options[selectedApt] ?? "";
                          await getUserInfo(context, viewModel, selectedAptNo, '72091588');
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("알림"),
                                content: const Text("로그인 되었습니다."),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => HomeScreen()),
                                      );
                                    },
                                    child: const Text("확인"),
                                  ),
                                ],
                              );
                            },
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("아파트를 선택해 주세요."),
                            ),
                          );
                        }
                      },
                      child: const Text("조"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
