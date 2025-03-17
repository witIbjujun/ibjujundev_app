import 'dart:convert';

import 'package:witibju/screens/seller/wit_seller_cash_recharge_sc.dart';
import 'package:witibju/screens/seller/wit_seller_esitmaterequest_areapop_sc.dart';
import 'package:witibju/screens/seller/wit_seller_esitmaterequest_contentpop_sc.dart';
import 'package:witibju/screens/seller/wit_seller_esitmaterequest_extimepop_sc.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:witibju/screens/seller/wit_seller_profile_appbar_sc.dart';

import '../../util/wit_api_ut.dart';
import '../home/wit_home_theme.dart';

class EstimateRequestDirectSetModify extends StatefulWidget {
  final dynamic sllrNo;
  final dynamic esdrNo;

  const EstimateRequestDirectSetModify(
      {Key? key, required this.sllrNo, this.esdrNo})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return EstimateRequestDirectSetModyfyState();
  }
}

class EstimateRequestDirectSetModyfyState
    extends State<EstimateRequestDirectSetModify> {
  dynamic sellerInfo;
  String storeName = "";
  Map cashInfo = {};
  Map directEstimateSetInfo = {};
  List<dynamic> autoEstimateList = [];
  String selectedRegionSubtitle = '선택된 지역 없음'; // 상태 변수 추가
  String selectedRegionCodes = ""; // 선택된 지역의 cd 값을 저장하는 리스트
  String estimateDescription = '서울시에서 제일 잘하는 집...'; // 견적 설명 상태 변수
  String? excludedStartTime; // 견적 발송 제외 시작 시간
  String? excludedEndTime; // 견적 발송 제외 종료 시간
  List<dynamic> codeList = [];
  List<dynamic> areaList = []; // 지역 정보를 담을 리스트

  int _sliderIndex = 0; // 슬라이더의 인덱스 초기값

  List<dynamic> _values = [];
  List<dynamic> _sendCounts = [];
  List<dynamic> _cds = [];

  @override
  void initState() {
    super.initState();
    getSellerInfo(widget.sllrNo);
    getCodeList(); // 공통코드 조회 추가
    getCashInfo(widget.sllrNo);
    getAutoEstimateList(widget.sllrNo);
    getDirectEstimateSetInfo(widget.esdrNo);
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

  // [서비스] 공통코드 조회
  Future<void> getCodeList() async {
    // REST ID
    String restId = "getCodeList";

    // PARAM
    final param = jsonEncode({
      "cdCls": "DRE01,AREA01", // DRE01 : 바로견적 설정 횟수
    });

    // API 호출 (바로견적 설정 정보 조회)
    final _codeList = await sendPostRequest(restId, param);

    // 결과 셋팅
    if (_codeList != null) {
      setState(() {
        codeList = _codeList;

        // areaList 초기화
        areaList.clear();

        // cdCls가 area01인 항목을 areaList에 추가
        areaList = codeList.where((code) => code['cdCls'] == 'AREA01').toList();

        codeList = codeList.where((code) => code['cdCls'] == 'DRE01').toList();

        /*for (var code in codeList) {
          print("cdCls: ${code['cdCls']}"); // 각 항목의 cdCls 값 출력
        }

        for (var area in areaList) {
          print("cdCls: ${area['cdCls']}"); // area의 cdCls 값 출력
        }*/

        _sendCounts =
            codeList.map((code) => code['cdNm']).toList(); // cdNm을 _values에 매핑
        _values = codeList
            .map((code) => code['rem'])
            .toList(); // rem을 _sendCounts에 매핑,
        _cds =
            codeList.map((code) => code['cd']).toList(); // rem을 _sendCounts에 매핑
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("공통코드 조회가 실패하였습니다.")),
      );
    }
  }

  // 캐시정보 조회
  Future<void> getCashInfo(dynamic sllrNo) async {
    // REST ID
    String restId = "getCashInfo";

    // PARAM
    final param = jsonEncode({
      "sllrNo": sllrNo,
    });

    // API 호출 (사전 점검 미완료 리스트 조회)
    final _cashInfo = await sendPostRequest(restId, param);

    // 결과 셋팅
    setState(() {
      cashInfo = _cashInfo;
    });
  }

  // [서비스] 바로 견적 설정 정보 조회
  Future<void> getDirectEstimateSetInfo(dynamic esdrNo) async {
    // REST ID
    String restId = "getDirectEstimateSetInfo";

    // PARAM
    final param = jsonEncode({
      "esdrNo": widget.esdrNo, // 바로견적 설정 번호
    });

    // API 호출 (바로견적 설정 정보 조회)
    final _directEstimateSetInfo = await sendPostRequest(restId, param);

    // 결과 셋팅
    if (_directEstimateSetInfo != null) {
      setState(() {
        directEstimateSetInfo = _directEstimateSetInfo;

        // 서비스 지역, 견적 설명, 견적 발송 제외시간 설정
        selectedRegionCodes = directEstimateSetInfo['area'] ?? '';
        //selectedRegionSubtitle = directEstimateSetInfo['area'] ?? '선택된 지역 없음';
        estimateDescription = directEstimateSetInfo['content'] ?? '견적 설명 없음';
        excludedStartTime = directEstimateSetInfo['exStartTime'] ?? '설정 없음';
        excludedEndTime = directEstimateSetInfo['exEndTime'] ?? '설정 없음';

        // 선택된 지역의 cd 값을 사용하여 지역 이름을 찾기
        if (selectedRegionCodes != null && selectedRegionCodes.isNotEmpty) {
          List<String> regionCodes = selectedRegionCodes.split(','); // cd 값 리스트로 변환
          selectedRegionSubtitle = areaList
              .where((area) => regionCodes.contains(area['cd'])) // areaList에서 cd가 일치하는 항목 찾기
              .map((area) => area['cdNm']) // cdNm 가져오기
              .join(", "); // 문자열로 합치기
        } else {
          selectedRegionSubtitle = '선택된 지역 없음'; // 선택된 지역이 없을 경우 처리
        }

        // esdrSendCntCd를 가져와서 인덱스를 찾기
        String sendCount = directEstimateSetInfo['esdrSendCntCd'].toString() ?? "01"; // 변경된 부분
        int index = _cds.indexOf(sendCount); // sendCount를 문자열로 비교

        // 유효한 인덱스인 경우에만 업데이트
        if (index != -1) {
          _sliderIndex = index;
        } else {
          // sendCount가 _sendCounts에 없을 경우 기본값 설정
          _sliderIndex = 0; // 기본값으로 0을 설정하거나 적절한 기본값으로 설정
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("바로 견적 설정 정보 조회가 실패하였습니다.")),
      );
    }
  }

  // [서비스] 바로 견적 발송 리스트 조회
  Future<void> getAutoEstimateList(dynamic sllrNo) async {
    // REST ID
    String restId = "getAutoEstimateList";

    // PARAM
    final param = jsonEncode({
      "sllrNo": widget.sllrNo, // stat을 사용하여 API에 전달
    });

    // API 호출 (바로견적 설정 정보 조회)
    final _autoEstimateList = await sendPostRequest(restId, param);

    // 결과 셋팅
    if (_autoEstimateList != null) {
      setState(() {
        autoEstimateList = _autoEstimateList;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("바로 견적 발송 리스트 조회가 실패하였습니다.")),
      );
    }
  }

  // [서비스] 바로 견적 설정 정보 수정
  Future<void> updateDirectEstimateSetInfo(dynamic esdrNo) async {
    // REST ID
    String restId = "updateDirectEstimateSetInfo";

    // PARAM
    final param = jsonEncode({
      "esdrNo": widget.esdrNo, // stat을 사용하여 API에 전달
      "esdrSendCntCd": _cds[_sliderIndex], // 슬라이더 인덱스에 해당하는 cds 값 // 바로견적 횟수 코드
      "area": selectedRegionCodes, // 선택된 지역 코드 저장
      "content": estimateDescription, // 견적 설명
      "exStartTime": excludedStartTime, // 견적 발송 제외 시작 시간
      "exEndTime": excludedEndTime, // 견적 발송 제외 종료 시간
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
      /*appBar: SellerAppBar(
        sllrNo: widget.sllrNo,
      ),*/
      appBar: AppBar(
        backgroundColor: WitHomeTheme.wit_gray,
        iconTheme: const IconThemeData(color: WitHomeTheme.wit_white),
        title: Text(
          '바로 견적 수정',
          style: WitHomeTheme.title.copyWith(color: WitHomeTheme.wit_white),
        ),
      ),
      body: SingleChildScrollView(
        // 추가된 부분
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
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CashRecharge(sllrNo: 17)),
                );
              },
              child: Text('충전하러가기 >>',
                style: WitHomeTheme.title.copyWith(fontSize: 16),
              ),
            ),
            Divider(),
            Card(
              margin: EdgeInsets.symmetric(vertical: 8.0), // 카드 간격
              elevation: 4, // 카드 그림자
              child: Padding(
                padding: const EdgeInsets.all(16.0), // 카드 내부 여백
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
                  children: [
                    Text(directEstimateSetInfo['categoryNm'].toString(),
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    // 방충망 텍스트 추가
                    SizedBox(height: 8),
                    // 방충망과 다음 텍스트 사이의 간격
                    Text('* 이번주 견적 발송 고객',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    ...autoEstimateList.map((estimate) {
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 8.0), // 항목 간 간격
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              // 양쪽 정렬
                              children: [
                                Expanded(
                                  child: Text(
                                    estimate['itemName'] ?? '품목명 없음',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold), // 강조된 품목명
                                  ),
                                ),
                                SizedBox(width: 10), // itemName과 estDt 사이의 간격
                                Text(
                                  estimate['estDt'] ?? '시간 없음',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.blueGrey), // 시간 표시 스타일
                                ),
                              ],
                            ),
                            SizedBox(height: 4), // itemName과 prsnName 사이의 간격
                            Text(
                              (estimate['prsnName'] ?? '요청자 없음') +
                                  '님 ' +
                                  (estimate['autoYn'] ?? ''),
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey), // 요청자 이름 스타일
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Text('| 바로견적',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            _buildEstimateProgress(),
            SizedBox(height: 16),
            _buildDetailItem('서비스 지역', isLink: true),
            _buildDetailItem('견적 설명', isLink: true),
            _buildDetailItem('견적발송 제외시간', isLink: true),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF63A566),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    updateDirectEstimateSetInfo(widget.esdrNo);
                  },
                  child: Text('수정하기'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF8D8D8D),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    // 취소 버튼 로직
                  },
                  child: Text('취소'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String title, {bool isLink = false}) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0), // 카드 간격
      elevation: 4, // 그림자 효과
      child: ListTile(
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          title == '견적 설명'
              ? estimateDescription
              : (title == '견적발송 제외시간'
                  ? (excludedStartTime == '설정 없음' && excludedEndTime == '설정 없음'
                      ? '설정 없음'
                      : '${excludedStartTime ?? '설정 없음'} ~ ${excludedEndTime ?? '설정 없음'}')
                  : selectedRegionSubtitle),
        ),
        trailing: isLink ? Icon(Icons.arrow_forward) : null,
        onTap: isLink
            ? () {
                if (title == '견적 설명') {
                  showDialog<String>(
                    context: context,
                    builder: (BuildContext context) {
                      return EstimateRequestContentPop(sllrNo: 17);
                    },
                  ).then((description) {
                    if (description != null && description.isNotEmpty) {
                      setState(() {
                        estimateDescription = description; // 상태 변수 업데이트
                      });
                    }
                  });
                } else if (title == '서비스 지역') {
                  showDialog<List<Map<String, String>>>(
                    context: context,
                    builder: (BuildContext context) {
                      return EstimateRequestAreaPop(sllrNo: widget.sllrNo);
                    },
                  ).then((selectedRegions) {
                    if (selectedRegions != null && selectedRegions.isNotEmpty) {
                      setState(() {
                        // cdNm 값 세팅
                        selectedRegionSubtitle = selectedRegions.map((region) => region["cdNm"]).join(",");

                        // cd 값 세팅 저장
                        selectedRegionCodes = selectedRegions.map((region) => region["cd"]).join(",");
                      });
                    }
                  });
                } else if (title == '견적발송 제외시간') {
                  showDialog<Map<String, String>>(
                    context: context,
                    builder: (BuildContext context) {
                      return EstimateRequestExTimePop(sllrNo: 17);
                    },
                  ).then((result) {
                    if (result != null) {
                      String selectedStartTime = result['startTime'] ?? '설정 없음';
                      String selectedEndTime = result['endTime'] ?? '설정 없음';

                      // 선택한 시간을 모 화면에서 사용
                      print('선택한 시작 시간: $selectedStartTime');
                      print('선택한 종료 시간: $selectedEndTime');

                      setState(() {
                        excludedStartTime = selectedStartTime;
                        excludedEndTime = selectedEndTime;
                      });
                    }
                  });
                }
              }
            : null,
      ),
    );
  }

  // 슬라이더의 발송 가능 횟수 표시를 위한 수정
  Widget _buildEstimateProgress() {
    if (_sendCounts.isEmpty || _values.isEmpty) {
      return Center(child: Text('견적 발송 횟수 정보가 없습니다.'));
    }

    return Card(
      margin: EdgeInsets.symmetric(vertical: 16.0),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('일일 견적 예상',
                    style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('${_sendCounts[_sliderIndex]} 회 발송가능',
                    style: TextStyle(fontSize: 16)),
              ],
            ),
            SizedBox(height: 12),
            Slider(
              value: _sliderIndex.toDouble(),
              min: 0,
              max: (_values.length - 1).toDouble(),
              divisions: _values.length - 1,
              label: '${_values[_sliderIndex]} C',
              onChanged: (double value) {
                setState(() {
                  _sliderIndex = value.round();
                });
              },
              activeColor: Colors.lightBlue,
              inactiveColor: Colors.grey,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${int.parse(_values[0])} C',
                    style: TextStyle(fontSize: 14)),
                Text('${int.parse(_values[_sliderIndex])} C',
                    style: TextStyle(fontSize: 14)),
                Text('${int.parse(_values.last)} C',
                    style: TextStyle(fontSize: 14)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
