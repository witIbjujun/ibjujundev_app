import 'package:flutter/material.dart';

class Agreement3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "개인정보 제3자 제공 동의서",
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
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "개인정보 제3자 제공 동의서",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "[입주전](이하 '회사')는 개인정보 보호법 제17조 및 제22조에 따라, "
                    "회원님의 개인정보를 아래와 같이 제3자에게 제공하고자 합니다. 내용을 충분히 숙지하신 후 동의 여부를 결정해 주세요.",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),

              const Text(
                "제1조 (제공받는 자)",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // 🔹 DataTable 사용하여 보기 좋게 테이블 형식으로 변경
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 12.0,
                  columns: const <DataColumn>[
                    DataColumn(
                      label: Text(
                        '제공받는 자',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        '제공 목적',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        '제공 항목',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        '보유 및 이용기간',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                  rows: const <DataRow>[
                    DataRow(
                      cells: <DataCell>[
                        DataCell(Text('㈜KG이니시스')),
                        DataCell(Text('전자결제 서비스 제공')),
                        DataCell(Text('이름, 휴대전화번호, 이메일, 결제정보')),
                        DataCell(Text('목적 달성 시까지\n(관련 법령에 따라 보관)')),
                      ],
                    ),
                    DataRow(
                      cells: <DataCell>[
                        DataCell(Text('제휴 시공업체\n(매칭된 업체에 한함)')),
                        DataCell(Text('견적 제공 및 시공 상담')),
                        DataCell(Text('이름, 휴대전화번호, 주소, 요청 내역')),
                        DataCell(Text('서비스 완료 후 3개월 이내 파기')),
                      ],
                    ),
                    DataRow(
                      cells: <DataCell>[
                        DataCell(Text('㈜카카오, 문자발송 대행업체')),
                        DataCell(Text('알림톡 및 문자 발송')),
                        DataCell(Text('이름, 전화번호, 알림내용')),
                        DataCell(Text('위탁 계약 종료 시까지')),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                "제2조 (동의 거부 권리 및 불이익)",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "회원님은 개인정보 제3자 제공에 대한 동의를 거부하실 수 있습니다.\n"
                    "단, 필수 항목에 대한 동의를 거부할 경우, 서비스 이용에 제한이 있을 수 있습니다.",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              const Text(
                "※ 위 내용을 충분히 확인하였으며, 본인은 개인정보의 제3자 제공에 동의합니다.",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
