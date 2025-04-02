// 2025-03-27 (질문 버튼 + 입력창 자동입력)
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../util/wit_api_ut.dart';
import '../home/wit_home_theme.dart';
import 'models/message_info.dart';

class CustomChatScreen extends StatefulWidget {
  final String? chatId;
  final String? clerkNo;
  const CustomChatScreen(this.chatId,this.clerkNo,{super.key});

  @override
  State<CustomChatScreen> createState() => _CustomChatScreenState();
}

class _CustomChatScreenState extends State<CustomChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final List<Map<String, dynamic>> _chatMessages = [];
  final String chatId = '1'; // 이건 실제 상황에 맞게 바꿔줘
  String _currentText = ''; // 2025-03-27: 현재 입력된 텍스트
  final secureStorage = FlutterSecureStorage();
  final ScrollController _scrollController = ScrollController();

  void _setMessageText(String text) {
    setState(() {
      _textController.text = text;
    });
  }

  @override
  void initState() {
    super.initState();
    getChatMessages();

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// 채팅 메시지를 서버에 저장하는 함수
  Future<void> _saveMessageToServer(String text) async {
    const String restId = "saveChatMessage";
    final String? chatId = widget.chatId;

    //String? clerkNo = await secureStorage.read(key: 'clerkNo');

    String? clerkNo = widget.clerkNo;

    final now = DateTime.now().toIso8601String();
    print('✅ 메시지 저장 성공+==='+text);
    final param = jsonEncode({
      "chatId": chatId,
      "clerkNo": clerkNo,
      "createdAt": now,
      "text": text,
      "chatgubun": "user",
      "type": "text", // 지금은 텍스트 메시지로 고정
      "metadata": {} // 없으면 빈 객체
    });

    try {
      final response = await sendPostRequest(restId, param) ?? '';
      if (response > 0) {
        print('✅ 메시지 저장 성공');
        getChatMessages(); // 다시 목록 불러오기
      } else {
        print("❌ 메시지 저장 실패: $response");
      }
    } catch (e) {
      print("❌ 저장 중 예외 발생: $e");
    }
  }


  /**
   * 채팅내용 조회
   */
  // 2025-03-29: 서버에서 채팅 목록을 가져오는 함수 수정
  Future<void> getChatMessages() async {
    String restId = "getChatList";
   // String? clerkNo = await secureStorage.read(key: 'clerkNo');

    String? clerkNo = widget.clerkNo;
    print('✅ 메시지 222222===${widget.clerkNo}');
    final param = jsonEncode({
      "clerkNo": clerkNo,
      "chatId": chatId,
      "chatgubun": "user",
    });

    print('📡 상세 조회 요청 전송 중...');

    try {
      final _chatList = await sendPostRequest(restId, param);
      final List<MessageInfo> parsedList = MessageInfo().parseMessageList(_chatList) ?? [];

      setState(() {
        _chatMessages.clear();
        _chatMessages.addAll(parsedList.map((msg) => msg.toJson()));
      });

      print('📡 상세 조회 성공: ${_chatMessages.length}건 수신');
    } catch (e) {
      print('❌ 채팅 목록 조회 중 오류 발생: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // 2025-03-29: 키보드가 올라올 때 하단 위젯 피해서 재배치
      //backgroundColor: const Color(0xFFBFD4E4),
      backgroundColor: const Color(0xFFD3D3D3),
      appBar: AppBar(
        title: const Text('대화화기'),
        backgroundColor: Colors.white, // 2025-03-27: 배경 흰색으로 설정
        foregroundColor: Colors.black, // 2025-03-27: 텍스트와 아이콘은 검정색
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _estimateCard(),
                const SizedBox(height: 12),
                _questionButtons(),
                const SizedBox(height: 16),

                // 2025-03-29: 유저 입력 메시지 렌더링
                ..._chatMessages.map((msg) {
                  print('🟡 chatgubun: ${msg['chatgubun']} | text: ${msg['text']} | time: ${msg['time']}| storeName: ${msg['storeName']}');
                  return _chatBubble(
                    text: msg['text'],
                    chatgubun: msg['chatgubun'], // 여기가 'me'여야 우측/노란색
                    date: msg['date'],
                    storeName: msg['storeName'],
                    profileImage: msg['profileImage'],
                  );
                }),


              ],
            ),
          ),
          const Divider(height: 1),
          Container(
            color: Colors.grey.shade100,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    focusNode: _focusNode,
                    controller: _textController,
                    onChanged: (val) {
                      setState(() {
                        _currentText = val; // 입력 변화 반영
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: '메시지를 입력하세요',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    final message = _textController.text.trim();
                    if (message.isNotEmpty) {
                      _saveMessageToServer(message); // 서버로 저장 요청
                      _textController.clear();
                      _currentText = '';
                    }
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  /**
   * 질문 버튼 리스트
   */
  Widget _questionButtons() {
    final questions = [
      '👍 안녕하세요 작업이 언제가능 할까요?',
      '⏰ 작업시간이 얼마나 걸릴까요?',
    ];

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: questions.map((q) => GestureDetector(
            onTap: () {
              // 2025-03-29: 입력창에 넣는 대신 바로 저장
              _saveMessageToServer(q);
              _textController.clear();
              _currentText = '';
              _focusNode.unfocus();
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                q,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
          )).toList(),
        ),
      ),
    );
  }

  /**
   * 계약서
   */
  Widget _estimateCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.receipt_long, color: Colors.black54),
              SizedBox(width: 6),
              Text('견적서', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          const Text('이재명 고객님 안녕하세요. 요청서에 따른 예상금액입니다.'),
          const SizedBox(height: 16),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('서비스', style: TextStyle(color: Colors.grey)),
              Text('미세방충망 설치'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('견적금액', style: TextStyle(color: Colors.grey)),
              Text('135,000 원', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(height: 24),
        ],
      ),
    );
  }

  /**
   * 채팅 글자
   */
  // 2025-03-29: isMe → messageType (me, system, other)
  Widget _chatBubble({
    required String text,
    required String chatgubun, // me, system, other
    required String date,
    String? profileImage,
    String? storeName,
  }) {
    final radius = Radius.circular(18);

    // 말풍선 색상 설정
    final Color bubbleColor;
    if (chatgubun == 'me') {
      bubbleColor = const Color(0xFFFFFF66);
    } else if (chatgubun == 'system') {
      bubbleColor = Colors.grey.shade400;
    } else {
      bubbleColor = const Color(0xFFBFD4E4);
    }

    // 정렬 설정
    final alignment = chatgubun == 'me'
        ? Alignment.centerRight
        : Alignment.centerLeft;

    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: chatgubun == 'me'
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (chatgubun == 'other' && profileImage != null)
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage(profileImage),
                  ),
                  const SizedBox(width: 6),
                  if (storeName != null)
                    Text(
                      storeName,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                ],
              ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: chatgubun == 'me'
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (chatgubun == 'other') const SizedBox(width: 40),
                Flexible(
                  child: Column(
                    crossAxisAlignment: chatgubun == 'me'
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: bubbleColor,
                          borderRadius: BorderRadius.all(radius),
                        ),
                        child: Text(
                          text,
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        date,
                        style: const TextStyle(fontSize: 11, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                if (chatgubun == 'me') const SizedBox(width: 8),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
