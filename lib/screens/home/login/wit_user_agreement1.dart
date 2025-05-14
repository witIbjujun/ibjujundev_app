import 'package:flutter/material.dart';

class Agreement1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "이용약관",
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
                "이 약관은 [입주전](이하 “회사”)이 제공하는 서비스의 이용과 관련하여 회사와 회원 간의 권리, 의무 및 책임사항, 기타 필요한 사항을 규정함을 목적으로 합니다.",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),

              // 🔹 제목
              Text(
                "제2조 (용어의 정의)",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "“서비스”란 회사가 제공하는 [앱의 주요 기능 – 예: 인테리어 견적 요청, 시공업체 매칭 등]을 말합니다.\n"
                    "“회원”이란 본 약관에 동의하고 회사가 제공하는 서비스를 이용하는 자를 말합니다.\n"
                    "“이용계약”이란 본 약관을 포함하여 회사와 회원 간에 체결되는 서비스 이용계약을 말합니다.",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),

              Text(
                "제3조 (약관의 효력 및 변경)",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "본 약관은 앱 내에 게시함으로써 효력을 발생합니다.\n"
                    "회사는 관련 법령을 위반하지 않는 범위에서 본 약관을 변경할 수 있으며, 변경 시 회원에게 사전 고지합니다.\n"
                    "변경된 약관에 동의하지 않을 경우 회원은 서비스 이용을 중단하고 탈퇴할 수 있습니다.",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),

              Text(
                "제4조 (회원가입 및 자격)",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "회원가입은 본 약관에 동의하고, 회사가 정한 가입양식에 따라 신청함으로써 이루어집니다.\n"
                    "회사는 신청자의 정보를 확인 후 서비스 이용을 승인할 수 있습니다.\n"
                    "다음 각 호에 해당하는 경우 가입을 거부하거나 이후 회원 자격을 제한 또는 박탈할 수 있습니다.\n"
                    "- 타인의 명의 또는 정보를 도용한 경우\n"
                    "- 허위 정보를 기재한 경우\n"
                    "- 서비스의 정상적인 운영을 방해한 경우",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),

              Text(
                "제5조 (회원의 의무)",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "회원은 관계 법령, 약관의 규정, 이용안내 및 주의사항 등 회사가 통지하는 사항을 준수해야 합니다.\n"
                    "회원은 다음 행위를 하여서는 안 됩니다.\n"
                    "- 타인의 정보 도용\n"
                    "- 회사의 명예 훼손 또는 업무 방해\n"
                    "- 서비스 이용과 관련한 불법 행위 등",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),

              Text(
                "제6조 (회사의 의무)",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "회사는 관련 법령 및 본 약관이 금지하거나 미풍양속에 반하는 행위를 하지 않으며, 지속적이고 안정적인 서비스를 제공하기 위해 노력합니다.\n"
                    "회원의 개인정보를 보호하기 위해 개인정보처리방침을 수립하고 준수합니다.",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),

              Text(
                "제7조 (서비스의 변경 및 중단)",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "회사는 서비스의 일부 또는 전부를 사전 공지 후 변경하거나 중단할 수 있습니다.\n"
                    "불가피한 사유로 인한 경우(예: 서버 장애, 정기 점검 등) 사전 고지 없이 변경/중단할 수 있습니다.",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),

              Text(
                "제8조 (계약 해지 및 회원 탈퇴)",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "회원은 언제든지 앱 내 탈퇴 절차를 통해 이용계약을 해지할 수 있습니다.\n"
                    "회사는 회원이 본 약관을 위반하거나 서비스 운영에 중대한 지장을 초래할 경우 계약을 해지할 수 있습니다.",
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
