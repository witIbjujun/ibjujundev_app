import 'package:flutter/material.dart';

import 'package:witibju/screens/home/models/main_view_model.dart';
import 'package:witibju/screens/home/widgets/wit_user_login.dart';
import 'package:witibju/screens/home/wit_home_theme.dart';
import 'package:witibju/screens/home/wit_kakaoLogin.dart';

class loingPopHome extends StatefulWidget {
  final VoidCallback? onLoginSuccess; // 로그인 성공 시 호출되는 콜백 함수

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
                onPressed: () {
                  String userId = _idController.text.trim();

                  print('입력된 아이디: $userId');
                  getUserInfo('', '72091587');
                  // 로그인 로직 추가 가능

                  if (widget.onLoginSuccess != null) {
                    widget.onLoginSuccess!();
                  }
                  // 팝업창 닫기
                  Navigator.of(context).pop();
                },
                child: Text('이'),
              ),
              SizedBox(width: 8), // 버튼 사이 간격
              ElevatedButton(
                onPressed: () {
                  String userId = _idController.text.trim();

                  print('입력된 아이디: $userId');
                  getUserInfo('', '72091586');
                  // 로그인 로직 추가 가능

                  if (widget.onLoginSuccess != null) {
                    widget.onLoginSuccess!();
                  }
                  // 팝업창 닫기
                  Navigator.of(context).pop();
                },
                child: Text('백'),
              ),
              SizedBox(width: 8), // 버튼 사이 간격
              ElevatedButton(
                onPressed: () {
                  String userId = _idController.text.trim();

                  print('입력된 아이디: $userId');
                  getUserInfo('', '72091588');
                  // 로그인 로직 추가 가능

                  if (widget.onLoginSuccess != null) {
                    widget.onLoginSuccess!();
                  }
                  // 팝업창 닫기
                  Navigator.of(context).pop();
                },
                child: Text('조'),
              ),
              SizedBox(width: 8), // 버튼 사이 간격
              ElevatedButton(
                onPressed: () {
                  String userId = _idController.text.trim();

                  print('입력된 아이디: $userId');
                  getUserInfo('', '72091584');
                  // 로그인 로직 추가 가능

                  if (widget.onLoginSuccess != null) {
                    widget.onLoginSuccess!();
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
              bool isLoginSuccessful = await viewModel.login();
              print('아파트 번호 모야???$isLoginSuccessful');
              if (isLoginSuccessful) {
                // 로그인 성공 시 콜백 호출
                if (widget.onLoginSuccess != null) {
                  widget.onLoginSuccess!();
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
        ],
      ),
    );
  }
}
