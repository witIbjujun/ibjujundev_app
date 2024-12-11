import 'dart:async';
import 'dart:io';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../util/wit_code_ut.dart';

class LocalPushNotifications {

  //플러그인 인스턴스 생성
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  //푸시 알림 스트림 생성
  static final StreamController<String?> notificationStream = StreamController<String?>.broadcast();

  //푸시 알림을 탭했을 때 호출되는 콜백 함수
  static void onNotificationTap(NotificationResponse notificationResponse) {
    notificationStream.add(notificationResponse.payload!);
  }

  //플러그인 초기화
  static Future init() async {
    //Android
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    //ios
    const DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings();
    //Linux
    const LinuxInitializationSettings initializationSettingsLinux = LinuxInitializationSettings(defaultActionName: 'Open notification');
    // OS 초기화
    const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
        linux: initializationSettingsLinux
    );

    //안드로이드 푸시 알림 권한 요청
    if (Platform.isAndroid) {
      _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()!.requestNotificationsPermission();
    }

    _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      // 푸시 알림을 탭했을 때 호출되는 콜백 함수 등록
      onDidReceiveNotificationResponse: onNotificationTap,
      // 백그라운드에서 푸시 알림을 탭했을 때 호출되는 콜백 함수 등록
      onDidReceiveBackgroundNotificationResponse: onNotificationTap,
    );

  }

  // 일반 푸시 알림 보내기
  // [title] : 알림의 제목
  // [body] : 알림의 내용
  // [payload] : 알림과 함께 전달되는 추가 데이터
  static Future showSimpleNotification({
    required String title, // 알림 제목
    required String body, // 알림 본문
    required String payload, // 알림 클릭 시 전달되는 데이터
  }) async {
    // 안드로이드 알림 세부정보 설정
    const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
        'channel 1', // 채널 ID
        'channel 1 name', // 채널 이름
        channelDescription: 'channel 1 description', // 채널 설명
        importance: Importance.max, // 알림 중요도 설정
        priority: Priority.high, // 알림 우선 순위 설정
        ticker: 'ticker' // 알림의 틱커 텍스트
    );

    // 알림 세부정보 설정
    const NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);

    // 알림 표시
    await _flutterLocalNotificationsPlugin.show(
        0, // 알림 ID (중복 방지를 위해 고유해야 함)
        title, // 알림 제목
        body, // 알림 본문
        notificationDetails, // 알림 세부정보
        payload: payload // 알림 클릭 시 전달될 데이터
    );
  }
/*
  // 지정된 스케쥴에 맞춰 알람 보내기
  static Future showScheduleNotification({
    required String title,
    required String body,
    required String payload,
  }) async {
    tz.initializeTimeZones(); //time zone 초기화
    await _flutterLocalNotificationsPlugin.zonedSchedule(
        2,
        title,
        body,
        tz.TZDateTime.now(tz.local).add(const Duration(seconds: 1)), //5초 이후에 푸시 알림
        const NotificationDetails(
            android: AndroidNotificationDetails(
                'channel 3', 'your channel name',
                channelDescription: 'your channel description',
                importance: Importance.max,
                priority: Priority.high,
                ticker: 'ticker')),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload
    );
  }*/
}