import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../util/wit_api_ut.dart';
import '../models/main_view_model.dart';
import '../models/userInfo.dart';
import '../wit_home_sc.dart';

// 데이터를 조회하는 비동기 함수
Future<void> getUserInfo(MainViewModel viewModel,String Idnum) async {

  String? kakaoId = viewModel.userInfo?.id; // Kakao ID
  String? nickName = viewModel.userInfo?.nickName; // Kakao ID
  String? profileImageUrl = viewModel.userInfo?.profileImageUrl; // Kakao ID
  String? email = viewModel.userInfo?.email; // Kakao ID


  //String? kakaoId =  "3776364728"; // Kakao ID
  //String? nickName = "이재명"; // Kakao ID
  //String? profileImageUrl = "https://k.kakaocdn.net/dn/6q8Rc/btsHRu6jL8c/Sg8L10BEavaSQJ1w9qKgeK/img_640x640.jpg"; // Kakao ID
  //String? email = "jaemeong3131@kakao.com"; // Kakao ID


  String restId = "getUserInfo";
  final param = jsonEncode({
    "kakaoId": kakaoId,
    "nickName": nickName,
    "profileImageUrl": profileImageUrl,
    "email": email,
    "clerkNo": Idnum});

  UserInfo? userInfo; // 사용자 정보를 저장할 변수
  final secureStorage = FlutterSecureStorage(); //

  try {
    final response = await sendPostRequest(restId, param);

      if (response is Map<String, dynamic>) {
        userInfo = UserInfo.fromJson(response);
      } else {
        userInfo = UserInfo.fromJson(jsonDecode(response));
      }

      print('userInfo 고객 번호: ' + (userInfo!.clerkNo ?? 'Unknown'));
      print('userInfo 닉네임: '+(userInfo!.nickName??''));
      print('userInfo 이름: '+(userInfo!.name??''));
      print('userInfo 역할: '+(userInfo!.role??''));
      print('userInfo Main아파트 번호: '+(userInfo!.mainAptNo??''));
      print('userInfo Main아파트 이름: '+(userInfo!.mainAptNm??''));
      print('userInfo aptNo 이름: ${userInfo!.aptNo?.join(', ') ?? ''}');
      print('userInfo aptName 이름: ${userInfo!.aptName?.join(', ') ?? ''}');
      // 사용자 정보를 Flutter Secure Storage에 저장
      bool isLogined =false;
      secureStorage.write(key: 'isLogined', value: "login");
      secureStorage.write(key: 'clerkNo', value: userInfo!.clerkNo);
      secureStorage.write(key: 'nickName', value: userInfo!.nickName);
      secureStorage.write(key: 'name', value: userInfo!.name);
      secureStorage.write(key: 'mainAptNo', value: userInfo!.mainAptNo);
      secureStorage.write(key: 'mainAptNm', value: userInfo!.mainAptNm);
      secureStorage.write(key: 'role', value: userInfo!.role);
      secureStorage.write(key: 'authToken', value: "11111");
      secureStorage.write(key: 'aptNo', value: userInfo!.aptNo?.join(',') ?? '');
      secureStorage.write(key: 'aptName', value: userInfo!.aptName?.join(',') ?? '');

      print('리버독 호출되남????????');

      print('리버독 호출되남????????');
      print('리버독 호출되남????????');
      print('리버독 호출되남????????');
      print('리버독 호출되남????????');
      print('리버독 호출되남????????');


  } catch (e) {
    print('사용자 정보 조회 중 오류 발생2222: $e');
  }
}

/**
 * 로그아웃
 */
Future<void> logOut(BuildContext context) async {
  final secureStorage = FlutterSecureStorage(); // Flutter Secure Storage 인스턴스 생성

  // SecureStorage 데이터 삭제
  await secureStorage.deleteAll();
  print("로그아웃 완료: 모든 SecureStorage 데이터가 삭제되었습니다.");

  // HomeScreen으로 이동하면서 이전 라우트 제거
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => const HomeScreen()),
        (route) => false, // 이전의 모든 라우트를 제거
  );
}



Future<bool> checkLoginStatus() async {
  final secureStorage = FlutterSecureStorage(); //
  final token = await secureStorage.read(key: 'authToken');
  return token != null; // 토큰이 있으면 로그인 상태
}




