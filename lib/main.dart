import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:witibju/screens/home/models/main_view_model.dart';
import 'package:witibju/screens/home/wit_home_sc.dart';
import 'package:witibju/screens/home/login/wit_kakaoLogin.dart';
import 'package:witibju/screens/seller/wit_seller_profile_detail_sc.dart';
import 'package:witibju/util/firebase_push_handler.dart';

/// 백그라운드 메시지 처리 함수
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}


// 화면 재조회 설정 // RouteObserver 선언 (전역)
final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {

  // ✅ Flutter Binding 초기화 및 Splash 유지
  WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: WidgetsFlutterBinding.ensureInitialized());

  // ✅ 3초 후에 Splash 화면 제거
  Future.delayed(Duration(seconds: 3), () {
    FlutterNativeSplash.remove();
  });

  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화 추가
  await Firebase.initializeApp(); // Firebase 서비스를 사용하기 전에 반드시 초기화해야 함
  // ✅ 푸시 초기화는 그 다음에!
  FirebasePushHandler.initialize(); // 🔄 새로운 핸들러 초기화 호출

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

  // 포그라운드 메시지 핸들러 등록 (앱이 실행중일때)
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
      navigatorKey: navigatorKey, // ✅ 전역 navigatorKey 등록 App_pusH 선택시 이동을 윈한
      navigatorObservers: [routeObserver],

      // 앱 언어 설정
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko'),
      ],
      home: SplashScreen(), //현재 메인
     // home: HomeScreen(), //현재 메인
      ///home: TableCalenderMain() , //네이버 로그인
      // 토스 결재 후 처리
      /*getPages: [
        GetPage(name: '/result', page: () => ResultPage()), // 결과 화면 등록
      ],*/

          );
  }
}

// ✅ 커스텀 스플래시 화면
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}


// ✅ 커스텀 스플래시 화면
class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // ✅ 3초 후에 HomeScreen으로 이동
    Future.delayed(Duration(seconds: 1), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          width: 150, // ✅ 기본 사이즈보다 살짝 크게 설정
          height: 150,
          child: Image.asset('assets/home/mainLogo.png', fit: BoxFit.contain),
        ),
      ),
    );
  }
}
