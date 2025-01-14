import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:witibju/screens/home/login/wit_user_loginStep2.dart';
import 'package:witibju/screens/home/login/wit_user_loginStep3.dart';

class WitUserLoginStep1 extends StatefulWidget {
  @override
  _WitUserLoginStep1State createState() => _WitUserLoginStep1State();
}

class _WitUserLoginStep1State extends State<WitUserLoginStep1> {
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
      _nicknameController.text = nickname ?? ''; // 닉네임 기본값 설정
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("사용자 등록"),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 1,
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
              children: List.generate(3, (index) {
                return Expanded(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 18.0,
                        backgroundColor: _currentStep >= index ? Colors.blue : Colors.grey,
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
                labelText: _nicknameController.text.isNotEmpty
                    ? _nicknameController.text
                    : "닉네임 입력",
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20.0),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9, // 버튼 너비 조정
                height: 50.0, // 버튼 높이 설정
                decoration: BoxDecoration(
                  color: Colors.blue, // 버튼 배경색 설정
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
                      MaterialPageRoute(builder: (context) => WitUserLoginStep2()),
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
