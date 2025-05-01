import 'package:flutter/material.dart';

class CardInfoConfirmPage extends StatelessWidget {
  final String customerUid;
  final int amount;
  final String storeName;
  final String cardName;
  final String maskedCardNumber;
  final Function onPaymentSuccess;  // 결제 성공 시 호출할 콜백 함수

  const CardInfoConfirmPage({
    required this.customerUid,
    required this.amount,
    required this.storeName,
    required this.cardName,
    required this.maskedCardNumber,
    required this.onPaymentSuccess,  // 콜백 함수 전달
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.3),
      body: Stack(
        children: [
          // Dim background
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(color: Colors.transparent),
          ),

          // Bottom sheet style
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 상단 바
                  Container(
                    width: 40,
                    height: 4,
                    margin: EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('결제수단', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(height: 16),
                  // 결제수단 라디오 버튼
                  Row(
                    children: [
                      Icon(Icons.radio_button_checked, color: Colors.deepPurple),
                      SizedBox(width: 8),
                      Text('신용/체크카드', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                    ],
                  ),
                  SizedBox(height: 12),
                  // 카드 정보
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: Text('$cardName $maskedCardNumber', style: TextStyle(fontSize: 15))),
                        //Text('삭제', style: TextStyle(color: Colors.grey, fontSize: 14)),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  // 하단 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        // 결제 성공 후 onPaymentSuccess 호출
                        onPaymentSuccess();  // 결제 성공 콜백 실행
                      },
                      child: Text('${amount.toString()}원 결제하기',
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
