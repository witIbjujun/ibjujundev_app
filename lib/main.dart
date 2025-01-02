import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:provider/provider.dart';
import 'package:witibju/screens/home/models/main_view_model.dart';
// import 'package:witibju/screens/home/wit_home2.dart';
import 'package:witibju/screens/home/wit_home_sc.dart';
import 'package:witibju/screens/home/login/wit_kakaoLogin.dart';
import 'package:witibju/screens/home/login/wit_kakaoLogin_home_sc.dart';
// import 'package:witibju/util/wit_apppush.dart';

/// 백그라운드 메시지 처리 함수
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화 추가
  await Firebase.initializeApp(); // Firebase 서비스를 사용하기 전에 반드시 초기화해야 함

  // Firebase Messaging 초기화
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // 백그라운드 메시지 처리
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);


  // 알림 권한 요청
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.denied) {
    print("알림 권한이 거부되었습니다.");
  } else {
    print("알림 권한이 허용되었습니다.");
  }

  KakaoSdk.init(
    nativeAppKey: '25cc33cc258862ad87987baa7b5f4477',
  );


  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => MainViewModel(KaKaoLogin()), // 구체적인 KakaoLogin 구현체 사용
        ),
      ],
      child: MyApp(), // MyApp에 토큰 전달
    ),
  );
}

class MyApp extends StatelessWidget {
  final String? token;

  MyApp({this.token});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      ///home: NavigationHomeScreen(),  기존 밀어서
      home: HomeScreen(), //현재 메인
      // home: FCMSender(), //현재 메인
      /// home: kakoLoingHome(),

      ///home: ImageSlider(),
      //home: Board("B01"),  //게시판
      ///home: Question(qustCd: 'Q00001'),  // 질의문
      ///home: SellerProfileDetail(sllrNo: '17'),  // 판매자
      ///home: Directionality(
      ///   textDirection: TextDirection.ltr,
      /// child: ChatPage(),
      ///),   채팅
    );
  }
}
