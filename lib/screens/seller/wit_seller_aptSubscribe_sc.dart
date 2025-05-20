import 'dart:convert';
import 'package:witibju/screens/seller/wit_seller_card_confirm_sc.dart';
import 'package:witibju/screens/seller/wit_seller_card_register_sc.dart';
import 'package:witibju/screens/seller/wit_seller_cash_history_sc.dart';
import 'package:witibju/screens/seller/wit_seller_cash_recharge_sc.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:witibju/screens/seller/wit_seller_profile_appbar_sc.dart';
import '../../util/wit_api_ut.dart';
import '../home/wit_home_theme.dart';
import '../tosspayments/home.dart';
import 'package:http/http.dart' as http;

Future<String?> getAccessToken() async {
  final url = Uri.parse('https://api.iamport.kr/users/getToken');  // Iamport 토큰 발급 엔드포인트

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    body: {
      // 'imp_key': '3440475312241762',  // Iamport에서 발급받은 imp_key
      // 'imp_secret': 'V8bhdgFkjH6q92j0Gvq65MXdLMrC317tnmR0RikUkuzIp3hek75FZ2moJQZlCKqly6qGkF8ClXBrm6yZ',  // Iamport에서 발급받은 imp_secret
      'imp_key': '3440475312241762', // REST API 키
      'imp_secret': 'V8bhdgFkjH6q92j0Gvq65MXdLMrC317tnmR0RikUkuzIp3hek75FZ2moJQZlCKqly6qGkF8ClXBrm6yZ', // REST API Secret
    },
  );

  if (response.statusCode == 200) {
    final responseData = jsonDecode(response.body);
    return responseData['response']['access_token'];  // 발급받은 액세스 토큰 반환
  } else {
    print('토큰 발급 실패: ${response.statusCode}');
    print('응답 본문: ${response.body}');  // 응답 본문을 출력하여 실패 원인 파악
    return null;
  }
}

class SellerAptSubscribe extends StatefulWidget {
  final dynamic sllrNo;

  const SellerAptSubscribe({Key? key, required this.sllrNo}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SellerAptSubscribeState();
  }
}

class SellerAptSubscribeState extends State<SellerAptSubscribe> {
  dynamic sellerInfo;
  String storeName = "";
  String? selectedCash; // 선택된 캐시 금액을 저장할 변수

  // 아파트구독 리스트
  List<dynamic> subscribeAptList = [];

  dynamic saleAmt = "";

  @override
  void initState() {
    super.initState();
    getSellerInfo(widget.sllrNo);
    getSubscribeAptList();
  }

  Future<void> getSellerInfo(dynamic sllrNo) async {

    String restId = "getSellerInfo";
    // PARAM
    final param = jsonEncode({
      "sllrNo": sllrNo,
    });

    print("sllrNo :" + sllrNo.toString());

    // API 호출
    final response = await sendPostRequest(restId, param);

    if (response != null) {
      setState(() {
        sellerInfo = response;
        storeName = sellerInfo['storeName'];
        print('Store Name: $storeName');
      });
    } else {
      // 오류 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("사업자 프로필 조회가 실패하였습니다.")),
      );
    }

  }

  // 아파트 구독 리스트
  Future<void> getSubscribeAptList() async {
    String restId = "getSubscribeAptList";

    // PARAM
    final param = jsonEncode({
      "sllrNo": widget.sllrNo,
      "searchType": "",
    });

    // API 호출
    final response = await sendPostRequest(restId, param);

    if (response != null) {
      setState(() {
        subscribeAptList = response;
      });
    } else {
      // 오류 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("아파트 구독 리스트 조회가 실패하였습니다.")),
      );
    }
  }

  // 카드 등록 여부 확인 함수
  Future<Map<String, dynamic>?> checkCardRegistration(String customerUid) async {
    final accessToken = await getAccessToken();

    if (accessToken == null) {
      print("엑세스 토큰 발급 실패");
      return null;
    } else {
      print("엑세스 토큰 발급 성공 : $accessToken");
    }

    customerUid = 'user_' + widget.sllrNo;

    print("13123211231321233:" + customerUid);

    final url = Uri.parse('https://api.iamport.kr/subscribe/customers/$customerUid');

    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        print('API 호출 성공: ${response.statusCode}');
        final responseData = jsonDecode(response.body);
        final data = responseData['response'];

        if (data == null) {
          print('카드 등록 정보 없음');
          return null;
        }
        else {
          print('카드 등록 정보 있음');
        }

        // 등록된 정보
        final getCustomer_uid = data['customer_uid'];
        bool isRegistered = getCustomer_uid != null && getCustomer_uid.isNotEmpty;

        return {
          'isRegistered': data['customer_uid'] != null && data['customer_uid'].toString().isNotEmpty,
          'cardName': data['card_name'],
          'cardNumber': data['card_number'],  // 마스킹된 카드번호
        };
      } else {
        print('API 호출 오류: ${response.statusCode}');
        print('응답 본문: ${response.body}');
        return null;
      }
    } catch (e) {
      print('API 호출 실패: $e');
      return null;
    }
  }

  // 아파트 구독 결제 정보 저장
  Future<void> insertSubscribePaymentData({
    required dynamic aptNo,
    required String? impUid,
    required String merchantUid,
    required String payMethod,
    required int amount,
    required String status,
    required String? cardName,
    required String? cardNumber,
    required String buyerName,
    required String buyerEmail,
    required int? paidAt,
    required String? receiptUrl,
    required String? failReason,
    // required String createdAt,
  }) async {

    print('결제 데이터 확인👇');
    print(jsonEncode({
      'customer_uid': widget.sllrNo,
      'apt_no': aptNo,
      'imp_uid': impUid,
      'merchant_uid': merchantUid,
      'pay_method': payMethod,
      'amount': amount,
      'status': status,
      'card_name': cardName,
      'card_number': cardNumber,
      'buyer_name': buyerName,
      'buyer_email': buyerEmail,
      'paid_at': paidAt,
      'receipt_url': receiptUrl,
      'fail_reason': failReason,
    }));


    String restId = "insertSubscribePaymentData";

    // 예: Supabase 사용 시
    final param = jsonEncode({
      'customer_uid': widget.sllrNo,
      'apt_no': aptNo,
      'imp_uid': impUid,
      'merchant_uid': merchantUid,
      'pay_method': payMethod,
      'amount': amount,
      'status': status,
      'card_name': cardName,
      'card_number': cardNumber,
      'buyer_name': buyerName,
      'buyer_email': buyerEmail,
      'paid_at': paidAt,
      'receipt_url': receiptUrl,
      'fail_reason': failReason,
      // 'created_at': createdAt,
    });

    final response = await sendPostRequest(restId, param);

    if (response.error != null) {
      print('결제 로그 저장 실패: ${response.error!.message}');
    } else {
      print('결제 로그 저장 성공');
    }
  }

  // 아파트 구독
  Future<void> insertSubscribeApt(dynamic aptNo) async {
    String restId = "insertSubscribeApt";

    // PARAM
    final param = jsonEncode({
      "sllrNo": widget.sllrNo,
      "aptNo": aptNo,
    });

    // API 호출
    final response = await sendPostRequest(restId, param);

    if (response != null) {
      // 성공 후 리스트 다시 가져오기
      setState(() {
        getSubscribeAptList();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("아파트 구독이 성공하였습니다.")),
      );
    } else {
      // 오류 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("아파트 구독이 실패하였습니다.")),
      );
    }
  }

  // 카드 등록 여부 확인 후 결제 또는 카드 등록
  Future<void> checkAndProceedWithPayment(dynamic aptNo, dynamic saleAmt) async {
    final cardData = await checkCardRegistration(widget.sllrNo);

    final isRegistered = cardData?['isRegistered'] ?? false;
    final cardName = cardData?['cardName'] ?? '';
    final maskedCardNumber = cardData?['cardNumber'] ?? '';

    if (isRegistered) {
      final result = await showModalBottomSheet<Map<String, dynamic>>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        isDismissible: true, // 바깥 영역을 눌러도 닫히게 설정
        builder: (_) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.308,
          maxChildSize: 0.9,
          minChildSize: 0.308,
          builder: (_, controller) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: CardInfoConfirmPage(
                customerUid: 'user_' + widget.sllrNo,
                amount: saleAmt,
                storeName: storeName,
                cardName: cardName,
                maskedCardNumber: maskedCardNumber,
                onPaymentSuccess: () {
                  // 결제 성공 시 팝업만 닫고 proceedWithAutoPayment 호출
                  Navigator.of(context).pop(); // 팝업 닫기
                  proceedWithAutoPayment(aptNo, saleAmt); // 결제 진행
                },
              ),
            );
          },
        ),
      );

    } else {
      proceedWithCardRegistration(aptNo, saleAmt);
    }
  }


  // 자동 결제 처리
  Future<void> proceedWithAutoPayment(dynamic aptNo, dynamic saleAmt) async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      print('자동결제 실패: 액세스 토큰 없음');
      return;
    }
    else {
      print('자동결제 진행: 액세스 토큰 있음');
    }

    final url = Uri.parse('https://api.iamport.kr/subscribe/payments/again');

    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      'customer_uid': 'user_' + widget.sllrNo,
      'merchant_uid': 'mid_${DateTime.now().millisecondsSinceEpoch}',
      'amount': saleAmt,
      'name': '아파트 구독 결제',
      'buyer_email': 'dravenn@naver.com',
      'buyer_name': '범석 방충망',
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 0) {
          final res = data['response'];

          await insertSubscribePaymentData(
            aptNo: aptNo,                               // 아파트 고유 번호
            impUid: res['imp_uid'],                     // 포트원 거래 고유 ID
            merchantUid: res['merchant_uid'],           // 주문 번호
            payMethod: res['pay_method'],               // 결제 수단
            amount: res['amount'],                      // 결제 금액
            status: res['status'],                      // 상태 (paid)
            cardName: res['card_name'],                 // 카드사 이름
            cardNumber: res['card_number'],                 // 승인번호
            buyerName: res['buyer_name'],               // 구매자 이름
            buyerEmail: res['buyer_email'],             // 구매자 이메일
            paidAt: res['paid_at'],                     // 결제 시각 (Unix timestamp)
            receiptUrl: res['receipt_url'],             // 영수증 URL
            failReason: null,                           // 실패 아님
            // createdAt: now.toIso8601String(),           // 저장 시각
          );

          insertSubscribeApt(aptNo); // 실제 구독 처리

        } else {
          // ❌ 실패 응답일 경우 (결제 요청은 됐지만 카드사 등에서 거절)
          await insertSubscribePaymentData(
            aptNo: aptNo,
            impUid: null,
            merchantUid: jsonDecode(body)['merchant_uid'] ?? 'unknown',
            payMethod: 'card',
            amount: saleAmt,
            status: 'failed',                           // 상태: 실패
            cardName: null,
            cardNumber: null,
            buyerName: '범석 방충망',
            buyerEmail: 'dravenn@naver.com',
            paidAt: null,
            receiptUrl: null,
            failReason: data['message'],                // 실패 사유 저장
            // createdAt: now.toIso8601String(),
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('자동결제 실패: ${data['message']}')),
          );
        }
      } else {
        print('자동결제 실패: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('자동결제 실패: ${response.body}')),
        );
      }
    } catch (e) {
      print('자동결제 예외 발생: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('자동결제 예외: $e')),
      );
    }
  }


  // 카드 등록 후 결제 처리
  void proceedWithCardRegistration(dynamic aptNo, dynamic saleAmt) async {
    int amount = 0;
    if (saleAmt != null && saleAmt.toString().isNotEmpty) {
      amount = int.tryParse(saleAmt.toString().split('.')[0]) ?? 0;  // 잘못된 형식일 경우 0으로 처리
    }

    // 카드 등록 화면 띄우기 (카드 등록을 진행)
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CardRegisterWebView(customerUid: 'user_1234',
          amount: amount, // 💰 실제 금액 전달
          storeName: storeName,),
      ),
    );

    if (result != null && result['success'] == true) {
      // 카드 등록 후 결제 진행
      proceedWithAutoPayment(aptNo, amount);
    } else {
      // 카드 등록 실패 또는 취소 시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("카드 등록이 실패하거나 취소되었습니다.")),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: WitHomeTheme.wit_white,
        body: ListView.builder(
          padding: EdgeInsets.all(16.0),
          itemCount: getItemCount(), // 아이템 개수 계산
          itemBuilder: (context, index) {
            return _buildItem(context, index);
          },
        ),
      ),
    );
  }

  int getItemCount() {
    if (subscribeAptList.isEmpty) return 0;

    // 중복된 month를 제외한 개수 계산
    String? currentMonth;
    int count = 0;

    for (int i = 0; i < subscribeAptList.length; i++) {
      String month = subscribeAptList[i]['moveinScjDate'] ?? '미정';
      if (currentMonth != month) {
        count++;
        currentMonth = month;
      }
    }
    return count;
  }

  Widget _buildItem(BuildContext context, int index) {
    String? currentMonth;
    int dataIndex = 0; // subscribeAptList의 실제 index

    // index에 해당하는 month 찾기
    for (int i = 0; i <= index; i++) {
      String month = subscribeAptList[dataIndex]['moveinScjDate'] ?? '미정';
      if (currentMonth != month) {
        currentMonth = month;
      } else {
        i--; // month가 같으면 index 유지
      }
      if (dataIndex < subscribeAptList.length - 1) {
        dataIndex++;
      }
    }

    // 해당 month의 데이터 필터링
    List<dynamic> itemsForMonth = subscribeAptList
        .where((item) => (item['moveinScjDate'] ?? '미정') == currentMonth)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(currentMonth!,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        ...itemsForMonth
            .map((item) => _buildCardItem(
          item['moveinScjDate'] ?? '미정',
          item['splSize'] + ' 세대',
          item['aptName'],
          item['stat'],
          item['aptNo'], // aptNo 추
          item['sscAmt'], // aptNo 추
          item['saleAmt'], // aptNo 추
        ))
            .toList(),
        SizedBox(height: 16), // 그룹 간 간격
      ],
    );
  }

  Widget _buildCardItem(
      String month, String unit, String description, String action, dynamic aptNo, dynamic sscAmt, dynamic saleAmt) {
    return Card(
      elevation: 0,
      color: Colors.grey[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      margin: EdgeInsets.symmetric(vertical: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.apartment, size: 24, color: Colors.grey[600]),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(unit, style: WitHomeTheme.title.copyWith(fontSize: 14)),
                  Text(description, style: WitHomeTheme.title.copyWith(fontSize: 14)),
                  Row(
                    children: [
                      Text(
                        sscAmt.toString() + '원',
                        style: TextStyle(
                          color: WitHomeTheme.wit_gray,
                          decoration: TextDecoration.lineThrough,
                          decorationColor: Colors.red,
                          fontSize: 13,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        ' -> ' + saleAmt.toString().split('.')[0] + '원',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(width: 6),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.local_offer, size: 14, color: Colors.white), // 🎯 세일 아이콘
                            SizedBox(width: 2),
                            Text(
                              'SALE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () async {
                if (action == '구독하기') {
                  checkAndProceedWithPayment(aptNo, int.tryParse(saleAmt.toString().split('.')[0]) ?? 0);
                }
              },
              style: TextButton.styleFrom(
                backgroundColor: action == '구독하기' ? WitHomeTheme.wit_lightGreen : WitHomeTheme.wit_lightgray,
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                minimumSize: Size(80.0, 36.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              child: Text(
                action,
                style: WitHomeTheme.subtitle.copyWith(fontSize: 14, color: WitHomeTheme.wit_black),
              ),
            ),

          ],
        ),
      ),
    );
  }

}
