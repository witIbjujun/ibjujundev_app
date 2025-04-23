import 'package:witibju/screens/tosspayments/payment.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:tosspayments_widget_sdk_flutter/model/paymentData.dart';

/// [Home] 위젯은 사용자에게 결제 수단 및 주문 관련 정보를 입력받아
/// 결제를 시작하는 화면을 제공합니다.
class Home extends StatefulWidget {
  /// 기본 생성자입니다.
  const Home(this.selectedCash, this.storeName, this.email, {super.key});

  final dynamic selectedCash; //
  final String? storeName; //
  final String? email; //

  @override
  State<Home> createState() => _HomeState();
}

/// [_HomeState]는 [Home] 위젯의 상태를 관리하는 클래스입니다.
class _HomeState extends State<Home> {
  final _form = GlobalKey<FormState>();
  late String payMethod = '카드'; // 결제수단
  late String orderId; // 주문번호
  late String orderName; // 주문명
  late String amount; // 결제금액
  late String customerName; // 주문자명
  late String customerEmail; // 구매자 이메일

  @override
  void initState() {
    super.initState();
    amount = widget.selectedCash?.split('.')[0] ?? '0'; // 기본값으로 '0' 설정
    customerName = widget.storeName!;
    customerEmail = widget.email!;
  }

  /// 이 메소드는 [Home] 위젯을 빌드합니다.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('toss payments 결제 테스트'),
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 15),
        child: Form(
          key: _form,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: '카드',
                decoration: const InputDecoration(
                  labelText: '결제수단',
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  labelStyle: TextStyle(fontSize: 15, color: Color(0xffcfcfcf)),
                ),
                onChanged: (String? newValue) {
                  payMethod = newValue ?? '카드';
                },
                items: ['카드', '가상계좌', '계좌이체', '휴대폰', '상품권']
                    .map<DropdownMenuItem<String>>((String i) {
                  return DropdownMenuItem<String>(
                    value: i,
                    child: Text(i),
                  );
                }).toList(),
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: '주문번호(orderId)',
                ),
                initialValue:
                'tosspaymentsFlutter_${DateTime.now().millisecondsSinceEpoch}',
                onSaved: (String? value) {
                  orderId = value!;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: '주문명(orderName)',
                ),
                initialValue: '아파트 구독',
                onSaved: (String? value) {
                  orderName = value!;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: '결제금액(amount)',
                ),
                initialValue: amount, // selectedCash를 amount에 할당
                keyboardType: TextInputType.number, // 소수점 없는 숫자 입력
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly // 소수점 입력 방지
                ],
                onSaved: (String? value) {
                  amount = value!;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: '구매자명(customerName)',
                ),
                initialValue: customerName,
                onSaved: (String? value) {
                  customerName = value!;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: '이메일(customerEmail)',
                ),
                initialValue: customerEmail,
                keyboardType: TextInputType.emailAddress,
                onSaved: (String? value) {
                  customerEmail = value!;
                },
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    _form.currentState!.save();
                    PaymentData data = PaymentData(
                      paymentMethod: payMethod,
                      orderId: orderId,
                      orderName: orderName,
                      amount: int.parse(amount), // amount을 int로 변환
                      customerName: customerName,
                      customerEmail: customerEmail,
                      successUrl: Constants.success,
                      failUrl: Constants.fail,
                    );
                    var result = await Get.to(
                          () => const Payment(),
                      fullscreenDialog: true,
                      arguments: data,
                    );
                    if (result != null) {
                      Get.toNamed("/result", arguments: result);
                    }
                  },
                  child: const Text(
                    '결제하기',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
