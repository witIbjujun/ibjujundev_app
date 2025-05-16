import 'package:flutter/material.dart';

import '../home/wit_home_theme.dart';

class SellerAgreement1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "전자금융거래 기본약관",
          style: WitHomeTheme.title.copyWith(fontSize: 16, color: WitHomeTheme.wit_white),
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
            children: [
              // 🔹 제목
              Text(
                "제1조 (목적)",
                style: WitHomeTheme.title.copyWith(fontSize: 18),
              ),
              SizedBox(height: 2),
              Text(
                "이 약관은 회사가 제공하는 전자금융거래 서비스의 이용조건 및 절차에 관한 사항을 규정합니다.",
                style: WitHomeTheme.subtitle.copyWith(fontSize: 14),
              ),
              SizedBox(height: 16),

              // 🔹 제목
              Text(
                "제2조 (정의)",
                style: WitHomeTheme.title.copyWith(fontSize: 18),

              ),
              SizedBox(height: 2),
              Text(
                "전자금융거래: 전자적 장치를 이용한 금융서비스(결제, 정산, 송금 등)\n "
                "전자지급수단: 신용카드, 계좌이체, 간편결제 등",
                style: WitHomeTheme.subtitle.copyWith(fontSize: 14),              ),
              SizedBox(height: 16),

              Text(
                "제3조 (약관의 명시 및 변경)",
                style: WitHomeTheme.title.copyWith(fontSize: 18),

              ),
              SizedBox(height: 2),
              Text(
                "본 약관은 회사 홈페이지 또는 앱 내에 게시하며,\n"
                    "관련 법령 또는 서비스 변경 시 사전 공지를 통해 개정합니다.",
                style: WitHomeTheme.subtitle.copyWith(fontSize: 14),              ),
              SizedBox(height: 16),

              Text(
                "제4조 (전자금융거래의 성립)",
                style: WitHomeTheme.title.copyWith(fontSize: 18),

              ),
              SizedBox(height: 2),
              Text(
                "사용자가 전자적 방법으로 결제 또는 금융 거래를 요청하고, 회사가 이를 수락함으로써 거래가 성립됩니다.",
                style: WitHomeTheme.subtitle.copyWith(fontSize: 14),              ),
              SizedBox(height: 16),

              Text(
                "제5조 (이용자 정보의 제공 및 정확성 확보)",
                style: WitHomeTheme.title.copyWith(fontSize: 18),

              ),
              SizedBox(height: 2),
              Text(
                "이용자는 정확한 정보를 제공해야 하며, 허위 정보 제공으로 인한 책임은 이용자에게 있습니다.",
                style: WitHomeTheme.subtitle.copyWith(fontSize: 14),              ),
              SizedBox(height: 16),

              Text(
                "제6조 (거래지시의 철회 및 제한)",
                style: WitHomeTheme.title.copyWith(fontSize: 18),

              ),
              SizedBox(height: 2),
              Text(
                "거래지시 후 일정 시점까지는 철회가 가능하며, 회사 정책 또는 PG사 정책에 따라 제한될 수 있습니다.",
                style: WitHomeTheme.subtitle.copyWith(fontSize: 14),              ),
              SizedBox(height: 16),

              Text(
                "제7조 (오류정정 및 피해보상)",
                style: WitHomeTheme.title.copyWith(fontSize: 18),

              ),
              SizedBox(height: 2),
              Text(
                "오류가 발생한 경우 이용자는 즉시 회사에 통지해야 하며, 회사는 확인 후 정정 또는 보상을 진행합니다.",
                style: WitHomeTheme.subtitle.copyWith(fontSize: 14),              ),
              SizedBox(height: 16),

              Text(
                "제8조 (이용자의 책임)",
                style: WitHomeTheme.title.copyWith(fontSize: 18),

              ),
              SizedBox(height: 2),
              Text(
                "전자금융거래 정보를 타인에게 유출하거나 부주의로 인한 피해 발생 시 책임은 이용자에게 있습니다.",
                style: WitHomeTheme.subtitle.copyWith(fontSize: 14),              ),

              SizedBox(height: 16),

              Text(
                "제9조 (회사의 책임)",
                style: WitHomeTheme.title.copyWith(fontSize: 18),

              ),
              SizedBox(height: 2),
              Text(
                "회사는 안정적인 거래 환경을 제공할 의무가 있으며, 고의 또는 과실로 인한 손해에 대해 배상책임을 집니다.",
                style: WitHomeTheme.subtitle.copyWith(fontSize: 14),              ),

              SizedBox(height: 16),

              Text(
                "제10조 (약관 외 준칙)",
                style: WitHomeTheme.title.copyWith(fontSize: 18),

              ),
              SizedBox(height: 2),
              Text(
                "본 약관에서 정하지 않은 사항은 관련 법령(전자금융거래법, 개인정보 보호법 등)에 따릅니다.",
                style: WitHomeTheme.subtitle.copyWith(fontSize: 14),              ),

              SizedBox(height: 16),

              Text(
                "부칙",
                style: WitHomeTheme.title.copyWith(fontSize: 18),

              ),
              SizedBox(height: 2),
              Text(
                "본 약관은 2025년 6월 23일부터 시행합니다.",
                style: WitHomeTheme.subtitle.copyWith(fontSize: 14),              ),
            ],
          ),
        ),
      ),
    );
  }
}
