import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sms_autofill/sms_autofill.dart';
import 'package:witibju/screens/seller/wit_seller_profile_appbar_sc.dart';
import 'package:witibju/screens/seller/wit_seller_profile_detail_sc.dart';
import '../../util/wit_api_ut.dart';
import 'package:kpostal/kpostal.dart';

import '../../util/wit_code_ut.dart';
import '../common/wit_ImageViewer_sc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:witibju/screens/home/wit_home_theme.dart';

import '../home/wit_home_theme.dart';


class SellerProfileModify extends StatefulWidget {

  final dynamic sllrNo;
  const SellerProfileModify({Key? key, required this.sllrNo}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SellerProfileModifyState();
  }
}

class SellerProfileModifyState extends State<SellerProfileModify> {


  dynamic sellerInfo;
  String storeName = "";
  String serviceArea = "";
  String serviceItem = "";
  String itemPrice1 = "";
  String sllrContent = "";
  String categoryContent = "";
  String sllrImage = "";
  String name = "";
  String ceoName = "";
  String email = "";
  String openDate = "";
  String storeCode = "";
  String storeImage = "";
  String hp = "";
  String zipCode = "";
  String address1 = "";
  String address2 = "";
  String asGbn = "";
  String bizCertification = "";
  String selectedServiceWithAsPeriodCd = "";
  List<dynamic> boardDetailImageList = [];
  List<dynamic> bizImageList = [];
  String buttonText = "인증요청";

  /* 이미지추가 S */
  List<File> _images = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImages(ImageSource source) async {
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _images = pickedFiles.map((pickedFile) => File(pickedFile.path)).toList();
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _images.add(File(pickedFile.path));
      });
    }
  }
  /* 이미지추가 E */

  @override
  void initState() {
    /*Firebase.initializeApp().whenComplete(() {
      print("completed");
      setState(() {});
    });*/
    super.initState();
    _startListeningForSms();
    getCodeList();
    getCategoryList();
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

        // 기본값 설정 및 null 체크
        storeName = sellerInfo['storeName'] ?? '';
        storeNameController.text = storeName;

        serviceArea = sellerInfo['serviceArea'] ?? '';
        serviceItem = sellerInfo['serviceItem'] ?? '';
        asGbn = sellerInfo['asGbn'] ?? '';

        print("serviceItem : " + serviceItem);
        print("asGbn : " + asGbn);

        // 선택된 지역이 있으면 selectedLocations에 추가
        if (serviceArea.isNotEmpty) {
          var matchedArea = areaList.firstWhere(
                (area) => area['cd'] == serviceArea,
            orElse: () => {'cd': '', 'cdNm': ''}, // 매칭되는 값이 없을 경우 기본값 반환
          );

          // matchedArea가 기본값이 아닌 경우에만 추가
          if (matchedArea['cd'] != '') {
            selectedLocations.add(matchedArea); // 매칭된 지역 코드 추가
          }
        }

        // 선택된 서비스 항목과 AS 기간을 매칭하여 추가
        if (serviceItem.isNotEmpty) {
          var matchedServiceItem = categoryList.firstWhere(
                (category) => category['categoryId'] == serviceItem,
            orElse: () => {'categoryId': '', 'categoryNm': ''}, // 기본값으로 빈 Map 반환
          );

          print("Matched matchedServiceItem: $matchedServiceItem");

          if (matchedServiceItem['categoryId'] != '') {
            String serviceName = matchedServiceItem['categoryNm'] ?? 'Unknown Service'; // null 체크 추가
            String serviceNameCd = matchedServiceItem['categoryId'] ?? 'Unknown Service'; // null 체크 추가
            // asGbn이 있을 경우 매칭하여 추가
            String combinedService = serviceName; // 기본값으로 서비스 이름 설정
            String combineCd = serviceNameCd;

            if (asGbn.isNotEmpty) {
              var matchedAsGbn = asList.firstWhere(
                    (as) => as['cd'] == asGbn,
                orElse: () => {'cd': '', 'cdNm': ''}, // 기본값으로 빈 Map 반환
              );

              print("Matched asGbn: $matchedAsGbn");

              if (matchedAsGbn['cd'] != '') {
                String asName = matchedAsGbn['cdNm'] ?? 'Unknown AS'; // null 체크 추가
                String asCd = matchedAsGbn['cd'] ?? 'Unknown AS'; // null 체크 추가
                combinedService += ' ($asName)'; // 예: "서비스 이름 (AS 기간)"
                combineCd += '/$asCd';
              }
            }

            // 최종 조합된 서비스 이름을 리스트에 추가
            selectedServiceWithAsPeriod.add(combinedService);
            selectedServiceWithAsPeriodCd = combineCd;
          }
        }

        // 나머지 필드 설정
        itemPrice1 = sellerInfo['itemPrice1'] ?? '';
        itemPrice1Controller.text = itemPrice1;

        sllrContent = sellerInfo['sllrContent'] ?? '';
        sllrContentController.text = sllrContent;

        categoryContent = sellerInfo['categoryContent'] ?? '';
        categoryContentController.text = categoryContent;

        name = sellerInfo['name'] ?? '';
        nameController.text = name;

        ceoName = sellerInfo['ceoName'] ?? '';
        ceoNameController.text = ceoName;

        email = sellerInfo['email'] ?? '';
        emailController.text = email;

        openDate = sellerInfo['openDate'] ?? '';
        openDateController.text = openDate;

        storeCode = sellerInfo['storeCode'] ?? '';
        storeCodeController.text = storeCode;

        hp = sellerInfo['hp'] ?? '';
        hp1Controller.text = hp;

        zipCode = sellerInfo['zipCode'] ?? '';
        receiverZipController.text = zipCode;

        address1 = sellerInfo['address1'] ?? '';
        receiverAddress1Controller.text = address1;

        address2 = sellerInfo['address2'] ?? '';
        receiverAddress2Controller.text = address2;

        buttonText = sellerInfo['bizCertificationNm'] != null && sellerInfo['bizCertificationNm'].isNotEmpty
            ? sellerInfo['bizCertificationNm']
            : '인증요청';

        getSellerDetailImageList("SR01");
        getSellerDetailImageList("SR02");
      });
    } else {
      // 오류 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("사업자 프로필 조회가 실패하였습니다.")),
      );
    }


  }

  TextEditingController storeNameController = TextEditingController();
  TextEditingController itemPrice1Controller = TextEditingController();
  TextEditingController itemPrice2Controller = TextEditingController();
  TextEditingController itemPrice3Controller = TextEditingController();
  TextEditingController sllrContentController = TextEditingController();
  TextEditingController sllrImageController = TextEditingController();
  TextEditingController categoryContentController = TextEditingController();
  //TextEditingController sllrImageController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController ceoNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController openDateController = TextEditingController();
  TextEditingController storeCodeController = TextEditingController();
  TextEditingController storeImageController = TextEditingController();
  TextEditingController hp1Controller = TextEditingController();
  TextEditingController hp2Controller = TextEditingController();
  TextEditingController hp3Controller = TextEditingController();
  TextEditingController zipCodeController = TextEditingController();

  TextEditingController receiverZipController = TextEditingController();
  TextEditingController receiverAddress1Controller = TextEditingController();
  TextEditingController receiverAddress2Controller = TextEditingController();

  final TextEditingController _smsController = TextEditingController();
  String? _verificationId;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<dynamic> selectedLocations = [];
  List<String> selectedServiceTypes = [];
  List<dynamic> selectedServiceWithAsPeriod = [];
  List<dynamic>  selectedAsPeriods = []; // AS 기간 선택 변수 추가
  List<XFile>? _imageFiles = [];

  String? selectedLocation;
  String? selectedServiceType;
  String? selectedAsPeriod;

  // 샘플 이미지 경로
  final List<String> sampleImages = [
    'assets/seller/aaa.jpg',
    'assets/seller/aaa.jpg',
  ];

  List<dynamic> areaList = []; // 지역 정보를 담을 리스트
  List<dynamic> areaCd = [];
  List<dynamic> asList = []; // 지역 정보를 담을 리스트
  List<dynamic> asCd = [];
  List<dynamic> codeList = [];
  List<dynamic> categoryList = [];


  final TextEditingController generalPriceController = TextEditingController();
  final TextEditingController premiumPriceController = TextEditingController();
  final TextEditingController specialPriceController = TextEditingController();

  final TextEditingController contact1Controller = TextEditingController();
  final TextEditingController contact2Controller = TextEditingController();
  final TextEditingController contact3Controller = TextEditingController();
  final TextEditingController verificationCodeController = TextEditingController();


  // 새로운 변수 추가
  String? selectedPostalCode;
  String? selectedAddress;
  final TextEditingController detailAddressController = TextEditingController();

  void _startListeningForSms() async {
    await SmsAutoFill().listenForCode;
  }

  // firebase
  void _verifyPhone() async {
    await _auth.verifyPhoneNumber(
      phoneNumber: hp1Controller.text,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        _showAlertDialog('인증 완료', '로그인에 성공했습니다.');
      },
      verificationFailed: (FirebaseAuthException e) {
        print('인증 실패: ${e.message}');
        _showAlertDialog('인증 실패', e.message ?? '알 수 없는 오류입니다.');
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
          print("verificationId : " + verificationId);
          print("resendToken : " + resendToken.toString());
          _smsController.text = ""; // 입력란 초기화
        });
        print('코드가 전송되었습니다.');
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() {
          _verificationId = verificationId;
        });
      },
    );
  }

  void _signInWithPhoneNumber() async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _smsController.text,
      );

      await _auth.signInWithCredential(credential);
      _showAlertDialog('로그인 성공', '전화번호 인증에 성공했습니다.');
    } catch (e) {
      print('로그인 실패: $e');
      _showAlertDialog('로그인 실패', '인증 코드가 잘못되었습니다.');
    }
  }

  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  // firebase

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
      });
    }
  }

  Future<List<String>> fetchAddresses(String postalCode) async {
    final response = await http
        .get(Uri.parse('https://api.example.com/postalcode/$postalCode'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // 예시: 주소 목록을 반환
      return List<String>.from(data['addresses']);
    } else {
      throw Exception('주소를 가져오는 데 실패했습니다.');
    }
  }

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
        SnackBar(content: Text("공통코드 조회가 실패하였습니다.")),
      );
    }

    getSellerInfo(widget.sllrNo);
  }

  void _addServiceWithAsPeriod() {
    if (selectedServiceType != null && selectedAsPeriod != null) {
      String combinedService = '$selectedServiceType / $selectedAsPeriod';
      setState(() {
        selectedServiceTypes.add(combinedService);
        selectedServiceType = null; // 선택 후 초기화
        selectedAsPeriod = null; // 선택 후 초기화
      });
    }
  }

  /*void verifyPhoneNumber() {
    // 인증 API 호출 로직
    String phoneNumber = hp1Controller.text;

    // 여기서 API 호출
    // 예시: await ApiService.verifyPhoneNumber(phoneNumber);

    // 인증 코드 요청 후 결과 처리
    // 성공 시 사용자에게 알림 표시
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SellerAppBar(
        sllrNo: widget.sllrNo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
            children: [
              // 회원정보 수정 제목
              Container(
                padding: const EdgeInsets.all(8.0), // 내부 여백
                decoration: BoxDecoration(
                  color: Colors.grey[400], // 회색 배경
                  borderRadius: BorderRadius.circular(5), // 모서리 둥글게
                ),
                child: Center( // 텍스트를 가운데 정렬
                  child: Text(
                    '파트너 프로필 수정',
                    style: WitHomeTheme.title.copyWith(fontSize: 24, color: Colors.black), // 글자 색상을 검은색으로 설정
                  ),
                ),
              ),

              SizedBox(height: 16), // 제목과 아래 요소 간격
              // 대표자명 레이블
              Text(
                '대표자명 (필수)',
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
                    hintText: '대표자명을 입력하세요', // 힌트 텍스트
                    contentPadding: EdgeInsets.only(left: 10), // 왼쪽 패딩만 설정
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text(
                '업체 설명',
                style: WitHomeTheme.title.copyWith(fontSize: 16),
              ),
              SizedBox(height: 8), // 레이블과 카드 사이의 간격
              Container(
                decoration: BoxDecoration(
                  color: WitHomeTheme.white,// 배경색을 하얀색으로
                  border: Border.all(color: Colors.grey, width: 1), // 회색 테두리
                  borderRadius: BorderRadius.circular(10), // 모서리 둥글게
                ),
                padding: const EdgeInsets.all(0), // 내부 여백
                child: TextField(
                  style: WitHomeTheme.subtitle.copyWith(fontSize: 16),
                  controller: sllrContentController,
                  maxLines: 10,
                  decoration: InputDecoration(
                    border: InputBorder.none, // 기본 테두리 제거
                    hintText: '업체 홍보문구를 입력하세요~', // 힌트 텍스트
                    contentPadding: EdgeInsets.all(10), // 왼쪽 패딩만 설정
                  ),
                ),
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
                            child: Text(item['cdNm']),
                          );
                        }).toList(),
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
                          if (newValue != null) {
                            setState(() {
                              selectedServiceType = newValue;
                              final selectedItem2 = categoryList.firstWhere((item) => item['categoryId'] == newValue);
                              selectedServiceTypes.add(selectedItem2['categoryNm']);
                              // AS 기간과 함께 선택된 경우 추가
                              if (selectedAsPeriod != null) {
                                selectedServiceWithAsPeriod.add('${selectedItem2['categoryNm']} / ${asList.firstWhere((item) => item['cd'] == selectedAsPeriod)['cdNm']}');
                              }
                            });
                          }
                        },
                        items: categoryList.map<DropdownMenuItem<String>>((item) {
                          return DropdownMenuItem<String>(
                            value: item['categoryId'],
                            child: Text(item['categoryNm'],
                              style: WitHomeTheme.subtitle.copyWith(fontSize: 16),
                            ),
                          );
                        }).toList(),
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
                            selectedAsPeriod = newValue;
                            // AS 기간과 서비스 품목이 함께 선택된 경우 추가
                            if (selectedServiceType != null) {
                              final selectedItem2 = categoryList.firstWhere((item) => item['categoryId'] == selectedServiceType);
                              selectedServiceWithAsPeriodCd = '${selectedItem2['categoryId']}/${asList.firstWhere((item) => item['cd'] == newValue)['cd']}';
                              selectedServiceWithAsPeriod.add(
                                  '${selectedItem2['categoryNm']} ( ${asList.firstWhere((item) => item['cd'] == newValue)['cdNm']} )'
                              );
                            }
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

              SizedBox(height: 3),
              Text(
                '* AS 무상 보증 기간을 등록하면 AS 보증 뱃지가 표시됩니다.',
                style: WitHomeTheme.title.copyWith(fontSize: 14,color: WitHomeTheme.nearlysYellow),
              ),
              SizedBox(height: 10),
              Text(
                '품목 설명',
                style: WitHomeTheme.title.copyWith(fontSize: 16),
              ),
              SizedBox(height: 8), // 레이블과 카드 사이의 간격
              Container(
                decoration: BoxDecoration(
                  color: WitHomeTheme.wit_white,
                  border: Border.all(color: Colors.grey, width: 1), // 회색 테두리
                  borderRadius: BorderRadius.circular(10), // 모서리 둥글게
                ),
                padding: const EdgeInsets.all(0), // 내부 여백
                child: TextField(
                  style: WitHomeTheme.subtitle.copyWith(fontSize: 16),
                  controller: categoryContentController,
                  maxLines: 10,
                  decoration: InputDecoration(
                    border: InputBorder.none, // 기본 테두리 제거
                    hintText: '판매 품목 설명을 입력하세요~', // 힌트 텍스트
                    contentPadding: EdgeInsets.all(10), // 왼쪽 패딩만 설정
                  ),
                ),
              ),
              SizedBox(height: 10),
              // 이미지 리스트
              SingleChildScrollView(
                scrollDirection: Axis.horizontal, // 가로 스크롤 활성화
                child: Row(
                  children: _images.asMap().entries.map((entry) {
                    int index = entry.key;
                    var image = entry.value;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0), // 이미지 간격
                      child: Stack(
                        children: [
                          ClipRRect( // 모서리 둥글게 만들기
                            borderRadius: BorderRadius.circular(12.0), // 원하는 둥글기 설정
                            child: Image.file(
                              image,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover, // 이미지 비율 유지
                            ),
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: IconButton(
                              icon: Icon(Icons.close, color: WitHomeTheme.nearlysYellow,), // X 아이콘
                              onPressed: () {
                                setState(() {
                                  _images.removeAt(index); // 이미지 삭제
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 16),
              Container(
                height: 120, // 높이 설정
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: boardDetailImageList.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        // 클릭 시 ImageViewer로 이동
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImageViewer(
                              imageUrls: boardDetailImageList.map((item) => apiUrl + item["imagePath"]).toList(),
                              initialIndex: index, // 클릭한 이미지 인덱스 전달
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: 120,
                        height: 120,
                        margin: EdgeInsets.only(right: 8), // 이미지 간격
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12), // 둥글게 처리
                          image: DecorationImage(
                            image: NetworkImage(apiUrl + boardDetailImageList[index]["imagePath"]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.start, // 왼쪽 정렬
                children: [
                  GestureDetector(
                    onTap: () => _pickImages(ImageSource.gallery),
                    child: Column(
                      children: [
                        Icon(Icons.photo, size: 40), // 갤러리 아이콘
                      ],
                    ),
                  ),
                  SizedBox(width: 16), // 아이콘 간격
                  GestureDetector(
                    onTap: () => _pickImage(ImageSource.camera),
                    child: Column(
                      children: [
                        Icon(Icons.camera_alt, size: 40), // 카메라 아이콘
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 10),
              Text(
                '사업자명 (필수)',
                style: WitHomeTheme.title.copyWith(fontSize: 16),

              ),
              SizedBox(height: 8),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
              ),
              Text(
                '대표자명 (필수)',
                style: WitHomeTheme.title.copyWith(fontSize: 16),

              ),
              TextField(
                controller: ceoNameController,
                decoration: InputDecoration(
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
              ),
              SizedBox(height: 10),
              Text(
                '대표 이메일 (필수)',
                style: WitHomeTheme.title.copyWith(fontSize: 16),
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
              ),
              SizedBox(height: 10),
              Text(
                '개업일자 (필수)',
                style: WitHomeTheme.title.copyWith(fontSize: 16),
              ),
              TextField(
                controller: openDateController,
                decoration: InputDecoration(
                  labelText: '개업일자 (필수)',
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '사업자 등록증 사본',
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),
                  SizedBox(width: 16.0), // 버튼 간격
                  ElevatedButton(
                    onPressed: () async {
                      print("12312312312");
                      // 첨부 버튼 클릭 시 이미지 선택
                      final XFile? image = await _picker.pickImage(source: ImageSource.camera);

                      if (image != null) {
                        // 이미지가 선택된 경우
                        print('선택된 이미지: ${image.path}');
                        setState(() {
                          bizImageList.add(image); // 선택된 이미지를 리스트에 추가
                        });
                        saveSellerBizImage();
                        // 선택된 이미지 경로 출력
                      } else {
                        // 이미지 선택이 취소된 경우
                        print('이미지 선택 취소됨');
                      }
                    },
                    child: Text('첨부',
                      style: WitHomeTheme.title.copyWith(fontSize: 14, color: WitHomeTheme.wit_white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: WitHomeTheme.wit_gray,
                    ),
                  ),
                  SizedBox(width: 16.0), // 버튼 간격
                  ElevatedButton(
                    onPressed: () {
                      updateBizCertification(); // 인증 요청 버튼 클릭 시 로직 추가
                    },
                    child: Text(buttonText,
                      style: WitHomeTheme.title.copyWith(fontSize: 14, color: WitHomeTheme.wit_white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: WitHomeTheme.wit_gray,
                    ),
                  ),
                ],
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal, // 가로 스크롤 활성화
                child: Row(
                  children: _images.asMap().entries.map((entry) {
                    int index = entry.key;
                    var image = entry.value;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0), // 이미지 간격
                      child: Stack(
                        children: [
                          ClipRRect( // 모서리 둥글게 만들기
                            borderRadius: BorderRadius.circular(12.0), // 원하는 둥글기 설정
                            child: Image.file(
                              image,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover, // 이미지 비율 유지
                            ),
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: IconButton(
                              icon: Icon(Icons.close, color: Colors.red), // X 아이콘
                              onPressed: () {
                                setState(() {
                                  _images.removeAt(index); // 이미지 삭제
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 16),
              Container(
                height: 120, // 높이 설정
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: bizImageList.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        // 클릭 시 ImageViewer로 이동
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImageViewer(
                              imageUrls: bizImageList.map((item) => apiUrl + item["imagePath"]).toList(),
                              initialIndex: index, // 클릭한 이미지 인덱스 전달
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: 120,
                        height: 120,
                        margin: EdgeInsets.only(right: 8), // 이미지 간격
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12), // 둥글게 처리
                          image: DecorationImage(
                            image: NetworkImage(apiUrl + bizImageList[index]["imagePath"]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // 담당자 연락처 입력란 수정
              SizedBox(height: 16),
              Column(
                children: [
                  TextField(
                    controller: hp1Controller,
                    decoration: InputDecoration(labelText: '휴대폰 번호'),
                  ),
                  ElevatedButton(
                    onPressed: _verifyPhone,
                    child: Text('인증 코드 요청',
                      style: WitHomeTheme.title.copyWith(fontSize: 14, color: WitHomeTheme.wit_white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: WitHomeTheme.wit_lightCoral,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  TextField(
                    controller: _smsController,
                    decoration: InputDecoration(labelText: '인증 코드 입력'),
                    readOnly: false, // 사용자 입력을 방지
                    onTap: () async {
                      await SmsAutoFill().listenForCode; // SMS 코드 수신 시작
                    },
                  ),
                  ElevatedButton(
                    onPressed: _signInWithPhoneNumber,
                    child: Text('인증 코드 확인',
                      style: WitHomeTheme.title.copyWith(fontSize: 14, color: WitHomeTheme.wit_white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: WitHomeTheme.wit_lightCoral,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),

              receiverZipTextField(),
              receiverAddress1TextField(),
              receiverAddress2TextField(),
              SizedBox(height: 20),
              Center( // Center 위젯으로 버튼을 감싸서 가운데 정렬
                child: ElevatedButton(
                      onPressed: () async {
                        // 사업자 프로필 변경 로직
                        String storeName = storeNameController.text;
                        String itemPrice1 = itemPrice1Controller.text;
                        String itemPrice2 = itemPrice2Controller.text;
                        String itemPrice3 = itemPrice3Controller.text;
                        String sllrContent = sllrContentController.text;
                        String sllrImage = sllrImageController.text;
                        String name = nameController.text;
                        String ceoName = ceoNameController.text;
                        String email = emailController.text;
                        String openDate = openDateController.text;
                        String storeCode = storeCodeController.text;
                        String storeImage = storeImageController.text;
                        String hp1 = hp1Controller.text;
                        //String hp2 = hp2Controller.text;
                        //String hp3 = hp13Controller.text;
                        String zipCode = receiverZipController.text;
                        String address1 = receiverAddress1Controller.text;
                        String address2 = receiverAddress2Controller.text;
                        String categoryContent = categoryContentController.text;
                        //String serviceArea = selectedLocations.join(', '); // 리스트를 문자열로 변환
                        //String serviceItem = selectedServiceTypes.join(', '); // 리스트를 문자열로 변환


                        // 이미지 저장 후 프로필 업데이트
                        await saveImages(storeName, itemPrice1, itemPrice2, itemPrice3, sllrContent, sllrImage, name,
                            ceoName, email, storeCode, storeImage, hp1, zipCode, address1, address2, openDate, categoryContent);
                      },
                      child: Text('프로필변경',
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

  // [서비스] 이미지 저장
  Future<void> saveImages(dynamic storeName,
      dynamic itemPrice1,
      dynamic itemPrice2,
      dynamic itemPrice3,
      dynamic sllrContent,
      dynamic sllrImage,
      dynamic name,
      dynamic ceoName,
      dynamic email,
      dynamic storeCode,
      dynamic storeImage,
      dynamic hp1,
      dynamic zipCode,
      dynamic address1,
      dynamic address2,
      dynamic openDate,
      dynamic categoryContent) async {

    // 이미지 확인
    if (_images.isEmpty) {
      // 이미지가 없으면 프로필 업데이트 호출
      updateSellerProfile(
        storeName,
        itemPrice1,
        itemPrice2,
        itemPrice3,
        sllrContent,
        null, // sllrImage는 null로 설정
        name,
        ceoName,
        email,
        storeCode,
        null, // storeImage는 null로 설정
        hp1,
        zipCode,
        address1,
        address2,
        openDate,
        categoryContent,
        null,
      );
    } else {
      final fileInfo = await sendFilePostRequest("fileUpload", _images);
      if (fileInfo == "FAIL") {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("파일 업로드 실패")));
      } else {
        // 파일 업로드 성공, 프로필 업데이트 호출
        updateSellerProfile(
          storeName,
          itemPrice1,
          itemPrice2,
          itemPrice3,
          sllrContent,
          fileInfo, // 업로드된 파일 정보
          name,
          ceoName,
          email,
          storeCode,
          fileInfo, // storeImage도 업로드된 파일 정보 사용
          hp1,
          zipCode,
          address1,
          address2,
          openDate,
          categoryContent,
          fileInfo,
        );
      }
    }
  }

  // 사업자 등록증 이미지 저장
  Future<void> saveSellerBizImage() async {

    // 이미지 확인
    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("사업자등록증을 첨부해주세요.")));

    } else {
      final fileInfo = await sendFilePostRequest("fileUpload", _images);
      if (fileInfo == "FAIL") {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("사업자등록증 업로드 실패")));
      } else {
        String restId = "saveSellerBizImage";

        print("여기 : " + sellerInfo["sllrNo"].toString());

        // PARAM
        final param = jsonEncode({
          "bizCd": "SR02",
          "bizKey": sellerInfo["sllrNo"],
        });

        // API 호출 (게시판 상세 조회)
        final _bizImageList = await sendPostRequest(restId, param);

        if (_bizImageList.isNotEmpty) {
          // 값이 있을 때 수행할 작업
          print("보드 상세 이미지 리스트에 값이 있습니다: ${bizImageList.length}개");
        } else {
          // 값이 없을 때 수행할 작업
          print("보드 상세 이미지 리스트가 비어 있습니다.");
        }

        // 결과 셋팅
        setState(() {
          bizImageList = _bizImageList;
        });

      }
    }
  }

  // [서비스]프로필 변경
  Future<void> updateSellerProfile(
      dynamic storeName,
      dynamic itemPrice1,
      dynamic itemPrice2,
      dynamic itemPrice3,
      dynamic sllrContent,
      dynamic sllrImage,
      dynamic name,
      dynamic ceoName,
      dynamic email,
      dynamic storeCode,
      dynamic storeImage,
      dynamic hp1,
      dynamic zipCode,
      dynamic address1,
      dynamic address2,
      dynamic openDate,
      dynamic categoryContent,
      dynamic fileInfo
      ) async {
    // REST ID
    String restId = "updateSellerInfo";

    // 선택된 지역의 cd 값

    String? serviceArea;
    if (selectedLocations.isNotEmpty && selectedLocations.first['cd'] != null) {
      serviceArea = selectedLocations.first['cd'].toString(); // String으로 변환
    } else {
      serviceArea = ''; // 기본값 설정
    }

    List<String> parts = selectedServiceWithAsPeriodCd.split('/');

// 각각의 변수에 할당
    String serviceItem = parts[0]; // 'CATE001'
    String asGbn = parts[1];       // '01'

    print("update serviceArea: " + serviceArea);
    print("update serviceItem: " + serviceItem);
    print("update asGbn: " + asGbn);



    // PARAM
    final param = jsonEncode({
      "sllrNo": widget.sllrNo,
      "storeName": storeName,
      "serviceArea": serviceArea,
      "serviceItem": serviceItem,
      "itemPrice1": itemPrice1,
      "itemPrice2": itemPrice2,
      "itemPrice3": itemPrice3,
      "sllrContent": sllrContent,
      //"sllrImage": sllrImage,
      "sllrImage": "item_image1",
      "name": name,
      "ceoName": ceoName,
      "email": email,
      "storeCode": storeCode,
      //"storeImage": storeImage,
      "storeImage": "item_image2",
      "hp": hp1,
      "zipCode": zipCode,
      "address1": address1,
      "address2": address2,
      "asGbn": asGbn,
      "openDate": openDate,
      "categoryContent" : categoryContent,
      "fileInfo": fileInfo
    });

    // API 호출
    final response = await sendPostRequest(restId, param);

    if (response != null) {
      // 성공적으로 저장된 경우 처리

      //int sllrNo = response; // response에서 ID 값을 가져옴

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("사업자 프로필이 성공적으로 변경되었습니다.")),
      );

      // 상세 화면으로 이동
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SellerProfileDetail(sllrNo: widget.sllrNo),
        ),
      );
    } else {
      // 오류 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("사업자 프로필 변경에 실패했습니다.")),
      );
    }
  }

  // [서비스] 판매자 상세 이미지 조회
  Future<void> getSellerDetailImageList(dynamic bizCd) async {
    // REST ID
    String restId = "getSellerDetailImageList";

    print("여기 : " + sellerInfo["sllrNo"].toString());

    // PARAM
    final param = jsonEncode({
      "bizCd": bizCd,
      "bizKey": sellerInfo["sllrNo"],
    });

    if(bizCd == "SR01") {
      // API 호출 (게시판 상세 조회)
      final _boardDetailImageList = await sendPostRequest(restId, param);

      if (boardDetailImageList.isNotEmpty) {
        // 값이 있을 때 수행할 작업
        print("보드 상세 이미지 리스트에 값이 있습니다: ${boardDetailImageList.length}개");
      } else {
        // 값이 없을 때 수행할 작업
        print("보드 상세 이미지 리스트가 비어 있습니다.");
      }

      // 결과 셋팅
      setState(() {
        boardDetailImageList = _boardDetailImageList;
      });
    }
    else if(bizCd == "SR02") {
      // API 호출 (게시판 상세 조회)
      final _bizImageList = await sendPostRequest(restId, param);

      if (bizImageList.isNotEmpty) {
        // 값이 있을 때 수행할 작업
        print("보드 상세 이미지 리스트에 값이 있습니다: ${bizImageList.length}개");
      } else {
        // 값이 없을 때 수행할 작업
        print("보드 상세 이미지 리스트가 비어 있습니다.");
      }

      // 결과 셋팅
      setState(() {
        bizImageList = _bizImageList;
      });
    }
  }

  // [서비스] 사업자 인증 상태 수정
  Future<void> updateBizCertification() async {
    // REST ID
    String restId = "updateBizCertification";

    // PARAM
    final param = jsonEncode({
      "sllrNo": sellerInfo["sllrNo"],
      "bizCertification": "01",
    });

    // API 호출 (사업자 인증 상태 수정)
    final response = await sendPostRequest(restId, param);

    if (response != null) {
      print("API 호출 성공");
      print("sellerInfo: $sellerInfo"); // sellerInfo의 상태 출력
      setState(() {
        buttonText = "요청중";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("사업자 인증 요청이 성공하였습니다.")),
      );
    } else {
      print("API 호출 실패");
      // 오류 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("사업자 인증 요청이 실패했습니다.")),
      );
    }
  }

  Widget receiverZipTextField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              readOnly: true,
              controller: receiverZipController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "우편번호",
              ),
            ),
          ),
          const SizedBox(width: 15),
          FilledButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) {
                  return KpostalView(
                    callback: (Kpostal result) {
                      receiverZipController.text = result.postCode;

                      receiverAddress1Controller.text = result.address;
                    },
                  );
                },
              ));
            },
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              backgroundColor: WitHomeTheme.wit_lightBlue,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 22.0),
              child: Text(
                "우편 번호 찾기",
                style: WitHomeTheme.title.copyWith(fontSize: 14, color: WitHomeTheme.wit_white),
              ),
            ),

          ),
        ],
      ),
    );
  }

  Widget receiverAddress1TextField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: receiverAddress1Controller,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: "기본 주소",
        ),
      ),
    );
  }

  Widget receiverAddress2TextField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: receiverAddress2Controller,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: "상세 주소",
        ),
      ),
    );
  }
}
