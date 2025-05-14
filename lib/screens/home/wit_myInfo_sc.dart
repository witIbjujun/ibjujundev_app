import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:witibju/screens/home/wit_home_theme.dart';

import '../../util/wit_api_ut.dart';

class MyInfo extends StatefulWidget {
  const MyInfo({super.key});

  @override
  _MyInfoState createState() => _MyInfoState();
}

class _MyInfoState extends State<MyInfo> {
  // 🔐 SecureStorage 인스턴스 생성
  final _storage = const FlutterSecureStorage();
  final TextEditingController _controller = TextEditingController();

  // 🔎 불러올 변수
  String _nickName = "";
  String _aptName = "";
  String _email = "";

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  // 🔹 SecureStorage에서 정보 읽어오기
  Future<void> _loadUserInfo() async {
    try {
      String? nickName = await _storage.read(key: 'nickName');
      String? aptName = await _storage.read(key: 'mainAptNm');
      String? email = await _storage.read(key: 'email');

      setState(() {
        _nickName = nickName ?? '닉네임이 설정되지 않았습니다.';
        _aptName = aptName ?? '아파트명이 설정되지 않았습니다.';
        _email = email ?? '이메일이 설정되지 않았습니다.';
        _controller.text = _nickName; // ✅ TextEditingController에 닉네임 세팅
      });
    } catch (e) {
      print('정보 로딩 중 오류 발생: $e');
    }
  }

  // 🔄 닉네임 업데이트 함수
  Future<void> updateMyInfo() async {
    String restId = "updateMyInfo";
    final param = jsonEncode({
      "clerkNo": await _storage.read(key: 'clerkNo'),
      "nickName": _controller.text   // ✅ 수정된 닉네임 값을 보냄
    });

    try {
      final response = await sendPostRequest(restId, param);
      if (response != null) {
        await _storage.write(key: 'nickName', value: _controller.text);

        // 저장 완료 후 메시지를 보여줌
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('닉네임이 저장되었습니다.'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        print("MY 닉네임 저장 실패: ${response['message']}");
      }
    } catch (e) {
      print('요청 상태 업데이트 중 오류 발생: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          '내정보',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'NotoSansKR',
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 닉네임 + 변경 버튼
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _controller,
                      decoration: InputDecoration(
                        labelText: '닉네임',
                        labelStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'NotoSansKR',

                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey.shade400,
                            width: 1.0,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey.shade400,
                            width: 2.0,
                          ),
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 16.0,
                        color: Colors.black,
                      ),
                    ),
                  ),
                 // SizedBox(width: 10),
                  OutlinedButton(
                    onPressed: () {
                      updateMyInfo();
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade400, width: 1), // 🔹 회색 테두리
                      backgroundColor: WitHomeTheme.wit_lightGreen,                   // 🔹 배경색 지정
                      minimumSize: Size(50, 36), // 🔹 크기 설정
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8), // 🔹 모서리 둥글게
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: Text(
                      '변경',
                      style: TextStyle(
                        color: Colors.white, // 🔹 글씨 색상
                        fontSize: 14.0,
                        fontWeight: FontWeight.normal, // 🔹 두께를 얇게
                      ),
                    ),
                  ),
                ],
              ),
            ),
           // Divider(height: 1, color: Colors.grey.shade400),

            // 🔹 아파트명
            SizedBox(height: 16),
            Text(
              '아파트명',
              style: TextStyle(
                color: Colors.black,
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'NotoSansKR',
              ),
            ),
            SizedBox(height: 5),
            Text(
              _aptName,
              style: TextStyle(fontSize: 16),
            ),
            Divider(height: 1, color: Colors.grey.shade400),

            // 🔹 이메일주소
            SizedBox(height: 25),
            Text(
              '이메일',
              style: TextStyle(
                color: Colors.black,
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'NotoSansKR',
              ),
            ),
            SizedBox(height: 5),
            Text(
              _email,
              style: TextStyle(fontSize: 14),
            ),
            Divider(height: 1, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
