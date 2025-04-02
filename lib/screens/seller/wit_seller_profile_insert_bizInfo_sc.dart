import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_launcher_icons/constants.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sms_autofill/sms_autofill.dart';
import 'package:witibju/screens/seller/wit_seller_profile_detail_sc.dart';
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

      });
    } else {
      // 오류 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("파트너 프로필 조회가 실패하였습니다.")),
      );
    }
  }

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
          "sllrNo": widget.sllrNo,
          "fileInfo": fileInfo,
        });

        // API 호출 (게시판 상세 조회)
        final _bizImageList = await sendPostRequest(restId, param);

        /*if (_bizImageList > 0) {
          // 값이 있을 때 수행할 작업
          print("보드 상세 이미지 리스트에 값이 있습니다");
        } else {
          // 값이 없을 때 수행할 작업
          print("보드 상세 이미지 리스트가 비어 있습니다.");
        }*/

        // 결과 셋팅
        setState(() {
          bizImageList = _bizImageList;
        });

      }
    }
  }

  // [서비스] 사업자 인증 상태 수정
  Future<void> updateBizCertification() async {
    // REST ID
    String restId = "updateBizCertification";

    // PARAM
    final param = jsonEncode({
      "sllrNo": widget.sllrNo,
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
              Container(
                width: double.infinity, // 넓이를 최대로 설정
                padding: EdgeInsets.all(16.0), // 텍스트 주변에 여백 추가
                decoration: BoxDecoration(
                  color: WitHomeTheme.wit_white, // 배경색을 하얀색으로
                  border: Border.all(color: Colors.grey, width: 1), // 회색 테두리
                  borderRadius: BorderRadius.circular(10), // 모서리 둥글게
                ),
                child: Text(
                  '사업자정보를 입력해주세요~\n견적요청시 사장님 회사를 돋보이게\n뱃지도 달아드려요~',
                  style: WitHomeTheme.title.copyWith(fontSize: 16),
                ),
              ),
              SizedBox(height: 8),
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
                      style: WitHomeTheme.title.copyWith(fontSize: 16),
                    ),
                  ),
                  SizedBox(width: 16.0), // 버튼 간격
                  ElevatedButton(
                    onPressed: () async {
                      // 첨부 버튼 클릭 시 이미지 선택
                      /*final XFile? image = await _picker.pickImage(source: ImageSource.camera);

                      if (image != null) {
                        // 이미지가 선택된 경우
                        print('선택된 이미지: ${image.path}');
                        // 이미지 선택 후 추가
                        if (image != null) {
                          setState(() {
                            bizImageList.add({'imagePath': image.path}); // XFile의 경로를 포함하는 맵으로 추가
                          });
                        }*/
                        saveSellerBizImage();
                        // 선택된 이미지 경로 출력
                      /*} else {
                        // 이미지 선택이 취소된 경우
                        print('이미지 선택 취소됨');
                      }*/
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


              // 담당자 연락처 입력란 수정
              SizedBox(height: 16),
              Text(
                '휴대폰 번호',
                style: WitHomeTheme.title.copyWith(fontSize: 16),
              ),
              Column(
                children: [
                  TextField(
                    controller: hp1Controller,
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
                  Align(
                    alignment: Alignment.centerLeft, // 우측 정렬
                    child: Text(
                      '인증 코드 입력',
                      style: WitHomeTheme.title.copyWith(fontSize: 16),
                    ),
                  ),
                  TextField(
                    controller: _smsController,
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
                    String name = nameController.text;
                    String ceoName = ceoNameController.text;
                    String email = emailController.text;
                    String openDate = openDateController.text;
                    String storeCode = storeCodeController.text;
                    String hp1 = hp1Controller.text;
                    String zipCode = receiverZipController.text;
                    String address1 = receiverAddress1Controller.text;
                    String address2 = receiverAddress2Controller.text;
                    // String categoryContent = categoryContentController.text;

                    // 이미지 저장 후 프로필 업데이트
                    await updateSellerProfile(name, ceoName, email, storeCode, hp1, zipCode, address1, address2, openDate);
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

  // [서비스]견적 정보 저장
  Future<void> updateSellerProfile(
      dynamic name,
      dynamic ceoName,
      dynamic email,
      dynamic storeCode,
      dynamic hp1,
      dynamic zipCode,
      dynamic address1,
      dynamic address2,
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
      "hp": hp1,
      "zipCode": zipCode,
      "address1": address1,
      "address2": address2,
      "openDate": openDate,
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
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SellerProfileDetail(sllrNo: widget.sllrNo),
        ),
      );
    } else {
      // 오류 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("파트너 프로필 저장에 실패했습니다.")),
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
