// 2025-03-27 (질문 버튼 + 입력창 자동입력)
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../../util/wit_api_ut.dart';
import '../../util/wit_code_ut.dart';
import '../common/wit_calendarDialog.dart';
import '../home/wit_home_theme.dart';
import 'models/message_info.dart';

// 대화하기
class CustomChatScreen extends StatefulWidget {
  final String? reqNo;
  final String seq;
  final String? target;

  const CustomChatScreen(this.reqNo, this.seq, this.target,{super.key});

  @override
  State<CustomChatScreen> createState() => _CustomChatScreenState();
}

class _CustomChatScreenState extends State<CustomChatScreen> {

  final List<Map<String, dynamic>> _chatMessages = [];
  final List<Map<String, dynamic>> _questionMessages = [];
  final List<Map<String, dynamic>> _chatUserMessages = [];

  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final String chatId = ''; // 이건 실제 상황에 맞게 바꿔줘
  String _currentText = '';
  String _selectedDate = ''; // ✅ 추가된 부분: 선택된 날짜 저장용
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
    //채팅내용 조회
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
  // 2025-04-30: gubun이 null이면 'user', messageId는 명확히 표시
  Future<void> _saveMessageToServer(
      String text, {
        String? anwCode,
        String? gubun,
        String? messageId,
      }) async {
    const String restId = "saveChatMessage";
    final String? chatId = _chatMessages.isNotEmpty ? _chatMessages.first['chatId']?.toString() : null;
    final String? clerkNo = _chatMessages.isNotEmpty ? _chatMessages.first['clerkNo']?.toString() : null;

    if (chatId == null || clerkNo == null) {
      print("❌ chatId 또는 clerkNo가 없습니다. 메시지 저장 중단");
      return;
    }
    final now = DateTime.now().toIso8601String();

    print('✅ 메시지 저장 (anwCode: ${anwCode ?? 'null'}, gubun: ${gubun ?? 'null'}, messageId: ${messageId ?? 'null'})');

    final param = jsonEncode({
      "chatId": chatId,
      "clerkNo": clerkNo,
      "createdAt": now,
      "text": text,
      "systemGubun": gubun ?? "user", // default fallback
      "chatgubun": "user",
      "messageId": messageId,
      "anwCode": anwCode,
      "type": "text",
      "metadata": {},
    });

    try {
      final response = await sendPostRequest(restId, param) ?? '';
      if (response > 0) {
        print('✅ 메시지 저장 성공');
        getChatMessages();
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
  // ✅ 2025-04-10: 채팅내용 조회 함수 전체
  Future<void> getChatMessages() async {
    const String restId = "getChatList";
    String? reqNo = widget.reqNo;
    String? seq = widget.seq;
    String? target = widget.target;
    print('✅ 메시지 조회 reqNo: $reqNo');

    final param = jsonEncode({
      "reqNo": reqNo,
      "target": target,
      "chatgubun": "user",
    });

    try {
      final _chatList = await sendPostRequest(restId, param);
      final List<MessageInfo> parsedList = MessageInfo().parseMessageList(_chatList) ?? [];

      setState(() {
        // ✅ 전체 메시지 저장
        _chatMessages.clear();
        _chatMessages.addAll(parsedList.map((msg) => msg.toJson()));

        // ✅ 질문 메시지와 유저 메시지 분리 저장
        _questionMessages.clear();
        _questionMessages.addAll(_chatMessages.where((msg) => msg['chatgubun'] == 'system'));

        _chatUserMessages.clear();
        _chatUserMessages.addAll(_chatMessages.where((msg) =>
        msg['chatgubun'] == 'me' || msg['chatgubun'] == 'other'));

        print('🟢 질문 메시지 수: ${_questionMessages.length}');
        print('🟢 유저/상대 메시지 수: ${_chatUserMessages.length}');
      });

    } catch (e) {
      print('❌ 채팅 목록 조회 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFD3D3D3),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          '대화화기',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'NotoSansKR',
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _estimateCard(),
                const SizedBox(height: 12),
                ..._buildGroupedWidgets(), // ✅ 이거 하나로 충분
              ],
            ),
          ),
          const Divider(height: 1),
          Container(
            color: Colors.grey.shade100,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: [
                // ✅ + 버튼
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, size: 28, color: Colors.black54),
                  onPressed: () {
                    _showImagePickerDialog(context);
                  },
                ),

                // ✅ 메시지 입력창
                Expanded(
                  child: TextField(
                    focusNode: _focusNode,
                    controller: _textController,
                    onChanged: (val) {
                      setState(() {
                        _currentText = val;
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: '메시지를 입력하세요',
                      border: InputBorder.none,
                    ),
                  ),
                ),

                // ✅ 전송 버튼
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    final message = _textController.text.trim();
                    if (message.isNotEmpty) {
                      _saveMessageToServer(message);
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

  // ✅ 2025-04-11: messageId 순회하면서 순차 처리
  List<Widget> _buildGroupedWidgets() {
  List<Widget> widgets = [];

    // messageId 로 그룹핑
    final Map<String, List<Map<String, dynamic>>> groupedMessages = {};

    for (var msg in _chatMessages) {
      final messageId = msg['messageId']?.toString() ?? 'unknown';
      if (!groupedMessages.containsKey(messageId)) {
        groupedMessages[messageId] = [];
      }
      groupedMessages[messageId]!.add(msg);
    }

    // messageId 순서대로 정렬
    final sortedKeys = groupedMessages.keys.toList()..sort();

    for (var messageId in sortedKeys) {
      final group = groupedMessages[messageId]!;

      print('🔍 Processing messageId: $messageId');

      // ✅ group 내부에서 먼저 system 메시지 출력
      final systemMessages = group.where((msg) => msg['chatgubun'] == 'system').toList();
      if (systemMessages.isNotEmpty) {
        widgets.add(_buildQuestionButtons(systemMessages));
      }

      // ✅ 다음으로 me / other 메시지 출력
      final userMessages = group.where((msg) => msg['chatgubun'] == 'me' || msg['chatgubun'] == 'other').toList();
      if (userMessages.isNotEmpty) {
        widgets.addAll(userMessages.map((msg) => _chatBubble(
          text: msg['text'],
          chatgubun: msg['chatgubun'],
          date: msg['date'] ?? '',
          storeName: msg['storeName'],
          profileImage: msg['profileImage'],
          type: msg['type'] ?? 'text', // ✅ type 전달
        )));
      }

      widgets.add(const SizedBox(height: 16)); // 그룹 간 간격
    }

    return widgets;
  }


  // 2025-04-16: CAL은 달력 버튼, BTN1은 진행하기 버튼으로 처리
  // 2025-04-30: messageId가 비어 있는 문제 해결 - 빈 문자열이 아닌 null로 유지
  Widget _buildQuestionButtons(List<Map<String, dynamic>> questionsGroup) {
    final questions = questionsGroup.map((msg) {
      return {
        'text': msg['text'],
        'anwCode': msg['anwCode'],
        'messageId': msg['messageId'], // null이면 그대로 null로 전달
      };
    }).toList();

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: questions.map((q) => _buildQuestionButton(q)).toList(),
        ),
      ),
    );
  }


  // 2025-04-30: messageId 전달 안되던 문제 수정 - Map<String, dynamic> 사용 및 로그 확인 추가
  // 2025-04-30: CAL, BTN1 버튼 중 BTN1(진행하기)에 견적 요청 스타일 적용
  Widget _buildQuestionButton(Map<String, dynamic> q) {
    final text = q['text'] ?? '';
    final anwCode = q['anwCode'];
    final messageId = q['messageId'];
    final isCalendarButton = text.contains('CAL');
    final isActionButton = text.contains('BTN1');
    final cleanedText = text.replaceAll('CAL', '').replaceAll('BTN1', '').trim();

    return GestureDetector(
      onTap: () async {
        print('🟡 버튼 클릭됨 → messageId: $messageId');

        if (isCalendarButton) {
          if (_selectedDate.isEmpty) {
            await _selectDate(
              context,
              anwCode: anwCode,
              cleanedText: cleanedText,
              messageId: messageId,
            );
          } else {
            final messageToSend = '$_selectedDate $cleanedText';
            _saveMessageToServer(
              messageToSend,
              anwCode: anwCode,
              gubun: 'system',
              messageId: messageId,
            );
            _textController.clear();
            _currentText = '';
            _focusNode.unfocus();
          }
        } else if (isActionButton) {
          _showProceedDialog(anwCode, messageId: messageId);
        } else {
          _saveMessageToServer(
            text,
            anwCode: anwCode,
            gubun: 'system',
            messageId: messageId,
          );
          _textController.clear();
          _currentText = '';
          _focusNode.unfocus();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: isActionButton ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isActionButton ? Colors.transparent : const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: isCalendarButton
            ? Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_today, size: 20, color: Colors.black87),
            const SizedBox(width: 6),
            Text(
              _selectedDate.isNotEmpty ? _selectedDate : '날짜 선택',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              cleanedText,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ],
        )
            : isActionButton
            ? Container(
          width: 160.0,
          height: 40.0,
          decoration: BoxDecoration(
            color: WitHomeTheme.wit_lightGreen,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: const Center(
            child: Text(
              '작업 진행하기',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        )
            : Text(text, style: const TextStyle(fontSize: 14, color: Colors.black87)),
      ),
    );
  }


  // 2025-04-16: BTN1 버튼 클릭 시 확인 다이얼로그 후 서버 전송
  void _showProceedDialog(String? anwCode, {String? messageId}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('진행 요청'),
        content: const Text('정말 작업을 진행하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _saveMessageToServer(
                '작업을 진행합니다.',
                anwCode: anwCode,
                gubun: 'system',      // 진행하기도 system으로 보내는거 맞지?
                messageId: messageId, // 여기 같이 넘겨줌
              );
              _textController.clear();
              _currentText = '';
              _focusNode.unfocus();
            },
            child: Container(
              width: double.infinity,
              height: 50.0,
              decoration: BoxDecoration(
                color: WitHomeTheme.wit_lightGreen,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Center(
                child: Text(
                  '작업 진행하기',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /**
   * 달력
   */
  // 2025-04-30: messageId를 _selectDate로 전달받아 서버 저장 시 함께 전송
  Future<void> _selectDate(
      BuildContext context, {
        String? anwCode,
        String? cleanedText,
        String? messageId, // ✅ 추가
      }) async {
    DateTime? selectedDate = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) => CustomCalendarBottomSheet(title: "작업요청일"),
    );

    if (selectedDate != null) {
      setState(() {
        _selectedDate =
        "${selectedDate.year}.${selectedDate.month.toString().padLeft(2, '0')}.${selectedDate.day.toString().padLeft(2, '0')}";
      });

      // ✅ 선택한 날짜 저장 후 서버 전송 시 messageId 포함
      if (anwCode != null && cleanedText != null) {
        final messageToSend = '$_selectedDate $cleanedText';
        print('📩 달력 선택 완료 후 전송 → messageId: $messageId');
        _saveMessageToServer(
          messageToSend,
          anwCode: anwCode,
          gubun: 'system',
          messageId: messageId, // ✅ 넘겨줌
        );
        _textController.clear();
        _currentText = '';
        _focusNode.unfocus();
      }
    }
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

  // 2025-04-30: + 버튼 클릭 시 이미지 선택 옵션 보여주는 다이얼로그
  void _showImagePickerDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('사진 촬영'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('갤러리에서 선택'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // 2025-05-01: BoardWrite 방식처럼 간단하게 변경 – 권한은 ImagePicker에 맡김
  // 2025-05-01: 이미지 선택 → 서버 업로드 → 이미지 메시지 전송까지 처리
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();

    try {
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile == null) return;

      print('✅ 이미지 선택됨: ${pickedFile.path}');

      // 서버로 이미지 업로드
      final fileInfo = await sendFilePostRequest("fileUpload", [File(pickedFile.path)]);
      if (fileInfo == "FAIL") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("이미지 업로드 실패")),
        );
        return;
      }

      final String? chatId = _chatMessages.isNotEmpty ? _chatMessages.first['chatId']?.toString() : null;
      final String? clerkNo = _chatMessages.isNotEmpty ? _chatMessages.first['clerkNo']?.toString() : null;

      if (chatId == null || clerkNo == null) {
        print("❌ chatId 또는 clerkNo가 없습니다. 메시지 저장 중단");
        return;
      }

      final param = jsonEncode({
        "chatId": chatId,
        "clerkNo": clerkNo,
        "createdAt": DateTime.now().toIso8601String(),
        "text": "[이미지]",  // 텍스트는 간단한 표시
        "systemGubun": "user",
        "chatgubun": "user",
        "type": "image",
        "fileInfo": fileInfo
      });

      final response = await sendPostRequest("saveChatMessage", param);
      if (response > 0) {
        getChatMessages(); // 채팅 새로고침
      } else {
        print("❌ 이미지 메시지 저장 실패: $response");
      }
    } catch (e) {
      print('❌ 이미지 처리 중 오류: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이미지를 전송할 수 없습니다.')),
      );
    }
  }

  /**
   * 채팅 글자
   */
  // 2025-03-29: isMe → messageType (me, system, other)
  // 2025-05-01: 이미지 메시지(type == image)일 경우 네트워크 이미지로 출력
  Widget _chatBubble({
    required String text,
    required String chatgubun, // me, system, other
    required String date,
    String? profileImage,
    String? storeName,
    String type = 'text',        // ✅ type 추가
  }) {
    final radius = Radius.circular(18);

    final Color bubbleColor = switch (chatgubun) {
      'me' => const Color(0xFFFFFF66),
      'system' => Colors.grey.shade400,
      _ => const Color(0xFFBFD4E4),
    };

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
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: bubbleColor,
                          borderRadius: BorderRadius.all(radius),
                        ),
                        child: type == 'image'
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            apiUrl + text, // ✅ 서버 이미지 URL 조합
                            width: 200,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Text('❌ 이미지 로딩 실패');
                            },
                          ),
                        )
                            : Text(
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
