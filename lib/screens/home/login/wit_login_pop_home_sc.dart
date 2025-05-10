import 'package:flutter/material.dart';
import 'package:witibju/screens/home/login/wit_user_loginStep.dart';
import 'package:witibju/screens/home/models/main_view_model.dart';

import '../wit_home_theme.dart';

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
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: widget.width,
          height: widget.height,
          color: Colors.black, // ✅ 팝업 배경을 검정색으로 설정
          child: Column(
            children: [
              // ✅ 이미지 위에 간격 추가
              const SizedBox(height: 20), // 🔹 이미지 위에 20px 간격 추가

              // ✅ 상단 이미지 (Layer Popup)
              Container(
                width: double.infinity,
                height: 150, // 이미지 영역의 높이
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/home/loginForm.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 30), // 이미지와 버튼 사이 간격

              // ✅ 로그인 버튼
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: WitHomeTheme.wit_lightGreen, // 버튼 색상
                    minimumSize: Size(double.infinity, 50), // 가로는 꽉 차게, 세로 50
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // 모서리 둥글게
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => WitUserLoginStep()),
                    );
                  },
                  child: const Text(
                    "로그인하고 입주전 혜택 받기",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
