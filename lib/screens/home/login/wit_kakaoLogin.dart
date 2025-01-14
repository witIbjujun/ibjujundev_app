import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:witibju/screens/home/wit_social_login_sc.dart';

class KaKaoLogin implements SocialLogin {
  BuildContext? _context; // BuildContext 저장용

  @override
  Future<bool> login() async {
    if (_context == null) {
      print("Error: Context is not set. Call setContext(context) before login.");
      return false;
    }

    try {
      // 카카오톡 어플 설치 여부 확인
      bool isInstalled = await isKakaoTalkInstalled();

      if (isInstalled) {
        try {
          await UserApi.instance.loginWithKakaoTalk();
          print('카카오톡으로 로그인 성공');
          return true;
        } catch (error) {
          print('카카오톡으로 로그인 실패: $error');
          _showErrorDialog('카카오톡으로 로그인 실패', error.toString());
          return false;
        }
      } else {
        try {
          await UserApi.instance.loginWithKakaoAccount();
          print('카카오계정으로 로그인 성공');
          return true;
        } catch (error) {
          print('카카오계정으로 로그인 실패: $error');
          _showErrorDialog('카카오계정으로 로그인 실패', error.toString());
          return false;
        }
      }
    } catch (e) {
      print('로그인 오류: $e');
      _showErrorDialog('로그인 오류', e.toString());
      return false;
    }
  }

  @override
  Future<bool> logOut() async {
    try {
      await UserApi.instance.unlink();
      return true;
    } catch (error) {
      print('로그아웃 실패: $error');
      return false;
    }
  }

  // BuildContext 설정
  void setContext(BuildContext context) {
    _context = context;
  }

  // 오류 다이얼로그 표시
  void _showErrorDialog(String title, String message) {
    if (_context == null) {
      print("Error: Context is null. Cannot show dialog.");
      return;
    }

    showDialog(
      context: _context!,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}
