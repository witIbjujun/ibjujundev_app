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
                Stack(
                  alignment: Alignment.bottomCenter,
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
                          color: Colors.grey.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButton<String>(
                          value: _selectedApartment,
                          items: <String>['병점아이파크캐슬', '기흥역푸르지오']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                child: Text(
                                  value,
                                  style: WitHomeTheme.title.copyWith(fontSize: 14),
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedApartment = newValue!;
                            });
                          },
                          dropdownColor: Colors.grey.withOpacity(0.7),
                          style: WitHomeTheme.title.copyWith(fontSize: 14),
                          underline: Container(),
                          icon: Icon(Icons.arrow_drop_down,
                              color: WitHomeTheme.wit_black),
                          isExpanded: true,
                          alignment: AlignmentDirectional.centerEnd,
                          selectedItemBuilder: (BuildContext context) {
                            return <String>['병점아이파크캐슬', '기흥역푸르지오']
                                .map<Widget>((String value) {
                              return Container(
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                child: Text(
                                  _selectedApartment,
                                  style: WitHomeTheme.title.copyWith(fontSize: 14),
                                ),
                              );
                            }).toList();
                          },
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 69,
                      left: 60,
                      child: Text(
                        '선착순모집 정원 10 / 신청 5',
                        style: WitHomeTheme.subtitle
                            .copyWith(fontSize: 12, color: WitHomeTheme.wit_white),
                      ),
                    ),
                    Positioned(
                      bottom: 38,
                      left: 60,
                      child: Text(
                        '모집일자 2025/04/30 까지',
                        style: WitHomeTheme.subtitle
                            .copyWith(fontSize: 12, color: WitHomeTheme.wit_white),
                      ),
                    ),
                  ],
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
          image: AssetImage('assets/images/견적설명 (1).png'), // 배경 이미지 설정
          fit: BoxFit.cover, // 배경 이미지를 꽉 채우도록 설정
        ),
        borderRadius: BorderRadius.circular(8), // 모서리 둥글게
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage:
                  AssetImage('assets/images/profile1.png'), // 사용자 사진
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /*Text(
                    application['estDt'] ?? '날짜 없음', // 신청 날짜
                    style: WitHomeTheme.title
                        .copyWith(fontSize: 12, color: WitHomeTheme.wit_gray),
                  ),*/
                  SizedBox(height: 4),
                  Text(
                    application['prsnName'] ?? '신청자명 없음', // 신청자 이름
                    style: WitHomeTheme.title.copyWith(fontSize: 18),
                  ),
                  SizedBox(height: 1),
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