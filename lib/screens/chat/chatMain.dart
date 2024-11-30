import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../../util/wit_api_ut.dart';
import '../../util/wit_soket.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<types.Message> _messages = [];
  final _user = const types.User(id: '72091587');
  late WitSocket _witSocket;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _connectWebSocket();
  }

  void _connectWebSocket() {
    _witSocket = WitSocket();
    _witSocket.connectWebSocket(
      destination: '/topic/chat/1',
      onMessageReceived: (messageData) {
        messageData = _sanitizeMessageData(messageData);
        if (messageData['id'] == null) {
          messageData['id'] = '72091587';
        }
        final message = types.TextMessage.fromJson(messageData);
        if (!_messages.any((m) => m.id == message.id)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _messages.insert(0, message);
            });
          });
          debugPrint('Received message: $message');
        }
      },
    );
  }

  Map<String, dynamic> _sanitizeMessageData(Map<String, dynamic> messageData) {
    return messageData.map((key, value) {
      if (value == null) {
        if (key == 'id') return MapEntry(key, Uuid().v4());
        if (key == 'text') return MapEntry(key, '');
        if (key == 'type') return MapEntry(key, 'text');
        if (key == 'createdAt') return MapEntry(key, DateTime.now().millisecondsSinceEpoch);
      }
      return MapEntry(key, value);
    });
  }

  void _addMessage(types.Message message) {
    if (!_messages.any((m) => m.id == message.id)) {
      setState(() {
        _messages.insert(0, message);
      });
      _saveMessage(message);
    }
  }

  void _saveMessage(types.Message message) async {
    String restId = "saveChatMessage";
    String chatId = "1";

    final param = jsonEncode({
      "chatId": chatId,
      "author": {"id": message.author.id},
      "createdAt": message.createdAt,
      "text": message is types.TextMessage ? message.text : null,
      "type": message.type.toString().split('.').last,
      "metadata": message.metadata ?? {}
    });

    try {
      final response = await sendPostRequest(restId, param) ?? '';
      if (response == 'success') {
        _loadMessages();
      } else {
        print("Failed to save message: $response");
      }
    } catch (e) {
      print("Error saving message: $e");
    }
  }

  void _loadMessages() async {
    String restId = "getChatList";
    String chatId = "1";
    final param = jsonEncode({"chatId": chatId});

    final response = await sendPostRequest(restId, param);
    if (response is List) {
      final messages = response
          .map((e) => e is Map<String, dynamic> ? types.TextMessage.fromJson(e.map((key, value) => MapEntry(key, value ?? ''))) : null)
          .where((message) => message != null)
          .toList()
          .cast<types.Message>();

      setState(() {
        _messages.clear();
        _messages.addAll(messages);
      });
    } else {
      print("Unsupported response type: ${response.runtimeType}");
    }
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message.text,
    );

    _addMessage(textMessage);
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
        ),
      ),
    );
  }
}
