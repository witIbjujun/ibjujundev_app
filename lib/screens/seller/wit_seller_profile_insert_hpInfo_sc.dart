import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_launcher_icons/constants.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:portone_flutter/iamport_certification.dart';
import 'package:portone_flutter/model/certification_data.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:witibju/screens/seller/wit_seller_profile_detail_sc.dart';
import '../../util/wit_api_ut.dart';
import 'package:kpostal/kpostal.dart';

import '../../util/wit_code_ut.dart';
import '../board/wit_board_detail_sc.dart';
import '../common/wit_ImageViewer_sc.dart';
import '../home/wit_home_theme.dart';

class SellerProfileInsertHpInfo extends StatefulWidget {
  final dynamic sllrNo;
  const SellerProfileInsertHpInfo({super.key, required this.sllrNo});

  @override
  State<StatefulWidget> createState() {
    return SellerProfileInsertHpInfoState();
  }
}

class SellerProfileInsertHpInfoState extends State<SellerProfileInsertHpInfo> {
  bool isCertified = false; // 휴대폰 인증 완료 여부

  dynamic sellerInfo;
  String hp = "";
  String zipCode = "";
  String address1 = "";
  String address2 = "";

  TextEditingController hp1Controller = TextEditingController();
  TextEditingController hp2Controller = TextEditingController();
  TextEditingController hp3Controller = TextEditingController();
  TextEditingController zipCodeController = TextEditingController();
  final TextEditingController detailAddressController = TextEditingController();


  TextEditingController receiverZipController = TextEditingController();
  TextEditingController receiverAddress1Controller = TextEditingController();
  TextEditingController receiverAddress2Controller = TextEditingController();

  String hpErrorMessage = '';
  String zipCodeErrorMessage = '';
  String address2ErrorMessage = '';

  @override
  void initState() {
    super.initState();
    getSellerInfo(widget.sllrNo);
  }

  Future<void> getSellerInfo(sllrNo) async {

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
        if(sellerInfo['certificationYn'] == 'Y') {
          isCertified = true;
        }
        hp = sellerInfo['hp'] ?? '';
        hp1Controller.text = hp;

      });
    } else {
      // 오류 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("파트너 프로필 조회가 실패하였습니다.")),
      );
    }
  }

  void _startListeningForSms() async {
    await SmsAutoFill().listenForCode;
  }

  // 본인 인증 시작
  void _startCertification() {
    if (hp1Controller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('휴대폰 번호를 입력해주세요.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            IamportCertification(
              userCode: 'imp47341432', // 네 실제 포트원 userCode로 교체
              data: CertificationData(
                  merchantUid: 'mid_${DateTime
                      .now()
                      .millisecondsSinceEpoch}',
                  phone: hp1Controller.text,
                  company: '포트원', // 또는 원하는 이름
                  mRedirectUrl : 'http://123.com'
              ),
              callback: (Map<String, String> result) {
                if (result['success'] == 'true') {
                  print('인증 성공: $result');
                  setState(() {
                    //isCertified = true;
                    // 인증완료로 데이터 값 수정
                    updateCertificationYn(hp1Controller.text);
                  });
                } else {
                  print('인증 실패: ${result['error_msg']}');
                }
                Navigator.pop(context);
              },
            ),
      ),
    );
  }

  // [서비스] 핸드폰 인증
  Future<void> updateCertificationYn(String hp1) async {
    // REST ID
    String restId = "updateCertificationYn";
    // PARAM
    final param = jsonEncode({
      "sllrNo" : widget.sllrNo,
      "hp" : hp1,
    });

    // API 호출 (바로견적 설정 정보 조회)
    final _certificationYn = await sendPostRequest(restId, param);

    // 결과 셋팅
    // 결과 셋팅
    if (_certificationYn != null) {
      setState(() {
        isCertified = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("본인인증여부 수정이 실패했습니다.")),
      );
    }

    getSellerInfo(widget.sllrNo);
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
                          backgroundColor: 3 == index ? WitHomeTheme.wit_lightGreen : WitHomeTheme.wit_gray,
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
                  color: WitHomeTheme.wit_white, // 배경색을 하얀색으로
                  border: Border.all(color: WitHomeTheme.wit_lightGreen, width: 3), // 회색 테두리
                  borderRadius: BorderRadius.circular(10), // 모서리 둥글게
                ),
                child: Text(
                  '사업자정보를 입력해주세요~\n견적요청시 사장님 회사를 돋보이게\n뱃지도 달아드려요~',
                  style: WitHomeTheme.title.copyWith(fontSize: 16),
                ),
              ),
              SizedBox(height: 10),
              Text(
                '담당자 연락처',
                style: WitHomeTheme.title.copyWith(fontSize: 16),
              ),
              Column(
                children: [
                  TextField(
                    controller: hp1Controller,
                  ),
                  ElevatedButton(
                    onPressed: isCertified ? null : _startCertification,
                    child: Text(
                      isCertified ? '인증 완료' : '본인인증 하기',
                      style: TextStyle(
                        fontSize: 14,
                        color: WitHomeTheme.wit_white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: WitHomeTheme.wit_lightCoral,
                      disabledBackgroundColor: WitHomeTheme.wit_gray, // <-- 추가!
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                ],
              ),

              Text(
                '사업장 주소 (필수)',
                style: WitHomeTheme.title.copyWith(fontSize: 16),
              ),
              SizedBox(height: 8),
              receiverZipTextField(),
              if (zipCodeErrorMessage.isNotEmpty)
                Text(
                  zipCodeErrorMessage,
                  style: WitHomeTheme.subtitle.copyWith(fontSize: 14, color: WitHomeTheme.wit_red),
                ),
              SizedBox(height: 10),
              receiverAddress1TextField(),
              SizedBox(height: 6),
              receiverAddress2TextField(),
              if (address2ErrorMessage.isNotEmpty)
                Text(
                  address2ErrorMessage,
                  style: WitHomeTheme.subtitle.copyWith(fontSize: 14, color: WitHomeTheme.wit_red),
                ),

              SizedBox(height: 10),
              Center( // Center 위젯으로 버튼을 감싸서 가운데 정렬
                child: ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      hpErrorMessage = '';
                      zipCodeErrorMessage = '';
                      address2ErrorMessage = '';

                      bool isHp1 = hp1Controller.text.isNotEmpty;
                      bool isZipCode = receiverZipController.text.isNotEmpty;
                      bool isAddress2 = receiverAddress2Controller.text.isNotEmpty;

                      if (!isHp1) {
                        hpErrorMessage = '휴대폰 번호를 입력해주세요.'; // 오류 메시지 설정
                      }
                      if (!isZipCode) {
                        zipCodeErrorMessage = '우편번호를 입력해주세요.'; // 오류 메시지 설정
                      }
                      if (!isAddress2) {
                        address2ErrorMessage = '상세주소를 입력해주세요.'; // 오류 메시지 설정
                      }
                    });

                    if (hpErrorMessage.isEmpty & zipCodeErrorMessage.isEmpty && address2ErrorMessage.isEmpty)
                    {
                      // 사업자 프로필 변경 로직
                      String hp1 = hp1Controller.text;
                      String zipCode = receiverZipController.text;
                      String address1 = receiverAddress1Controller.text;
                      String address2 = receiverAddress2Controller.text;

                      // 이미지 저장 후 프로필 업데이트
                      await updateSellerProfile(hp1, zipCode, address1, address2);
                    }
                   },
                  child: Text('사업자등록 완료',
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
      dynamic hp1,
      dynamic zipCode,
      dynamic address1,
      dynamic address2,
  ) async {

    // REST ID
    String restId = "updateSellerInfo";

    // PARAM
    final param = jsonEncode({
      "sllrNo": widget.sllrNo,
      "hp": hp1,
      "zipCode": zipCode,
      "address1": address1,
      "address2": address2,
      "regiLevel": "04"
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
      padding: const EdgeInsets.all(0),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              readOnly: true,
              controller: receiverZipController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0), // 원하는 둥근 정도를 설정
                ), // 원하는 둥근 정도를 설정
                hintText: "우편번호",
              ),
            ),
          ),
          // 오류 메시지 표시
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
                borderRadius: BorderRadius.circular(10),
              ),
              backgroundColor: WitHomeTheme.wit_lightBlue,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
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
      padding: const EdgeInsets.all(0.0),
      child: TextFormField(
        controller: receiverAddress1Controller,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0), // 원하는 둥근 정도를 설정
          ),
          hintText: "기본 주소",
        ),
      ),
    );
  }

  Widget receiverAddress2TextField() {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: TextFormField(
        controller: receiverAddress2Controller,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0), // 원하는 둥근 정도를 설정
          ),
          hintText: "상세 주소",
        ),
      ),
    );
  }

}
