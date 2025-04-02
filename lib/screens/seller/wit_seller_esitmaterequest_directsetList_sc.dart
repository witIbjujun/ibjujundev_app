import 'dart:convert';
import 'package:witibju/screens/seller/wit_seller_cash_recharge_sc.dart';
import 'package:witibju/screens/seller/wit_seller_esitmaterequest_directsetModify_sc.dart';
import 'package:witibju/screens/seller/wit_seller_esitmaterequest_directset_sc.dart';
import 'package:flutter/material.dart';
import 'package:witibju/screens/seller/wit_seller_estimaterequest_detail_sc.dart';
import 'package:witibju/screens/seller/wit_seller_profile_appbar_sc.dart';
import 'package:witibju/screens/seller/wit_seller_profile_view_sc.dart';
import '../../util/wit_api_ut.dart';
import '../home/wit_home_theme.dart';

class EstimateRequestDirectList extends StatefulWidget {
  final dynamic sllrNo;
  const EstimateRequestDirectList({Key? key, required this.sllrNo}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return EstimateRequestDirectListState();
  }
}

class EstimateRequestDirectListState extends State<EstimateRequestDirectList> {
  dynamic sellerInfo;
  String storeName = "";
  List<dynamic> directEstimateSetList = [];
  TextEditingController estimateContentController = TextEditingController();
  Map directEstimateSetInfo = {};

  @override
  void initState() {
    super.initState();
    getSellerInfo(widget.sllrNo);
    getAutoEstimateList(widget.sllrNo);
    getDirectEstimateSetInfo(widget.sllrNo);
  }

  bool _isChecked = false; // 체크박스 상태 관리

  void _onCheckboxChanged(bool? value) {
    setState(() {
      _isChecked = value ?? false;
    });

    // 체크박스가 체크되었을 때 프로필 불러오는 로직 추가
    if (_isChecked) {
      _loadProfile();
    }
  }

  void _loadProfile() {
    // 여기에 프로필을 불러오는 로직 추가
    print("프로필을 불러옵니다."); // 예시로 콘솔에 출력
  }

  Future<void> getSellerInfo(dynamic sllrNo) async {
    String restId = "getSellerInfo";
    final param = jsonEncode({"sllrNo": sllrNo});
    final response = await sendPostRequest(restId, param);

    if (response != null) {
      setState(() {
        sellerInfo = response;
        storeName = sellerInfo['storeName'];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("사업자 프로필 조회가 실패하였습니다.")),
      );
    }
  }

  // [서비스] 바로 견적 설정 정보 조회
  Future<void> getDirectEstimateSetInfo(dynamic esdrNo) async {
    // REST ID
    String restId = "getDirectEstimateSetInfo";

    // PARAM
    final param = jsonEncode({
      "sllrNo": widget.sllrNo, // 바로견적 설정 번호
    });

    // API 호출 (바로견적 설정 정보 조회)
    final _directEstimateSetInfo = await sendPostRequest(restId, param);

    // 결과 셋팅
    if (_directEstimateSetInfo is Map<String, dynamic>) {
      setState(() {
        directEstimateSetInfo = _directEstimateSetInfo;
        estimateContentController.text = directEstimateSetInfo['content'];
      });
    }
    else if(_directEstimateSetInfo != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("바로견적 설정 정보가 없습니다..")),
      );
    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("바로 견적 설정 정보 조회가 실패하였습니다.")),
      );
    }
  }

  Future<void> getAutoEstimateList(dynamic sllrNo) async {
    String restId = "getAutoEstimateList";
    final param = jsonEncode({"sllrNo": widget.sllrNo});
    final response = await sendPostRequest(restId, param);

    if (response != null) {
      setState(() {
        directEstimateSetList = response;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("바로견적 설정 목록 조회가 실패하였습니다.")),
      );
    }
  }

  // [서비스] 바로 견적 설정 정보 저장
  Future<void> insertDirectEstimateSetInfo() async {
    // REST ID
    String restId = "insertDirectEstimateSetInfo";

    // PARAM
    final param = jsonEncode({
      "sllrNo": widget.sllrNo, // stat을 사용하여 API에 전달
      "content": estimateContentController.text, // 견적 설명
      "categoryId": sellerInfo['serviceItem'],
    });

    print("1231132123 : " + widget.sllrNo.toString());

    // API 호출 (바로견적 설정 정보 조회)
    final response = await sendPostRequest(restId, param);

    // 결과 셋팅
    if (response != null) {
      setState(() {
        // 사용자에게 성공 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("바로 견적 설정 정보가 저장되었습니다.")),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("바로 견적 설정 정보 수정이 실패하였습니다.")),
      );
    }
  }

  // [서비스] 바로 견적 설정 정보 수정
  Future<void> updateDirectEstimateSetInfo() async {
    // REST ID
    String restId = "updateDirectEstimateSetInfo";

    // PARAM
    final param = jsonEncode({
      "sllrNo": widget.sllrNo, // stat을 사용하여 API에 전달
      "content": estimateContentController.text, // 견적 설명
    });

    // API 호출 (바로견적 설정 정보 조회)
    final response = await sendPostRequest(restId, param);

    // 결과 셋팅
    if (response != null) {
      setState(() {
        // 사용자에게 성공 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("바로 견적 설정 정보가 수정되었습니다.")),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("바로 견적 설정 정보 수정이 실패하였습니다.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WitHomeTheme.wit_white,

      appBar: AppBar(
        backgroundColor: WitHomeTheme.wit_black,
        iconTheme: const IconThemeData(color: WitHomeTheme.wit_white),
        title: Text(
          '바로견적',
          style: WitHomeTheme.title.copyWith(color: WitHomeTheme.wit_white),
        ),
      ),
      body: SingleChildScrollView( // SingleChildScrollView로 감싸줍니다.
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 광고 이미지 영역
              Padding(
                padding: EdgeInsets.only(left:5,top: 0.0),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.25,
                  width: MediaQuery.of(context).size.width * 0.90,
                  child: Image.asset(
                    'assets/images/바로견적.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: AssetImage('assets/images/견적설명 창.png'), // 배경 이미지 설정
                    fit: BoxFit.fill,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 40),
                    TextField(
                      style: WitHomeTheme.subtitle.copyWith(fontSize: 16),
                      controller: estimateContentController,
                      minLines: 3,
                      maxLines: null,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '여기에 견적 설명을 입력하세요',
                        hintStyle: WitHomeTheme.subtitle.copyWith(fontSize: 16),
                        contentPadding: EdgeInsets.all(8),
                      ),
                    ),
                    SizedBox(height: 20), // 버튼과 텍스트 필드 사이 간격 조절
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween, // 전체 Row는 양쪽 정렬
                      children: [
                        // 왼쪽 정렬 그룹 (체크박스 + 텍스트)
                        Row(
                          mainAxisSize: MainAxisSize.min, // 내부 요소 크기만큼만 차지하도록 설정
                          children: [
                            Checkbox(
                              value: _isChecked,
                              onChanged: (bool? value) {
                                _onCheckboxChanged(value); // 기존의 메소드 사용
                              },
                              activeColor: Colors.blue,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // 체크박스의 터치 영역 축소
                            ),
                            SizedBox(width: 4), // 체크박스와 텍스트 사이 간격 조절
                            Text(
                              "프로필 자동 붙이기",
                              style: WitHomeTheme.title.copyWith(fontSize: 16),
                            ),
                          ],
                        ),

                        // 저장 버튼 (오른쪽 정렬)
                        GestureDetector(
                          onTap: () {
                            print("저장 버튼 클릭됨");
                          },
                          child: Container(
                            width: 80, // 버튼 크기 조절
                            height: 30,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/images/저장하기.png'), // 저장 버튼 배경 이미지
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 체크박스가 체크된 경우에만 SellerProfileView 표시
              if (_isChecked) ...[
                SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  constraints: BoxConstraints(
                    minHeight: 100,
                    maxHeight: 800,
                  ),
                  child: SellerProfileView(sllrNo: widget.sllrNo, appbarYn: "N"),
                ),
              ],

              SizedBox(height: 10),
              Text(
                '- 이번주 견적 발송 내역',
                style: WitHomeTheme.title.copyWith(fontSize: 16),
              ),
              SizedBox(height: 10),
              if (directEstimateSetList.isNotEmpty) ...[
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: directEstimateSetList.map((request) {
                    return buildEstimateItem(request, context);
                  }).toList(),
                ),
              ] else ...[
                // 리스트가 비어있을 경우 (이미지 크기만큼만 차지)
                Center(
                  child: Image.asset(
                    'assets/images/nolist2.png', // 광고 이미지
                    fit: BoxFit.contain, // 이미지 비율 유지
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  Widget buildEstimateItem(dynamic request, BuildContext context) {
    return EstimateItem(
      request: request,
      sllrNo: widget.sllrNo,
      onExpandToggle: (bool isExpanded) {
        setState(() {
          request['isExpanded'] = isExpanded; // 상태를 업데이트
        });
      },
    );
  }
}

class EstimateItem extends StatelessWidget {
  final Map<String, dynamic> request;
  final dynamic sllrNo;
  final ValueChanged<bool> onExpandToggle;

  EstimateItem({required this.request, required this.sllrNo, required this.onExpandToggle});

  @override
  Widget build(BuildContext context) {
    bool isExpanded = request['isExpanded'] ?? false; // 상세보기 상태 관리
    String reqContents = request['reqContents'] ?? '내용 없음'; // 내용

    // 내용이 3줄 이상인지 확인
    bool hasMoreThanThreeLines = (reqContents.split('\n').length > 3);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8), // 카드 간의 간격 설정
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/견적설명 (1).png'), // 배경 이미지 설정
          fit: BoxFit.cover, // 배경 이미지를 꽉 채우도록 설정
        ),
        borderRadius: BorderRadius.circular(8), // 모서리 둥글게
      ),
      child: Padding(
        padding: EdgeInsets.all(16), // 내부 여백 추가
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
          children: [
            Row(
              children: [
                // 왼쪽에 사진
                Container(
                  width: 50,
                  height: 50, // 이미지 높이 설정
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25), // 둥근 프로필 사진
                    image: DecorationImage(
                      image: AssetImage('assets/images/profile1.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: 10), // 이미지와 텍스트 사이의 간격 추가
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 날짜를 이름 위로 배치
                      /*Text(
                        request['autoYn'], // 날짜
                        style: WitHomeTheme.title.copyWith(fontSize: 14, color: WitHomeTheme.wit_gray),
                      ),*/
                      SizedBox(height: 4), // 날짜와 이름 사이의 간격
                      Text(
                        request['prsnName'] ?? '요청자명 없음', // 요청자명
                        style: WitHomeTheme.title.copyWith(fontSize: 18),
                      ),
                      SizedBox(height: 1), // 이름과 아파트명 사이의 간격
                      Text(
                        request['aptName'], // 아파트명
                        style: WitHomeTheme.title.copyWith(fontSize: 12, color: WitHomeTheme.wit_gray),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 10), // 상태 텍스트와의 간격
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EstimateRequestDetail(
                          estNo: request['estNo'],
                          seq: request['seq'],
                          sllrNo: request[sllrNo],
                        ),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero, // 패딩을 0으로 설정하여 간격 줄이기
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0), // 테두리 없애기
                    ),
                  ),
                  child: Text(
                    request['estDt'], // 상태
                    style: WitHomeTheme.title.copyWith(fontSize: 14),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
