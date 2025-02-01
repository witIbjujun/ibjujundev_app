import 'package:flutter/material.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:flutter/services.dart'; // 클립보드 기능 추가

class NaverLoginScreen extends StatefulWidget {
  @override
  _NaverLoginScreenState createState() => _NaverLoginScreenState();
}

class _NaverLoginScreenState extends State<NaverLoginScreen> {
  NaverLoginResult? _naverLoginResult;

  /// 네이버 로그인
  Future<void> _loginWithNaver() async {
    try {
      final result = await FlutterNaverLogin.logIn();
      setState(() {
        _naverLoginResult = result;
      });

      if (result.status == NaverLoginStatus.loggedIn) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('네이버 로그인 성공: ${result.account.name}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('네이버 로그인 실패')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('네이버 로그인 오류: $e')),
      );
    }
  }

  /// 네이버 로그아웃
  Future<void> _logoutFromNaver() async {
    try {
      await FlutterNaverLogin.logOut();
      setState(() {
        _naverLoginResult = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('네이버 로그아웃 완료')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('네이버 로그아웃 오류: $e')),
      );
    }
  }

  /// **로그인된 사용자 정보 복사 기능**
  void _copyUserInfoToClipboard() {
    if (_naverLoginResult == null) return;

    String userInfo = '''
✅ 네이버 로그인 정보
🔹 ID: ${_naverLoginResult?.account.id ?? "없음"}
🔹 이메일: ${_naverLoginResult?.account.email ?? "없음"}
🔹 이름: ${_naverLoginResult?.account.name ?? "없음"}
🔹 닉네임: ${_naverLoginResult?.account.nickname ?? "없음"}
🔹 성별: ${_naverLoginResult?.account.gender ?? "없음"}
🔹 생년월일: ${_naverLoginResult?.account.birthday ?? "없음"}
🔹 출생년도: ${_naverLoginResult?.account.birthyear ?? "없음"}
🔹 휴대폰 번호: ${_naverLoginResult?.account.mobile ?? "없음"}
🔹 연령대: ${_naverLoginResult?.account.age ?? "없음"}
''';

    Clipboard.setData(ClipboardData(text: userInfo));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('네이버 로그인 정보가 클립보드에 복사되었습니다.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('네이버 로그인 테스트')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _loginWithNaver,
              child: Text('네이버 로그인'),
            ),
            SizedBox(height: 16),
            if (_naverLoginResult != null) ...[
              Text('✅ 로그인 정보', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('🔹 ID: ${_naverLoginResult?.account.id ?? "없음"}'),
              Text('🔹 이메일: ${_naverLoginResult?.account.email ?? "없음"}'),
              Text('🔹 이름: ${_naverLoginResult?.account.name ?? "없음"}'),
              Text('🔹 닉네임: ${_naverLoginResult?.account.nickname ?? "없음"}'),
              Text('🔹 성별: ${_naverLoginResult?.account.gender ?? "없음"}'),
              Text('🔹 생년월일: ${_naverLoginResult?.account.birthday ?? "없음"}'),
              Text('🔹 출생년도: ${_naverLoginResult?.account.birthyear ?? "없음"}'),
              Text('🔹 휴대폰 번호: ${_naverLoginResult?.account.mobile ?? "없음"}'),
              Text('🔹 연령대: ${_naverLoginResult?.account.age ?? "없음"}'),
              SizedBox(height: 16),

              /// 🔹 **복사 버튼 추가**
              ElevatedButton(
                onPressed: _copyUserInfoToClipboard,
                child: Text('로그인 정보 복사'),
              ),

              SizedBox(height: 8),
              ElevatedButton(
                onPressed: _logoutFromNaver,
                child: Text('로그아웃'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
