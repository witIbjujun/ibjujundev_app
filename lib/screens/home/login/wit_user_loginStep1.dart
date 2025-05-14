import 'package:flutter/material.dart';
import 'package:witibju/screens/home/login/wit_user_agreement1.dart';
import 'package:witibju/screens/home/login/wit_user_agreement2.dart';
import 'package:witibju/screens/home/login/wit_user_loginStep2.dart';
import '../wit_home_theme.dart';

class WitUserLoginStep1 extends StatefulWidget {
  final String nickName; // 🔹 전달받은 닉네임

  const WitUserLoginStep1(this.nickName, {Key? key}) : super(key: key);

  @override
  _WitUserLoginStep1State createState() => _WitUserLoginStep1State();
}

class _WitUserLoginStep1State extends State<WitUserLoginStep1> {
  bool _allChecked = false;
  final Map<String, bool> _agreementList = {
    "(필수) 입주전 서비스 이용약관": false,
    "(필수) 개인정보 수집 및 이용 동의": false,
  };

  /// 🔹 모두 동의 체크 시 모든 항목 업데이트
  void _toggleAll(bool? value) {
    setState(() {
      _allChecked = value ?? false;
      _agreementList.updateAll((key, value) => _allChecked);
    });
  }

  /// 🔹 개별 체크 시 상태 업데이트
  void _toggleSingle(String key, bool? value) {
    setState(() {
      _agreementList[key] = value ?? false;
      _allChecked = _agreementList.values.every((checked) => checked);
    });
  }

  /// 🔹 모든 필수 항목이 체크되었는지 확인
  bool _isAllRequiredChecked() {
    return _agreementList.entries
        .where((entry) => entry.key.contains('(필수)'))
        .every((entry) => entry.value == true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "약관에 동의해주세요.",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 18,
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
      body: Column(
        children: [
          const SizedBox(height: 20),

          // 🔹 안내 문구
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: const Text(
              "서비스 가입을 위해 약관에 동의해 주세요",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ✅ "전체동의" 영역
          ListTile(
            leading: Checkbox(
              value: _allChecked,
              onChanged: _toggleAll,
              activeColor: WitHomeTheme.wit_lightGreen,
            ),
            title: const Text(
              "전체동의",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Divider(color: Colors.grey.shade300),

          // ✅ 서브 약관 목록
          Expanded(
            child: ListView(
              children: _agreementList.keys.map((key) {
                return InkWell(
                  onTap: () {
                    if (key.contains("입주전 서비스 이용약관")) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Agreement1()),
                      );
                    } else if (key.contains("개인정보 수집 및 이용 동의")) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Agreement2()),
                      );
                    }
                  },
                  child: ListTile(
                    leading: Checkbox(
                      value: _agreementList[key],
                      onChanged: (value) {
                        _toggleSingle(key, value);
                      },
                      activeColor: WitHomeTheme.wit_lightGreen,
                    ),
                    title: Text(
                      key,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    trailing: const Text(
                      "보기",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blueAccent,
                        decoration: TextDecoration.underline, // 🔹 언더라인 추가
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // ✅ 확인 버튼
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor:
                _isAllRequiredChecked() ? WitHomeTheme.wit_lightGreen : Colors.grey[300],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: _isAllRequiredChecked()
                  ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WitUserLoginStep2(widget.nickName)),
                );
              }
                  : null,
              child: const Text(
                "확인",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
