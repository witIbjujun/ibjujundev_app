import 'package:flutter/material.dart';

class Agreement2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "개인정보 수집 및 이용 동의서",
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
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
        color: Colors.white,  // 🔹 백그라운드 색상 흰색
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              // 🔹 제목
              Text(
                "제1조 (목적)",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "[입주전](이하 “회사”)는 「개인정보 보호법」 및 관련 법령에 따라 회원님의 개인정보를 안전하게 보호하며, "
                    "아래와 같이 개인정보를 수집·이용하고자 합니다. 내용을 자세히 읽으신 후 동의 여부를 결정해 주세요.",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),

              Text(
                "제2조 (수집하는 개인정보 항목 및 목적)",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "회사는 회원가입 시 다음과 같은 개인정보를 수집합니다:\n"
                    "- SNS 키값 (회원 식별을 위한 고유 값)\n"
                    "- 이름, 휴대폰 번호, 이메일 주소\n"
                    "- 닉네임 (서비스 내 사용자 식별 및 커뮤니케이션 목적)\n"
                    "※ 서비스 이용 과정에서 생성되는 정보: 접속 IP, 쿠키, 서비스 이용 기록, 기기정보 등",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),

              Text(
                "제3조 (개인정보의 보관 및 삭제)",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "1. 회원 탈퇴 시 또는 수집·이용 목적 달성 시까지 보관 후 파기\n"
                    "   단, 다음의 경우 관련 법령에 따라 일정 기간 보관\n\n"
                    "   - 전자상거래 등에서의 소비자 보호에 관한 법률\n"
                    "     . 계약 또는 청약철회 등에 관한 기록: 5년\n"
                    "     . 대금결제 및 재화 등의 공급에 관한 기록: 5년\n"
                    "     . 소비자 불만 또는 분쟁처리에 관한 기록: 3년\n"
                    "   - 통신비밀보호법\n"
                    "     . 로그인 기록(IP 등): 3개월\n\n"
                    "2. 보관된 개인정보는 다음과 같은 경우에만 사용됩니다:\n"
                    "   - 법적 분쟁 발생 시 증빙 자료 제공\n"
                    "   - 서비스 재가입 시 본인 확인\n\n"
                    "3. 보관 기간이 종료된 후, 개인정보는 안전한 방법으로 삭제됩니다.",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),

              Text(
                "제4조 (개인정보 보호 조치)",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "회사는 개인정보 보호를 위해 다음과 같은 보안 조치를 적용합니다:\n"
                    "- 데이터 암호화 및 접근 제한\n"
                    "- 내부 관리 절차 강화\n"
                    "- 개인정보 유출 방지를 위한 기술적 보호 조치\n\n"
                    "회원은 개인정보 보호 관련 문의를 할 수 있으며, 이에 대한 상세한 내용은 에서 확인할 수 있습니다.",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),

              Text(
                "제5조 (개인정보의 제3자 제공 및 위탁)",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "1. 회사는 회원의 개인정보를 원칙적으로 외부에 제공하지 않습니다.\n"
                    "   단, 법적 요구가 있는 경우 또는 회원의 동의가 있는 경우에 한하여 제공될 수 있습니다.",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),

              Text(
                "제6조 (개인정보처리방침 변경 및 공지)",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "1. 회사는 필요에 따라 본 개인정보처리방침을 변경할 수 있으며, 변경된 내용은 회원에게 사전 공지됩니다.\n"
                    "2. 변경된 개인정보처리방침은 공지 후 일정 기간이 지나면 자동으로 적용됩니다.",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),

              Text(
                "■ 개인정보 보호 책임자",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "성명: 이재명\n"
                    "직책: 개인정보 보호 책임자\n"
                    "이메일: jaemeong3131@gmail.com",
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
