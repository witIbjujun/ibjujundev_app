import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:witibju/screens/home/models/main_view_model.dart';
import 'package:witibju/screens/home/login/wit_user_login.dart';
import 'package:witibju/screens/home/wit_home_theme.dart';
import 'package:witibju/screens/home/login/wit_kakaoLogin.dart';

import '../models/userInfo.dart';

class loingPopHome extends StatefulWidget {
  final Function(MainViewModel)? onLoginSuccess;
  final double width;  // ← 외부에서 받는 너비
  final double height; // ← 외부에서 받는 높이

  loingPopHome({
    this.onLoginSuccess,
    this.width = 300,       // 기본값 설정 가능
    this.height = 300,
  });

  @override
  State<loingPopHome> createState() => _loingPopHomeState();
}

class _loingPopHomeState extends State<loingPopHome> {
  ///final viewModel = MainViewModel(KaKaoLogin());

  final TextEditingController _idController = TextEditingController(); // 아이디 입력 컨트롤러

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<MainViewModel>(context); // ✅ 전역 인스턴스 사용
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/home/loginForm.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 160),
                  // 2025-04-22: 로그인 성공 시 사용자 정보를 팝업으로 보여주고, 이후 로그인 팝업 닫기
                  GestureDetector(
                    onTap: () async {
                      final ok = await viewModel.login(context);

                      if (ok) {
                        await viewModel.getUserInfoProxy(context, '','K');
                        widget.onLoginSuccess?.call(viewModel);

                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('로그인에 실패했습니다.')),
                        );
                      }
                    },

                    child: Container(
                      width: 310,
                      height: 40,
                      color: Colors.black,
                      child: Image.asset(
                        'assets/home/kakaoLogin.png',
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () async {
                      final ok = await viewModel.loginWithNaver(context);
                      if (ok) {
                        await viewModel.getUserInfoProxy(context, '','K');
                     //   await getChckUser(viewModel, '');
                        ///viewModel.userInfo?.tempClerkNo = '72091587';
                      //  viewModel.userInfo?.tempClerkNo = '72091587';
                        widget.onLoginSuccess?.call(viewModel);
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('로그인에 실패했습니다.')),
                        );
                      }
                    },
                    child: Container(
                      width: 310,
                      height: 40, // 전체 박스 높이
                      color: Colors.black, // ✅ 흰색 배경 추가
                      child: Image.asset(
                        'assets/home/naverLogin.png',
                        /// width: 200,        // 이미지 자체 너비
                        /// height: 300,       // 이미지 자체 높이
                        fit: BoxFit.fill, // 비율 유지
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
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
