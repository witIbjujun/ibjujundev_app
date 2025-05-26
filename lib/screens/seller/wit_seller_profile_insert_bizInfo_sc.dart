import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_launcher_icons/constants.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sms_autofill/sms_autofill.dart';
import 'package:witibju/screens/seller/wit_seller_profile_detail_sc.dart';
import 'package:witibju/screens/seller/wit_seller_profile_insert_hpInfo_sc.dart';
import '../../util/wit_api_ut.dart';
import 'package:kpostal/kpostal.dart';

import '../../util/wit_code_ut.dart';
import '../board/wit_board_detail_sc.dart';
import '../common/wit_ImageViewer_sc.dart';
import '../home/wit_home_theme.dart';

class SellerProfileInsertBizInfo extends StatefulWidget {
  final dynamic sllrNo;
  const SellerProfileInsertBizInfo({super.key, required this.sllrNo});

  @override
  State<StatefulWidget> createState() {
    return SellerProfileInsertBizInfoState();
  }
}

class SellerProfileInsertBizInfoState extends State<SellerProfileInsertBizInfo> {
  dynamic sellerInfo;
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
  final TextEditingController detailAddressController = TextEditingController();


  TextEditingController receiverZipController = TextEditingController();
  TextEditingController receiverAddress1Controller = TextEditingController();
  TextEditingController receiverAddress2Controller = TextEditingController();

  final TextEditingController contact1Controller = TextEditingController();
  final TextEditingController contact2Controller = TextEditingController();
  final TextEditingController contact3Controller = TextEditingController();
  final TextEditingController verificationCodeController = TextEditingController();

  final TextEditingController _smsController = TextEditingController();
  String? _verificationId;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String nameErrorMessage = ''; // 오류 메시지 초기화
  String ceoErrorMessage = '';
  String emailErrorMessage = '';
  String openDateErrorMessage = '';
  String hpErrorMessage = '';
  String zipCodeErrorMessage = '';
  String address2ErrorMessage = '';
  String storeCodeErrorMessage = '';

  @override
  void initState() {
    super.initState();
    getSellerInfo();
  }

  Future<void> getSellerInfo() async {

    String restId = "getSellerInfo";
    // PARAM
    final param = jsonEncode({
      "sllrNo": widget.sllrNo,
    });

    print("sllrNo :" + widget.sllrNo.toString());

    // API 호출
    final response = await sendPostRequest(restId, param);

    if (response != null) {
      setState(() {
        sellerInfo = response;

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

        buttonText = sellerInfo['bizCertificationNm'] != null && sellerInfo['bizCertificationNm'].isNotEmpty
            ? sellerInfo['bizCertificationNm']
            : '인증요청';

        // 사업자 등록증 가져오기
        getSellerDetailImageList("SR02");

      });
    } else {
      // 오류 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("파트너 프로필 조회가 실패하였습니다.")),
      );
    }
  }

  // [서비스] 판매자 상세 이미지 조회
  Future<void> getSellerDetailImageList(dynamic bizCd) async {
    // REST ID
    String restId = "getSellerDetailImageList";

    // PARAM
    final param = jsonEncode({
      "bizCd": bizCd,
      "bizKey": sellerInfo["sllrNo"],
    });

    if(bizCd == "SR02") {
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

  /* 이미지추가 S */
  List<File> _images2 = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _images2.add(File(pickedFile.path));
      });
    }
  }

  // 사업자 등록증 이미지 저장
  Future<void> saveSellerBizImage() async {

    // 이미지 확인
    if (_images2.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("사업자등록증을 첨부해주세요.")));

    } else {
      final fileInfo = await sendFilePostRequest("fileUpload", _images2);
      if (fileInfo == "FAIL") {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("사업자등록증 업로드 실패")));
      } else {
        String restId = "saveSellerBizImage";

        print("여기 : " + sellerInfo["sllrNo"].toString());

        // PARAM
        final param = jsonEncode({
          "sllrNo": widget.sllrNo,
          "fileInfo": fileInfo,
        });

        // API 호출 (게시판 상세 조회)
        final _bizImageList = await sendPostRequest(restId, param);

        if (_bizImageList > 0) {
          // 값이 있을 때 수행할 작업
          /*ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("사업자 등록증이 첨부가 성공하였습니다.")),
          );*/

          updateBizCertification();
        } else {
          // 값이 없을 때 수행할 작업
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("사업자 등록증 첨부가 실패하였습니다.")),
          );
        }

        // 결과 셋팅
        /*setState(() {
          bizImageList = _bizImageList;
        });*/

      }
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
      // 인증 상태만 변경 (sellerInfo는 로컬 변수 또는 상태 관리에 따라 다르게 처리 가능)
      setState(() {
        setState(() {
          bizCertification = "01";
          sellerInfo["bizCertification"] = "01";
          buttonText = "요청중";
        });
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

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: WitHomeTheme.wit_white,
      appBar: AppBar(
        backgroundColor: WitHomeTheme.wit_black,
        iconTheme: const IconThemeData(color: WitHomeTheme.wit_white),
        title: Text(
          '파트너 사업자 정보 등록',
          style: WitHomeTheme.title.copyWith(color: WitHomeTheme.wit_white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(4, (index) {
                  return Expanded(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 18.0,
                          backgroundColor: 2 == index ? WitHomeTheme.wit_lightGreen : WitHomeTheme.wit_gray,
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 8.0),
                      ],
                    ),
                  );
                }),
              ),
              const Divider(height: 32.0),
              /*Container(
                width: double.infinity, // 넓이를 최대로 설정
                padding: EdgeInsets.all(16.0), // 텍스트 주변에 여백 추가
                decoration: BoxDecoration(
                  color: WitHomeTheme.wit_white, // 배경색을 하얀색으로
                  border: Border.all(color: WitHomeTheme.wit_lightGreen, width: 3), // 회색 테두리
                  borderRadius: BorderRadius.circular(10), // 모서리 둥글게
                ),
                child: Text(
                  '입주전에서 사용할 판매자 정보를 입력해주세요.',
                  style: WitHomeTheme.title.copyWith(fontSize: 16),
                ),
              ),*/
              Container(
                  width: double.infinity, // 넓이를 최대로 설정
                  padding: EdgeInsets.all(16.0), // 텍스트 주변에 여백 추가
                  decoration: BoxDecoration(
                    color: WitHomeTheme.wit_lightGreen, //Colors.lightGreen[100], // 연한 녹색 배경
                    borderRadius: BorderRadius.circular(10), // 모서리 둥글게
                  ),
                  child: Text(
                    '사업자정보를 입력해주세요~\n견적요청시 사장님 회사를 돋보이게\n뱃지도 달아드려요~',
                    style: WitHomeTheme.title.copyWith(fontSize: 16),
                  ),
              ),

              SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    '사업자명 ',
                    style: WitHomeTheme.title.copyWith(fontSize: 16),
                  ),
                  Icon(
                    Icons.star,
                    color: Colors.red,
                    size: 16,
                  ),
                ],
              ),

              SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: WitHomeTheme.white, // 배경색을 하얀색으로
                  border: Border.all(color: Colors.grey, width: 1), // 회색 테두리
                  borderRadius: BorderRadius.circular(10), // 모서리 둥글게
                ),
                padding: const EdgeInsets.all(0), // 내부 여백
                child: TextField(
                  style: WitHomeTheme.subtitle.copyWith(fontSize: 16),
                  controller: nameController,
                  decoration: InputDecoration(
                    border: InputBorder.none, // 기본 테두리 제거
                    hintText: '사업자명을 입력하세요', // 힌트 텍스트
                    contentPadding: EdgeInsets.only(left: 10), // 왼쪽 패딩만 설정
                  ),
                  onChanged: (text) {
                    setState(() {
                      // 텍스트가 변경될 때마다 오류 메시지 초기화
                      nameErrorMessage = '';
                    });
                  },
                ),

              ),
              // 오류 메시지 표시
              if (nameErrorMessage.isNotEmpty)
                Text(
                  nameErrorMessage,
                  style: WitHomeTheme.subtitle.copyWith(fontSize: 14, color: WitHomeTheme.wit_red),
                ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    '대표자명 ',
                    style: WitHomeTheme.title.copyWith(fontSize: 16),
                  ),
                  Icon(
                    Icons.star,
                    color: Colors.red,
                    size: 16,
                  ),
                ],
              ),
              SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: WitHomeTheme.white, // 배경색을 하얀색으로
                  border: Border.all(color: Colors.grey, width: 1), // 회색 테두리
                  borderRadius: BorderRadius.circular(10), // 모서리 둥글게
                ),
                padding: const EdgeInsets.all(0), // 내부 여백
                child: TextField(
                  style: WitHomeTheme.subtitle.copyWith(fontSize: 16),
                  controller: ceoNameController,
                  decoration: InputDecoration(
                    border: InputBorder.none, // 기본 테두리 제거
                    hintText: '대표자명을 입력하세요', // 힌트 텍스트
                    contentPadding: EdgeInsets.only(left: 10), // 왼쪽 패딩만 설정
                  ),
                  onChanged: (text) {
                    setState(() {
                      // 텍스트가 변경될 때마다 오류 메시지 초기화
                      ceoErrorMessage = '';
                    });
                  },
                ),

              ),
              // 오류 메시지 표시
              if (ceoErrorMessage.isNotEmpty)
                Text(
                  ceoErrorMessage,
                  style: WitHomeTheme.subtitle.copyWith(fontSize: 14, color: WitHomeTheme.wit_red),
                ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    '대표 이메일 ',
                    style: WitHomeTheme.title.copyWith(fontSize: 16),
                  ),
                  Icon(
                    Icons.star,
                    color: Colors.red,
                    size: 16,
                  ),
                ],
              ),
              SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: WitHomeTheme.white, // 배경색을 하얀색으로
                  border: Border.all(color: Colors.grey, width: 1), // 회색 테두리
                  borderRadius: BorderRadius.circular(10), // 모서리 둥글게
                ),
                padding: const EdgeInsets.all(0), // 내부 여백
                child: TextField(
                  style: WitHomeTheme.subtitle.copyWith(fontSize: 16),
                  controller: emailController,
                  decoration: InputDecoration(
                    border: InputBorder.none, // 기본 테두리 제거
                    hintText: '대표 이메일을 입력하세요', // 힌트 텍스트
                    contentPadding: EdgeInsets.only(left: 10), // 왼쪽 패딩만 설정
                  ),
                  onChanged: (text) {
                    setState(() {
                      // 텍스트가 변경될 때마다 오류 메시지 초기화
                      emailErrorMessage = '';
                    });
                  },
                ),

              ),
              // 오류 메시지 표시
              if (emailErrorMessage.isNotEmpty)
                Text(
                  emailErrorMessage,
                  style: WitHomeTheme.subtitle.copyWith(fontSize: 14, color: WitHomeTheme.wit_red),
                ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    '개업일자 ',
                    style: WitHomeTheme.title.copyWith(fontSize: 16),
                  ),
                  Icon(
                    Icons.star,
                    color: Colors.red,
                    size: 16,
                  ),
                ],
              ),
              SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: WitHomeTheme.white, // 배경색을 하얀색으로
                  border: Border.all(color: Colors.grey, width: 1), // 회색 테두리
                  borderRadius: BorderRadius.circular(10), // 모서리 둥글게
                ),
                padding: const EdgeInsets.all(0), // 내부 여백
                child: TextField(
                  style: WitHomeTheme.subtitle.copyWith(fontSize: 16),
                  controller: openDateController,
                  decoration: InputDecoration(
                    border: InputBorder.none, // 기본 테두리 제거
                    hintText: '개업일자를 입력하세요', // 힌트 텍스트
                    contentPadding: EdgeInsets.only(left: 10), // 왼쪽 패딩만 설정
                  ),
                  onChanged: (text) {
                    setState(() {
                      // 텍스트가 변경될 때마다 오류 메시지 초기화
                      openDateErrorMessage = '';
                    });
                  },
                ),

              ),
              // 오류 메시지 표시
              if (openDateErrorMessage.isNotEmpty)
                Text(
                  openDateErrorMessage,
                  style: WitHomeTheme.subtitle.copyWith(fontSize: 14, color: WitHomeTheme.wit_red),
                ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    '사업자등록번호 ',
                    style: WitHomeTheme.title.copyWith(fontSize: 16),
                  ),
                  Icon(
                    Icons.star,
                    color: Colors.red,
                    size: 16,
                  ),
                ],
              ),
              SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: WitHomeTheme.white, // 배경색을 하얀색으로
                  border: Border.all(color: Colors.grey, width: 1), // 회색 테두리
                  borderRadius: BorderRadius.circular(10), // 모서리 둥글게
                ),
                padding: const EdgeInsets.all(0), // 내부 여백
                child: TextField(
                  style: WitHomeTheme.subtitle.copyWith(fontSize: 16),
                  controller: storeCodeController,
                  decoration: InputDecoration(
                    border: InputBorder.none, // 기본 테두리 제거
                    hintText: '사업자등록번호를 입력하세요', // 힌트 텍스트
                    contentPadding: EdgeInsets.only(left: 10), // 왼쪽 패딩만 설정
                  ),
                  onChanged: (text) {
                    setState(() {
                      // 텍스트가 변경될 때마다 오류 메시지 초기화
                      storeCodeErrorMessage = '';
                    });
                  },
                ),

              ),
              // 오류 메시지 표시
              if (storeCodeErrorMessage.isNotEmpty)
                Text(
                  storeCodeErrorMessage,
                  style: WitHomeTheme.subtitle.copyWith(fontSize: 14, color: WitHomeTheme.wit_red),
                ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '사업자 등록증 사본',
                      style: WitHomeTheme.title.copyWith(fontSize: 16),
                    ),
                  ),
                  SizedBox(width: 16.0), // 버튼 간격
                  /*ElevatedButton(
                    onPressed: (sellerInfo != null &&
                        (sellerInfo['bizCertification'] == '04' ||
                            sellerInfo['bizCertification'] == null ||
                            sellerInfo['bizCertification'].toString().isEmpty))
                        ? () async {
                      // 이미지 저장 함수 호출
                      saveSellerBizImage();
                    }
                        : null, // 비활성화
                    child: Text(
                      '첨부',
                      style: WitHomeTheme.title.copyWith(
                        fontSize: 14,
                        color: WitHomeTheme.wit_white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: WitHomeTheme.wit_lightBlue,
                      disabledBackgroundColor: WitHomeTheme.wit_gray,
                      disabledForegroundColor: WitHomeTheme.wit_white,
                    ),
                  ),
                  SizedBox(width: 16.0), // 버튼 간격*/
                  ElevatedButton(
                    onPressed: (sellerInfo != null &&
                        (sellerInfo['bizCertification'] == '04' ||
                            sellerInfo['bizCertification'] == null ||
                            sellerInfo['bizCertification'].toString().isEmpty))
                        ? () {
                      saveSellerBizImage();
                      // updateBizCertification(); // 인증 요청 로직
                    }
                        : null, // 비활성화 (회색 + 클릭 안됨)
                    child: Text(
                      buttonText,
                      style: WitHomeTheme.title.copyWith(
                        fontSize: 14,
                        color: WitHomeTheme.wit_white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: WitHomeTheme.wit_lightBlue,
                      disabledBackgroundColor: WitHomeTheme.wit_gray, // 비활성화일 때 색상 지정
                      disabledForegroundColor: WitHomeTheme.wit_white, // 비활성화 텍스트 색상
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10,),
              Container(
                height: 120, // 높이 설정
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // 카메라 아이콘
                      GestureDetector(
                        onTap: () => _showImagePickerOptions2(),
                        child: Container(
                          width: 100,
                          height: 100,
                          margin: EdgeInsets.only(right: 8), // 이미지 간격
                          decoration: BoxDecoration(
                            color: WitHomeTheme.wit_white,
                            border: Border.all(width: 1, color: WitHomeTheme.wit_lightgray),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.add_a_photo, size: 40, color: WitHomeTheme.wit_gray), // 사진기 아이콘
                          alignment: Alignment.center,
                        ),
                      ),
                      // 등록된 이미지 리스트
                      ...bizImageList.asMap().entries.map((entry) {
                        int index = entry.key;
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
                      }).toList(),
                      // 선택한 이미지 리스트
                      ..._images2.asMap().entries.map((entry) {
                        int index = entry.key;
                        var image = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0), // 이미지 간격
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12.0), // 원하는 둥글기 설정
                                child: Image.file(
                                  image,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover, // 이미지 비율 유지
                                ),
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: IconButton(
                                  icon: Icon(Icons.close, color: WitHomeTheme.wit_red), // X 아이콘
                                  onPressed: () {
                                    setState(() {
                                      _images2.removeAt(index); // 이미지 삭제
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),

              /*Container(
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
                              imageUrls: bizImageList.map((item) => apiUrl + item['imagePath']).toList(),
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
                            image: NetworkImage(apiUrl + bizImageList[index]['imagePath']),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),*/
              SizedBox(height: 6),
              Container(
                width: double.infinity, // 넓이를 최대로 설정
                padding: EdgeInsets.all(16.0), // 텍스트 주변에 여백 추가
                decoration: BoxDecoration(
                  color: Colors.grey[200], // 배경색을 하얀색으로
                  //border: Border.all(color: Colors.grey, width: 1), // 회색 테두리
                  borderRadius: BorderRadius.circular(10), // 모서리 둥글게
                ),
                child: Text(
                  '* 사업자 인증 후 전문업체 뱃지가 표시됩니다.',
                  style: WitHomeTheme.title.copyWith(fontSize: 16),
                ),
              ),
              SizedBox(height: 20),

              Center( // Center 위젯으로 버튼을 감싸서 가운데 정렬
                child: ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      nameErrorMessage = ''; // 오류 메시지 초기화
                      ceoErrorMessage = '';
                      emailErrorMessage = '';
                      openDateErrorMessage = '';
                      storeCodeErrorMessage = '';

                      bool isNameValid = nameController.text.isNotEmpty;
                      bool isCeoName = ceoNameController.text.isNotEmpty;
                      bool isEmail = emailController.text.isNotEmpty;
                      bool isOpenDate = openDateController.text.isNotEmpty;
                      bool isStoreCode = storeCodeController.text.isNotEmpty;

                      if (!isNameValid) {
                        nameErrorMessage = '사업자명을 입력해주세요.'; // 오류 메시지 설정
                      }
                      if (!isCeoName) {
                        ceoErrorMessage = '대표자명을 입력해주세요.'; // 오류 메시지 설정
                      }
                      if (!isEmail) {
                        emailErrorMessage = '대표 이메일을 입력해주세요.'; // 오류 메시지 설정
                      }
                      if (!isOpenDate) {
                        openDateErrorMessage = '개업일자를 입력해주세요.'; // 오류 메시지 설정
                      }
                      if (!isStoreCode) {
                        storeCodeErrorMessage = '사업자등록번호를 입력해주세요.'; // 오류 메시지 설정
                      }

                    });

                    if (nameErrorMessage.isEmpty && ceoErrorMessage.isEmpty && emailErrorMessage.isEmpty
                    && openDateErrorMessage.isEmpty && storeCodeErrorMessage.isEmpty)
                    {
                      // 사업자 프로필 변경 로직
                      String name = nameController.text;
                      String ceoName = ceoNameController.text;
                      String email = emailController.text;
                      String openDate = openDateController.text;
                      String storeCode = storeCodeController.text;

                      // 이미지 저장 후 프로필 업데이트
                      await updateSellerProfile(name, ceoName, email, storeCode, openDate);
                    }
                   },
                  child: Text('다음',
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
  Future<void> updateSellerProfile(
      dynamic name,
      dynamic ceoName,
      dynamic email,
      dynamic storeCode,
      dynamic openDate,
      // dynamic categoryContent,
  ) async {

    // REST ID
    String restId = "updateSellerInfo";

    // PARAM
    final param = jsonEncode({
      "sllrNo": widget.sllrNo,
      "name": name,
      "ceoName": ceoName,
      "email": email,
      "storeCode": storeCode,
      "openDate": openDate,
      "regiLevel": "03"
//      "categoryContent" : categoryContent,
    });

    // API 호출
    final response = await sendPostRequest(restId, param);

    if (response != null) {
      // 성공적으로 저장된 경우 처리

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("파트너 프로필이 성공적으로 저장되었습니다.")),
      );

      // 상세 화면으로 이동
      // 상세 화면으로 이동
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SellerProfileInsertHpInfo(sllrNo: widget.sllrNo),
        ),
      );
    } else {
      // 오류 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("파트너 프로필 저장에 실패했습니다.")),
      );
    }
  }

  // [팝업] 갤러리, 카메라 팝업 호출
  void _showImagePickerOptions2() {
    showModalBottomSheet(
      context: context,
      backgroundColor: WitHomeTheme.wit_white,
      builder: (BuildContext context) {
        return Container(
          height: 150,
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.photo),
                title: Text('갤러리에서 선택',
                    style: WitHomeTheme.title),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera),
                title: Text('사진 찍기',
                    style: WitHomeTheme.title),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
