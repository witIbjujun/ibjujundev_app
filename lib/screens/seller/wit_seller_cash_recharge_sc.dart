import 'dart:convert';

import 'package:witibju/screens/seller/wit_seller_cash_history_sc.dart';
import 'package:witibju/screens/seller/wit_seller_cash_recharge_auto_sc.dart';
import 'package:flutter/material.dart';
import 'package:witibju/screens/seller/wit_seller_profile_appbar_sc.dart';
// import 'package:tosspayments_widget_sdk_flutter/widgets/payment_method.dart';

import '../../util/wit_api_ut.dart';
import 'package:intl/intl.dart';

import '../home/wit_home_theme.dart';
import '../tosspayments/home.dart';

class CashRecharge extends StatefulWidget {
  final dynamic sllrNo;
  const CashRecharge({Key? key, required this.sllrNo}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return CashRechargeState();
  }
}

class CashRechargeState extends State<CashRecharge> {
  dynamic sellerInfo;
  String storeName = "";
  Map cashInfo = {};
  List<dynamic> cashRechargeList = [];
  String? selectedCash; // 선택된 캐시 금액을 저장할 변수
  String?  selectedAmount;

  @override
  void initState() {
    super.initState();
    getSellerInfo(widget.sllrNo);
    getCashInfo(); // 초기화 시 캐시정보를 가져옵니다.
    getCashRechargeList();
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

  Future<void> getCashInfo() async {
    // REST ID
    String restId = "getCashInfo";

    // PARAM
    final param = jsonEncode({
      "sllrNo": "17",
    });

    // API 호출 (사전 점검 미완료 리스트 조회)
    final _cashInfo = await sendPostRequest(restId, param);

    // 결과 셋팅
    setState(() {
      cashInfo = _cashInfo;
    });
  }

  Future<void> getCashRechargeList() async {
    // REST ID
    String restId = "getCashRechargeList";

    // PARAM
    final param = jsonEncode({
      "cashGbn": "01", // 01 : 캐시춪전, 02 : 자동충전
    });

    // API 호출 (사전 점검 미완료 리스트 조회)
    final _cashRechargeList = await sendPostRequest(restId, param);

    // 결과 셋팅
    setState(() {
      cashRechargeList = _cashRechargeList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WitHomeTheme.wit_white,

      /*appBar: SellerAppBar(
        sllrNo: widget.sllrNo,
      ),*/
      appBar: AppBar(
        backgroundColor: WitHomeTheme.wit_gray,
        iconTheme: const IconThemeData(color: WitHomeTheme.wit_white),
        title: Text(
          '캐시충전',
          style: WitHomeTheme.title.copyWith(color: WitHomeTheme.wit_white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              /*decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2.0),
                color: Colors.white,
              ),*/
              child: Row(
                children: [
                  Container(
                    color: WitHomeTheme.wit_gray,
                    padding: EdgeInsets.symmetric(
                        vertical: 5, horizontal: 10),
                    child: Text(
                      "IBJU",
                      style: WitHomeTheme.title.copyWith(fontSize: 20, color: WitHomeTheme.wit_white),
                    ),

                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerRight,
                      color: Colors.grey[300],
                      padding: EdgeInsets.symmetric(
                          vertical: 5, horizontal: 10),
                      child: Text(
                        (cashInfo['cash'] != null && cashInfo['cash'] != '')
                            ? '${NumberFormat('#,###').format(int.parse(cashInfo['cash']))} C'
                            : '0 C',
                        style: WitHomeTheme.title.copyWith(fontSize: 20),

                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 10),
            Text('| 캐시충전',
              style: WitHomeTheme.title.copyWith(fontSize: 20),
            ),
            Text('- 캐시구매로 많은 견적서비스를 이용해보세요~',
              style: WitHomeTheme.subtitle.copyWith(fontSize: 16),
            ),
            SizedBox(height: 20),
            ...cashRechargeList.map((rechargeOption) {
              double totalAmount = double.parse(rechargeOption['totalCash'] ?? '0');
              String total = '${NumberFormat('#,###').format(totalAmount)} C';

              double pointRatioAmount = double.parse(rechargeOption['bonusRatio'] ?? '0');
              String fee = '${NumberFormat('#,###').format(pointRatioAmount)}%';

              // bonusCash와 total도 정수로 변환 후 포맷팅
              double bonusCashAmount = double.parse(rechargeOption['bonusCash'] ?? '0');
              String bonus = '${NumberFormat('#,###').format(bonusCashAmount)} 보너스캐시';

              double cashAmount = double.parse(rechargeOption['cash'] ?? '0');
              String amount = '${NumberFormat('#,###').format(cashAmount)}원';

              String popularYn = rechargeOption['popularYn'] ?? 'N';

              bool isRecommended = false;
              if(popularYn == "Y") {
                isRecommended = true;
              }

              return CashOption(
                amount: amount,
                fee: fee,
                total: total,
                bonus: bonus,
                isRecommended : isRecommended,
                isSelected: selectedCash == rechargeOption['totalCash'].toString(), // 선택 상태
                onSelect: () {
                  setState(() {
                    selectedCash = rechargeOption['totalCash'].toString(); // 선택된 캐시 금액 설정
                    selectedAmount = rechargeOption['cash'].toString(); // 결재할 금액
                  });
                },
              );
            }).toList(),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: WitHomeTheme.wit_lightCoral,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  //onPressed: createTossPayment,
                  onPressed: () {
                    // 토스 API 호출
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Home(selectedAmount, storeName, sellerInfo['email'])),
                          //builder: (context) => tossPaymentsWebview("https://example.com/payment?orderId=12345&amount=50000")),
                    );

                    // 토스 API 호출값 받아서 이상없으면 아래 update 로직 타도록 수정 필요함
                    /*if (selectedCash != null) {
                      updateCashInfo(selectedCash!); // 선택된 캐시 금액 전달
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("캐시를 선택해 주세요.")),
                      );
                    }*/
                  },
                  child: Text('결제하기',
                    style: WitHomeTheme.title.copyWith(fontSize: 16, color: WitHomeTheme.wit_white),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: WitHomeTheme.wit_gray,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    // 취소 버튼 로직
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SellerCashHistory(sllrNo: sellerInfo["sllrNo"])),
                      //builder: (context) => tossPaymentsWebview("https://example.com/payment?orderId=12345&amount=50000")),
                    );
                  },
                  child: Text('취소',
                    style: WitHomeTheme.title.copyWith(fontSize: 16, color: WitHomeTheme.wit_white),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                print("sllrNo: " + widget.sllrNo.toString());

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CashRechargeAuto(sllrNo: 17)),
                );
              },
              child: Text(
                '자동캐시충전으로 10% 추가 캐시를 받아보세요~ >>>',
                style: WitHomeTheme.subtitle.copyWith(fontSize: 16, color: WitHomeTheme.wit_lightCoral, decoration: TextDecoration.underline),
              ),
            ),
            Text(
              'Web에서 수수료 없이 30% 저렴하게 충전하세요~',
              style: WitHomeTheme.subtitle.copyWith(fontSize: 16, color: WitHomeTheme.wit_lightCoral),
            ),
            SizedBox(height: 20),
            Text(
              '입주전 캐시 이용안내',
              style: WitHomeTheme.title.copyWith(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              '안드로이드 앱에서 충전 시 구글플레이 수수료 30%가 적용되어 결제 '
                  '금액의 70%를 캐시로 충전합니다. (예시 : 7,000캐시 상품을 구매하는 경우 10,000원 결제)\n'
                  '• 안드로이드 앱의 스토어 상품은 인앱 결제(In-App Purchase) 전용상품입니다.\n'
                  '• 안드로이드 앱의 스토어 상품은 인앱 결제(In-App Purchase) 전용상품으로, 별도의 이용약관이 적용됩니다.\n'
                  'ᆞ 충전한 캐시는 입주전의 모든 플랫폼에서 사용할 수 있습니다.\n'
                  '안드로이드 앱에서 충전한 캐시의 구매 취소는 구글플레이 고객센터에서 가능하며, 환불 규정은 구글플레이의 정책에 따릅니다.\n'
                  '입주전 고객센터로 구매 취소를 요청한 경우 구글플레이의 정책에 따라 결제수단 상의 제한이 발생할 수 있습니다. '
                  '자세한 사항은 구글플레이의 정책을 참고해주시기 바랍니다.\n'
                  '입주전 고객센터로 구매 취소를 요청한 경우 총 환불 가능 금액 전체를 대상으로 환불이 진행되며, '
                  '총 환불 가능 금액 중 부분 환불은 불가합니다. 캐시 구매 시 지급되는 보너스캐시와 이벤트로 받은 무료캐시는 '
                  '구매취소 및 환불 대상이 아닙니다.\n'
                  '보너스캐시는 일반 충전캐시가 모두 소진된 후 사용됩니다.\n'
                  '• 캐시 충전금액은 스토어에 표시되는 금액 기준이며, 결제 금액과 지급금액은 차이가 있을 수 있습니다.\n'
                  '• 캐시 구매 전 별도의 이용약관 동의가 필요합니다.\n'
                  '모든 상품은 부가세(VAT)가 포함된 가격입니다.\n'
                  '• 충전캐시의 유효기간은 마지막 접속일로부터 5년입니다.',
              style: WitHomeTheme.subtitle.copyWith(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> updateCashInfo(String totalCash, BuildContext context) async {
    // REST ID
    String restId = "updateCashInfo";

    // PARAM
    final param = jsonEncode({
      "sllrNo": "17",
      "cashNo": cashInfo['cashNo'],
      "cash": totalCash,
      "cashGbn": "01", // 01 : 포인트 충전, 02 : 견적서비스
    });

    // API 호출
    final response = await sendPostRequest(restId, param);

    if (response != null) {
      await getCashInfo(); // 캐시 정보 갱신

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("캐시가 성공적으로 충전되었습니다.")),
      );

      // 상세 화면으로 이동

      // 화면 전환: CashRecharge 화면으로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CashRecharge(sllrNo: widget.sllrNo)),
      );

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("캐시 충전에 실패했습니다.")),
      );
    }
  }
}

