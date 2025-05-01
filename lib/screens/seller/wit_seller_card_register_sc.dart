import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../util/wit_api_ut.dart';
import '../home/wit_home_theme.dart';

class CardRegisterWebView extends StatefulWidget {
  final String customerUid;
  final int amount; // 💰 결제할 금액 추가
  final String storeName;

  const CardRegisterWebView({
    super.key,
    required this.customerUid,
    required this.amount,
    required this.storeName,
  });

  @override
  State<CardRegisterWebView> createState() => _CardRegisterWebViewState();
}

class _CardRegisterWebViewState extends State<CardRegisterWebView> {
  WebViewController? _controller;

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized(); // Flutter WebView 초기화 필요

    final js = '''
    var IMP = window.IMP;
    IMP.init("imp47341432"); // 본인 가맹점 식별 코드
    IMP.request_pay({
      pg: "html5_inicis",
      pay_method: "card",
      merchant_uid: "mid_${DateTime.now().millisecondsSinceEpoch}",
      name: "${widget.storeName} 구독 결제",
      amount: ${widget.amount}, // 💳 실제 결제 금액
      customer_uid: "${widget.customerUid}"
    }, function (rsp) {
      if (window.callback && window.callback.postMessage) {
         window.callback.postMessage(JSON.stringify(rsp));
      } else {
         console.error("JavaScriptChannel 'callback' is not available.");
      }
    });
''';

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted) // JavaScript 사용
      ..addJavaScriptChannel('callback', onMessageReceived: _onJsCallback); // callback 핸들러 추가
    _controller = controller;

    // HTML 문자열을 로딩하는 부분을 변경
    controller.loadRequest(
      Uri.dataFromString( // Uri.dataFromString으로 URI 객체 생성
        _htmlWrapper(js),
        mimeType: 'text/html',
        encoding: Encoding.getByName('utf-8'),
      ),
    );
  }

  void _onJsCallback(JavaScriptMessage message) {
    try {
      final result = jsonDecode(message.message);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("카드등록이 성공했습니다.")),
      );
      print('Iamport 콜백 결과: $result');
      // 카드등록이 성공했습니다.
      // <-- 이 부분을 추가하여 결과 확인
      // result['success'] 또는 result['imp_success'] 값을 확인하여 성공 여부 판단
      // 실패 시 result['error_code'], result['error_msg'] 등을 확인

      // 결과 반환 (성공/실패/취소 여부에 따라 다른 값 반환 고려)
      Navigator.pop(context, result);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("카드등록이 실패했습니다.")),
      );
      print('Iamport 콜백 결과 디코딩 오류: $e');
      // 오류 처리 로직
      Navigator.pop(context, {'success': false, 'error_msg': '결과 처리 중 오류 발생'});
    }
  }

  // HTML 문자열로 감싸는 함수
  String _htmlWrapper(String js) {
    return '''
  <!DOCTYPE html>
  <html>
  <head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script> <!-- jQuery 추가 -->
    <script src="https://cdn.iamport.kr/js/iamport.payment-1.1.8.js"></script>
  </head>
  <body>
    <script>
      document.addEventListener("DOMContentLoaded", function() {
        $js
      });
    </script>
  </body>
  </html>
  ''';
  }

  // 카드 등록 결과 저장
  void _sendCardRegisterResultToServer(Map<String, dynamic> result) async {
    String restId = "insertCartInfo";

    /*final cardInfo = {
      'customer_uid': result['customer_uid'],
      'card_name': result['card_name'],
      'card_number': result['card_number'],
      'imp_uid': result['imp_uid'],
      'receipt_url': result['receipt_url'],
    };*/

    // PARAM
    final param = jsonEncode({
      'customer_uid': result['customer_uid'],
      'card_name': result['card_name'],
      'card_number': result['card_number'],
      'imp_uid': result['imp_uid'],
      'receipt_url': result['receipt_url'],
    });

    final response = await sendPostRequest(restId, param);

    if (response != null) {
      print("서버에 카드 등록 결과 저장 성공");
    } else {
      print("서버 저장 실패: ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("결제정보 등록",  style: WitHomeTheme.title.copyWith(fontSize: 16))),
      body: _controller == null
          ? Center(child: CircularProgressIndicator()) // WebView가 준비되기 전 로딩 화면
          : WebViewWidget(controller: _controller!), // WebView에 컨트롤러 적용
    );
  }


}
