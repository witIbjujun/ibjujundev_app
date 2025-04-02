import 'package:flutter/material.dart';

import 'package:witibju/screens/home/models/main_view_model.dart';
import 'package:witibju/screens/home/login/wit_user_login.dart';
import 'package:witibju/screens/home/wit_home_theme.dart';
import 'package:witibju/screens/home/login/wit_kakaoLogin.dart';

import '../models/userInfo.dart';

class loingPopHome extends StatefulWidget {
  final Function(MainViewModel)? onLoginSuccess;

  loingPopHome({this.onLoginSuccess});

  @override
  State<loingPopHome> createState() => _loingPopHomeState();
}

class _loingPopHomeState extends State<loingPopHome> {
  final viewModel = MainViewModel(KaKaoLogin());
  final TextEditingController _idController = TextEditingController(); // 아이디 입력 컨트롤러

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            '로그인하고 무료견적을 받아보세요!',
            style: WitHomeTheme.title.copyWith(
              decoration: TextDecoration.none,
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  String userId = _idController.text.trim();
                  String result =  await getChckUser(viewModel, '72091587');

                  if (widget.onLoginSuccess != null) {

                    viewModel.userInfo = UserInfo(tempClerkNo: '72091587');
                    widget.onLoginSuccess!(viewModel);
                  }
                  // 팝업창 닫기
                  Navigator.of(context).pop();
                },
                child: Text('이'),
              ),
              SizedBox(width: 8), // 버튼 사이 간격
              ElevatedButton(
                onPressed: () async {
                  String userId = _idController.text.trim();
                  String result =  await getChckUser(viewModel, '72091586');
                  // 로그인 로직 추가 가능
                  if (widget.onLoginSuccess != null) {
                    viewModel.userInfo = UserInfo(tempClerkNo: '72091586');
                    widget.onLoginSuccess!(viewModel);
                  }
                  // 팝업창 닫기
                  Navigator.of(context).pop();
                },
                child: Text('백'),
              ),
              SizedBox(width: 8), // 버튼 사이 간격
              ElevatedButton(
                onPressed: () async {
                  String userId = _idController.text.trim();

                  print('입력된 아이디: $userId');
                  String result =  await getChckUser(viewModel, '72091588');

                  if (widget.onLoginSuccess != null) {
                    viewModel.userInfo = UserInfo(tempClerkNo: '72091588');
                    widget.onLoginSuccess!(viewModel);
                  }

                  // 팝업창 닫기
                  Navigator.of(context).pop();
                },
                child: Text('조'),
              ),
              SizedBox(width: 8), // 버튼 사이 간격
              ElevatedButton(
                onPressed: () async {
                  String userId = _idController.text.trim();
                  String result =  await getChckUser(viewModel, '72091584');

                  if (widget.onLoginSuccess != null) {
                    viewModel.userInfo = UserInfo(tempClerkNo: '72091584');
                    widget.onLoginSuccess!(viewModel);
                  }

                  // 팝업창 닫기
                  Navigator.of(context).pop();
                },
                child: Text('우'),
              ),
            ],
          ),
          SizedBox(height: 8),
          GestureDetector(
            onTap: () async {
              bool isLoginSuccessful = await viewModel.login(context);
              print('아파트 번호 모야???$isLoginSuccessful');
              if (isLoginSuccessful) {
                // 로그인 성공 시 콜백 호출
                String userId = _idController.text.trim();

                String result =  await getChckUser(viewModel, '');
                ///await getUserInfo(context,viewModel, '');
                viewModel.userInfo?.tempClerkNo = '72091587';
                if (widget.onLoginSuccess != null) {
                  widget.onLoginSuccess!(viewModel);
                }

                // 팝업창 닫기
                Navigator.of(context).pop();
              } else {
                // 로그인 실패 시 에러 메시지를 표시하거나 다른 처리를 할 수 있음
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('로그인에 실패했습니다.')),
                );
              }
            },
            child: Image.asset(
              'assets/home/kakao_login_medium_narrow.png',
              width: 200,
              height: 50,
            ),
          ),
          GestureDetector(
            onTap: () async {
              bool isLoginSuccessful = await viewModel.loginWithNaver(context);
              print('아파트 번호 모야??? $isLoginSuccessful');

              if (isLoginSuccessful) {
                // 로그인 성공 시 콜백 호출
                String userId = _idController.text.trim();
                print("🔹 모델 userInfo.id: ${viewModel.userInfo?.id}");
                print("🔹 모델 userInfo 닉네임: ${viewModel.userInfo?.nickName}");

                String result = await getChckUser(viewModel, '');
                print("🔹 모델 result: ${result}");

                if (widget.onLoginSuccess != null) {
                  print("🔹 넘기나????");
                  viewModel.userInfo?.tempClerkNo = '72091587';
                  // ✅ 기존 result 대신 viewModel을 전달
                  widget.onLoginSuccess!(viewModel);
                }

                // 팝업창 닫기
                Navigator.of(context).pop();
              } else {
                // 로그인 실패 시 에러 메시지를 표시
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('로그인에 실패했습니다.')),
                );
              }
            },
            child: Image.asset(
              'assets/home/naver_login_large.png',
              width: 200,
              height: 48,
            ),
          ),
        ],
      ),
    );
  }

  void showAlertWithUserId(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('입력된 아이디'),
        content: Text('입력된 아이디: $userId'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // AlertDialog 닫기
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void showRegistrationPopup(BuildContext context) {
    // 최상위 컨텍스트를 사용
    final rootContext = Navigator.of(context).overlay!.context;

    // 기존 Dialog 닫기
    Navigator.of(context).pop();

    // 새로운 팝업 표시
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: rootContext,
        barrierColor: Colors.transparent, // 배경색 투명
        builder: (context) {
          return AlertDialog(
            backgroundColor: Color(0xFFF5F5FF), // 원하는 팝업 배경색 설정
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            title: Text(
              '등록 선택',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            content: Text('등록 유형을 선택하세요:'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // 팝업 닫기
                  print('사용자 등록 선택');
                },
                child: Text(
                  '사용자 등록',
                  style: TextStyle(color: Colors.purple),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // 팝업 닫기
                  print('판매자 등록 선택');
                },
                child: Text(
                  '판매자 등록',
                  style: TextStyle(color: Colors.purple),
                ),
              ),
            ],
          );
        },
      );
    });
  }



}
