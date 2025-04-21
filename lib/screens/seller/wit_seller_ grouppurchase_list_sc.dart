import 'dart:convert';
import 'package:flutter/material.dart';
import '../../util/wit_api_ut.dart';
import 'package:witibju/screens/home/wit_home_theme.dart';
import '../home/widgets/wit_home_widgets.dart'; // WitHomeTheme 경로 확인
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SellerGroupPurchaseList extends StatefulWidget {
  final String sllrNo; // 판매자 번호

  const SellerGroupPurchaseList({Key? key, required this.sllrNo})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    //sellerInfo = this.sellerId;
    return SellerGroupPurchaseListState();
  }
}

class SellerGroupPurchaseListState extends State<SellerGroupPurchaseList> {
  List<dynamic> applicationList = []; // 신청 목록
  String selectedOption = ''; // 기본 선택 값
  List<String> options = [];
  final _storage = const FlutterSecureStorage();
  String _selectedApartment = '병점아이파크캐슬'; // 초기 선택 값

  @override
  void initState() {
    super.initState();
    _loadOptions();
    if (options.isNotEmpty) {
      selectedOption = options.first;
    }
    getSellerGroupPurchaseList(); // 신청 목록 조회
  }

  Future<void> _loadOptions() async {
    String? aptName = await _storage.read(key: 'aptName');
    String? clerkNo = await _storage.read(key: 'clerkNo');
    String? nickName = await _storage.read(key: 'nickName');
    String? role = await _storage.read(key: 'role');
    String? mainAptNo = await _storage.read(key: 'mainAptNo');

    print('myprofile 고객 번호: $clerkNo');
    print('myprofile 닉네임: $nickName');
    print('myprofile 역할: $role');
    print('myprofile Main아파트 번호: $mainAptNo');
    print('myprofile Main아파트 이름: $aptName');

    if (aptName != null) {
      setState(() {
        options = aptName.split(',');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WitHomeTheme.wit_white,
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                SizedBox( // Column에 높이 제한을 추가
                  height: MediaQuery.of(context).size.height * 0.25, // 예시: 화면 높이의 50%
                  child: Column(
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 2, top: 0.0, bottom: 0),
                              child: Container(
                                height: MediaQuery.of(context).size.height * 0.25,
                                width: MediaQuery.of(context).size.width * 0.92,
                                child: Image.asset(
                                  'assets/images/공동구매 판매자 배너.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 20,
                              left: 20,
                              child: Container(
                                width: 340,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: PopupMenuButton<String>(
                                  initialValue: _selectedApartment,
                                  onSelected: (String item) {
                                    setState(() {
                                      _selectedApartment = item;
                                    });
                                  },
                                  itemBuilder: (BuildContext context) {
                                    return <String>['병점아이파크캐슬', '기흥역푸르지오'].map((String value) {
                                      return PopupMenuItem<String>(
                                        value: value,
                                        child: Text(
                                          value,
                                          style: WitHomeTheme.title.copyWith(fontSize: 14),
                                        ),
                                      );
                                    }).toList();
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 10.0),
                                        child: Text(
                                          _selectedApartment ?? '아파트 선택',
                                          style: WitHomeTheme.title.copyWith(fontSize: 14),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(right: 10.0),
                                        child: Icon(Icons.arrow_drop_down, color: WitHomeTheme.wit_black),
                                      ),
                                    ],
                                  ),
                                  offset: Offset(0, 40),
                                ),
                              ),
                            ),
                            LayoutBuilder(
                              builder: (BuildContext context, BoxConstraints constraints) {
                                return Stack(
                                  children: [
                                    Positioned(
                                      bottom: constraints.maxHeight * 0.31,
                                      left: constraints.maxWidth * 0.15,
                                      child: Text(
                                        '선착순모집 정원 10 / 신청 5',
                                        style: WitHomeTheme.subtitle.copyWith(
                                          fontSize: MediaQuery.of(context).size.width * 0.03,
                                          color: WitHomeTheme.wit_white,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: constraints.maxHeight * 0.16,
                                      left: constraints.maxWidth * 0.15,
                                      child: Text(
                                        '모집일자 2025/04/30 까지',
                                        style: WitHomeTheme.subtitle.copyWith(
                                          fontSize: MediaQuery.of(context).size.width * 0.03,
                                          color: WitHomeTheme.wit_white,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 10),
                Padding( // Row 전체를 Padding으로 감싸서 여백 조정
                  padding: EdgeInsets.only(left: 0, right: 0), // Stack의 Padding 값과 동일하게 설정
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: InkWell(
                          onTap: () {
                            // onTap 이벤트 추가
                            // 마감 완료 로직 추가
                          },
                          child: Container(
                            padding: EdgeInsets.all(0), // 모든 방향 패딩을 0으로 설정
                            child: Center(
                              child: Image.asset(
                                'assets/images/마감완료.png',
                                fit: BoxFit.contain,
                                width: double.infinity,
                                height: 50,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: InkWell(
                          onTap: () {
                            // onTap 이벤트 추가
                            // 마감 완료 로직 추가
                          },
                          child: Container(
                            padding: EdgeInsets.all(0), // 모든 방향 패딩을 0으로 설정
                            child: Center(
                              child: Image.asset(
                                'assets/images/조기마감.png',
                                fit: BoxFit.fill,
                                width: double.infinity,
                                height: 50,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: InkWell(
                          onTap: () {
                            // onTap 이벤트 추가
                            // 마감 완료 로직 추가
                          },
                          child: Container(
                            padding: EdgeInsets.all(0), // 모든 방향 패딩을 0으로 설정
                            child: Center(
                              child: Image.asset(
                                'assets/images/메세지.png',
                                fit: BoxFit.contain,
                                width: 40,
                                height: 40,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: applicationList.length,
                itemBuilder: (context, index) {
                  return buildApplicationItem(applicationList[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget buildApplicationItem(dynamic application) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/견적설명 (2).png'), // 배경 이미지 설정
          fit: BoxFit.cover, // 배경 이미지를 꽉 채우도록 설정
        ),
        borderRadius: BorderRadius.circular(8), // 모서리 둥글게
      ),
      child: Padding(
        padding: const EdgeInsets.only(top : 12.0, bottom: 27, left: 16, right: 16),
        child: Row(
          children: [
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
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    application['estDt'] ?? '날짜 없음', // 신청 날짜
                    style: WitHomeTheme.title
                        .copyWith(fontSize: 12, color: WitHomeTheme.wit_gray),
                  ),
                  //SizedBox(height: 4),
                  Text(
                    application['prsnName'] ?? '신청자명 없음', // 신청자 이름
                    style: WitHomeTheme.title.copyWith(fontSize: 16),
                  ),
                  SizedBox(height: 6), // 이름과 아파트명 사이의 간격
                  Text(
                    application['aptName'] ?? '아파트명 없음', // 아파트명
                    style: WitHomeTheme.title
                        .copyWith(fontSize: 12, color: WitHomeTheme.wit_gray),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                // 신청 버튼 클릭 시 로직 추가
              },
              style: TextButton.styleFrom(
                //padding: EdgeInsets.zero, // 패딩을 0으로 설정하여 간격 줄이기
                padding: EdgeInsets.only(top:14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0), // 테두리 없애기
                ),
              ),
              child: Text(
                // application['stat'] ?? '상태 없음', // 상태
                '신청',
                style: WitHomeTheme.title
                    .copyWith(fontSize: 14,),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> getSellerGroupPurchaseList() async {
    String restId = "getEstimateRequestList"; // API ID
    final param = jsonEncode({
      //"stat": widget.stat,
      "sllrNo": widget.sllrNo,
    });

    final response = await sendPostRequest(restId, param);
    setState(() {
      applicationList = response; // 신청 목록 저장
    });
  }
}


/*Text(
              '> 공동구매 진행 APT',
              style: WitHomeTheme.title.copyWith(fontSize: 20, color: WitHomeTheme.wit_lightGreen),
            ),
            SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                String initialSelection = options.isNotEmpty ? options.first : ''; // 기본값을 options의 첫 번째 값으로 설정
                WitHomeWidgets.showSelectBox(context, initialSelection, options, (option) {
                  setState(() {
                    selectedOption = option;
                    /// _storage.write(key: 'aptName', value: option);
                  });
                });
              },
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: 50.0,
                decoration: BoxDecoration(
                  border: Border.all(color: WitHomeTheme.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Text(
                        selectedOption.isNotEmpty ? selectedOption : (options.isNotEmpty ? options.first : 'APT 선택'),
                        style: WitHomeTheme.title,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(right: 16.0),
                      child: Icon(Icons.arrow_drop_down, color: WitHomeTheme.darkText),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '> 선착순 모집 정원 ',
                    style: WitHomeTheme.subtitle.copyWith(fontSize: 16), // 녹색
                  ),
                  TextSpan(
                    text: '10', //'${applicationList.length}', // 신청 수
                    style: WitHomeTheme.title.copyWith(fontSize: 16), // 빨간색
                  ),
                  TextSpan(
                    text: ' 명 ',
                    style: WitHomeTheme.subtitle.copyWith(fontSize: 16), // 녹색
                  ),
                  TextSpan(
                    text: '- 신청 ',
                    style: WitHomeTheme.subtitle.copyWith(fontSize: 16), // 녹색
                  ),
                  TextSpan(
                    text: '5',
                    style: WitHomeTheme.title.copyWith(fontSize: 16), // 녹색
                  ),
                  TextSpan(
                    text: ' 명',
                    style: WitHomeTheme.subtitle.copyWith(fontSize: 16), // 녹색
                  ),
                ],
              ),
            ),

            SizedBox(height: 8),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '> 모집 일자 ',
                    style: WitHomeTheme.subtitle.copyWith(fontSize: 16), // 녹색
                  ),
                  TextSpan(
                    text: '25 / 03 / 31',
                    style: WitHomeTheme.title.copyWith(fontSize: 16), // 빨간색
                  ),
                  TextSpan(
                    text: ' 까지',
                    style: WitHomeTheme.subtitle.copyWith(fontSize: 16), // 빨간색
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),*/