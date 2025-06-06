import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../screens/home/widgets/wit_home_widgets.dart';
import '../screens/home/wit_estimate_detail.dart';
import '../screens/seller/wit_seller_estimaterequest_list_sc.dart';
import '../main.dart'; // navigatorKey 사용

class FirebasePushHandler {
  static void initialize() {
    // 🔹 앱이 꺼진 상태에서 푸시 클릭한 경우
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) _handleMessage(message);
    });

    // 🔹 백그라운드 상태에서 푸시 클릭한 경우
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleMessage(message);
    });

    // 🔹 포어그라운드 상태에서 메시지 수신 시 처리
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print("✅ [포어그라운드] 메시지 수신: ${message.notification?.title}");
      print("📦 데이터 메시지: ${message.data}");

      final data = message.data;
      final screen = data['screen'];

      // ✅ AlertDialog 먼저 띄우고
      await DialogUtils.showIPhoneAlertDialog(
        context: navigatorKey.currentContext!,
        title: message.notification?.title ?? '알림',
        content: message.notification?.body ?? '새로운 메시지가 도착했습니다.',
        onConfirm: () {
          // ✅ 확인 누르면 화면 이동
          _navigateToScreen(screen);
        },
      );
    });
  }

  // ✅ 푸시 클릭 또는 AlertDialog 확인 시 화면 이동 처리
  static void _handleMessage(RemoteMessage message) {
    print("✅ [푸시 클릭] _handleMessage 호출됨");
    final data = message.data;
    print("📦 수신된 data: $data");

    final screen = data['screen'];
    _navigateToScreen(screen);
  }

  // ✅ screen 값에 따라 라우팅 처리
  static void _navigateToScreen(String? screen) {
    print("🧭 이동할 screen 값: $screen");

    if (screen == 'SellerProfileDetail') {
      print("🚀 SellerProfileDetail 화면으로 이동 시작");
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => EstimateRequestList(stat: ''),
        ),
      );
    }else  if (screen == 'EstimateScreen') {
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => EstimateScreen(),
        ),
      );
    } else {
      print("❗ 알 수 없는 screen 값입니다: $screen");
    }
  }
}
