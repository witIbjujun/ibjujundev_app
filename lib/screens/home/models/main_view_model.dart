import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:witibju/screens/home/models/userInfo.dart';
import 'package:witibju/screens/home/wit_social_login_sc.dart';

class MainViewModel extends ChangeNotifier {
  final SocialLogin _socialLogin;
  bool isLogined = false;
  User? user;
  OAuthToken? token;
  UserInfo? userInfo; // UserInfo 객체 추가
  MainViewModel(this._socialLogin);

  Future<bool> login(BuildContext context) async {
    try {
      // 카카오톡 설치 여부 확인
      if (await isKakaoTalkInstalled()) {
        try {
          token = await UserApi.instance.loginWithKakaoTalk();
          print('카카오톡으로 로그인 성공1: ${token?.accessToken}');

          await _initializeUserInfo(context);  // userInfo 초기화
          isLogined = true;
        } catch (error) {
          //_showErrorDialog(context, '카카오톡으로 로그인 실패2222', error.toString());
          // 카카오톡 로그인이 실패하면 카카오 계정으로 로그인 시도
          await _loginWithKakaoAccount(context);
        }
      } else {
        // 카카오톡이 설치되어 있지 않으면 바로 카카오 계정으로 로그인 시도

        //_showErrorDialog(context, '카카오톡이 설치되어 있지 않으면 바로 카카오 계정으로 로그인 시도', "성공");

        await _loginWithKakaoAccount(context);
      }
    } catch (error) {
      print('로그인 실패 $error');

      // _showErrorDialog(context, '로그인 실패', error.toString());
      isLogined = false;
    }

    notifyListeners();
    return isLogined;
  }

  Future<void> _loginWithKakaoAccount(BuildContext context) async {
    try {
      token = await UserApi.instance.loginWithKakaoAccount();
      print('카카오계정으로 로그인 성공2: ${token?.accessToken}');

      //_showErrorDialog(context, '카카오계정으로 로그인 성공2:', "성공");

      await _initializeUserInfo(context);  // userInfo 초기화
      isLogined = true;
      await _handleAdditionalAgreements(context);
    } catch (error) {
      print('카카오계정으로 로그인 실패4124124124124 $error');

      isLogined = false;
    }
    notifyListeners();  // 로그인 상태 변경 알림
  }

  Future<void> _initializeUserInfo(BuildContext context) async {
    user = await UserApi.instance.me(); // 로그인된 유저 정보 가져오기

    if (user != null) {
      userInfo = UserInfo(
        id: user!.id.toString(),
        nickName: user!.kakaoAccount?.profile?.nickname,
        profileImageUrl: user!.kakaoAccount?.profile?.profileImageUrl,
        email: user!.kakaoAccount?.email,
      );

      print('사용자 정보 요청 성공'
          '\n회원번호: ${userInfo?.id}'
          '\n닉네임: ${userInfo?.nickName}'
          '\n이미지: ${userInfo?.profileImageUrl}'
          '\n이메일: ${userInfo?.email}');
    }


    // 사용자 정보를 변수에 저장
    String id = userInfo?.id ?? '정보 없음';
    String nickName = userInfo?.nickName ?? '정보 없음';
    String profileImageUrl = userInfo?.profileImageUrl ?? '정보 없음';
    String email = userInfo?.email ?? '정보 없음';




    notifyListeners();  // userInfo 변경 알림
  }

  Future<void> _handleAdditionalAgreements(BuildContext context) async {
    List<String> scopes = [];

    if (user?.kakaoAccount?.emailNeedsAgreement == true) {
      scopes.add('account_email');
    }
    if (user?.kakaoAccount?.birthdayNeedsAgreement == true) {
      scopes.add("birthday");
    }
    if (user?.kakaoAccount?.birthyearNeedsAgreement == true) {
      scopes.add("birthyear");
    }
   /// if (user?.kakaoAccount?.ciNeedsAgreement == true) {
    ///  scopes.add("account_ci");
    ///}
    if (user?.kakaoAccount?.phoneNumberNeedsAgreement == true) {
      scopes.add("phone_number");
    }
    if (user?.kakaoAccount?.profileNeedsAgreement == true) {
      scopes.add("profile");
    }
    if (user?.kakaoAccount?.ageRangeNeedsAgreement == true) {
      scopes.add("age_range");
    }

    if (scopes.isNotEmpty) {
      try {
        token = await UserApi.instance.loginWithNewScopes(scopes);
        print('현재 사용자가 동의한 동의항목: ${token!.scopes}');
        await _initializeUserInfo(context);  // userInfo 초기화
      } catch (error) {
        print('추가 동의 요청 실패 $error');
      }
    }
  }

  Future<void> logout() async {
    await _socialLogin.logOut();
    isLogined = false;
    user = null;
    userInfo = null;  // 로그아웃 시 UserInfo 초기화
    print('로그아웃 들어왔다.');
    try {
      await UserApi.instance.unlink();
      print('로그아웃 성공, SDK에서 토큰 삭제');
    } catch (error) {
      print('로그아웃 실패, SDK에서 토큰 삭제 $error');
    }

    notifyListeners();  // 로그아웃 상태 변경 알림
  }

  void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
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
