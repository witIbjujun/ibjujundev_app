import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../../util/wit_api_ut.dart';
import '../../util/wit_soket.dart';

/// `ChatPage` 위젯: 채팅 화면을 표시하는 StatefulWidget
class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

/// 채팅 상태를 관리하는 `_ChatPageState` 클래스
class _ChatPageState extends State<ChatPage> {
  final List<types.Message> _messages = [];
  /// 현재 로그인한 사용자를 나타내는 객체
  final _user = const types.User(id: '72091587');

  // 추천 메시지 리스트
  final List<String> _suggestedMessages = [
    "👍 안녕하세요. 진행 방식은 어떻게 되나요?",
    "🤔 안녕하세요. 제공 서비스를 자세히 설명해 주세요",
    "💲 안녕하세요. 견적 산정 방식은 어떻게 되나요?"
  ];

  @override
  void initState() {
    super.initState();
    _loadMessages();
    //_connectWebSocket();
  }

  /// 메시지 데이터를 정리하는 함수 (누락된 데이터 처리)
    Map<String, dynamic> _sanitizeMessageData(Map<String, dynamic> messageData) {
    return messageData.map((key, value) {
      if (value == null) {
        if (key == 'id') return MapEntry(key, Uuid().v4());  // ID가 없으면 새로운 UUID 생성
        if (key == 'text') return MapEntry(key, ''); // text가 없으면 빈 문자열 추가
        if (key == 'type') return MapEntry(key, 'text'); // type이 없으면 'text'로 설정
        if (key == 'createdAt') return MapEntry(key, DateTime.now().millisecondsSinceEpoch); // 현재 시간 설정
      }
      return MapEntry(key, value);
    });
  }

  /// 새 메시지를 채팅 목록에 추가하는 함수
  void _addMessage(types.Message message) {
    if (!_messages.any((m) => m.id == message.id)) { // 중복 방지
      setState(() {
        _messages.insert(0, message); // 리스트 맨 앞에 추가
      });
      _saveMessage(message); // 서버에 저장
    }
  }

  /// 채팅 메시지를 서버에 저장하는 함수
  void _saveMessage(types.Message message) async {
    String restId = "saveChatMessage";
    String chatId = "1"; // 현재 채팅방 ID

    final param = jsonEncode({
      "chatId": chatId,
      "author": {"id": message.author.id}, // 메시지 작성자 ID
      "createdAt": message.createdAt, // 생성 시간
      "text": message is types.TextMessage ? message.text : null, // 텍스트 메시지
      "type": message.type.toString().split('.').last, // 메시지 유형
      "metadata": message.metadata ?? {} // 추가 데이터 (없으면 빈 객체)
    });

    try {
      final response = await sendPostRequest(restId, param) ?? '';
      if (response == 'success') {
        _loadMessages();  // 성공하면 다시 메시지 목록을 불러옴
      } else {
        print("Failed to save message: $response");
      }
    } catch (e) {
      print("Error saving message: $e");
    }
  }

  void _handleSuggestedMessagePressed(String text) {
    final suggestedMessage = types.PartialText(text: text);
    _handleSendPressed(suggestedMessage);
  }


  /// 기존 메시지를 서버에서 불러오는 함수
  void _loadMessages() async {
    String restId = "getChatList";
    String chatId = "1";
    final param = jsonEncode({"chatId": chatId});

    final response = await sendPostRequest(restId, param);
    if (response is List) {
      final messages = response
          .map((e) => e is Map<String, dynamic>
          ? types.TextMessage.fromJson(e.map((key, value) => MapEntry(key, value ?? '')))
          : null)
          .where((message) => message != null)
          .toList()
          .cast<types.Message>();

      setState(() {
        _messages.clear(); // 기존 메시지 삭제
        _messages.addAll(messages); // 불러온 메시지 추가

        // 🔴 추천 메시지를 시스템 메시지처럼 추가
        _suggestedMessages.forEach((text) {
          final suggestedMessage = types.TextMessage(
            author: types.User(id: 'system'), // 시스템 메시지로 구분
            createdAt: DateTime.now().millisecondsSinceEpoch,
            id: const Uuid().v4(),
            text: text,
          );
          _messages.insert(0, suggestedMessage); // 최근 메시지처럼 추가
        });
      });
    } else {
      print("Unsupported response type: ${response.runtimeType}");
    }
  }


  Widget _buildMessage(types.Message message) {
    bool isSuggestedMessage = message.author.id == 'system';

    // 메시지가 TextMessage 타입인지 확인 후 text 속성 사용
    String messageText = (message is types.TextMessage) ? message.text : "[지원되지 않는 메시지]";

    return GestureDetector(
      onTap: isSuggestedMessage ? () => _handleSuggestedMessagePressed(messageText) : null,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isSuggestedMessage ? Colors.grey[200] : Colors.blue[100], // 추천 메시지는 회색
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Text(
          messageText,
          style: TextStyle(
            fontSize: 16,
            color: isSuggestedMessage ? Colors.black87 : Colors.blue[900], // 추천 메시지는 검정, 일반 메시지는 파란색
          ),
        ),
      ),
    );
  }

  /// 사용자가 채팅 입력 후 전송 버튼을 누르면 실행되는 함수
  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: _user, // 현재 사용자
      createdAt: DateTime.now().millisecondsSinceEpoch, // 현재 시간
      id: const Uuid().v4(), // 메시지 ID 생성
      text: message.text, // 입력된 메시지 텍스트
    );

    _addMessage(textMessage); // 메시지 추가
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Chat(
          key: UniqueKey(), // 각 빌드마다 고유한 키 추가
          messages: _messages,
          onSendPressed: _handleSendPressed,
          showUserAvatars: true,
          showUserNames: true,
          user: _user,
          textMessageBuilder: (message, {required int messageWidth, required bool showName}) {
            if (message.author.id == 'system') {
              return GestureDetector(
                onTap: () => _handleSuggestedMessagePressed(message.text),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[200], // 추천 메시지는 회색
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Text(
                    message.text,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ),
              );
            }
            // 기본 메시지 스타일을 반환하여 null 오류 방지
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Text(
                message.text,
                style:  TextStyle(fontSize: 16, color: Colors.black87),
              ),
            );
          },
        ),
      ),
    );
  }
}
