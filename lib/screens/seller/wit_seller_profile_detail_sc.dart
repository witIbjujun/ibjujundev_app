import 'dart:math';
import 'package:witibju/screens/seller/wit_seller_%20grouppurchase_list_sc.dart';
import 'package:witibju/screens/seller/wit_seller_%20schedule_list_sc.dart';
import 'package:witibju/screens/seller/wit_seller_card_info_sc.dart';
import 'package:witibju/screens/seller/wit_seller_cash_history_sc.dart';
import 'package:witibju/screens/seller/wit_seller_esitmaterequest_directsetList_sc.dart';
import 'package:witibju/screens/seller/wit_seller_esitmaterequest_directset_sc.dart';
import 'package:witibju/screens/seller/wit_seller_profile_appbar_sc.dart';
import 'package:witibju/screens/seller/wit_seller_profile_detail_sc.dart';
import 'package:flutter/material.dart';
import 'package:witibju/screens/seller/wit_seller_profile_sc.dart';
import 'package:witibju/screens/seller/wit_seller_profile_view_sc.dart';
import 'dart:convert';
import 'package:witibju/util/wit_api_ut.dart';
import 'package:intl/intl.dart';


import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:witibju/screens/seller/wit_seller_community_sc.dart';
import 'package:witibju/screens/seller/wit_seller_estimaterequest_detail_sc.dart';
import 'package:witibju/screens/seller/wit_seller_estimaterequest_list_sc.dart';
import 'package:witibju/screens/seller/wit_seller_profile_modify_sc.dart';

// import '../../main_toss.dart';
import '../board/wit_board_main_sc.dart';
import '../home/wit_home_sc.dart';
import 'package:witibju/screens/home/wit_home_theme.dart';

//import '../intro.dart';
class SellerProfileDetail extends StatefulWidget {
  //final dynamic sllrNo;
  final dynamic sllrNo; // 초기 sllrNo를 받기 위한 변수
  const SellerProfileDetail({super.key, required this.sllrNo});

  @override
  State<StatefulWidget> createState() {
    //sellerInfo = this.sellerId;
    return SellerProfileDetailState();
  }
}

class SellerProfileDetailState extends State<SellerProfileDetail> {
  dynamic sellerInfo;
  String storeName = "";
  Map cashInfo = {};
  dynamic sllrNo; // 새로운 sllrNo 변수 추가
  final TextEditingController _sllrNoController = TextEditingController(); // 입력 필드 컨트롤러


  @override
  void initState() {
    super.initState();
    sllrNo = widget.sllrNo.toString(); // 초기값 설정
    print("상세 sllrNo : " + sllrNo.toString() );
    getSellerInfo(sllrNo);
    getCashInfo(sllrNo); // 초기화 시 캐시정보를 가져옵니다.
  }

  Future<void> getSellerInfo(dynamic sllrNo) async {

    String restId = "getSellerInfo";

    // PARAM
    final param = jsonEncode({
      "sllrNo": sllrNo,
    });

    // API 호출
    final response = await sendPostRequest(restId, param);

    if (response != null) {
      setState(() {
        sellerInfo = response;
        storeName = sellerInfo['storeName'];
      });
    } else {
      // 오류 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("사업자 프로필 조회가 실패하였습니다.")),
      );
    }

  }

  Future<void> getCashInfo(dynamic sllrNo) async {
    // REST ID
    String restId = "getCashInfo";

    // PARAM
    final param = jsonEncode({
      "sllrNo": sllrNo,
    });

    print("getCashInfo : " + sllrNo.toString());

    try {
      // API 호출 (사전 점검 미완료 리스트 조회)
      final response = await sendPostRequest(restId, param);

      if (response != null && response.isNotEmpty) {
        setState(() {
          cashInfo = response; // 유효한 응답일 경우 cashInfo 설정
        });
      } else {
        setState(() {
          cashInfo = {}; // 응답이 null이거나 비어있으면 빈 맵으로 초기화
        });
      }
    } catch (e) {
      print("Error occurred: $e"); // 오류 출력
      setState(() {
        cashInfo = {}; // 오류 발생 시 빈 맵으로 초기화
      });
      /*ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("서버와의 통신 중 오류가 발생했습니다.")),
      );*/
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,

        appBar: SellerAppBar(
          sllrNo: widget.sllrNo,
        ),
        body:
        SingleChildScrollView(
            child: SafeArea(
                child: Column(
                  children: <Widget>[
                    // 광고 이미지 영역
                    SizedBox(height: 10),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.13,  // 화면 높이의 18%
                      width: MediaQuery.of(context).size.width * 0.85,    // 화면 너비의 85%
                      child: Image.asset(
                        'assets/images/배너4.png', // 광고 이미지 URL
                        fit: BoxFit.contain, // 이미지 비율 유지
                      ),
                    ),

                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(10.0),
                  color: Colors.white, // 회색 바탕
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // 양쪽 끝으로 배치
                    children: [
                      // 왼쪽에 IBJU와 금액 표기 부분
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              color: WitHomeTheme.wit_gray,
                              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                              child: Text(
                                "IBJU",
                                style: WitHomeTheme.title.copyWith(fontSize: 20, color: WitHomeTheme.wit_white),
                              ),
                            ),
                            Expanded( // <<--- 여기 추가
                              child: Container(
                                alignment: Alignment.centerRight,
                                color: Colors.grey[300],
                                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                child: Text(
                                  (cashInfo['cash'] != null && cashInfo['cash'] != '')
                                      ? '${NumberFormat('#,###').format(int.parse(cashInfo['cash']))} C'
                                      : '0 C',
                                  style: WitHomeTheme.title.copyWith(fontSize: 20),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 5), // <<--- 여백 추가
                      // 오른쪽에 캐시충전 버튼
                      ElevatedButton(
                        onPressed: () {
                          print("sllrNo: " + widget.sllrNo.toString());
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SellerCashHistory(sllrNo: sellerInfo["sllrNo"]),
                            ),
                          );
                        },
                        child: Text(
                          '캐시충전',
                          style: WitHomeTheme.title.copyWith(color: WitHomeTheme.wit_white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: WitHomeTheme.wit_mediumSeaGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),



                Container(
                      margin: EdgeInsets.symmetric(vertical: 10.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          // backgroundColor: WitHomeTheme.wit_tan
                        ),
                        onPressed: () {
                          // EstimateRequestList 화면으로 이동
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (BuildContext context) {
                                return Scaffold(
                                  /*appBar: SellerAppBar(
                                    sllrNo: widget.sllrNo,
                                  ),*/
                                  appBar: AppBar(
                                    backgroundColor: WitHomeTheme.wit_gray,
                                    iconTheme: const IconThemeData(color: WitHomeTheme.wit_white),
                                    title: Text(
                                      '거래내역',
                                      style: WitHomeTheme.title.copyWith(color: WitHomeTheme.wit_white),
                                    ),
                                  ),
                                  body: Container(
                                    padding: EdgeInsets.all(16.0),
                                    child: EstimateRequestList(stat: '', sllrNo: sllrNo.toString()), // 리스트를 추가
                                  ),
                                );
                              },
                            ),
                          );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "거래내역",
                              style: WitHomeTheme.title.copyWith(color: WitHomeTheme.wit_black),
                            ),
                            SizedBox(width: 5),
                            Text(
                              '(${sellerInfo != null && sellerInfo['ingCnt'] != null ? sellerInfo['ingCnt'].toString() : '0'})',
                              style: WitHomeTheme.title.copyWith(color: WitHomeTheme.wit_lightBlue),

                            ),
                          ],
                        ),
                      ),
                    ),

                    // 견적요청목록버튼
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 10.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          // backgroundColor: WitHomeTheme.wit_lightOrchid
                        ),
                        onPressed: () {
                          // 견적 요청 리스트 팝업 띄우기
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (BuildContext context) {
                                return Scaffold(
                                  /*appBar: SellerAppBar(
                                    sllrNo: widget.sllrNo,
                                  ),*/
                                  appBar: AppBar(
                                    backgroundColor: WitHomeTheme.wit_gray,
                                    iconTheme: const IconThemeData(color: WitHomeTheme.wit_white),
                                    title: Text(
                                      '견적요청내역',
                                      style: WitHomeTheme.title.copyWith(color: WitHomeTheme.wit_white),
                                    ),
                                  ),
                                  body: Container(
                                    padding: EdgeInsets.all(16.0),
                                    child: EstimateRequestList(stat: '01', sllrNo: sllrNo.toString()), // 리스트를 추가
                                  ),
                                );
                              },
                            ),
                          );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "견적요청내역",
                              style: WitHomeTheme.title.copyWith(color: WitHomeTheme.wit_black),

                            ),
                            SizedBox(width: 5),
                            Text(
                              '(${sellerInfo != null && sellerInfo['reqCnt'] != null ? sellerInfo['reqCnt'].toString() : '0'})',
                              style: WitHomeTheme.title.copyWith(color: WitHomeTheme.wit_lightBlue),

                            ),
                          ],
                        ),

                      ),
                    ),

                    // 커뮤니티 버튼
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 10.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          // backgroundColor: WitHomeTheme.grey
                        ),
                        onPressed: () {
                          // 커뮤니티 페이지로 이동
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (BuildContext context) {
                                return Scaffold(
                                  /*appBar: SellerAppBar(
                                    sllrNo: widget.sllrNo,
                                  ),*/
                                  appBar: AppBar(
                                    backgroundColor: WitHomeTheme.wit_gray,
                                    iconTheme: const IconThemeData(color: WitHomeTheme.wit_white),
                                    title: Text(
                                      '커뮤니티',
                                      style: WitHomeTheme.title.copyWith(color: WitHomeTheme.wit_white),
                                    ),
                                  ),
                                  body: Container(
                                    padding: EdgeInsets.all(16.0),
                                    child: Board(widget.sllrNo,"C1"), // 리스트를 추가
                                  ),
                                );
                              },
                            ),
                          );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("커뮤니티",
                              style: WitHomeTheme.title.copyWith(color: WitHomeTheme.wit_black),

                            )
                          ],
                        ),
                      ),
                    ),

                    // 공동구매 관리
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 10.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50),
                            // backgroundColor: WitHomeTheme.wit_mediumSeaGreen
                        ),
                        onPressed: () {
                          // 공동구매 관리 화면으로 이동
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (BuildContext context) {
                                return Scaffold(
                                  /*appBar: SellerAppBar(
                                    sllrNo: widget.sllrNo,
                                  ),*/
                                  appBar: AppBar(
                                    backgroundColor: WitHomeTheme.wit_gray,
                                    iconTheme: const IconThemeData(color: WitHomeTheme.wit_white),
                                    title: Text(
                                      '공동구매 관리',
                                      style: WitHomeTheme.title.copyWith(color: WitHomeTheme.wit_white),
                                    ),
                                  ),
                                  body: Container(
                                    padding: EdgeInsets.all(16.0),
                                    child: SellerGroupPurchaseList(sllrNo: sllrNo.toString()), // 리스트를 추가
                                  ),
                                );
                              },
                            ),
                          );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "공동구매 관리",
                              style: WitHomeTheme.title.copyWith(color: WitHomeTheme.wit_black),

                            ),
                            SizedBox(width: 5),
                            // 나중에 DB 에서 가져오는 거로 수정필요
                            /*Text(
                              '(${sellerInfo != null && sellerInfo['reqCnt'] != null ? sellerInfo['reqCnt'].toString() : '0'})',
                              style: WitHomeTheme.title.copyWith(color: WitHomeTheme.wit_white),
                            ),*/
                            Text(
                             '(5/10)',
                              style: WitHomeTheme.title.copyWith(color: WitHomeTheme.wit_lightBlue),
                            ),
                          ],
                        ),

                      ),
                    ),

                    // 스케쥴 관리
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 10.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50),
                            // backgroundColor: WitHomeTheme.wit_lightCoral
                        ),
                        onPressed: () {
                          // 스케쥴 관리 화면으로 이동
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (BuildContext context) {
                                return Scaffold(
                                  /*appBar: SellerAppBar(
                                    sllrNo: widget.sllrNo,
                                  ),*/
                                  appBar: AppBar(
                                    backgroundColor: WitHomeTheme.wit_gray,
                                    iconTheme: const IconThemeData(color: WitHomeTheme.wit_white),
                                    title: Text(
                                      '스케쥴 관리',
                                      style: WitHomeTheme.title.copyWith(color: WitHomeTheme.wit_white),
                                    ),
                                  ),
                                  body: Container(
                                    padding: EdgeInsets.all(16.0),
                                    child: SellerScheduleList(sllrNo: sllrNo.toString()), // 리스트를 추가
                                  ),
                                );
                              },
                            ),
                          );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "스케쥴 관리",
                              style: WitHomeTheme.title.copyWith(color: WitHomeTheme.wit_black),
                            ),
                          ],
                        ),

                      ),
                    ),

                    // 결재정보 등록 버튼
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 10.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          // backgroundColor: WitHomeTheme.wit_lightGoldenrodYellow,

                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    CardInfo(sllrNo: sllrNo.toString())),
                          );
                        },
                        child: Container(
                          child: Center(
                            child: Text(
                              "결제정보 등록",
                              style: WitHomeTheme.title.copyWith(color: WitHomeTheme.wit_black),

                            ),
                          ),
                        ),
                      ),
                    ),
                    // 거래내역 버튼
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 10.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          // backgroundColor: WitHomeTheme.wit_lightSteelBlue,

                        ),
                        onPressed: () {
                          // 버튼 클릭 시 수행할 작업 추가
                          // 가입정보 변경 페이지로 이동
                          String aaa = sellerInfo["sllrNo"].toString();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SellerProfileModify(sllrNo: sellerInfo["sllrNo"].toString()),
                            ),
                          );
                        },
                        child: Container(
                          child: Center(
                            child: Text(
                              "가입정보 변경",
                              style: WitHomeTheme.title.copyWith(color: WitHomeTheme.wit_black),

                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 10.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          // backgroundColor: WitHomeTheme.wit_lightGreen,

                        ),
                        onPressed: () {
                          // 버튼 클릭 시 수행할 작업 추가
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EstimateRequestDirectList(sllrNo: sellerInfo["sllrNo"])),
                          );
                        },
                        child: Container(
                          child: Center(
                            child: Text(
                              "바로견적 서비스",
                              style: WitHomeTheme.title.copyWith(color: WitHomeTheme.wit_black),

                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 10.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          // backgroundColor: WitHomeTheme.wit_lightBlue,

                        ),
                        onPressed: () {
                          // 버튼 클릭 시 수행할 작업 추가
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SellerProfileView(sllrNo: sellerInfo["sllrNo"])),
                          );
                        },
                        child: Container(
                          child: Center(
                            child: Text(
                              "파트너 프로필",
                              style: WitHomeTheme.title.copyWith(color: WitHomeTheme.wit_black),

                            ),
                          ),
                        ),
                      ),
                    ),

                    Container(
                      margin: EdgeInsets.symmetric(vertical: 10.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          // backgroundColor: WitHomeTheme.wit_lightCoral,

                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (BuildContext context) {
                                return Scaffold(
                                  /*appBar: SellerAppBar(
                                    sllrNo: widget.sllrNo,
                                  ),*/
                                  appBar: AppBar(
                                    backgroundColor: WitHomeTheme.wit_gray,
                                    iconTheme: const IconThemeData(color: WitHomeTheme.wit_white),
                                    title: Text(
                                      '공지사항',
                                      style: WitHomeTheme.title.copyWith(color: WitHomeTheme.wit_white),
                                    ),
                                  ),
                                  body: Container(
                                    padding: EdgeInsets.all(16.0),
                                    child: Board(widget.sllrNo,"C1"), // 리스트를 추가
                                  ),
                                );
                              },
                            ),
                          );

                        },
                        child: Container(
                          child: Center(
                            child: Text(
                              "공지사항",
                              style: WitHomeTheme.title.copyWith(color: WitHomeTheme.wit_black),

                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
            )
        )
    );
  }
}
