import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tosspayments_widget_sdk_flutter/model/tosspayments_result.dart';
import 'package:witibju/screens/seller/paymentFailPage.dart';
import 'package:witibju/screens/seller/paymentSuccessPage.dart';
import 'package:witibju/screens/seller/wit_seller_cash_recharge_sc.dart';

import '../util/wit_api_ut.dart'; // updateCashInfo 호출을 위한 import


/// [ResultPage] class는 결제의 성공 혹은 실패 여부를 보여주는 위젯입니다.
class ResultPage extends StatefulWidget {
  const ResultPage({super.key});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      handleResult();
    });
  }

  void handleResult() async {
    final result = Get.arguments;
    dynamic paymentAmount = result.amount.toString(); // int를 String으로 변환

    if (result is Success) {
      final resultFromSuccessPage = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentSuccessPage(
            paymentAmount: paymentAmount,
            itemName: '아파트 구독',
          ),
        ),
      );

      // PaymentSuccessPage에서 결과 받아서 첫 페이지로 pop
      Navigator.pop(context, resultFromSuccessPage);
    } else {
      Navigator.pop(context, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
