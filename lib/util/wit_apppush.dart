import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseMessageService {
  /// FirebaseMessaging 인스턴스 초기화
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  /// 초기화 및 메시지 핸들러 등록
  static void initialize(BuildContext context) {
    // 포어그라운드 메시지 핸들러
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        String? title = message.notification!.title ?? '알림';
        String? body = message.notification!.body ?? '내용 없음';

        print('포어그라운드 메시지: $title, $body');

        // 다이얼로그로 메시지 표시
        _showDialog(context, title, body);
      }

      // 데이터 메시지 처리 (옵션)
      if (message.data.isNotEmpty) {
        print('데이터 메시지: ${message.data}');
      }
    });

    // 백그라운드 메시지 처리 핸들러 등록 (필요시)
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  /// 다이얼로그 표시 함수
  static void _showDialog(BuildContext context, String title, String body) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

  /// 백그라운드 메시지 핸들러 (옵션)
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print('백그라운드 메시지 수신: ${message.messageId}');
    // 추가 백그라운드 로직 작성
  }
}
