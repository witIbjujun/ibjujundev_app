import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:provider/provider.dart';
import 'package:witibju/screens/home/login/wit_naverLogin.dart';
import 'package:witibju/screens/home/models/main_view_model.dart';
// import 'package:witibju/screens/home/wit_home2.dart';
import 'package:witibju/screens/home/wit_home_sc.dart';
import 'package:witibju/screens/home/login/wit_kakaoLogin.dart';
import 'package:witibju/screens/home/login/wit_kakaoLogin_home_sc.dart';
import 'package:witibju/screens/result.dart';
import 'package:witibju/screens/tosspayments_widget/widget_home.dart';
// import 'package:witibju/util/wit_apppush.dart';

/// 백그라운드 메시지 처리 함수
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화 추가
  await Firebase.initializeApp(); // Firebase 서비스를 사용하기 전에 반드시 초기화해야 함
  // 날짜 형식 초기화
  await initializeDateFormatting('ko_KR', null);
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

  // 포그라운드 메시지 핸들러 등록
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("포그라운드에서 메시지 수신: ${message.notification?.title}");
    print("내용: ${message.notification?.body}");
  });


  if (settings.authorizationStatus == AuthorizationStatus.denied) {
    print("알림 권한이 거부되었습니다.");
  } else {
    print("알림 권한이 허용되었습니다.");
  }

  KakaoSdk.init(
    nativeAppKey: '25cc33cc258862ad87987baa7b5f4477',
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp, // 세로 모드 고정
  ]).then((_) {
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
  });
}

class MyApp extends StatelessWidget {
  final String? token;

  MyApp({this.token});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,

      // 앱 언어 설정
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko'),
      ],

      home: HomeScreen(), //현재 메인
      ///home: TableCalenderMain() , //네이버 로그인
      // 토스 결재 후 처리
      getPages: [
        GetPage(name: '/result', page: () => ResultPage()), // 결과 화면 등록
      ],


      // home: FCMSender(), //현재 메인
      ///home: kakoLoingHome(),

      ///home: Directionality(
      ///   textDirection: TextDirection.ltr,
      /// child: ChatPage(),
      ///),   채팅
      ///
      ///
    );
  }
}
