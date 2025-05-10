import 'package:flutter/material.dart';
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
    "만 14세 이상입니다.(필수)": false,
    "서비스 이용약관 동의(필수)": false,
    "전자금융거래 기본약관 동의(필수)": false,
    "개인정보 수집 및 이용 동의(필수)": false,
    "위치정보 이용동의(필수)": false,
    "개인정보 제3자 제공 동의(필수)": false,
    "SMS 이벤트등 마케팅 수신 동의(선택)": false,
    "이메일 이벤트등 마케팅 수신 동의(선택)": false,
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
      backgroundColor: Colors.white, // ✅ 기본 배경을 흰색으로 설정
      appBar: AppBar(
        title: const Text(
          "약관에 동의해주세요.",
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
      body: Column(
        children: [
          const SizedBox(height: 20),

          // ✅ "아래 약관에 모두 동의합니다." 영역
          Container(
            color: Colors.black, // ✅ 배경을 검정색으로 설정
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    "아래 약관에 모두 동의합니다.",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                Checkbox(
                  value: _allChecked,
                  onChanged: _toggleAll,
                  activeColor: WitHomeTheme.wit_lightGreen, // ✅ 체크 시 녹색
                  checkColor: Colors.white, // ✅ 체크 표시 흰색
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // ✅ 간격 줄이기
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // ✅ 약관 목록
          Expanded(
            child: ListView(
              children: _agreementList.keys.map((key) {
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                  title: Text(
                    key,
                    style: WitHomeTheme.title.copyWith(fontSize: 16), // ✅ 폰트 스타일 적용
                  ),
                  trailing: SizedBox(
                    width: 40, // ✅ 공간을 제한함으로써 오류 해결
                    child: Checkbox(
                      value: _agreementList[key],
                      onChanged: (value) {
                        _toggleSingle(key, value);
                      },
                      activeColor: WitHomeTheme.wit_lightGreen, // ✅ 체크 시 녹색
                      checkColor: Colors.white, // ✅ 체크 표시 흰색
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // ✅ 간격 줄이기
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // ✅ 다음 버튼
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor:
                _isAllRequiredChecked() ? WitHomeTheme.wit_lightGreen : Colors.grey[400],
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
                "다음",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
