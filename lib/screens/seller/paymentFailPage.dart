import 'package:flutter/material.dart';
import 'package:witibju/screens/seller/wit_seller_cash_recharge_sc.dart';

class PaymentFailPage extends StatelessWidget {
  final String paymentAmount;
  final String itemName; // 품목명 추가

  PaymentFailPage({required this.paymentAmount, required this.itemName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('결제 실패'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
                '결제가 실패하였습니다',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                '결제 금액: $paymentAmount',
                style: const TextStyle(fontSize: 18),
              ),
              Text(
                '품목명: $itemName',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => CashRecharge(sllrNo: '17')),
                  );
                },
                child: const Text('확인'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}