import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:witibju/screens/seller/wit_seller_profile_detail_sc.dart';
import 'package:witibju/screens/seller/wit_seller_profile_insert_content_sc.dart';
import '../../util/wit_api_ut.dart';
import 'package:kpostal/kpostal.dart';

import '../home/wit_home_theme.dart';

class SellerProfileInsertName extends StatefulWidget {
  const SellerProfileInsertName({super.key});

  @override
  State<StatefulWidget> createState() {
    return SellerProfileInsertNameState();
  }
}

class SellerProfileInsertNameState extends State<SellerProfileInsertName> {
  TextEditingController storeNameController = TextEditingController();

  List<dynamic> selectedLocations = [];
  List<String> selectedServiceTypes = [];
  List<dynamic> selectedServiceWithAsPeriod = [];
  List<dynamic>  selectedAsPeriods = []; // AS 기간 선택 변수 추가

  String? selectedLocation;
  String? selectedServiceType;
  String? selectedAsPeriod;

  List<dynamic> areaList = []; // 지역 정보를 담을 리스트
  List<dynamic> areaCd = [];
  List<dynamic> asList = []; // 지역 정보를 담을 리스트
  List<dynamic> asCd = [];
  List<dynamic> codeList = [];
  List<dynamic> categoryList = [];
  String selectedServiceWithAsPeriodCd = "";

  String errorMessage = ''; // 판매자명 오류 메시지 변수
  String areaErrorMessage = ''; // 서비스 지역 오류 메시지 변수
  String serviceErrorMessage = ''; // 서비스 품목 오류 메시지 변수

  // [서비스] 공통코드 조회
  Future<void> getCodeList() async {
    // REST ID
    String restId = "getCodeList";

    // PARAM
    final param = jsonEncode({
      "cdCls": "AREA01,AS01,BIZ01", // DRE01 : 바로견적 설정 횟수
    });

    // API 호출 (바로견적 설정 정보 조회)
    final _codeList = await sendPostRequest(restId, param);

    // 결과 셋팅
    // 결과 셋팅
    if (_codeList != null) {
      setState(() {
        codeList = _codeList;
        // cdCls가 area01인 항목을 areaList에 추가
        areaList = codeList.where((code) => code['cdCls'] == 'AREA01')
            .map((code) => {
          'cdNm': code['cdNm'], // cdNm 값
          'cd': code['cd'],      // cd 값
        }).toList();

        asList = codeList.where((code) => code['cdCls'] == 'AS01')
            .map((code) => {
          'cdNm': code['cdNm'], // 디스플레이값
          'cd': code['cd']      // 실제 저장할 값
        }).toList();

      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("공통코드 조회가 실패하였습니다.")),
      );
    }
  }

  // [서비스] 공통코드 조회
  Future<void> getCategoryList() async {
    // REST ID
    String restId = "getCategoryList";

    // PARAM
    final param = jsonEncode({

    });

    // API 호출 (바로견적 설정 정보 조회)
    final _categoryList = await sendPostRequest(restId, param);

    // 결과 셋팅
    // 결과 셋팅
    if (_categoryList != null) {
      setState(() {
        categoryList = _categoryList;

      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("품목 조회가 실패하였습니다.")),
      );
    }
  }

  void _addLocation() {
    if (selectedLocation != null) {
      // 선택된 지역의 cdNm과 cd 값을 찾기
      final selectedItem = areaList.firstWhere((item) => item['cd'] == selectedLocation);
      setState(() {
        // 선택된 지역 추가
        selectedLocations.add({
          'cdNm': selectedItem['cdNm'], // cdNm 값
          'cd': selectedItem['cd'],      // cd 값
        });
        // 선택된 지역 초기화
        selectedLocation = null;

        // 오류 메시지 초기화
        areaErrorMessage = ''; // 서비스 지역 오류 메시지 초기화
      });
    }
  }

  void _addServiceWithAsPeriod() {
    if (selectedServiceType != null && selectedAsPeriod != null) {
      // 선택된 서비스와 AS 기간을 찾기
      final selectedItem = categoryList.firstWhere(
              (item) => item['categoryId'] == selectedServiceType,
          orElse: () => {'categoryNm': '서비스 없음', 'categoryId': null}); // 기본값 설정

      final selectedAsItem = asList.firstWhere(
              (item) => item['cd'] == selectedAsPeriod,
          orElse: () => {'cdNm': 'AS 기간 없음', 'cd': null}); // 기본값 설정

      // 선택된 서비스와 AS 기간이 유효한지 확인
      if (selectedItem['categoryId'] != null && selectedAsItem['cd'] != null) {
        String combinedService = '${selectedItem['categoryNm']} / ${selectedAsItem['cdNm']}'; // 디스플레이할 값
        String serviceCd = selectedItem['categoryId']; // 저장할 서비스 품목 ID
        String asCd = selectedAsItem['cd']; // 저장할 AS 기간 ID

        setState(() {
          selectedServiceTypes.add(combinedService); // 디스플레이용 추가
          selectedServiceWithAsPeriod.add(combinedService); // 디스플레이용 추가
          selectedServiceWithAsPeriodCd = '$serviceCd / $asCd'; // 실제 저장할 값을 결합
          selectedServiceType = null; // 선택 후 초기화
          selectedAsPeriod = null; // 선택 후 초기화

          serviceErrorMessage = ''; // 서비스 오류 메시지 초기화
        });
      } else {
        // 선택된 서비스 또는 AS 기간이 유효하지 않은 경우
        print("Invalid selection: Service Item or AS Period not found");
      }
    }
  }

  @override
  void initState() {
    /*Firebase.initializeApp().whenComplete(() {
      print("completed");
      setState(() {});
    });*/
    super.initState();
    getCodeList();
    getCategoryList();
  }

  @override
  Widget build(BuildContext context) {
    // 필수 입력 체크를 위한 상태 변수 추가
    bool isStoreNameValid = storeNameController.text.isNotEmpty;
    bool isServiceAreaValid = selectedLocations.isNotEmpty;
    bool isServiceTypeValid = selectedServiceTypes.isNotEmpty;

    return Scaffold(
      backgroundColor: WitHomeTheme.wit_white,
      appBar: AppBar(
        backgroundColor: WitHomeTheme.wit_gray,
        iconTheme: const IconThemeData(color: WitHomeTheme.wit_white),
        title: Text(
          '파트너 등록',
          style: WitHomeTheme.title.copyWith(color: WitHomeTheme.wit_white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '판매자명 (필수)',
                style: WitHomeTheme.title.copyWith(fontSize: 16),

              ),
              SizedBox(height: 8), // 레이블과 카드 사이의 간격
              // 대표자명 입력 필드
              Container(
                decoration: BoxDecoration(
                  color: WitHomeTheme.white, // 배경색을 하얀색으로
                  border: Border.all(color: Colors.grey, width: 1), // 회색 테두리
                  borderRadius: BorderRadius.circular(10), // 모서리 둥글게
                ),
                padding: const EdgeInsets.all(0), // 내부 여백
                child: TextField(
                  style: WitHomeTheme.subtitle.copyWith(fontSize: 16),
                  controller: storeNameController,
                  decoration: InputDecoration(
                    border: InputBorder.none, // 기본 테두리 제거
                    hintText: '판매자명을 입력하세요', // 힌트 텍스트
                    contentPadding: EdgeInsets.only(left: 10), // 왼쪽 패딩만 설정
                  ),
                  onChanged: (text) {
                    setState(() {
                      // 텍스트가 변경될 때마다 오류 메시지 초기화
                      errorMessage = '';
                    });
                  },
                ),

              ),
              // 오류 메시지 표시
              if (errorMessage.isNotEmpty)
                Text(
                  errorMessage,
                  style: WitHomeTheme.subtitle.copyWith(fontSize: 14, color: WitHomeTheme.wit_red),
                ),
              SizedBox(height: 10),
              Text(
                '서비스지역 선택',
                style: WitHomeTheme.title.copyWith(fontSize: 16),
              ),
              SizedBox(height: 8),
// 서비스 지역 선택 위젯
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 1), // 회색 테두리
                        borderRadius: BorderRadius.circular(10), // 모서리 둥글게
                        color: WitHomeTheme.white, // 배경색 하얗게
                      ),
                      padding: EdgeInsets.only(left: 10), // 왼쪽 패딩 설정
                      child: DropdownButton<String>(
                        hint: Text(
                          '서비스 지역 선택',
                          style: WitHomeTheme.subtitle.copyWith(fontSize: 14),
                        ),
                        value: selectedLocation,
                        isExpanded: true, // Dropdown이 가득 차게 설정
                        underline: SizedBox(), // 기본 언더라인 제거
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedLocation = newValue;
                          });
                        },
                        items: areaList.map<DropdownMenuItem<String>>((item) {
                          return DropdownMenuItem<String>(
                            value: item['cd'],
                            child: Container(
                              color: WitHomeTheme.white, // 드롭다운 항목 배경색 하얗게 설정
                              child: Text(item['cdNm']),
                            ),
                          );
                        }).toList(),
                        // 드롭다운의 배경색을 흰색으로 설정
                        dropdownColor: WitHomeTheme.white, // 드롭다운 메뉴 배경색
                      ),
                    ),
                  ),
                  SizedBox(width: 8), // 버튼과의 간격
                  Container(
                    height: 48, // 드롭다운과 높이를 맞추기 위해 설정
                    child: ElevatedButton(
                      onPressed: _addLocation,
                      child: Text(
                        '선택',
                        style: WitHomeTheme.title.copyWith(fontSize: 14, color: WitHomeTheme.wit_white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: WitHomeTheme.wit_lightBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

// 선택된 지역 표시
              Wrap(
                spacing: 8.0,
                children: selectedLocations.map((location) => Container(
                  height: 48, // 선택된 지역의 높이를 선택 버튼과 맞춤
                  child: Chip(
                    label: Text(
                      location['cdNm'],
                      style: WitHomeTheme.title.copyWith(fontSize: 14, color: WitHomeTheme.wit_black),
                    ), // cdNm 값을 가져옴
                    deleteIcon: Icon(Icons.close),
                    backgroundColor: WitHomeTheme.wit_white, // 배경색을 하얀색으로 설정
                    onDeleted: () {
                      setState(() {
                        selectedLocations.remove(location);
                      });
                    },
                  ),
                )).toList(),
              ),

              // 오류 메시지 표시
              if (areaErrorMessage.isNotEmpty)
                Text(
                  areaErrorMessage,
                  style: WitHomeTheme.subtitle.copyWith(fontSize: 14, color: WitHomeTheme.wit_red),
                ),

              SizedBox(height: 10),
              Text(
                '서비스품목 선택',
                style: WitHomeTheme.title.copyWith(fontSize: 16),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  // 서비스 품목 선택 드롭다운
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 1), // 회색 테두리
                        borderRadius: BorderRadius.circular(10), // 모서리 둥글게
                        color: WitHomeTheme.white, // 배경색 하얗게
                      ),
                      padding: EdgeInsets.only(left: 10), // 왼쪽 패딩 설정
                      child: DropdownButton<String>(
                        hint: Text(
                          '서비스 품목 선택',
                          style: WitHomeTheme.subtitle.copyWith(fontSize: 14),
                        ),
                        value: selectedServiceType,
                        isExpanded: true, // Dropdown이 가득 차게 설정
                        underline: SizedBox(), // 기본 언더라인 제거
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedServiceType = newValue; // 서비스 품목 선택
                          });
                        },
                        items: categoryList.map<DropdownMenuItem<String>>((item) {
                          return DropdownMenuItem<String>(
                            value: item['categoryId'],
                            child: Text(item['categoryNm'],
                              style: WitHomeTheme.subtitle.copyWith(fontSize: 16),
                            ),
                          );
                        }).toList(),
                        dropdownColor: WitHomeTheme.white, // 드롭다운 메뉴 배경색

                      ),
                    ),
                  ),
                  SizedBox(width: 8), // 드롭다운과 선택 버튼 사이의 간격
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 1), // 회색 테두리
                        borderRadius: BorderRadius.circular(10), // 모서리 둥글게
                        color: WitHomeTheme.white, // 배경색 하얗게
                      ),
                      padding: EdgeInsets.only(left: 10), // 왼쪽 패딩 설정
                      child: DropdownButton<String>(
                        hint: Text(
                          'AS 기간 선택',
                          style: WitHomeTheme.subtitle.copyWith(fontSize: 14),
                        ),
                        value: selectedAsPeriod,
                        isExpanded: true, // Dropdown이 가득 차게 설정
                        underline: SizedBox(), // 기본 언더라인 제거
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedAsPeriod = newValue; // AS 기간 선택
                          });
                        },
                        items: asList.map<DropdownMenuItem<String>>((item) {
                          return DropdownMenuItem<String>(
                            value: item['cd'],
                            child: Text(item['cdNm'],
                              style: WitHomeTheme.subtitle.copyWith(fontSize: 16),
                            ),
                          );
                        }).toList(),
                        dropdownColor: WitHomeTheme.white, // 드롭다운 메뉴 배경색

                      ),
                    ),
                  ),
                  SizedBox(width: 8), // 드롭다운과 선택 버튼 사이의 간격
                  Container(
                    height: 48, // 드롭다운과 높이를 맞추기 위해 설정
                    child: ElevatedButton(
                      onPressed: _addServiceWithAsPeriod,
                      child: Text(
                        '선택',
                        style: WitHomeTheme.title.copyWith(fontSize: 14, color: WitHomeTheme.wit_white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: WitHomeTheme.wit_lightBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

// 선택된 서비스와 AS 기간 표시
              Wrap(
                spacing: 8.0,
                children: selectedServiceWithAsPeriod.map((service) => Container(
                  height: 48, // 선택된 서비스의 높이를 선택 버튼과 맞춤
                  child: Chip(
                    label: Text(
                      service,
                      style: WitHomeTheme.title.copyWith(fontSize: 14, color: WitHomeTheme.wit_black),
                    ),
                    deleteIcon: Icon(Icons.close),
                    backgroundColor: WitHomeTheme.wit_white, // 배경색을 하얀색으로 설정
                    onDeleted: () {
                      setState(() {
                        selectedServiceWithAsPeriod.remove(service);
                      });
                    },
                  ),
                )).toList(),
              ),


              // 오류 메시지 표시
              if (serviceErrorMessage.isNotEmpty)
                Text(
                  serviceErrorMessage,
                  style: WitHomeTheme.subtitle.copyWith(fontSize: 14, color: WitHomeTheme.wit_red),
                ),

              SizedBox(height: 3),
              Text(
                '* AS 무상 보증 기간을 등록하면 AS 보증 뱃지가 표시됩니다.',
                style: WitHomeTheme.title.copyWith(fontSize: 14,color: WitHomeTheme.nearlysYellow),
              ),
              SizedBox(height: 16),


              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // 필수 입력 체크
                    setState(() {
                      errorMessage = ''; // 오류 메시지 초기화
                      areaErrorMessage = ''; // 서비스 지역 오류 메시지 초기화
                      serviceErrorMessage = ''; // 서비스 품목 오류 메시지 초기화

                      // 필수 입력 체크
                      bool isStoreNameValid = storeNameController.text.isNotEmpty;
                      bool isServiceAreaValid = selectedLocations.isNotEmpty;
                      bool isServiceTypeValid = selectedServiceTypes.isNotEmpty;

                      if (!isStoreNameValid) {
                        errorMessage = '판매자명을 입력해주세요.'; // 오류 메시지 설정
                      }
                      if (!isServiceAreaValid) {
                        areaErrorMessage = '서비스 지역을 선택해주세요.'; // 오류 메시지 설정
                      }
                      if (!isServiceTypeValid) {
                        serviceErrorMessage = '서비스 품목을 선택해주세요.'; // 오류 메시지 설정
                      }

                    });

                    // 오류가 없을 경우 프로필 등록
                    if (errorMessage.isEmpty && areaErrorMessage.isEmpty && serviceErrorMessage.isEmpty) {
                      String storeName = storeNameController.text;
                      String serviceArea = selectedLocations.map((loc) => loc['cdNm']).join(', ');
                      String serviceItem = selectedServiceTypes.join(', ');

                      saveSellerProfile(
                        storeName,
                        serviceArea,
                        serviceItem,
                      );
                    }
                  },
                  child: Text('프로필등록',
                    style: WitHomeTheme.title.copyWith(fontSize: 14, color: WitHomeTheme.wit_white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: WitHomeTheme.wit_lightGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // [서비스]견적 정보 저장
  Future<void> saveSellerProfile(
    dynamic storeName,
    dynamic serviceArea,
    dynamic serviceItem,
  ) async {

    // REST ID
    String restId = "saveSellerProfile";

    String? saveServiceAreaCd = '';
    if (selectedLocations.isNotEmpty && selectedLocations.first['cd'] != null) {
      saveServiceAreaCd = selectedLocations.first['cd']; // 선택된 서비스 지역의 cd
    }

    // AS 기간과 서비스 품목을 선택하고 처리
    List<String> parts = selectedServiceWithAsPeriodCd.split('/');

    String saveServiceItemCd = ''; // 서비스 품목 ID 초기화
    String saveAsGbn = ''; // AS 기간 초기화

    if (parts.length > 0) {
      saveServiceItemCd = parts[0].trim(); // 서비스 품목 ID
    }

    if (parts.length > 1) {
      saveAsGbn = parts[1].trim(); // AS 기간
    }

    // PARAM
    final param = jsonEncode({
      "storeName": storeName,
      "serviceArea": saveServiceAreaCd,
      "serviceItem": saveServiceItemCd,
      "asGbn":saveAsGbn,
    });

    // API 호출
    final response = await sendPostRequest(restId, param);

    if (response != null) {
      // 성공적으로 저장된 경우 처리

      dynamic sllrNo = response; // response에서 ID 값을 가져옴

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("파트너 프로필이 성공적으로 저장되었습니다.")),
      );

      // 상세 화면으로 이동
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SellerProfileInsertContents(sllrNo: sllrNo),
        ),
      );
    } else {
      // 오류 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("파트너 프로필 저장에 실패했습니다.")),
      );
    }
  }
}
