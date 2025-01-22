import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tosspayments_widget_sdk_flutter/model/tosspayments_result.dart';
import 'package:witibju/screens/seller/paymentFailPage.dart';
import 'package:witibju/screens/seller/paymentSuccessPage.dart';
import 'package:witibju/screens/seller/wit_seller_cash_recharge_sc.dart';

import '../util/wit_api_ut.dart'; // updateCashInfo 호출을 위한 import


/// [ResultPage] class는 결제의 성공 혹은 실패 여부를 보여주는 위젯입니다.
class ResultPage extends StatelessWidget {
  /// 기본 생성자입니다.
  const ResultPage({super.key});

  /// 주어진 title과 message를 이용하여 [Row]를 생성합니다.
  ///
  /// [title]과 [message]는 [Text] 위젯의 일부로 포함됩니다.
  ///
  /// [title]는 회색 텍스트 스타일로, [message]는 기본 텍스트 스타일로 표시됩니다.
  Row makeRow(String title, String message) {
    return Row(children: [
      Expanded(
          flex: 3,
          child: Text(title, style: const TextStyle(color: Colors.grey))),
      Expanded(
        flex: 8,
        child: Text(message),
      )
    ]);
  }

  /// 결제 결과에 따라 적절한 [Container]를 반환합니다.
  ///
  /// [result]이 [Success] 타입이면 성공 메시지와 함께 세부 정보를 표시합니다.
  /// [result]이 [Fail] 타입이면 오류 메시지와 함께 세부 정보를 표시합니다.
  /// 그 외의 경우, 비어있는 [Container]를 반환합니다.
  /*Container getContainer(dynamic result) {
    return Container(
      color: Colors.transparent,
      child: Builder(
        builder: (context) {
          // Success 타입인 경우
          if (result is Success) {
            return Column(
              children: <Widget>[
                makeRow('paymentKey', result.paymentKey),
                const SizedBox(height: 20),
                makeRow('orderId', result.orderId),
                const SizedBox(height: 20),
                makeRow('amount', result.amount.toString()),
                const SizedBox(height: 20),
                ...?result.additionalParams?.entries.map<Widget>((e) => Column(
                      children: [
                        makeRow(e.key, e.value),
                        const SizedBox(height: 10),
                      ],
                    )),
                ElevatedButton(
                  onPressed: () {
                    // copyToClipboard 함수 구현 필요
                    // copyToClipboard(result.toString());
                  },
                  child: const Center(
                    child: Text(
                      '복사하기',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          // Fail 타입인 경우
          if (result is Fail) {
            return Column(
              children: <Widget>[
                makeRow('errorCode', result.errorCode),
                const SizedBox(height: 20),
                makeRow('errorMessage', result.errorMessage),
                const SizedBox(height: 20),
                makeRow('orderId', result.orderId),
              ],
            );
          }

          // Success 또는 Fail 타입이 아닌 경우
          return const SizedBox(); // 빈 위젯 반환
        },
      ),
    );
  }*/

  /// 위젯을 빌드합니다.
  ///
  /// [Success]인 경우, '인증 성공!' 메시지를 표시하며,
  /// 그 외의 경우, '결제에 실패하였습니다' 메시지를 표시합니다.
  @override
  Widget build(BuildContext context) {
    dynamic result = Get.arguments;
    String message;
    String paymentAmount;

    if (result is Success) {
      message = '인증 성공! 결제승인API를 호출해 결제를 완료하세요!';
      paymentAmount = result.amount.toString(); // int를 String으로 변환
      print("paymentAmount : " + paymentAmount);
      updateCashInfo(context, paymentAmount);
    } else {
      message = '결제에 실패하였습니다';
    }

    // 빈 위젯 반환 (사용자에게 아무것도 보여주지 않음)
    return const SizedBox.shrink();

    return Scaffold(
        appBar: AppBar(
          title: const Text('결제 결과'),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(30, 30, 30, 50),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  message,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 50),
                //getContainer(result),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  icon: const Icon(Icons.home),
                  onPressed: () {
                    Get.back();
                  },
                  label: const Text(
                    '홈으로',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    shadowColor: Colors.transparent,
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Future<void> updateCashInfo(BuildContext context, String paymentAmount) async {
    print('여기 왔냐?');
    String restId = "updateCashInfo";

    // PARAM
    final param = jsonEncode({
      "sllrNo": "17",
      "cash": paymentAmount,
      "cashGbn": "01", // 01 : 포인트 충전, 02 : 견적서비스
    });

    // API 호출
    final response = await sendPostRequest(restId, param);

    if (response != null) {
      //await getCashInfo(); // 캐시 정보 갱신

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("캐시가 성공적으로 충전되었습니다.")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentSuccessPage(
            paymentAmount: paymentAmount,
            itemName: "입주 캐시 구매", // 품목명은 적절히 수정
          ),
        ),
      );
      // 상세 화면으로 이동

      /*WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CashRecharge(sllrNo: '17')), // sllrNo는 적절히 수정
        );
      });*/

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("캐시 충전에 실패했습니다.")),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentFailPage(
            paymentAmount: paymentAmount,
            itemName: "입주 캐시 구매", // 품목명은 적절히 수정
          ),
        ),
      );
    }
  }
}
