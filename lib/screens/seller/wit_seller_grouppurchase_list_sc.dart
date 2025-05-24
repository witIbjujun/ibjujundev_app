import 'dart:convert';
import 'package:flutter/material.dart';
import '../../util/wit_api_ut.dart';
import 'package:witibju/screens/home/wit_home_theme.dart';
import '../chat/CustomChatScreen.dart';
import '../common/wit_common_util.dart';
import '../home/widgets/wit_home_widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SellerGroupPurchaseList extends StatefulWidget {
  final String sllrNo;

  const SellerGroupPurchaseList({Key? key, required this.sllrNo})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => SellerGroupPurchaseListState();
}

class SellerGroupPurchaseListState extends State<SellerGroupPurchaseList> {
  List<dynamic> applicationList = [];
  String selectedOption = '';
  List<Map<String, String>> options = [];
  final _storage = const FlutterSecureStorage();
  String _selectedApartment = '';
  String _selectedAptNo = "";
  dynamic sellerInfo;
  List<Map<String, dynamic>> gpList = []; // 타입 명시적으로 변경

  @override
  void initState() {
    super.initState();
    //_loadOptions();
    getSellerInfo();
  }

  /*Future<void> _loadOptions() async {
    String? aptName = await _storage.read(key: 'aptName');
    if (aptName != null) {
      setState(() {
        options = aptName.split(',');
        if (options.isNotEmpty) {
          _selectedApartment = options.first;
        }
      });
    }
  }*/

  Future<void> getSellerInfo() async {
    final param = jsonEncode({"sllrNo": widget.sllrNo});
    final response = await sendPostRequest("getSellerInfo", param);

    if (response != null) {
      setState(() {
        sellerInfo = response;
        getGPList();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("사업자 프로필 조회가 실패하였습니다.")),
      );
    }
  }

  Future<void> getGPList() async {
    String prevAptNo = _selectedAptNo; // ✅ 이전 선택값 저장

    final param = jsonEncode({
      "sllrNo": widget.sllrNo,
      "ctgrId": sellerInfo["serviceItem"]
    });
    final response = await sendPostRequest("getGPList", param);

    if (response is List) {
      setState(() {
        gpList = response.map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e)).toList();
        options = gpList.map((gp) {
          return {
            'aptName': gp['aptName']?.toString() ?? '',
            'aptNo': gp['aptNo']?.toString() ?? '',
          };
        }).toList();

        // ✅ 이전 선택값이 여전히 존재하는지 확인
        final found = options.firstWhere(
                (opt) => opt['aptNo'] == prevAptNo,
            orElse: () => options.isNotEmpty ? options.first : {'aptNo': '', 'aptName': ''}
        );

        _selectedAptNo = found['aptNo']!;
        _selectedApartment = found['aptName']!;

        getSellerGroupPurchaseList();
      });
    } else {
      print("getGPList 응답이 리스트가 아닙니다: $response");
    }
  }


  Future<void> getSellerGroupPurchaseList() async {
    final selectedGP = getSelectedGP();
    final aptNo = selectedGP != null ? selectedGP['aptNo'] ?? '' : '';

    print("aptNo : " + aptNo);

    final param =
        jsonEncode({
          "sllrNo": widget.sllrNo,
          "reqGubun": "G",
          "aptNo": aptNo
        });

    final response = await sendPostRequest("getEstimateRequestList", param);
    setState(() {
      applicationList = response;
      print("12213321212 : " + applicationList.length.toString());
    });
  }

  // 공동구매 상태 변경
  Future<void> updateGPstat(dynamic ctgrId, String gpStat) async {
    String restId = "updateGPstat";

    // PARAM
    final param = jsonEncode({
      "ctgrId": ctgrId,
      "gpStat": gpStat
    });

    // API 호출
    final response = await sendPostRequest(restId, param);

    if (response != null) {
      // ✅ 공동구매 리스트 다시 불러오기 (상태 갱신 포함)
      await getGPList(); // gpList, options, selected 값 자동 갱신
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("처리가 성공하였습니다.")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("처리가 실패하였습니다.")),
      );
    }
  }

  dynamic getSelectedGP() {
    return gpList.firstWhere(
          (gp) => gp['aptNo'].toString() == _selectedAptNo,
      orElse: () => <String, dynamic>{}, // ✅ 타입 일치
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedGP = getSelectedGP();

    return Scaffold(
      backgroundColor: WitHomeTheme.wit_white,
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.25,
                  child: Column(
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            Padding(
                              padding:
                                  EdgeInsets.only(left: 2, top: 0.0, bottom: 0),
                              child: Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.25,
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
                                  initialValue: _selectedAptNo,
                                  onSelected: (String aptNo) {
                                    final selected = options.firstWhere(
                                            (option) => option['aptNo'] == aptNo,
                                        orElse: () => {'aptName': '', 'aptNo': ''}
                                    );

                                    setState(() {
                                      _selectedAptNo = aptNo;
                                      _selectedApartment = selected['aptName'] ?? '';
                                    });

                                    getSellerGroupPurchaseList();
                                  },

                                  itemBuilder: (BuildContext context) {
                                    return options.map((option) {
                                      return PopupMenuItem<String>(
                                        value: option['aptNo'],
                                        child: Text(option['aptName']!,
                                            style: WitHomeTheme.title
                                                .copyWith(fontSize: 14)),
                                      );
                                    }).toList();
                                  },
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10.0),
                                        child: Text(
                                          _selectedApartment,
                                          style: WitHomeTheme.title
                                              .copyWith(fontSize: 14),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 10.0),
                                        child: Icon(Icons.arrow_drop_down,
                                            color: WitHomeTheme.wit_black),
                                      ),
                                    ],
                                  ),
                                  offset: Offset(0, 40),
                                ),
                              ),
                            ),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                return Stack(
                                  children: [
                                    Positioned(
                                      bottom: constraints.maxHeight * 0.31,
                                      left: constraints.maxWidth * 0.15,
                                      child: Text(
                                        selectedGP != null
                                            ? '선착순모집 정원 ${selectedGP['limitCount'] ?? '0'} / 신청 ${selectedGP['reqCount'] ?? '0'}'
                                            : '공동구매 정보 없음',
                                        style: WitHomeTheme.subtitle.copyWith(
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.03,
                                          color: WitHomeTheme.wit_white,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: constraints.maxHeight * 0.16,
                                      left: constraints.maxWidth * 0.15,
                                      child: Text(
                                        selectedGP != null
                                            ? '모집일자 ${formatDate(selectedGP['gpEndDate'] ?? '')} 까지'
                                            : '',
                                        style: WitHomeTheme.subtitle.copyWith(
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.03,
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
                Padding(
                  padding: EdgeInsets.zero,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: InkWell(
                          onTap: () {
                            if (selectedGP == null) return;

                            final gpStat = selectedGP['gpStat']?.toString() ?? '';

                            if (gpStat == '30') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('이미 마감되었습니다.')),
                              );
                              return;
                            }

                            // 확인 창 표시
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor: Colors.white,
                                  title: Text('마감 완료',
                                      style: WitHomeTheme.title
                                          .copyWith(fontSize: 16)),
                                  content: Text('마감완료 하시겠습니까?',
                                      style: WitHomeTheme.subtitle
                                          .copyWith(fontSize: 14)),
                                  actions: [
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        backgroundColor: Colors.grey[300], // 연한 회색
                                        foregroundColor: Colors.black, // 글씨 색
                                      ),
                                      onPressed: () => Navigator.of(context).pop(),
                                      child: Text('취소', style: WitHomeTheme.title
                                          .copyWith(fontSize: 14),),
                                    ),
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        backgroundColor: WitHomeTheme.wit_lightGreen, // 초록 배경
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop(); // 다이얼로그 닫기
                                        updateGPstat(selectedGP['ctgrId'], "30");
                                      },
                                      child: Text('확인', style: WitHomeTheme.title
                                          .copyWith(fontSize: 14, color: WitHomeTheme.wit_white),),
                                    ),
                                  ],
                                );
                              },
                            );

                          },
                          child: Container(
                            padding: EdgeInsets.zero,
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
                            if (selectedGP == null) return;

                            final gpStat = selectedGP['gpStat']?.toString() ?? '';

                            if (gpStat == '20' || gpStat == '30') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('이미 마감되었습니다.')),
                              );
                              return;
                            }

                            // 조기 마감 확인 창
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor: Colors.white, // 배경 흰색
                                  title: Text('조기 마감',
                                      style: WitHomeTheme.title
                                          .copyWith(fontSize: 16)),
                                  content: Text('조기 마감하시겠습니까?',
                                      style: WitHomeTheme.subtitle
                                          .copyWith(fontSize: 14)),
                                  actions: [
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        backgroundColor: Colors.grey[300], // 연한 회색 배경
                                        foregroundColor: Colors.black,     // 검정 글씨
                                      ),
                                      onPressed: () => Navigator.of(context).pop(),
                                      child: Text('취소', style: WitHomeTheme.title
                                          .copyWith(fontSize: 14),),
                                    ),
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        backgroundColor: WitHomeTheme.wit_lightGreen, // 초록 배경
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop(); // 다이얼로그 닫기
                                        updateGPstat(selectedGP['ctgrId'], "20");
                                      },
                                      child: Text('확인', style: WitHomeTheme.title
                                          .copyWith(fontSize: 14, color: WitHomeTheme.wit_white),),
                                    ),
                                  ],
                                );
                              },
                            );

                          },
                          child: Container(
                            padding: EdgeInsets.zero,
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
                          onTap: () {},
                          child: Container(
                            padding: EdgeInsets.zero,
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
          image: AssetImage('assets/images/견적설명 (2).png'),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding:
            const EdgeInsets.only(top: 12.0, bottom: 27, left: 16, right: 16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
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
                    application['estDt'] ?? '날짜 없음',
                    style: WitHomeTheme.title
                        .copyWith(fontSize: 12, color: WitHomeTheme.wit_gray),
                  ),
                  Text(
                    application['prsnName'] ?? '신청자명 없음',
                    style: WitHomeTheme.title.copyWith(fontSize: 16),
                  ),
                  SizedBox(height: 6),
                  Text(
                    application['aptName'] ?? '아파트명 없음',
                    style: WitHomeTheme.title
                        .copyWith(fontSize: 12, color: WitHomeTheme.wit_gray),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  CustomChatScreen(
                    application["estNo"],   // 첫 번째 인자: 요청 번호
                    application["seq"],     // 두 번째 인자: 시퀀스 (chatId)
                    "sellerView",      // 세 번째 인자: 뷰 타입
                  ),
                  ),
                );
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.only(top: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0)),
              ),
              child: Text(
                application["stat"],
                style: WitHomeTheme.title.copyWith(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String formatDate(String yyyymmdd) {
  if (yyyymmdd.length != 8) return yyyymmdd;
  return '${yyyymmdd.substring(0, 4)}/${yyyymmdd.substring(4, 6)}/${yyyymmdd.substring(6, 8)}';
}
