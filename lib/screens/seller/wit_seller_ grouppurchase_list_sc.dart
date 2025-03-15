import 'dart:convert';
import 'package:flutter/material.dart';
import '../../util/wit_api_ut.dart';
import 'package:witibju/screens/home/wit_home_theme.dart';
import '../home/widgets/wit_home_widgets.dart'; // WitHomeTheme 경로 확인
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class SellerGroupPurchaseList extends StatefulWidget {
  final String sllrNo; // 판매자 번호

  const SellerGroupPurchaseList({Key? key, required this.sllrNo}) : super(key: key);

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
      backgroundColor: Colors.white, // 배경색을 흰색으로 설정
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '>공동구매 진행 APT',
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
                    style: WitHomeTheme.title.copyWith(fontSize: 20, color: WitHomeTheme.wit_lightGreen), // 녹색
                  ),
                  TextSpan(
                    text: '10', //'${applicationList.length}', // 신청 수
                    style: WitHomeTheme.title.copyWith(fontSize: 20, color: Colors.red), // 빨간색
                  ),
                  TextSpan(
                    text: ' 명 ',
                    style: WitHomeTheme.title.copyWith(fontSize: 20), // 녹색
                  ),
                  TextSpan(
                    text: '- 신청 ',
                    style: WitHomeTheme.title.copyWith(fontSize: 20, color: WitHomeTheme.wit_lightGreen), // 녹색
                  ),
                  TextSpan(
                    text: '5',
                    style: WitHomeTheme.title.copyWith(fontSize: 20, color: WitHomeTheme.wit_lightSteelBlue), // 녹색
                  ),
                  TextSpan(
                    text: ' 명',
                    style: WitHomeTheme.title.copyWith(fontSize: 20), // 녹색
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
                    style: WitHomeTheme.title.copyWith(fontSize: 20, color: WitHomeTheme.wit_lightGreen),
                  ),
                  TextSpan(
                    text: '25 / 03 / 31',
                    style: WitHomeTheme.title.copyWith(fontSize: 20, color: Colors.red), // 빨간색
                  ),
                  TextSpan(
                    text: ' 까지',
                    style: WitHomeTheme.title.copyWith(fontSize: 20), // 빨간색
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // 마감 완료 로직 추가
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: WitHomeTheme.wit_lightCoral, // 연두색 배경
                      padding: EdgeInsets.symmetric(vertical: 8), // 패딩 추가
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20), // 둥근 모서리
                      ),
                    ),
                    child: Text(
                      '마감완료',
                      style: WitHomeTheme.title.copyWith(fontSize: 14, color: WitHomeTheme.wit_white),
                    ),
                  ),
                ),
                SizedBox(width: 10), // 버튼 간격
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // 조기 마감 로직 추가
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: WitHomeTheme.wit_lightBlue, // 연두색 배경
                      padding: EdgeInsets.symmetric(vertical: 8), // 패딩 추가
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20), // 둥근 모서리
                      ),
                    ),
                    child: Text(
                      '조기마감',
                      style: WitHomeTheme.title.copyWith(fontSize: 14, color: WitHomeTheme.wit_white),
                    ),
                  ),
                ),
                SizedBox(width: 10), // 버튼 간격
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // 메시지 보내기 로직 추가
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: WitHomeTheme.wit_lightGreen, // 연두색 배경
                      padding: EdgeInsets.symmetric(vertical: 8), // 패딩 추가
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20), // 둥근 모서리
                      ),
                    ),
                    child: Text(
                      '메시지보내기',
                      style: WitHomeTheme.title.copyWith(fontSize: 14, color: WitHomeTheme.wit_white),
                    ),
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
    return Card(
      color: Colors.grey[100], // 회색 배경 추가
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage('assets/images/profile1.png'), // 사용자 사진
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    application['estDt'], // 신청 날짜
                    style: WitHomeTheme.title.copyWith(fontSize: 12, color: WitHomeTheme.wit_gray),
                  ),
                  SizedBox(height: 4),
                  Text(
                    application['prsnName'] ?? '신청자명 없음', // 신청자 이름
                    style: WitHomeTheme.title.copyWith(fontSize: 18),
                  ),
                  SizedBox(height: 4),
                  Text(
                    application['aptName'], // 아파트명
                    style: WitHomeTheme.title.copyWith(fontSize: 12, color: WitHomeTheme.wit_gray),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                // 신청 버튼 클릭 시 로직 추가
              },
              child: Text(
                application['stat'], // 상태
                style: WitHomeTheme.title.copyWith(fontSize: 14, color: WitHomeTheme.wit_lightBlue),
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

