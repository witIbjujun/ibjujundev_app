import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:witibju/screens/home/login/wit_user_loginStep1.dart';

import '../models/main_view_model.dart';
import '../wit_home_sc.dart';
import '../wit_home_theme.dart';

class WitUserLoginStep extends StatelessWidget {
  final Function(MainViewModel)? onLoginSuccess;
  WitUserLoginStep({super.key, this.onLoginSuccess});

  final secureStorage = FlutterSecureStorage(); // Flutter Secure Storage 인스턴스

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<MainViewModel>(context); // ✅ 전역 인스턴스 사용
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ✅ 메인 이미지
            Container(
              width: 200,
              height: 200,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/home/mainLogo.png'), // 👉 메인 이미지
                  fit: BoxFit.contain,
                ),
              ),
            ),

            const SizedBox(height: 20), // 이미지와 문구 사이 간격

            // ✅ 설명 문구 추가
            const Text(
              "로그인하고 무료견적을 받아보세요!",
              style: WitHomeTheme.title, // ✅ 스타일을 WitHomeTheme.headline으로 적용
            ),
            const SizedBox(height: 40), // 문구와 버튼 간격



            // ✅ 카카오 로그인 버튼
            GestureDetector(
              onTap: () async {
                print("🔹 카카오 로그인 시도 중...");
                final ok = await viewModel.login(context);

                if (ok) {
                  print("✅ 카카오 로그인 성공");
                  await viewModel.getUserInfoProxy(context, '', 'K');
                  final info = viewModel.userInfo;
                  print("🔹 로그인 후 userInfo.id: ${info?.id}");
                  print("🔹 로그인 후 userInfo.clerkNo: ${info?.clerkNo}");

                  String? storedClerkNo = await secureStorage.read(key: 'clerkNo');
                  print('📝 SecureStorage에 저장된 clerkN11111o: $storedClerkNo');
                  if (info != null) {
                    if (storedClerkNo == null || (storedClerkNo?.isEmpty ?? true)) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WitUserLoginStep1(info.nickName ?? ""),
                          ),
                        );
                      });
                    } else {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const HomeScreen()),
                        );
                      });
                    }
                  }
                  print("✅ 사용자 정보 로딩 완료");
                } else {
                  print("🚨 카카오 로그인 실패");
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('로그인에 실패했습니다.')),
                  );
                }
              },
              child: Container(
                width: 310,
                height: 40,
                color: Colors.white,
                child: Image.asset(
                  'assets/home/kakaoLogin.png',
                  fit: BoxFit.fill,
                ),
              ),
            ),
            const SizedBox(height: 20), // 버튼 간격

            // ✅ 네이버 로그인 버튼
            GestureDetector(
              onTap: () async {
                print("🔹 네이버 로그인 시도 중...");
                final ok = await viewModel.loginWithNaver(context);

                if (ok) {
                  print("✅ 네이버 로그인 성공");
                  await viewModel.getUserInfoProxy(context, '', 'N');
                  final info = viewModel.userInfo;
                  print("🔹 로그인 후 userInfo.id: ${info?.id}");
                  print("🔹 로그인 후 userInfo.clerkNo: ${info?.clerkNo}");

                  String? storedClerkNo = await secureStorage.read(key: 'clerkNo');
                  print('📝 SecureStorage에 저장된 clerkNo: $storedClerkNo');
                  if (info != null) {
                    if (storedClerkNo == null || (storedClerkNo?.isEmpty ?? true)) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WitUserLoginStep1(info.nickName ?? ""),
                          ),
                        );
                      });
                    } else {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const HomeScreen()),
                        );
                      });
                    }
                  }
                  print("✅ 사용자 정보 로딩 완료");
                } else {
                  print("🚨 네이버 로그인 실패");
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('로그인에 실패했습니다.')),
                  );
                }
              },
              child: Container(
                width: 310,
                height: 40,
                color: Colors.white,
                child: Image.asset(
                  'assets/home/naverLogin.png',
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
