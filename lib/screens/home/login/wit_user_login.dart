import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../util/wit_api_ut.dart';
import '../models/main_view_model.dart';
import '../models/userInfo.dart';
import '../wit_home_sc.dart';

Future<void> getUserInfo(MainViewModel viewModel,String tempClerkNo,String gubun) async {

  String? kakaoId = viewModel.userInfo?.id; // Kakao ID
  String? nickName = viewModel.userInfo?.nickName; // Kakao ID
  String? profileImageUrl = viewModel.userInfo?.profileImageUrl; // Kakao ID
  String? email = viewModel.userInfo?.email; // Kakao ID
  String? mainAptNo = viewModel.userInfo?.mainAptNo; // Kakao ID
  String? mainAptPyoung = viewModel.userInfo?.mainAptPyoung; // Kakao ID
  String? loginSnsType = viewModel.userInfo?.loginSnsType; // Kakao ID


  // 토큰 가져오기
  String? token = await FirebaseMessaging.instance.getToken();
  print("나의 kakaoId은???====$kakaoId");
  print("나의 clerkNo???====$tempClerkNo");
  print("나의 email???====$email");
  print("나의 토큰은???====$token");
  print("나의 토큰은???====$token");
  print("나의 nickName은???====$nickName");
  print("나의 mainAptNo은???====$mainAptNo");
  print("나의 mainAptPyoung은???====$mainAptPyoung");
  print("나의 loginSnsType은???====$loginSnsType");

  String restId = "getUserInfo";
  final param = jsonEncode({
    "kakaoId": kakaoId,
    "nickName": nickName,
    "profileImageUrl": profileImageUrl,
    "loginGubun": gubun,
    "email": email,
    "aptNo": mainAptNo,
    "pyoung": mainAptPyoung,
    "clerkNo":tempClerkNo,
    "loginSnsType":loginSnsType,
     "token":token});

  UserInfo? userInfo; // 사용자 정보를 저장할 변수
  final secureStorage = FlutterSecureStorage(); //

  try {
    final response = await sendPostRequest(restId, param);
    print("API 응답 데이터: $response"); // 응답 확인
    if (response is Map<String, dynamic>) {
      print('1111111 ' );
      userInfo = UserInfo.fromJson(response);
    } else {
      print('222222222222 ' );

      userInfo = UserInfo.fromJson(jsonDecode(response));
    }

    print('userInfo 고객 번호: ' + (userInfo!.clerkNo ?? 'Unknown'));
    print('userInfo 닉네임: '+(userInfo!.nickName??''));
    print('userInfo 역할: '+(userInfo!.role??''));
    print('userInfo 역할: '+(userInfo!.email??''));
    print('userInfo Main아파트 번호: '+(userInfo!.mainAptNo??''));
    print('userInfo Main아파트 이름: '+(userInfo!.mainAptNm??''));
    print('userInfo aptNo 이름: ${userInfo!.aptNo?.join(', ') ?? ''}');
    print('userInfo aptName 이름: ${userInfo!.aptName?.join(', ') ?? ''}');
    // 사용자 정보를 Flutter Secure Storage에 저장
    bool isLogined =false;
    await secureStorage.write(key: 'isLogined', value: "login");
    await secureStorage.write(key: 'email', value: userInfo!.email);
    await secureStorage.write(key: 'kakaoId', value: userInfo!.id);
    await secureStorage.write(key: 'clerkNo', value: userInfo!.clerkNo);
    await secureStorage.write(key: 'profileImageUrl', value: userInfo!.profileImageUrl);
    await secureStorage.write(key: 'nickName', value: userInfo!.nickName);
    await secureStorage.write(key: 'mainAptNo', value: userInfo!.mainAptNo);
    await secureStorage.write(key: 'mainAptNm', value: userInfo!.mainAptNm);
    await secureStorage.write(key: 'role', value: userInfo!.role);
    await secureStorage.write(key: 'authToken', value: "11111");
    await secureStorage.write(key: 'aptNo', value: userInfo!.aptNo?.join(',') ?? '');
    await secureStorage.write(key: 'aptName', value: userInfo!.aptName?.join(',') ?? '');

    // ✅ 저장 후 바로 읽어서 확인해보기
    String? savedClerkNo = await secureStorage.read(key: 'clerkNo');
    print('📝 SecureStorage에 방금 저장된 clerkNo: $savedClerkNo');
  } catch (e) {
    print('사용자 정보 조회 중 오류 발생2222: $e');
  }
}

Future<String> getCreateUser(MainViewModel viewModel,String clerkNo) async {
  String? kakaoId = viewModel.userInfo?.id; // Kakao ID
  String? nickName = viewModel.userInfo?.nickName; // Kakao ID
  String? profileImageUrl = viewModel.userInfo?.profileImageUrl; // Kakao ID
  String? email = viewModel.userInfo?.email; // Kakao ID
  String? mainAptNo = viewModel.userInfo?.mainAptNo; // Kakao ID
  String? mainAptPyoung = viewModel.userInfo?.mainAptPyoung; // Kakao ID
  String? loginSnsType = viewModel.userInfo?.loginSnsType; // Kakao ID

  // 토큰 가져오기
  String? token = await FirebaseMessaging.instance.getToken();
  print("나의 초기 등록 getCreateUser kakaoId은???====$kakaoId");
  print("나의 초기 등록 getCreateUser clerkNo???====$clerkNo");
  print("나의 초기 getCreateUser 등록토큰은???====$token");
  print("나의 초기 getCreateUser 등록nickName은???====$nickName");
  print("나의 초기 getCreateUser 등록mainAptNo은???====$mainAptNo");
  print("나의 초기 getCreateUser 등록 mainAptPyoung은???====$mainAptPyoung");
  print("나의 초기 getCreateUser 등록 loginSnsType???====$loginSnsType");
  print("나의 초기 getCreateUser 등록 email???====$email");

  String restId = "getCreateUser";
  final param = jsonEncode({
    "kakaoId": kakaoId,
    "nickName": nickName,
    "profileImageUrl": profileImageUrl,
    "email": email,
    "loginSnsType": loginSnsType,
    "aptNo": mainAptNo,
    "pyoung": mainAptPyoung,
    "clerkNo":clerkNo,
    "agreeGbn":"1,2",
    "token":token});

  UserInfo? userInfo; // 사용자 정보를 저장할 변수
  final secureStorage = FlutterSecureStorage(); //

  try {
    final response = await sendPostRequest(restId, param);
    print("API 응답 데이터: $response"); // 응답 확인
    if (response is Map<String, dynamic>) {
      print('1111111 ' );
      userInfo = UserInfo.fromJson(response);
    } else {
      print('222222222222 ' );

      userInfo = UserInfo.fromJson(jsonDecode(response));
    }

    print('초기 등록 getCreateUser userInfo 고객 번호: ' + (userInfo!.clerkNo ?? 'Unknown'));
    print('초기 등록 getCreateUser userInfo 닉네임: '+(userInfo!.nickName??''));
    print('초기 등록 getCreateUser userInfo 역할: '+(userInfo!.role??''));
    print('초기 등록 getCreateUser userInfo 역할 email: '+(userInfo!.email??''));
    print('초기 등록 getCreateUser userInfo Main아파트 번호: '+(userInfo!.mainAptNo??''));
    print('초기 등록 getCreateUser userInfo Main아파트 이름: '+(userInfo!.mainAptNm??''));
    print('초기 등록 getCreateUser userInfo aptNo 이름: ${userInfo!.aptNo?.join(', ') ?? ''}');
    print('초기 등록 getCreateUser userInfo aptName 이름: ${userInfo!.aptName?.join(', ') ?? ''}');
    // 사용자 정보를 Flutter Secure Storage에 저장
    bool isLogined =false;
    secureStorage.write(key: 'isLogined', value: "login");
    secureStorage.write(key: 'clerkNo', value: userInfo!.clerkNo);
    secureStorage.write(key: 'nickName', value: userInfo!.nickName);
    secureStorage.write(key: 'mainAptNo', value: userInfo!.mainAptNo);
    secureStorage.write(key: 'mainAptNm', value: userInfo!.mainAptNm);
    secureStorage.write(key: 'email', value: userInfo!.email);
    secureStorage.write(key: 'role', value: userInfo!.role);
    secureStorage.write(key: 'authToken', value: "11111");
    secureStorage.write(key: 'aptNo', value: userInfo!.aptNo?.join(',') ?? '');
    secureStorage.write(key: 'aptName', value: userInfo!.aptName?.join(',') ?? '');
    return '1';
  } catch (e) {
    print('사용자 정보 조회 중 오류 발생2222: $e');
    return '0';
  }
}


Future<String> getChckUser(MainViewModel viewModel,String clerkNo) async {
  String? kakaoId = viewModel.userInfo?.id; // Kakao ID
  String restId = "getChckUserInfo";
  final param = jsonEncode({
    "kakaoId": kakaoId,
    "clerkNo":clerkNo
    , });
  try {
    final response = await sendPostRequest(restId, param);


    if (response != null) {
      print('사용자 있음 ==$response');

     if(response > 0){
       return response.toString();
     }else{
       return response.toString();
     }


    } else {
      print('사용자 없음');
      return response; // response가 null일 경우 기본값 반환
    }
  } catch (e) {
    print('설마요기?? ==');
    return "0"; // null인 경우를 위한 기본 값 반환
    print('사용자 정보 조회 중 오류 발생2222: $e');
  }
}




// 데이터를 조회하는 비동기 함수
Future<int> getChckUserInfo(MainViewModel viewModel) async {

  //String? kakaoId = viewModel.userInfo?.id; // Kakao ID
  //String? nickName = viewModel.userInfo?.nickName; // Kakao ID
  //String? profileImageUrl = viewModel.userInfo?.profileImageUrl; // Kakao ID
  //String? email = viewModel.userInfo?.email; // Kakao ID


  String? kakaoId =  "3776364728"; // Kakao ID
  String? nickName = "이재명"; // Kakao ID
  String? profileImageUrl = "https://k.kakaocdn.net/dn/6q8Rc/btsHRu6jL8c/Sg8L10BEavaSQJ1w9qKgeK/img_640x640.jpg"; // Kakao ID
  String? email = "jaemeong3131@kakao.com"; // Kakao ID


  String restId = "getChckUserInfo";
  final param = jsonEncode({
    "kakaoId": kakaoId});
  try {
    final response = await sendPostRequest(restId, param);
    if (response != null) {
      return response; // response 값 반환
    } else {
      return -1; // response가 null일 경우 기본값 반환
    }
  } catch (e) {
    return -1; // null인 경우를 위한 기본 값 반환
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




