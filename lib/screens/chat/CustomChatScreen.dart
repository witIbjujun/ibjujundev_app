// 2025-03-27 (질문 버튼 + 입력창 자동입력)
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../../util/wit_api_ut.dart';
import '../../util/wit_code_ut.dart';
import '../board/wit_board_write_sc.dart';
import '../common/wit_calendarDialog.dart';
import '../home/widgets/wit_home_widgets.dart';
import '../home/wit_home_theme.dart';
import '../seller/wit_seller_profile_view_sc.dart';
import 'models/message_info.dart';

// 대화하기
class CustomChatScreen extends StatefulWidget {
  final String? reqNo;
  final String seq;
  final String? target; // ✅ final로 그대로 유지 (late 제거)

  CustomChatScreen(this.reqNo, this.seq, this.target,{super.key});

  @override
  State<CustomChatScreen> createState() => _CustomChatScreenState();
}

class _CustomChatScreenState extends State<CustomChatScreen> {
  late String? _target; // 내부 변수로 선언
  final List<Map<String, dynamic>> _chatMessages = [];
  final List<Map<String, dynamic>> _questionMessages = [];
  final List<Map<String, dynamic>> _chatUserMessages = [];

  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late String chatId = ''; // 이건 실제 상황에 맞게 바꿔줘
  String _currentText = '';
  String _selectedDate = ''; // ✅ 추가된 부분: 선택된 날짜 저장용
  final secureStorage = FlutterSecureStorage();
  final ScrollController _scrollController = ScrollController();

  // 2025-05-04: getChatInfo 결과를 상태로 저장하여 estimateCard에 사용

  String _reqName = '';  //신청자
  String _categoryNm = '';  // 카테고리 명
  String _categoryId = '';  // 카테고리  ID
  String _estimateAmount = ''; // 견적금액
  String _storeName = ''; // 업체명
  String _estimateDate = ''; // 최초 작업요청일
  String _estimateProcDate = ''; // 최종 작업요청일
  String _nextReqState = ''; //  다음상태
  String _reqBtenNm = ''; // 버튼명
  String _reqStepState = ''; // 버튼명
  String _sllrNo = ''; // 업체ID
  String _reqState = ''; // 상태


  String nextPage = ''; // anwCode 값에 따라서 후기등록(BOARD) , 완전종료(END)

  void _setMessageText(String text) {
    setState(() {
      _textController.text = text;
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  @override
  void initState() {
    super.initState();
    _target = widget.target; // ✅ 최초 값 복사
    //print('🧪 initState - reqNo: ${widget.reqNo}, seq: ${widget.seq}, target: ${widget.target}');
    _loadData();
    // 2025-05-04: 채팅정보 먼저 가져오고 → 그다음 채팅내용 조회
    getChatInfo().then((_) {
      getChatMessages();
    });

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

  Future<void> _loadData() async {
    await getChatInfo(); // ✅ 정보 로딩 대기
    await getChatMessages(); // ✅ 메시지 로딩 대기

    // 데이터를 로딩한 후에 화면 갱신
    setState(() {
      print('🔄 화면 갱신 - 견적서 정보 로딩 완료');
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
        String? msgCode, // 🔹 msgCode 추가
      }) async {
    const String restId = "saveChatMessage";

     String? clerkNo = await secureStorage.read(key: 'clerkNo');
    String? inputGubun = "user";
    //print("🧾 chatId: $chatId, clerkNo: $clerkNo  text =-==$text" ); // ✅ 여기서 출력

    if (chatId == null || clerkNo == null) {
     // print("❌ chatId 또는 clerkNo가 없습니다. 메시지 저장 중단");
      return;
    }
    final now = DateTime.now().toIso8601String();

   // print('✅ 메시지 저장 (anwCode: ${anwCode ?? 'null'}, gubun: ${gubun ?? 'null'}, messageId: ${messageId ?? 'null'})');


    if(_target =="sellerView"){

      inputGubun = "seller";
    }

 /*   print("🔍 [파라미터 출력]");
    print("chatId: $chatId");
    print("reqNo: ${widget.reqNo}");
    print("seq: ${widget.seq}");
    print("clerkNo: $clerkNo");
    print("msgCode: $msgCode");
    print("createdAt: $now");
    print("text: $text");
    print("systemGubun: ${gubun ?? "user"}");
    print("inputGubun: $inputGubun");
    print("messageId: $messageId");
    print("anwCode: $anwCode");
    print("type: text");*/

    /*다음페이지 진행*/
    nextPage = anwCode ?? '';

    print('✅ 메시지 저장 성공===' + (nextPage.isNotEmpty ? nextPage : '값이 없습니다.'));

    final param = jsonEncode({
      "chatId": chatId,
      "reqNo": widget.reqNo,
      "seq": widget.seq,
      "clerkNo": clerkNo,
      "createdAt": now,
      "msgCode": msgCode,
      "text": text,
      "systemGubun": gubun ?? "user", // default fallback
      "inputGubun": inputGubun,
      "messageId": messageId,
      "anwCode": anwCode,
      "type": "text",
      "metadata": {},
    });

    try {
      final response = await sendPostRequest(restId, param) ?? '';

      if (nextPage.isNotEmpty) {
        print('✅ 메시지 저장 성공===' + nextPage);
      } else {
        print('⚠️ nextPage 값이 없습니다.');
      }

      if (response > 0) {
        print('✅ 메시지 저장 성공===' + nextPage);
        if(nextPage == "BOARD"){
          print('✅ 업체후기 이동');
          String clerkNo = await secureStorage.read(key: 'clerkNo') ?? '';
          String aptNo = await secureStorage.read(key: 'mainAptNo') ?? '';

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BoardWrite(
                  bordNo: "",             // 게시판 번호 (필요한 경우 수정)
                  bordType: 'UH01',       // 게시판 타입
                  bordKey: '',            // 게시판 키 (필요한 경우 수정)
                  aptNo: aptNo,             // 아파트 번호
                  sllrNo: _sllrNo,           // 판매자 번호
                  reqNo: widget.reqNo ?? '',  // 요청 번호
                  ctgrId: _categoryId,            // 카테고리 ID
                  creUserId: clerkNo ?? ''  // 생성자 ID
              ),
            ),
          );

        }else if(nextPage == "END"){
          print('✅ 종료종료');
        }else{
          getChatMessages();
        }

      } else {
        print("❌ 메시지 저장 실패: $response");
      }
    } catch (e) {
      print("❌ 저장 중 예외 발생: $e");
    }
  }

  /**
   * 채팅메인 정보
   */

  Future<void> getChatInfo() async {
    const String restId = "getChatInfo";

    String? reqNo = widget.reqNo;
    String? seq = widget.seq;
    String? target = _target;
    //print('✅ getChatInfo 호출 - seq: $seq');

    final param = jsonEncode({
      "reqNo": reqNo,
      "seq": seq,
      "target": target,
    });

    try {
      final result = await sendPostRequest(restId, param);

      if (result != null && result is Map<String, dynamic>) {
        //print('🟢 getChatInfo 결과: $result');

        setState(() {
          _reqName = result['reqName']?.toString() ?? '';
          _categoryNm = result['categoryNm']?.toString() ?? '';
          _categoryId = result['categoryId']?.toString() ?? '';
          _estimateAmount = result['estimateAmount']?.toString() ?? '0';
          _storeName = result['storeName']?.toString() ?? '';
          _estimateDate = result['estimateDate']?.toString() ?? '';
          _estimateProcDate = result['estimateProcDate']?.toString() ?? '';
          _nextReqState = result['nextReqState']?.toString() ?? '';
          _reqBtenNm = result['reqBtenNm']?.toString() ?? '';
          _reqStepState = result['reqStepState']?.toString() ?? '';
          _sllrNo = result['sllrNo']?.toString() ?? '';
          _reqState = result['reqState']?.toString() ?? '';
        });
      }
    } catch (e) {
      print('❌ getChatInfo 오류: $e');
    }
  }

  /**
   * 채팅내용 조회
   */
  Future<void> getChatMessages() async {
    const String restId = "getChatList";

    String clerkNo = (await secureStorage.read(key: 'clerkNo'))!;
    String? reqNo = widget.reqNo;
    String? seq = widget.seq;
    String? target = _target;
    //print('✅ 메시지 조회 seq: $seq');


    final param = jsonEncode({
      "reqNo": reqNo,
      "seq": seq,
      "clerkNo": clerkNo,
      "target": target,
      "chatgubun": "user",
    });

    try {
      // ✅ 서버에서 받아온 메시지 그대로 출력
      final _chatList = await sendPostRequest(restId, param);
      final List<MessageInfo> parsedList = MessageInfo().parseMessageList(_chatList) ?? [];

      //print('🧾 파싱된 메시지 리스트:');
   /*   for (var msg in parsedList) {
        final json = msg.toJson();
        print('👉 ${json['text']} | msgCode: ${json['msgCode']} | keys: ${json.keys}');
      }*/

      // ✅ chatId 설정
      if (parsedList.isNotEmpty) {
        setState(() {
          chatId = parsedList.first.chatId ?? ''; // chatId 값 설정
        });
      }

      // ✅ 서버 순서대로 화면에 반영
      setState(() {
        _chatMessages.clear();
        _chatMessages.addAll(parsedList.map((msg) => msg.toJson()));

        _questionMessages.clear();
        _questionMessages.addAll(_chatMessages.where((msg) => msg['chatgubun'] == 'system'));

        _chatUserMessages.clear();
        _chatUserMessages.addAll(_chatMessages.where((msg) =>
        msg['chatgubun'] == 'me' || msg['chatgubun'] == 'other'));

        // print('🟢 질문 메시지 수: ${_questionMessages.length}');
        // print('🟢 유저/상대 메시지 수: ${_chatUserMessages.length}');
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
          // ✅ 상단에 고정된 견적 카드
          _estimateCardFixed(),
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
        ],
      ),
      bottomNavigationBar: _buildBottomInputBar(), // 2025-05-28 추가
    );
  }


  // 2025-05-28: reqState가 '70'이면 입력창 전체 숨김 처리
  Widget? _buildBottomInputBar() {
    if (_reqState == '70') return null;

    return Container(
      color: Colors.grey.shade100,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 28, color: Colors.black54),
            onPressed: () {
              _showImagePickerDialog(context);
            },
          ),
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
    );
  }

  // ✅ 2025-04-11: messageId 순회하면서 순차 처리
  // ✅ 2025-05-14: 시간 순서대로 메시지 그룹핑 및 출력
  List<Widget> _buildGroupedWidgets() {
    List<Widget> widgets = [];

    // ✅ messageId 로 그룹핑
    final Map<String, List<Map<String, dynamic>>> groupedMessages = {};

    for (var msg in _chatMessages) {
      final messageId = msg['messageId']?.toString() ?? 'unknown';
      if (!groupedMessages.containsKey(messageId)) {
        groupedMessages[messageId] = [];
      }
      groupedMessages[messageId]!.add(msg);
    }

    // ✅ 서버에서 이미 정렬된 상태로 내려오기 때문에 순서를 그대로 유지
    final sortedKeys = groupedMessages.keys.toList();

    // ✅ 시간 순서대로 출력
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
          nickName: msg['nickName'],
          userImage: msg['userImage'],
          storeImgPath: msg['storeImgPath'],
          type: msg['type'] ?? 'text',
        )));
      }

      widgets.add(const SizedBox(height: 16)); // 그룹 간 간격
    }

    return widgets;
  }

  /*상단 고정카드 */
  Widget _estimateCardFixed() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔹 업체명 + 시간 표시
          Row(
            children: [
              // 업체명 클릭 시 프로필로 이동
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SellerProfileView(
                        sllrNo: _sllrNo,
                        appbarYn: "Y",
                      ),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Icon(Icons.store, color: Colors.grey[700]),
                    const SizedBox(width: 6),
                    Text(
                      _storeName,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.access_time, color: Colors.grey[700]),
              const SizedBox(width: 6),
              Text(_estimateDate, style: const TextStyle(fontSize: 14)),
            ],
          ),
          const SizedBox(height: 5),
          /// 🔹 작업 단계 동그라미
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStepIndicator("1. 협의", _reqStepState == "10"),
              _buildStepIndicator("2. 작업중", _reqStepState == "20"),
              _buildStepIndicator("3. 작업완료", _reqStepState == "30"),
              _buildStepIndicator("4. 최종완료", _reqStepState == "40"),
            ],
          ),

          const SizedBox(height: 5),
          /// 🔹 단계 선 (Divider) 표시
          /*Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(3, (index) => Expanded(
              child: Divider(
                color: _reqStepState == "10" && index == 0
                    || _reqStepState == "20" && index <= 1
                    || _reqStepState == "30" && index <= 2
                    || _reqStepState == "40"
                    ? WitHomeTheme.wit_lightGreen
                    : Colors.grey[400],
                thickness: 2,
              ),
            )),
          ),*/

          if (_reqStepState == "20") ...[
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  // 🔸 작업 취소 버튼
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        bool isConfirmed = await DialogUtils.showIPhoneConfirmDialog(
                          context: context,
                          title: '작업 중지',
                          content: '작업을 중지하시겠습니까?',
                        );
                        if (isConfirmed) {
                          await updateProgressStatus("99");
                        }
                      },
                      child: Container(
                        height: 48,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Color(0xFFE0E0E0)),
                            right: BorderSide(color: Color(0xFFE0E0E0)),
                          ),
                        ),
                        child: const Text(
                          '작업취소',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.red, // ✅ 빨간색 글씨
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 🔸 작업 완료 버튼
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        bool isConfirmed = await DialogUtils.showIPhoneConfirmDialog(
                          context: context,
                          title: '작업 완료',
                          content: '작업을 완료하시겠습니까?',
                        );
                        if (isConfirmed) {
                          await updateProgressStatus("70");
                        }
                      },
                      child: Container(
                        height: 48,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Color(0xFFE0E0E0)),
                          ),
                        ),
                        child: const Text(
                          '작업완료',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue, // ✅ 파란색 글씨
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }


  // ✅ 단계를 표현하는 위젯
  Widget _buildStepIndicator(String title, bool isActive) {
    return Column(
      children: [
        CircleAvatar(
          radius: 10,
          backgroundColor: isActive ? WitHomeTheme.wit_lightGreen : Colors.grey[400],
          child: isActive
              ? const Icon(Icons.check, color: Colors.white, size: 10)
              : null,
        ),
        const SizedBox(height: 5),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isActive ? WitHomeTheme.wit_lightGreen : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionButtons(List<Map<String, dynamic>> questionsGroup) {
    final questions = questionsGroup.map((msg) {
      print("🧐 _buildQuestionButtons msg: $msg");
      return {
        'text': msg['text'],
        'anwCode': msg['anwCode'],
        'messageId': msg['messageId'], // null이면 그대로 null로 전달
        'msgCode': msg['msgCode'] , // 🔹 msgCode 추가
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
    final msgCode = q['msgCode'];  // 🔹 msgCode 추가
    final isCalendarButton = text.contains('CAL');
    final isActionButton = text.contains('BTN1');
    final replacedText = text.replaceAll('ValDate', _estimateDate);
    final cleanedText = text.replaceAll('CAL', '').replaceAll('BTN1', '').trim();

      print("🚀 _buildQuestionButton: text=$text, anwCode=$anwCode, messageId=$messageId, replacedText=$replacedText");

    return GestureDetector(
      onTap: () async {
        // print('🟡 버튼 클릭됨 → messageId: $messageId, msgCode: $msgCode');
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
              msgCode: msgCode, // 🔹 msgCode 추가 전달
            );
            _textController.clear();
            _currentText = '';
            _focusNode.unfocus();
          }
        } else if (isActionButton) { // 작업 진행하기
          _showProceedDialog(text,anwCode, msgCode,messageId: messageId);
        } else {
          _saveMessageToServer(
            replacedText, // ✅ 여기
            anwCode: anwCode,
            gubun: 'system',
            messageId: messageId,
            msgCode: msgCode, // 🔹 msgCode 추가 전달
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
            : Text(replacedText, style: const TextStyle(fontSize: 14, color: Colors.black87)),
      ),
    );
  }

  // 2025-05-14: iOS 스타일 다이얼로그로 수정
  void _showProceedDialog(String? text, anwCode,msgCode, {String? messageId}) {
    showDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text(
          '작업진행',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text('작업을 진행하시겠습니까?'),
        ),
        actions: [
          // 🔹 취소 버튼
          CupertinoDialogAction(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              '취소',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          // 🔹 확인 버튼
          CupertinoDialogAction(
            onPressed: () async {
              Navigator.pop(context);

              // ✅ 상태값 수정 함수 호출
              await updateProgressStatus("50");

              // ✅ 서버에 메시지 저장
              _saveMessageToServer(
                '작업을 진행합니다.',
                anwCode: anwCode,
                gubun: 'system',
                messageId: messageId,
                msgCode: msgCode,
              );

              _textController.clear();
              _currentText = '';
              _focusNode.unfocus();
            },
            child: const Text(
              '확인',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  /**
   * 진행상태 업데이트
   */
  Future<void> updateProgressStatus(String? reqState) async {
    const String restId = "updateProgressStatus";
    // ✅ "REBTN1"일 때만 진행하도록 조건 추가
      final param = jsonEncode({
        "reqNo": widget.reqNo,
        "seq": widget.seq,
        "reqState": reqState,
        "status": "IN_PROGRESS" // 상태값을 진행 중으로 업데이트
      });

      try {
        final response = await sendPostRequest(restId, param);
        if (response > 0) {
          await DialogUtils.showIPhoneAlertDialog(
            context: context,
            title: '처리완료',
            content: '성공적으로 완료되었습니다.',
            onConfirm: () {
              Navigator.pop(context); // 🔙 이전 화면으로 돌아감
            },
          );
          print("✅ 진행 상태 업데이트 완료");
        } else {
          print("❌ 진행 상태 업데이트 실패: $response");
        }
      } catch (e) {
        print("❌ 진행 상태 업데이트 중 오류 발생: $e");
      }
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
   * 견적서
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
          Text('${_reqName} 고객님 안녕하세요. 요청서에 따른 예상금액입니다.'),
          const SizedBox(height: 16),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('서비스', style: TextStyle(color: Colors.grey)),
              Text(_categoryNm),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('견적금액', style: TextStyle(color: Colors.grey)),
              Text('${_estimateAmount} 원', style: const TextStyle(fontWeight: FontWeight.bold)),
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
      if (pickedFile == null) {
        print("❌ 이미지가 선택되지 않았습니다.");
        return;
      }

      print('✅ 이미지 선택됨: ${pickedFile.path}');

      // 서버로 이미지 업로드
      final fileInfo = await sendFilePostRequest("fileUpload", [File(pickedFile.path)]);
      if (fileInfo == "FAIL") {
        print("❌ 이미지 업로드 실패");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("이미지 업로드 실패")),
        );
        return;
      }

      String? clerkNo = await secureStorage.read(key: 'clerkNo');

     /* if (widget.target == "sellerView") {
        clerkNo = "17";
      }*/

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
  // 2025-05-04: chatgubun이 me인 경우 프로필 이미지 숨김, profileImage 없을 시 기본 이미지로 대체
  // 2025-05-04: chatgubun == 'me'일 경우 date 오른쪽, 'other'일 경우 왼쪽에 표시
  // 2025-05-23: target이 userView일 경우 storeImgPath 또는 userImage 사용하고, storeName / nickName 처리 추가
  Widget _chatBubble({
    required String text,
    required String chatgubun,
    required String date,
    String? profileImage,
    String? storeName,
    String? nickName,
    String? userImage,
    String? storeImgPath,
    String type = 'text',

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



    // 🔸 프로필 이미지 선택 (target에 따라 storeImgPath 또는 userImage)
    final String targetValue = _target ?? '';

    final String? resolvedProfileImage =
    (targetValue == 'sellerView')
        ? (userImage?.isNotEmpty ?? false)
        ? userImage
        : null
        : (storeImgPath?.isNotEmpty ?? false)
        ? storeImgPath
        : null;


    // 🔸 사용자 이름 선택 (target에 따라 storeName 또는 nickName)
    final String? displayName =
    (_target == 'userView') ? storeName : (nickName ?? storeName);

   /* print("🔍 [파라미터 출력]");
    print("widget.target: $_target");
    print("reqNo: ${widget.reqNo}");
    print("seq: ${widget.seq}");
    print("storeImgPath: $storeImgPath");
    print("userImage: $userImage");
    print("nickName: $nickName");
    print("storeName: $storeName");
    print("displayName: $displayName");
    print("resolvedProfileImage: $resolvedProfileImage");*/

    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: chatgubun == 'me'
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (chatgubun == 'other')
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: proFlieImage.getImageProvider(resolvedProfileImage ?? ""),
                  ),
                  const SizedBox(width: 6),
                  if (displayName != null)
                    Text(
                      displayName,
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
                            apiUrl + text,
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
                      Row(
                        mainAxisAlignment: chatgubun == 'me'
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          if (chatgubun == 'me') const SizedBox(width: 4),
                          Text(
                            date,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.black54,
                            ),
                          ),
                        ],
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
