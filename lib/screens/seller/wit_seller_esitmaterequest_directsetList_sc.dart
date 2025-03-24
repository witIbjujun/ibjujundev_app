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

  @override
  void initState() {
    super.initState();
    getSellerInfo(widget.sllrNo);
    getDirectEstimateSetList(widget.sllrNo);
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

  Future<void> getDirectEstimateSetList(dynamic sllrNo) async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: WitHomeTheme.wit_gray,
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
              Container(
                padding: EdgeInsets.all(8.0), // 텍스트와 테두리 사이의 여백
                decoration: BoxDecoration(
                  border: Border.all(width: 2.0), // 테두리 색상 및 두께 설정
                  borderRadius: BorderRadius.circular(8.0), // 모서리 둥글게 설정 (선택 사항)
                ),
                child: Text(
                  '* 25년 7월까지는 바로견적서비스가 무료지원됩니다.',
                  style: WitHomeTheme.title.copyWith(fontSize: 16, color: WitHomeTheme.wit_lightBlue),
                ),
              ),
              SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[100], // 배경색을 회색으로 설정
                  borderRadius: BorderRadius.circular(8), // 모서리를 둥글게 설정
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "견적 설명",
                      style: WitHomeTheme.title.copyWith(fontSize: 16, color: WitHomeTheme.wit_lightSteelBlue),
                    ),
                    SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[300], // 배경색을 회색으로 설정
                        borderRadius: BorderRadius.circular(8), // 모서리를 둥글게 설정
                      ),
                      child: TextField(
                        style: WitHomeTheme.subtitle.copyWith(fontSize: 16),
                        controller: estimateContentController,
                        minLines: 3, // 최소 3줄
                        maxLines: null, // 내용에 따라 자동으로 늘어남
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: '여기에 견적 설명을 입력하세요',
                          hintStyle: WitHomeTheme.subtitle.copyWith(fontSize: 16),
                          contentPadding: EdgeInsets.all(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Checkbox(
                    value: _isChecked,
                    onChanged: (bool? value) {
                      _onCheckboxChanged(value);
                    },
                    activeColor: Colors.blue, // 체크박스 체크 시 색상 설정
                  ),
                  Text(
                    "프로필 자동 붙이기",
                    style: WitHomeTheme.title.copyWith(fontSize: 16),
                  ),
                ],
              ),
              // 체크박스가 체크된 경우 SellerProfileView 표시
              if (_isChecked)
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black), // 테두리 색상 설정
                    borderRadius: BorderRadius.circular(2), // 둥근 모서리 설정
                  ),
                  constraints: BoxConstraints(
                    minHeight: 100, // 최소 높이 설정
                    maxHeight: 800, // 최대 높이 설정
                  ),
                  child: SellerProfileView(sllrNo: widget.sllrNo, appbarYn: "N"),
                ),
              SizedBox(height: 10),
              Text(
                '* 견적 자동발송 제외시간입니다.',
                style: WitHomeTheme.title.copyWith(fontSize: 16),
              ),
              SizedBox(height: 10),
              Text(
                '- 밤 9시~ 아침8시까지',
                style: WitHomeTheme.title.copyWith(fontSize: 16, color: WitHomeTheme.wit_gray),
              ),
              SizedBox(height: 20),
              Text(
                '- 이번주 견적 발송 내역',
                style: WitHomeTheme.title.copyWith(fontSize: 16),
              ),
              if (directEstimateSetList.isNotEmpty) ...[
                // 리스트가 비어있지 않을 경우
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: directEstimateSetList.map((request) {
                    return buildEstimateItem(request, context);
                  }).toList(),
                ),
              ] else ...[
                // 리스트가 비어있을 경우
                Container(
                  height: MediaQuery.of(context).size.height - 100, // 여유 공간 설정
                  child: Center( // Center 위젯으로 텍스트 중앙 정렬
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.18,  // 화면 높이의 18%
                      width: MediaQuery.of(context).size.width * 0.85,    // 화면 너비의 85%
                      child: Image.asset(
                        'assets/images/nolist3.png', // 광고 이미지 URL
                        fit: BoxFit.contain, // 이미지 비율 유지
                      ),
                    ),
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
        color: Colors.grey[100], // 카드 배경색
        borderRadius: BorderRadius.circular(8), // 모서리 둥글게
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3), // 그림자 위치
          ),
        ],
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
                      Text(
                        request['autoYn'], // 날짜
                        style: WitHomeTheme.title.copyWith(fontSize: 14, color: WitHomeTheme.wit_gray),
                      ),
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
                          sllrNo: sllrNo,
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
                    style: WitHomeTheme.title.copyWith(fontSize: 14, color: WitHomeTheme.wit_lightBlue),
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