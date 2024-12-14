import 'dart:math';
import 'package:witibju/screens/seller/wit_seller_card_info_sc.dart';
import 'package:witibju/screens/seller/wit_seller_cash_history_sc.dart';
import 'package:witibju/screens/seller/wit_seller_esitmaterequest_directsetList_sc.dart';
import 'package:witibju/screens/seller/wit_seller_esitmaterequest_directset_sc.dart';
import 'package:witibju/screens/seller/wit_seller_profile_detail_sc.dart';
import 'package:flutter/material.dart';
import 'package:witibju/screens/seller/wit_seller_profile_sc.dart';
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
//import '../intro.dart';
class SellerProfileDetail extends StatefulWidget {
  //final dynamic sllrNo;
  final dynamic sllrNo; // 초기 sllrNo를 받기 위한 변수
  const SellerProfileDetail({Key? key, required this.sllrNo}) : super(key: key);

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
    sllrNo = widget.sllrNo; // 초기값 설정
    getSellerInfo(sllrNo);
    getCashInfo(sllrNo); // 초기화 시 캐시정보를 가져옵니다.
  }

  Future<void> getSellerInfo(dynamic sllrNo) async {

    String restId = "getSellerInfo";

    print("aaaaa:" + sllrNo.toString());
    int sllrNoInt = int.tryParse(sllrNo.toString()) ?? 0; // 기본값은 0

    // PARAM
    final param = jsonEncode({
      "sllrNo": sllrNoInt,
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
        appBar: AppBar(
          leadingWidth: 90,
          leading: Container(height: double.infinity,
              child: Center(child: Text(
                  storeName, style: TextStyle(fontSize: 15, color: Colors.black),
                  textAlign: TextAlign.center))),
          //IconButton(onPressed: () {}, icon: Icon(Icons.menu)), // 왼쪽 메뉴버튼
          title: Text("Profile"),
          centerTitle: true,
          backgroundColor: Colors.lightBlue,
          actions: [
            // 입력 필드 추가
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: SizedBox(
                width: 100, // 입력 필드의 너비 설정
                child: TextField(
                  controller: _sllrNoController,
                  decoration: InputDecoration(
                    hintText: 'sllrNo 입력',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number, // 숫자 키패드로 설정
                ),
              ),
            ),
            // 버튼 추가
            IconButton(
              onPressed: () {
                // 입력된 값을 sllrNo로 변경
                dynamic newSllrNo = _sllrNoController.text;
                if (newSllrNo.isNotEmpty) {
                  setState(() {
                    sllrNo = int.tryParse(newSllrNo); // sllrNo 업데이트
                    getSellerInfo(sllrNo); // 화면 재조회
                    getCashInfo(sllrNo); // 화면 재조회
                  });
                }
              },
              icon: Icon(Icons.search),
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()), // HomeScreen으로 이동
                );
              },
              icon: Icon(Icons.perm_identity),
            ),
            IconButton(onPressed: () {}, icon: Icon(Icons.mail)),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SellerProfile()), // HomeScreen으로 이동
                );
              },
              icon: Icon(Icons.logout),
            ),
          ],
        ),
        body:
        SingleChildScrollView(
            child: SafeArea(
                child: Column(
                  children: <Widget>[
                    // 광고 이미지 영역
                    Container(
                      width: double.infinity,
                      height: 200,
                      child: Image.asset(
                        'assets/seller/aaa.jpg', // 광고 이미지 URL
                        fit: BoxFit.contain,
                      ),
                    ),
                    // 입주포인트 영역
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(10.0),
                      color: Colors.white, // 회색 바탕
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "입주포인트",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                              ElevatedButton(onPressed: () {

                                print("sllrNo: " + widget.sllrNo.toString());

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          SellerCashHistory(sllrNo: sellerInfo["sllrNo"])),
                                );
                              },

                                child: Text('캐시충전'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color.fromARGB(
                                      255, 3, 199, 90),
                                  surfaceTintColor: Color.fromARGB(
                                      255, 3, 199, 90),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),

                                ),

                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black,
                                width: 2.0,
                              ),
                              color: Colors.white,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  color: Colors.grey,
                                  padding: EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 10),
                                  child: Text(
                                    "IBJU",
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                    ),
                                  ),

                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Container(
                                    alignment: Alignment.centerRight,
                                    color: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                        vertical: 5, horizontal: 10),
                                    child: Text(
                                      (cashInfo['cash'] != null && cashInfo['cash'] != '')
                                          ? '${NumberFormat('#,###').format(int.parse(cashInfo['cash']))} C'
                                          : '0 C',
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 거래내역 버튼
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 10.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                        ),
                        onPressed: () {
                          // 견적 요청 리스트 팝업 띄우기
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return Dialog(
                                insetPadding: EdgeInsets.zero, // 여백을 제거하여 가로를 꽉 차게
                                shape: RoundedRectangleBorder( // 모서리를 둥글게 설정
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Container(
                                  width: double.infinity, // 가로 꽉 차게
                                  height: MediaQuery.of(context).size.height * 0.8, // 세로 꽉 차게
                                  padding: EdgeInsets.all(16.0), // 내부 여백 추가
                                  child: SingleChildScrollView( // 스크롤 가능하게 설정
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text("거래내역목록", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                        SizedBox(height: 10), // 제목과 리스트 사이에 간격 추가
                                        EstimateRequestList(stat: '', sllrNo: sllrNo.toString(),), // 리스트를 추가
                                        SizedBox(height: 10), // 리스트와 버튼 사이에 간격 추가
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(); // 팝업 닫기
                                          },
                                          child: Text("닫기"),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("거래내역"),
                            SizedBox(width: 5),
                            Text(
                              ('(${sellerInfo != null && sellerInfo['ingCnt'] != null ? sellerInfo['ingCnt'].toString() : '0'})'),
                              style: TextStyle(
                                  color: Colors.blue, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // 거래내역 버튼
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 10.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                        ),
                        onPressed: () {
                          // 견적 요청 리스트 팝업 띄우기
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return Dialog(
                                insetPadding: EdgeInsets.zero, // 여백을 제거하여 가로를 꽉 차게
                                shape: RoundedRectangleBorder( // 모서리를 둥글게 설정
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Container(
                                  width: double.infinity, // 가로 꽉 차게
                                  height: MediaQuery.of(context).size.height * 0.8, // 세로 꽉 차게
                                  padding: EdgeInsets.all(16.0), // 내부 여백 추가
                                  child: SingleChildScrollView( // 스크롤 가능하게 설정
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text("견적요청목록", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                        SizedBox(height: 10), // 제목과 리스트 사이에 간격 추가
                                        EstimateRequestList(stat: '01', sllrNo: sllrNo.toString(),), // 리스트를 추가
                                        SizedBox(height: 10), // 리스트와 버튼 사이에 간격 추가
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(); // 팝업 닫기
                                          },
                                          child: Text("닫기"),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("견적요청내역"),
                            SizedBox(width: 5),
                            Text(
                              ('(${sellerInfo != null && sellerInfo['reqCnt'] != null ? sellerInfo['reqCnt'].toString() : '0'})'),
                              style: TextStyle(
                                  color: Colors.blue, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // 거래내역 버튼
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 10.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                        ),
                        onPressed: () {
                          // 커뮤니티 페이지로 이동
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Board(widget.sllrNo,"C1")),
                          );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("업체후기"),
                          ],
                        ),
                      ),
                    ),
                    // 거래내역 버튼
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 10.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    CardInfo()),
                          );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("결재정보등록"),
                          ],
                        ),
                      ),
                    ),
                    // 거래내역 버튼
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 10.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                        ),
                        onPressed: () {
                          // 버튼 클릭 시 수행할 작업 추가
                          // 가입정보 변경 페이지로 이동
                          int sllrNoForModity = widget.sllrNo;
                          String aaa = widget.sllrNo.toString();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SellerProfileModify(sllrNo: sellerInfo["sllrNo"])),
                            ), // 이 줄에 괄호 추가
                          );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("가입정보 변경"),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 10.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                        ),
                        onPressed: () {
                          // 버튼 클릭 시 수행할 작업 추가
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EstimateRequestDirectList(sllrNo: sellerInfo["sllrNo"])),
                          );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("바로견적 서비스"),
                          ],
                        ),
                      ),
                    ),
                    // 거래내역 버튼
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 10.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                        ),
                        onPressed: () {
                          // 커뮤니티 페이지로 이동
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Board(widget.sllrNo,"C1")),
                          );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("공지사항"),
                          ],
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
