import 'dart:math';
import 'package:witibju/screens/seller/wit_seller_card_register_sc.dart';
import 'package:witibju/screens/seller/wit_seller_grouppurchase_list_sc.dart';
import 'package:witibju/screens/seller/wit_seller_schedule_list_sc.dart';
import 'package:witibju/screens/seller/wit_seller_aptSubscribe_sc.dart';
import 'package:witibju/screens/seller/wit_seller_card_info_sc.dart';
import 'package:witibju/screens/seller/wit_seller_cash_history_sc.dart';
import 'package:witibju/screens/seller/wit_seller_esitmaterequest_directsetList_sc.dart';
import 'package:witibju/screens/seller/wit_seller_esitmaterequest_directset_sc.dart';
import 'package:witibju/screens/seller/wit_seller_profile_appbar_sc.dart';
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
import '../../main.dart';
import '../board/wit_board_main_sc.dart';
import '../common/wit_tableCalendar_sc.dart';
import '../common/wit_tableCalendar_widget.dart';
import '../home/widgets/wit_home_widgets2.dart';
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

class SellerProfileDetailState extends State<SellerProfileDetail> with RouteAware {
  dynamic sellerInfo;
  String storeName = "";
  Map cashInfo = {};
  dynamic sllrNo; // 새로운 sllrNo 변수 추가
  final TextEditingController _sllrNoController =
  TextEditingController(); // 입력 필드 컨트롤러
  late final DateTime? _selectedDate; // 선택된 날짜를 여기에 설정
  String appbarYn = "";
  // 아파트구독 리스트
  List<dynamic> subscribeAptList= [];

  @override
  void initState() {
    super.initState();
    sllrNo = widget.sllrNo.toString(); // 초기값 설정
    // 초기화 메서드 호출
    fetchData();
  }

  void fetchData() {
    // sllrNo가 설정된 경우에만 데이터를 가져옴
    if (sllrNo != null) {
      // API 호출 등의 초기화 로직 구현
      getSellerInfo(sllrNo);
      getSubscribeAptList(sllrNo);
      // getCashInfo(sllrNo); // 초기화 시 캐시정보를 가져옵
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!); // Route 감시 시작
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this); // Route 감시 해제
    super.dispose();
  }

  @override
  void didPopNext() {
    // 이 화면으로 다시 돌아왔을 때 실행됨
    fetchData();
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

  // 아파트 구독 리스트
  Future<void> getSubscribeAptList(dynamic sllrNo) async {
    String restId = "getSubscribeAptList";

    // PARAM
    final param = jsonEncode({
      "sllrNo": sllrNo,
      "searchType": "S",
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



  /*Future<void> getCashInfo(dynamic sllrNo) async {
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
      */ /*ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("서버와의 통신 중 오류가 발생했습니다.")),
      );*/ /*
    }
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: WitHomeTheme.wit_white, // Scaffold의 배경색을 하얀색으로 설정
        resizeToAvoidBottomInset: false,
        appBar: SellerAppBar(
          sllrNo: widget.sllrNo,
          onSllrNoChanged: (newSllrNo) {
            setState(() {
              sllrNo = newSllrNo; // sllrNo 업데이트
              fetchData();
            });
          },
        ),
        body: Container(
            child: SingleChildScrollView(
                child: SafeArea(
                    child: Column(
                      children: <Widget>[
                        // 광고 이미지 영역
                        Padding(
                          padding: EdgeInsets.only(top: 12.0, left: 12),
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.25,
                            width: MediaQuery.of(context).size.width * 0.95,
                            child: Stack(
                              children: [
                                Image.asset(
                                  'assets/images/판매자 환영.png',
                                  fit: BoxFit.contain,
                                ),
                                Positioned(
                                  left: 270, // 왼쪽 위치 (전체 너비의 20%)
                                  bottom: 12.0, // 아래쪽 위치 (20 픽셀)
                                  child: Text(
                                    '#부자되세요.',
                                    style: WitHomeTheme.subtitle.copyWith(fontSize: 14, color: WitHomeTheme.wit_white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // 캐시 정보 영역
                        /*Container(
              width: 370,
              height: 100,
              // padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 0.0, bottom: 0.0),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/캐시.png'),
                  // fit: BoxFit.cover,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                // 양쪽 끝으로 배치
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.only(
                          left: 50.0, right: 20.0, top: 0.0, bottom: 0.0),
                      alignment: Alignment.centerLeft,
                      //color: Colors.grey[300],
                      //padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      child: Text(
                        (cashInfo['cash'] != null && cashInfo['cash'] != '')
                            ? '${NumberFormat('#,###').format(int.parse(cashInfo['cash']))} C'
                            : '0 C',
                        style: WitHomeTheme.title.copyWith(fontSize: 18),
                        overflow: TextOverflow.ellipsis, // 텍스트 오버플로우 처리
                      ),
                    ),
                  ),
                  SizedBox(width: 5),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SellerCashHistory(sllrNo: widget.sllrNo),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.only(right: 10.0, top: 0.0, bottom: 0.0),
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: Size(80, 30), // 최소 크기 설정
                    ),
                    child: Ink(
                      width: 80,
                      height: 25,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/캐시충전.png'),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ],
              ),
            ),*/

                        // 내 구독 APT
                        SizedBox(height: 10),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 20.0), // 좌우 패딩 추가
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween, // 좌우 정렬
                            children: [
                              Text(
                                '내 구독 APT',
                                style: WitHomeTheme.title.copyWith(fontSize: 20),

                              ),

                              TextButton(
                                onPressed: () {
                                  // TODO: 다른 화면으로 이동하는 코드 작성
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (BuildContext context) {
                                        return Scaffold(
                                          appBar: AppBar(
                                            backgroundColor: WitHomeTheme.wit_black,
                                            iconTheme: const IconThemeData(
                                                color: WitHomeTheme.wit_white),
                                            title: Text(
                                              '입주 APT',
                                              style: WitHomeTheme.title
                                                  .copyWith(color: WitHomeTheme.wit_white),
                                            ),
                                          ),
                                          body: Container(
                                            child: SellerAptSubscribe(
                                                sllrNo: sllrNo.toString()), // 리스트를 추가
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero, // 기본 패딩 제거
                                  minimumSize: Size.zero, // 최소 크기 제거
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap, // 터치 영역 최소 크기 제거
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      '구독하기',
                                      style: WitHomeTheme.title.copyWith(fontSize: 16, color: WitHomeTheme.wit_lightGreen),
                                    ),
                                    Icon(Icons.arrow_right, color: WitHomeTheme.wit_lightGreen), // 아이콘 추가
                                  ],
                                ),
                              ),

                            ],
                          ),
                        ),

                        if (subscribeAptList.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 20.0, top: 8.0),
                            child: Text(
                              '구독 중인 아파트가 없습니다.',
                              style: TextStyle(fontSize: 16, color: WitHomeTheme.wit_black),
                            ),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                // 줄 수 계산
                                int rowCount = (subscribeAptList.length / 2).ceil();
                                print("rowCount :" + rowCount.toString());
                                // 전체 높이 계산 (한 줄당 높이를 50으로 가정)
                                double totalHeight = rowCount * 50;

                                return SizedBox(
                                  height: totalHeight, // 계산된 높이 적용
                                  child: Column(
                                    children: List.generate(rowCount, (index) {
                                      // 각 줄에 들어갈 아파트 목록
                                      List<dynamic> rowApts = subscribeAptList.sublist(
                                        index * 2,
                                        (index * 2 + 2) <= subscribeAptList.length ? index * 2 + 2 : subscribeAptList.length,
                                      );

                                      return Row(
                                        children: [
                                          ...rowApts.map((apt) => Expanded( // Expanded 추가
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                              child: Chip(
                                                backgroundColor: WitHomeTheme.wit_black,
                                                label: Center(
                                                  child: Text(
                                                    apt['aptName'],
                                                    style: WitHomeTheme.subtitle.copyWith(fontSize: 14, color: WitHomeTheme.wit_white),
                                                  ),
                                                ), // Center 추가
                                                shape: RoundedRectangleBorder( // 테두리 없애기
                                                  side: BorderSide(
                                                    color: Colors.transparent, // 테두리 색상을 투명하게 설정
                                                    width: 0.0, // 테두리 두께를 0으로 설정
                                                  ),
                                                  borderRadius: BorderRadius.circular(12.0), // 원하는 radius 값으로 조절
                                                ),
                                              ),
                                            ),
                                          )),
                                          // 마지막 줄에 항목이 하나만 있는 경우 남는 공간을 채우는 SizedBox 추가
                                          if (rowApts.length == 1 && index == rowCount - 1)
                                            Expanded(child: SizedBox.shrink()),
                                        ],
                                      );
                                    }),
                                  ),
                                );
                              },
                            ),
                          ),






                        SizedBox(height: 20), // 레이블과 카드 사이의 간격
                        Container(
                          padding: EdgeInsets.only(left: 20.0), // 전체 패딩 20
                          alignment: Alignment.centerLeft, // 왼쪽 정렬
                          child: Text(
                            '거래관리',
                            style: WitHomeTheme.title.copyWith(fontSize: 20),
                          ),
                        ),
                        SizedBox(height: 12), // 레이블과 카드 사이의 간격
                        // 스케쥴 관리
                        TextButton(
                          onPressed: () {
                            // 스케쥴 관리 화면으로 이동
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (BuildContext context) {
                                  return Scaffold(
                                    body: Container(
                                      child: TableCalenderMain(
                                          stat: "", sllrNo: widget.sllrNo.toString()),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: WitHomeTheme.wit_white,
                            padding: EdgeInsets.only(left: 20.0, top: 6.0, bottom: 6.0, right: 0.0), // 왼쪽 20, 상하 0
                            alignment: Alignment.centerLeft,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center, // 세로 방향 가운데 정렬
                            children: [
                              Text(
                                "스케쥴 관리",
                                style: WitHomeTheme.subtitle.copyWith(
                                    fontSize: 14, color: WitHomeTheme.wit_black),
                              ),
                              Padding(
                                padding: EdgeInsets.only(right: 20.0),
                                // 우측 패딩 20
                                child: Icon(Icons.arrow_forward_ios,
                                    size: 14, color: WitHomeTheme.wit_black),
                              ),
                            ],
                          ),
                        ),

                        // 공동구매 관리
                        TextButton(
                          onPressed: () {
                            // 공동구매 관리 화면으로 이동
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (BuildContext context) {
                                  return Scaffold(
                                    appBar: AppBar(
                                      backgroundColor: WitHomeTheme.wit_black,
                                      iconTheme: const IconThemeData(
                                          color: WitHomeTheme.wit_white),
                                      title: Text(
                                        '공동구매 관리',
                                        style: WitHomeTheme.title
                                            .copyWith(color: WitHomeTheme.wit_white),
                                      ),
                                    ),
                                    body: Container(
                                      child: SellerGroupPurchaseList(
                                          sllrNo: sllrNo.toString()), // 리스트를 추가
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: WitHomeTheme.wit_white,
                            padding: EdgeInsets.only(left: 20.0, top: 6.0, bottom: 6.0, right: 0.0), // 왼쪽 20, 상하 0
                            alignment: Alignment.centerLeft,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center, // 세로 방향 가운데 정렬
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "공동구매 관리",
                                    style: WitHomeTheme.subtitle.copyWith(
                                        fontSize: 14, color: WitHomeTheme.wit_black),
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    '(5/10)',
                                    style: WitHomeTheme.subtitle.copyWith(
                                        fontSize: 14, color: WitHomeTheme.wit_lightBlue),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.only(right: 20.0),
                                child: Icon(Icons.arrow_forward_ios,
                                    size: 14, color: WitHomeTheme.wit_black),
                              ),
                            ],
                          ),
                        ),

                        // 견적요청내역
                        TextButton(
                          onPressed: () {
                            // 견적 요청 리스트 팝업 띄우기
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (BuildContext context) {
                                  return Scaffold(
                                    appBar: AppBar(
                                      backgroundColor: WitHomeTheme.wit_black,
                                      iconTheme: const IconThemeData(
                                          color: WitHomeTheme.wit_white),
                                      title: Text(
                                        '받은 요청',
                                        style: WitHomeTheme.title
                                            .copyWith(color: WitHomeTheme.wit_white),
                                      ),
                                    ),
                                    body: Container(
                                      child: EstimateRequestList(
                                          stat: '01', sllrNo: sllrNo.toString()), // 리스트를 추가
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: WitHomeTheme.wit_white,
                            padding: EdgeInsets.only(left: 20.0, top: 6.0, bottom: 6.0, right: 0.0), // 왼쪽 20, 상하 0
                            alignment: Alignment.centerLeft,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "받은 요청",
                                    style: WitHomeTheme.subtitle.copyWith(
                                        fontSize: 14, color: WitHomeTheme.wit_black),
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    '(${sellerInfo != null && sellerInfo['reqCnt'] != null ? sellerInfo['reqCnt'].toString() : '0'})',
                                    style: WitHomeTheme.subtitle.copyWith(
                                        fontSize: 14, color: WitHomeTheme.wit_lightBlue),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.only(right: 20.0),
                                child: Icon(Icons.arrow_forward_ios,
                                    size: 14, color: WitHomeTheme.wit_black),
                              ),
                            ],
                          ),
                        ),

                        // 거래내역
                        TextButton(
                          onPressed: () {
                            // EstimateRequestList 화면으로 이동
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (BuildContext context) {
                                  return Scaffold(
                                    appBar: AppBar(
                                      backgroundColor: WitHomeTheme.wit_black,
                                      iconTheme: const IconThemeData(
                                          color: WitHomeTheme.wit_white),
                                      title: Text(
                                        '진행중',
                                        style: WitHomeTheme.title
                                            .copyWith(color: WitHomeTheme.wit_white),
                                      ),
                                    ),
                                    body: Container(
                                      child: EstimateRequestList(
                                          stat: '', sllrNo: sllrNo.toString()), // 리스트를 추가
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: WitHomeTheme.wit_white,
                            padding: EdgeInsets.only(left: 20.0, top: 6.0, bottom: 6.0, right: 0.0), // 왼쪽 20, 상하 0
                            alignment: Alignment.centerLeft,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "진행중",
                                    style: WitHomeTheme.subtitle.copyWith(
                                        fontSize: 14, color: WitHomeTheme.wit_black),
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    '(${sellerInfo != null && sellerInfo['ingCnt'] != null ? sellerInfo['ingCnt'].toString() : '0'})',
                                    style: WitHomeTheme.subtitle.copyWith(
                                        fontSize: 14, color: WitHomeTheme.wit_lightBlue),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.only(right: 20.0),
                                child: Icon(Icons.arrow_forward_ios,
                                    size: 14, color: WitHomeTheme.wit_black),
                              ),
                            ],
                          ),
                        ),

                        // 바로견적 서비스
                        TextButton(
                          onPressed: () {
                            // 버튼 클릭 시 수행할 작업 추가
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EstimateRequestDirectList(
                                      sllrNo: sllrNo.toString())),
                            );
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: WitHomeTheme.wit_white,
                            padding: EdgeInsets.only(left: 20.0, top: 6.0, bottom: 6.0, right: 0.0), // 왼쪽 20, 상하 0
                            alignment: Alignment.centerLeft,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "바로견적 서비스",
                                style: WitHomeTheme.subtitle.copyWith(
                                    fontSize: 14, color: WitHomeTheme.wit_black),
                              ),
                              Padding(
                                padding: EdgeInsets.only(right: 20.0),
                                child: Icon(Icons.arrow_forward_ios,
                                    size: 14, color: WitHomeTheme.wit_black),
                              ),
                            ],
                          ),
                        ),


                        // 내 정보
                        Container(
                          padding: EdgeInsets.only(left: 20.0, top: 20),
                          // 전체 패딩 20
                          alignment: Alignment.centerLeft,
                          // 왼쪽 정렬
                          child: Text(
                            '내 정보',
                            style: WitHomeTheme.title.copyWith(fontSize: 20),
                          ),
                        ),

                        // 파트너 프로필
                        TextButton(
                          onPressed: () {
                            // 버튼 클릭 시 수행할 작업 추가
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SellerProfileView(
                                      sllrNo: sllrNo.toString(), appbarYn: 'Y')),
                            );
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: WitHomeTheme.wit_white,
                            padding: EdgeInsets.only(left: 20.0, top: 6.0, bottom: 6.0, right: 0.0), // 왼쪽 20, 상하 0
                            alignment: Alignment.centerLeft,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "파트너 프로필",
                                style: WitHomeTheme.subtitle.copyWith(
                                    fontSize: 14, color: WitHomeTheme.wit_black),
                              ),
                              Padding(
                                padding: EdgeInsets.only(right: 20.0),
                                child: Icon(Icons.arrow_forward_ios,
                                    size: 14, color: WitHomeTheme.wit_black),
                              ),
                            ],
                          ),
                        ),

                        // 가입정보 변경
                        TextButton(
                          onPressed: () {
                            // 버튼 클릭 시 수행할 작업 추가
                            // 가입정보 변경 페이지로 이동
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SellerProfileModify(
                                    sllrNo: sellerInfo["sllrNo"].toString()),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: WitHomeTheme.wit_white,
                            padding: EdgeInsets.only(left: 20.0, top: 6.0, bottom: 6.0, right: 0.0), // 왼쪽 20, 상하 0
                            alignment: Alignment.centerLeft,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "가입정보 변경",
                                style: WitHomeTheme.subtitle.copyWith(
                                    fontSize: 14, color: WitHomeTheme.wit_black),
                              ),
                              Padding(
                                padding: EdgeInsets.only(right: 20.0),
                                child: Icon(Icons.arrow_forward_ios,
                                    size: 14, color: WitHomeTheme.wit_black),
                              ),
                            ],
                          ),
                        ),

                        // 결제정보 등록
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      CardRegisterWebView(customerUid: sllrNo, amount: 0, storeName: sellerInfo['storeName'],),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: WitHomeTheme.wit_white,
                            padding: EdgeInsets.only(left: 20.0, top: 6.0, bottom: 6.0, right: 0.0), // 왼쪽 20, 상하 0
                            alignment: Alignment.centerLeft,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "결제정보 등록",
                                style: WitHomeTheme.subtitle.copyWith(
                                    fontSize: 14, color: WitHomeTheme.wit_black),
                              ),
                              Padding(
                                padding: EdgeInsets.only(right: 20.0),
                                child: Icon(Icons.arrow_forward_ios,
                                    size: 14, color: WitHomeTheme.wit_black),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          padding: EdgeInsets.only(left: 20.0, top: 20),
                          // 전체 패딩 20
                          alignment: Alignment.centerLeft,
                          // 왼쪽 정렬
                          child: Text(
                            '고객지원',
                            style: WitHomeTheme.title.copyWith(fontSize: 20),
                          ),
                        ),

                        // 업체후기
                        TextButton(
                          onPressed: () {
                            // 업체후기 페이지로 이동
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (BuildContext context) {
                                  return Scaffold(
                                    body: Container(
                                      child: Board(widget.sllrNo, "C1"), // 리스트를 추가
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: WitHomeTheme.wit_white,
                            padding: EdgeInsets.only(left: 20.0, top: 6.0, bottom: 6.0, right: 0.0), // 왼쪽 20, 상하 0
                            alignment: Alignment.centerLeft,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "업체후기",
                                style: WitHomeTheme.subtitle.copyWith(
                                    fontSize: 14, color: WitHomeTheme.wit_black),
                              ),
                              Padding(
                                padding: EdgeInsets.only(right: 20.0),
                                child: Icon(Icons.arrow_forward_ios,
                                    size: 14, color: WitHomeTheme.wit_black),
                              ),
                            ],
                          ),
                        ),

                        //공지사항
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (BuildContext context) {
                                  return Scaffold(
                                    body: Container(
                                      child: Board(widget.sllrNo, "C1"), // 리스트를 추가
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: WitHomeTheme.wit_white,
                            padding: EdgeInsets.only(left: 20.0, top: 6.0, bottom: 6.0, right: 0.0), // 왼쪽 20, 상하 0
                            alignment: Alignment.centerLeft,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "공지사항",
                                style: WitHomeTheme.subtitle.copyWith(
                                    fontSize: 14, color: WitHomeTheme.wit_black),
                              ),
                              Padding(
                                padding: EdgeInsets.only(right: 20.0),
                                child: Icon(Icons.arrow_forward_ios,
                                    size: 14, color: WitHomeTheme.wit_black),
                              ),
                            ],
                          ),
                        ),

                      ],
                    )))));
  }
}