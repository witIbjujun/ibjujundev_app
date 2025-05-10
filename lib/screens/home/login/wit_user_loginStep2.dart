import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:witibju/screens/home/login/wit_user_loginStep2.dart';
import 'package:witibju/screens/home/login/wit_user_loginStep3.dart';
import '../wit_home_theme.dart';

class WitUserLoginStep2 extends StatefulWidget {
  final String nickName; // 🔹 전달받은 닉네임

  const WitUserLoginStep2(this.nickName, {Key? key}) : super(key: key);

  @override
  _WitUserLoginStep2State createState() => _WitUserLoginStep2State();
}

class _WitUserLoginStep2State extends State<WitUserLoginStep2> {
  final TextEditingController _nicknameController = TextEditingController(); // 닉네임 입력 컨트롤러
  final FlutterSecureStorage secureStorage = FlutterSecureStorage(); // SecureStorage 인스턴스
  int _currentStep = 0; // 현재 스텝 인덱스

  @override
  void initState() {
    super.initState();
    _loadNickname(); // 저장된 닉네임 로드
  }

  Future<void> _loadNickname() async {
    String? nickname = await secureStorage.read(key: 'nickName');
    print("MY 11111111111: $nickname");
    setState(() {
      _nicknameController.text = widget.nickName.isNotEmpty ? widget.nickName : (nickname ?? '');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "사용자 등록",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white, // ✅ 글씨 색상 흰색으로 설정
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        color: Colors.white, // 배경색 설정
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Custom Horizontal Stepper
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(2, (index) {
                return Expanded(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 18.0,
                        backgroundColor: _currentStep >= index ? WitHomeTheme.wit_lightGreen : Colors.grey,
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 8.0),
                    ],
                  ),
                );
              }),
            ),
            const Divider(height: 32.0),
            const Text(
              "입주전에서 사용 할 닉네임을 입력해주세요.",
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _nicknameController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                focusedBorder: OutlineInputBorder( // 2025-04-26: 포커스 테두리 색 지정
                  borderSide: BorderSide(
                    color: WitHomeTheme.wit_lightGreen, // ✅ 원하는 색으로 변경 (예: 초록색)
                    width: 2.0,
                  ),
                ),
                enabledBorder: OutlineInputBorder( // 2025-04-26: 포커스 안됐을 때 테두리 색도 지정
                  borderSide: BorderSide(
                    color: Colors.grey, // ✅ 평소에는 회색
                    width: 1.0,
                  ),
                ),
              ),

            ),
            const SizedBox(height: 20.0),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9, // 버튼 너비 조정
                height: 50.0, // 버튼 높이 설정
                decoration: BoxDecoration(
                  color: WitHomeTheme.wit_lightGreen, // 버튼 배경색 설정
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: ElevatedButton(
                  onPressed: () async {
                    final nickname = _nicknameController.text.trim();
                    if (nickname.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('닉네임을 입력해주세요.')),
                      );
                      return;
                    }
                    // 닉네임 저장
                    await secureStorage.write(key: 'nickName', value: nickname);
                    print("닉네임 저장됨: $nickname");

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('닉네임 "$nickname"이 저장되었습니다.')),
                    );

                    // 다음 단계로 이동
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => WitUserLoginStep3()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent, // 버튼 자체는 투명
                    shadowColor: Colors.transparent,
                  ),
                  child: const Text(
                    "저장",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
