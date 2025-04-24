import 'package:flutter/material.dart';
import 'package:witibju/screens/seller/wit_seller_cash_recharge_sc.dart';
import 'package:witibju/screens/seller/wit_seller_profile_detail_sc.dart';

import '../home/wit_home_theme.dart';

class PaymentSuccessPage extends StatelessWidget {
  final String paymentAmount;
  final String itemName; // 품목명 추가
  final dynamic sllrNo; // 품목명 추가

  PaymentSuccessPage({required this.paymentAmount, required this.itemName, this.sllrNo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('결제 성공',
                      style: WitHomeTheme.title.copyWith(fontSize: 20)
                    ),
        centerTitle: true,
        backgroundColor: WitHomeTheme.wit_white,
        automaticallyImplyLeading: false, // 🔒 뒤로가기 버튼 제거

      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(0),
          decoration: BoxDecoration(
            color: WitHomeTheme.wit_white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 5,
                blurRadius: 15,
                offset: Offset(0, 3), // 그림자 위치
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center, // 중앙 정렬
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blue,
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '결제가 성공적으로 완료되었습니다!',
                style: WitHomeTheme.title.copyWith(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                '좋은 서비스로 보답하겠습니다!',
                style: WitHomeTheme.title.copyWith(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Divider(thickness: 2, color: Colors.blue), // 구분선 추가
              const SizedBox(height: 20),
              Text(
                '품목명: $itemName',
                style: WitHomeTheme.title.copyWith(fontSize: 18),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 30),
              Text(
                '결제 금액: $paymentAmount' + '원',
                style: WitHomeTheme.title.copyWith(fontSize: 18),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 20),
              Divider(thickness: 2, color: Colors.blue), // 구분선 추가
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, 'success'); // 성공 결과 전달
                  /*Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => SellerProfileDetail(sllrNo: '17')),

                  );*/
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // 버튼 배경색 파란색
                  foregroundColor: Colors.white, // 글씨색 흰색
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                ),
                child: Text('확인', style: WitHomeTheme.title.copyWith(fontSize: 18, color: WitHomeTheme.wit_white),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
