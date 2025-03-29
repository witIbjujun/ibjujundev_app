import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:witibju/screens/seller/wit_seller_cash_recharge_sc.dart';
import 'package:flutter/material.dart';
import 'package:witibju/screens/seller/wit_seller_profile_appbar_sc.dart';
import 'package:witibju/screens/seller/wit_seller_profile_view_sc.dart';

// import '../../main_toss.dart';
import '../../util/wit_api_ut.dart';
import 'package:witibju/screens/seller/wit_seller_profile_detail_sc.dart';

import '../../util/wit_code_ut.dart';
import '../board/wit_board_detail_sc.dart';
import '../chat/chatMain.dart';
import '../common/wit_ImageViewer_sc.dart';
import '../home/wit_home_theme.dart';


/* 이미지추가 S */
List<File> _images = [];
final ImagePicker _picker = ImagePicker();
class EstimateRequestDetail extends StatefulWidget {
  final String estNo;
  final String seq;
  final String sllrNo;

  const EstimateRequestDetail({Key? key, required this.estNo, required this.seq, required this.sllrNo}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return EstimateRequestDetailState();
  }
}

class EstimateRequestDetailState extends State<EstimateRequestDetail> {
  Map estimateRequestInfoForSend = new Map<String, dynamic>();

  TextEditingController itemPrice1Controller = TextEditingController();
  TextEditingController estimateContentController = TextEditingController();

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
    super.initState();
    // 견적 상세 조회
    getEstimateRequestInfoForSend(widget.estNo, widget.seq);
  }

  @override
  void dispose() {
    _images.clear(); // 화면이 종료될 때 이미지 리스트 초기화
    itemPrice1Controller.dispose();
    estimateContentController.dispose();
    super.dispose();
  }

  bool _isChecked = false; // 체크박스 상태 관리

  void _onCheckboxChanged(bool? value) {
    setState(() {
      _isChecked = value ?? false;
    });

    // 체크박스가 체크되었을 때 프로필 불러오는 로직 추가
    if (_isChecked) {
      _loadProfile();
    }
  }

  void _loadProfile() {
    // 여기에 프로필을 불러오는 로직 추가
    print("프로필을 불러옵니다."); // 예시로 콘솔에 출력
  }

  @override
  Widget build(BuildContext context) {
    String estNo = estimateRequestInfoForSend['estNo'] ?? "";
    String seq = estimateRequestInfoForSend['seq'] ?? "";
    String aptName = estimateRequestInfoForSend['aptName'] ?? "고객 APT 정보 없음";
    String reqContents = estimateRequestInfoForSend['reqContents'] ??
        "content 정보 없음";
    String itemImage = estimateRequestInfoForSend['itemImage'] ??
        "itemImage 정보 없음";
    String itemName = estimateRequestInfoForSend['itemName'] ??
        "itemName 정보 없음";
    String estimateContent = estimateRequestInfoForSend['estimateContent'] ??
        "";
    String itemPrice1 = estimateRequestInfoForSend['itemPrice1'] ?? "";
    String sllrNo = estimateRequestInfoForSend['sllrNo'] ?? "sllrNo 정보 없음";
    String sllrClerkNo = estimateRequestInfoForSend['sllrClerkNo'] ??
        "itemPrice1 정보 없음";
    String reqState = estimateRequestInfoForSend['reqState'] ??
        "reqState 정보 없음";

    // 입력 필드에 초기값 설정
    if (reqState != "01") {
      itemPrice1Controller.text = itemPrice1; // reqState가 01이 아닐 때 기존 값 표시
      estimateContentController.text = estimateContent; // 기존 설명 표시
    }

    return
      Scaffold(
        backgroundColor: WitHomeTheme.wit_white,

        /*appBar: SellerAppBar(
          sllrNo: widget.sllrNo,
        ),*/
        appBar: AppBar(
          backgroundColor: WitHomeTheme.wit_gray,
          iconTheme: const IconThemeData(color: WitHomeTheme.wit_white),
          title: Text(
            '견적 요청 상세',
            style: WitHomeTheme.title.copyWith(color: WitHomeTheme.wit_white),
          ),
          automaticallyImplyLeading: true,  // <<--- 뒤로가기 버튼 자동 추가
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100], // 배경색을 회색으로 설정
                      borderRadius: BorderRadius.circular(8), // 모서리를 둥글게 설정
                    ),
                    padding: const EdgeInsets.all(12.0), // 여백 설정 (필요에 따라 조정)
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 첫 번째 Row: 프로필 사진과 요청 정보
                        Row(
                          children: [
                            // 왼쪽에 사진
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
                            SizedBox(width: 10), // 이미지와 텍스트 사이의 간격 추가
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 날짜를 이름 위로 배치
                                  Text(
                                    estimateRequestInfoForSend['estDt'] ?? '날짜 없음', // 날짜
                                    style: WitHomeTheme.title.copyWith(fontSize: 12, color: WitHomeTheme.wit_gray),
                                  ),
                                  SizedBox(height: 4), // 날짜와 이름 사이의 간격
                                  Text(
                                    estimateRequestInfoForSend['prsnName'] ?? '요청자명 없음', // 요청자명
                                    style: WitHomeTheme.title.copyWith(fontSize: 18),
                                  ),
                                  SizedBox(height: 1), // 이름과 아파트명 사이의 간격
                                  Text(
                                    estimateRequestInfoForSend['aptName'] ?? '아파트명 없음', // 아파트명
                                    style: WitHomeTheme.title.copyWith(fontSize: 12, color: WitHomeTheme.wit_gray),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 10), // 상태 텍스트와의 간격
                            TextButton(
                              onPressed: () {
                                // 버튼 클릭 시 동작
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero, // 패딩을 0으로 설정하여 간격 줄이기
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(0), // 테두리 없애기
                                ),
                              ),
                              child: Text(
                                estimateRequestInfoForSend['stat'] ?? '상태 없음', // 상태
                                style: WitHomeTheme.title.copyWith(fontSize: 14, color: WitHomeTheme.wit_lightBlue),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10), // 텍스트와 내용 사이의 간격
                        // 두 번째 Container: 작업 요청 내용
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[300], // 배경색을 회색으로 설정
                            borderRadius: BorderRadius.circular(8), // 모서리를 둥글게 설정
                          ),                          padding: EdgeInsets.all(12), // 내부 여백
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
                            children: [
                              Align(
                                alignment: Alignment.centerLeft, // 왼쪽 정렬
                                child: Text(
                                  reqContents, // 내용
                                  style: WitHomeTheme.subtitle.copyWith(fontSize: 14),
                                  textAlign: TextAlign.left, // 텍스트 왼쪽 정렬
                                ),
                              ),
                              SizedBox(height: 15), // 내용과 작업 요청 예상일 사이의 간격
                              Text(
                                "작업요청예상일 : 2025/02/10", // 작업 요청 예상일
                                style: WitHomeTheme.title.copyWith(fontSize: 16), // 스타일 적용
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (reqState == "01") ...[ // 조건이 만족할 때만 해당 위젯을 추가
                    Row(
                      children: [
                        Checkbox(
                          value: _isChecked,
                          onChanged: (bool? value) {
                            setState(() {
                              _isChecked = value ?? false; // 체크 상태 업데이트
                            });
                          },
                          activeColor: Colors.blue, // 체크박스 체크 시 색상 설정
                        ),
                        Text(
                          "프로필 자동 붙이기",
                          style: WitHomeTheme.title.copyWith(fontSize: 16),
                        ),
                      ],
                    ),
                    // 체크박스가 체크된 경우 SellerProfileView 표시
                    if (_isChecked)
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black), // 테두리 색상 설정
                          borderRadius: BorderRadius.circular(2), // 둥근 모서리 설정
                        ),
                        constraints: BoxConstraints(
                          minHeight: 100, // 최소 높이 설정
                          maxHeight: 800, // 최대 높이 설정
                        ),
                        child: SellerProfileView(sllrNo : widget.sllrNo, appbarYn: "N"),
                      ),
                  ],

                  SizedBox(height: 5),
                  // 금액 입력란 카드
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[100], // 배경색을 회색으로 설정
                      borderRadius: BorderRadius.circular(8), // 모서리를 둥글게 설정
                    ),
                    child: Row(
                      children: [
                        Text(
                          "견적금액",
                          style: WitHomeTheme.title.copyWith(fontSize: 16, color: WitHomeTheme.wit_lightSteelBlue),
                        ),
                        SizedBox(width: 5), // 텍스트와 입력란 사이의 간격
                        Expanded( // Expanded 사용하여 공간을 차지하도록 설정
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Expanded( // 금액 입력란을 꽉 채우도록 설정
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300], // 배경색을 회색으로 설정
                                    borderRadius: BorderRadius.circular(8), // 모서리를 둥글게 설정
                                  ),
                                  child: TextField(
                                    style: WitHomeTheme.subtitle.copyWith(fontSize: 16),
                                    textAlign: TextAlign.right, // 텍스트 오른쪽 정렬
                                    controller: itemPrice1Controller,
                                    decoration: InputDecoration(
                                      hintText: "금액을 입력하세요",
                                      hintStyle: WitHomeTheme.subtitle.copyWith(fontSize: 16),
                                      border: InputBorder.none, // 테두리 없애기
                                      filled: true, // 배경색을 적용하기 위해 filled 속성 추가
                                      fillColor: Colors.transparent, // 배경색을 투명으로 설정
                                      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10), // 패딩 설정
                                    ),
                                    keyboardType: TextInputType.number,
                                    enabled: reqState == "01", // reqState가 01일 때만 활성화
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly, // 숫자만 입력 가능
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                "원",
                                style: WitHomeTheme.title.copyWith(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 10),
                  // 견적 내용 입력란 카드
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[100], // 배경색을 회색으로 설정
                      borderRadius: BorderRadius.circular(8), // 모서리를 둥글게 설정
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "견적 추가 설명",
                          style: WitHomeTheme.title.copyWith(fontSize: 16, color: WitHomeTheme.wit_lightSteelBlue),
                        ),
                        SizedBox(height: 10),
                        Container(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[300], // 배경색을 회색으로 설정
                              borderRadius: BorderRadius.circular(8), // 모서리를 둥글게 설정
                            ),
                            child: TextField(
                              style: WitHomeTheme.subtitle.copyWith(fontSize: 16),
                              controller: estimateContentController,
                              minLines: 3, // 최소 3줄
                              maxLines: null, // 내용에 따라 자동으로 늘어남
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: '여기에 추가 설명을 입력하세요',
                                hintStyle: WitHomeTheme.subtitle.copyWith(fontSize: 16),
                                contentPadding: EdgeInsets.all(8),
                                enabled: reqState == "01", // reqState가 01일 때만 활성화
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "* 업체 전화번호나 위치 설명 금지",
                    style: WitHomeTheme.subtitle.copyWith(fontSize: 14, color: WitHomeTheme.wit_red),
                  ),
                  SizedBox(height: 5),
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
                  boardDetailImageList.isNotEmpty
                      ? Container(
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
                  ):
                  SizedBox(height: 16),
                  if (reqState == "01") ...[ // reqState가 "01"일 때만 이 부분이 렌더링됨
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
                  ],
                  SizedBox(height: 20),
                  Center(
                    child: reqState == "05" ? Container() : ElevatedButton(
                      //onPressed: (reqState == "03" || reqState == "04") ? null : () {
                      onPressed: (reqState == "04") ? null : () {
                        String sllrNo = estimateRequestInfoForSend['companyId'] ?? "";
                        String sllrClerkNo = estimateRequestInfoForSend['sllrClerkNo'] ?? "";
                        String estNo = estimateRequestInfoForSend['estNo'] ?? "";
                        String seq = estimateRequestInfoForSend['seq'] ?? "";
                        String estimateContent = estimateContentController.text;
                        String inputItemPrice1 = itemPrice1Controller.text;

                        if (reqState == "01") {
                          // 견적 보내기 로직
                          updateEstimateInfo(
                              sllrNo,
                              sllrClerkNo,
                              estNo,
                              seq,
                              estimateContent,
                              inputItemPrice1,
                              '02' // 상태를 '02'로 변경
                          );
                        } else if (reqState == "02") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ChatPage()),
                          );
                          // 작업 진행 로직
/*                          updateEstimateInfo(
                              sllrNo,
                              sllrClerkNo,
                              estNo,
                              seq,
                              estimateContent,
                              inputItemPrice1,
                              '03' // 상태를 '05'로 변경
                          );*/
                        } else if (reqState == "03") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ChatPage()),
                          );
                        // 작업 진행 로직
                          /*updateEstimateInfo(
                              sllrNo,
                              sllrClerkNo,
                              estNo,
                              seq,
                              estimateContent,
                              inputItemPrice1,
                              '04' // 상태를 '05'로 변경
                          );*/
                        }
                        else {
                          // 견적 취소 로직
                          updateEstimateInfo(
                              sllrNo,
                              sllrClerkNo,
                              estNo,
                              seq,
                              estimateContent,
                              inputItemPrice1,
                              '05' // 상태를 '05'로 변경
                          );
                        }
                      },
                      child: Text(
                        reqState == "01" ? '견적보내기' :
                        reqState == "02" ? '메시지 대화하기' :
                        reqState == "03" || reqState == "04" ? '메시지 대화하기' :
                        '취소',
                        style: WitHomeTheme.title.copyWith(fontSize: 16, color: WitHomeTheme.wit_white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: WitHomeTheme.wit_lightGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      ),
                    ),
                  ),

                ],
              ),
            ),
          ),
        ),
      );
  }

  // [서비스] 견적발송 용 데이터 조회
  Future<void> getEstimateRequestInfoForSend(estNo, seq) async {
    // REST ID
    String restId = "getEstimateRequestInfoForSend";

    // PARAM
    final param = jsonEncode({
      "estNo": estNo,
      "seq": seq,
      //"sllrNo" : "COMP001",
    });

    // API 호출 (견적발송 용 데이터 조회)
    final _estimateRequestInfoForSend = await sendPostRequest(restId, param);

    // 결과 셋팅
    setState(() {
      estimateRequestInfoForSend = _estimateRequestInfoForSend;
      print("estNo : " + estimateRequestInfoForSend["estNo"]);
      print("seq : " + estimateRequestInfoForSend["seq"]);
    });

    getSellerDetailImageList();
  }

  // [서비스] 견적 정보 저장
  Future<void> updateEstimateInfo(
      dynamic sllrNo,
      dynamic sllrClerkNo,
      dynamic estNo,
      dynamic seq,
      dynamic estimateContent,
      dynamic inputItemPrice1,
      dynamic reqState, // 인자로 전달된 reqState를 그대로 사용
      ) async {

    if (reqState != "02") {
      // reqState가 02가 아닐 경우, 바로 updateEstimateInfo2 호출
      String cash = "1200"; // 필요한 경우 cash 값을 설정
      await updateEstimateInfo2(
        context,
        sllrNo,
        sllrClerkNo,
        estNo,
        seq,
        estimateContent,
        inputItemPrice1,
        cash,
        reqState,
        null, // fileInfo는 null로 설정
      );
      return; // 더 이상 진행하지 않음
    }

    saveImages(context, sllrNo, sllrClerkNo, estNo, seq, estimateContent, inputItemPrice1, null, reqState);


/*    String restId = "getCashInfo";
    int sllrNoInt = int.tryParse(sllrNo.toString()) ?? 0;

    // 1. 견적 발송 전 캐시 정보 조회
    final param2 = jsonEncode({
      "sllrNo": sllrNoInt,
    });

    // API 호출
    final response = await sendPostRequest(restId, param2);

    // API 응답 처리
    if (response != null) {
      dynamic cashInfo = response;
      dynamic cash = cashInfo['cash'];

      int cashInt = int.tryParse(cash.toString()) ?? 0;

      *//*if (cashInt == 0) {
        print("캐시가 부족합니다.");
        // 다이얼로그 표시
        WidgetsBinding.instance?.addPostFrameCallback((_) {
          if (context.mounted) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return PointNotOKDialog(sllrNo: sllrNo);
              },
            );
          }
        });
      }*//*
      //else {
      //print("캐시가 충분합니다: " + cashInt.toString());
        // 이미지 저장
        saveImages(context, sllrNo, sllrClerkNo, estNo, seq, estimateContent, inputItemPrice1, cash, reqState);
      //}
    } else {
      // 오류 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("캐시 조회가 실패하였습니다.")),
      );
    }*/
  }


  // [서비스] 이미지 저장
  Future<void> saveImages(BuildContext context, dynamic sllrNo, dynamic sllrClerkNo,
      dynamic estNo, dynamic seq, dynamic estimateContent, dynamic inputItemPrice1
      , dynamic cash, dynamic reqState) async {

    // 이미지 확인
    if (_images.isEmpty) {
      // 이미지가 없으면 프로필 업데이트 호출
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        if (context.mounted) {
          // 필요한 데이터 수집
          String sllrNo = estimateRequestInfoForSend['companyId'];
          String sllrClerkNo = estimateRequestInfoForSend['sllrClerkNo'];
          String estNo = estimateRequestInfoForSend['estNo'];
          String seq = estimateRequestInfoForSend['seq'];
          String estimateContent = estimateContentController.text;
          String inputItemPrice1 = itemPrice1Controller.text;

          updateEstimateInfo2(
              context, sllrNo, sllrClerkNo, estNo, seq, estimateContent, inputItemPrice1, cash, reqState, null
          );

          /*showDialog(
            context: context,
            builder: (BuildContext context) {
              return PointOKDialog(
                sllrNo: sllrNo,
                sllrClerkNo: sllrClerkNo,
                estNo: estNo,
                seq: seq,
                estimateContent: estimateContent,
                inputItemPrice1: inputItemPrice1,
                reqState: reqState,
                fileInfo: null,
                onSuccess: () {
                  // 다이얼로그가 닫힌 후 이동 로직
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SellerProfileDetail(sllrNo: sllrNo)),
                  );
                },
              );
            },
          );*/
        }
      });
    } else {
      final fileInfo = await sendFilePostRequest("fileUpload", _images);
      if (fileInfo == "FAIL") {
        print("파일 실패");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("파일 업로드 실패")));
      } else {
        // 파일 업로드 성공
        print("파일 성공");
        WidgetsBinding.instance?.addPostFrameCallback((_) {
          if (context.mounted) {
            // 필요한 데이터 수집
            String sllrNo = estimateRequestInfoForSend['companyId'];
            String sllrClerkNo = estimateRequestInfoForSend['sllrClerkNo'];
            String estNo = estimateRequestInfoForSend['estNo'];
            String seq = estimateRequestInfoForSend['seq'];
            String estimateContent = estimateContentController.text;
            String inputItemPrice1 = itemPrice1Controller.text;

            updateEstimateInfo2(
                context, sllrNo, sllrClerkNo, estNo, seq, estimateContent, inputItemPrice1, cash, reqState, fileInfo
            );

            // 다이얼로그 표시 후, 성공적인 이미지 저장 후 화면 이동
            /*showDialog(
              context: context,
              builder: (BuildContext context) {
                return PointOKDialog(
                  sllrNo: sllrNo,
                  sllrClerkNo: sllrClerkNo,
                  estNo: estNo,
                  seq: seq,
                  estimateContent: estimateContent,
                  inputItemPrice1: inputItemPrice1,
                  reqState: reqState,
                  fileInfo: fileInfo,
                  onSuccess: () {
                    // 다이얼로그가 닫힌 후에 화면 이동
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SellerProfileDetail(sllrNo: sllrNo)),
                    );
                  },
                );
              },
            );*/
          }
        });
      }
    }
  }


  // [서비스] 판매자 상세 이미지 조회
  Future<void> getSellerDetailImageList() async {
    // REST ID
    String restId = "getSellerDetailImageList";

    String estNo = estimateRequestInfoForSend["estNo"].toString();
    String seq = estimateRequestInfoForSend["seq"].toString();
    String bizKey = estNo + "^" + seq;

    // PARAM
    final param = jsonEncode({
      "bizCd": "RQ01",
      "bizKey": bizKey,
    });

    // API 호출 (게시판 상세 조회)
    final _boardDetailImageList = await sendPostRequest(restId, param);

    // 결과 셋팅
    setState(() {
      boardDetailImageList = _boardDetailImageList;
    });
  }

  Future<void> updateEstimateInfo3(BuildContext context, dynamic sllrNo, dynamic sllrClerkNo,
      dynamic estNo, dynamic seq, dynamic estimateContent, dynamic inputItemPrice1
      , dynamic cash, dynamic reqState, dynamic fileInfo) async {
    // REST ID
    String restId = "updateEstimateInfo";

    print("sllrNo : " + sllrNo);
    print("inputItemPrice1 : " + inputItemPrice1);
    print("estimateContent : " + estimateContent);


    // PARAM
    final param = jsonEncode({
      "sllrNo": sllrNo,
      "sllrClerkNo": sllrClerkNo,
      "estNo": estNo,
      "seq": seq,
      "estimateContent": estimateContent,
      "itemPrice1": inputItemPrice1,
      "stat": reqState, // 02 : 판매자가 견적발송
      "cash": cash,
      "cashGbn": "02", // 02 : 견적발송
      "fileInfo": fileInfo
    });

    // API 호출
    final response = await sendPostRequest(restId, param);

    // API 응답 처리
    if (response != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SellerProfileDetail(sllrNo: sllrNo)),
      );
      // 성공적으로 저장된 경우 처리
      //_showSuccessDialog(context); // 다이얼로그 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("견적이 성공적으로 발송되었습니다.")),
      );
    } else {
      // 오류 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("견적 저장에 실패했습니다.")),
      );
    }
  }

}

// PointOKDialog 클래스에 onSuccess 콜백 추가
/*class PointOKDialog extends StatelessWidget {
  final String sllrNo;
  final String sllrClerkNo;
  final String estNo;
  final String seq;
  final String estimateContent;
  final String inputItemPrice1;
  final String reqState;
  final dynamic fileInfo;
  final VoidCallback onSuccess; // 추가된 부분

  PointOKDialog({required this.sllrNo, required this.sllrClerkNo, required this.estNo, required this.seq, required this.estimateContent, required this.inputItemPrice1, required this.reqState, required this.fileInfo, required this.onSuccess}); // 수정된 부분

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('캐시가 충분합니다.'),
      content: Text('*견적을 보내기 위해 캐시가 1200 차감됩니다.'),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green, // 초록색 배경
            foregroundColor: Colors.white, // 하얀색 글씨
          ),
          onPressed: () {
            // 충전 로직 추가
            String cash = "1200";
            updateEstimateInfo2(
                context, sllrNo, sllrClerkNo, estNo, seq, estimateContent, inputItemPrice1, cash, reqState, fileInfo
            );
            onSuccess(); // 성공 시 콜백 호출
            Navigator.of(context).pop();
          },
          child: Text('보내기'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey, // 회색 배경
            foregroundColor: Colors.white, // 하얀색 글씨
          ),
          onPressed: () {
            Navigator.of(context).pop(); // 다이얼로그 닫기
          },
          child: Text('취소'),
        ),
      ],
    );
  }*/


  // [서비스]견적 정보 저장
  Future<void> updateEstimateInfo2(BuildContext context, dynamic sllrNo, dynamic sllrClerkNo,
      dynamic estNo, dynamic seq, dynamic estimateContent, dynamic inputItemPrice1
      , dynamic cash, dynamic reqState, dynamic fileInfo) async {
    // REST ID
    String restId = "updateEstimateInfo";

    print("sllrNo : " + sllrNo);
    print("inputItemPrice1 : " + inputItemPrice1);

    // PARAM
    final param = jsonEncode({
      "sllrNo": sllrNo,
      "sllrClerkNo": sllrClerkNo,
      "estNo": estNo,
      "seq": seq,
      "estimateContent": estimateContent,
      "itemPrice1": inputItemPrice1,
      "stat": reqState, // 02 : 판매자가 견적발송
      "cash": cash,
      "cashGbn": "02", // 02 : 견적발송
      "fileInfo": fileInfo
    });

    // API 호출
    final response = await sendPostRequest(restId, param);

    // API 응답 처리
    if (response != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SellerProfileDetail(sllrNo: sllrNo)),
      );
      // 성공적으로 저장된 경우 처리
      //_showSuccessDialog(context); // 다이얼로그 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("견적이 성공적으로 발송되었습니다.")),
      );
    } else {
      // 오류 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("견적 저장에 실패했습니다.")),
      );
    }
  }

  // 성공 다이얼로그를 표시하는 메서드
  /*void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('견적 발송 성공'),
          content: Text('견적이 정상적으로 발송되었습니다.'),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // 초록색 배경
                foregroundColor: Colors.white, // 하얀색 글씨
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SellerProfileDetail(sllrNo: sllrNo)),
                );
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }*/



/*class PointNotOKDialog extends StatelessWidget {
  final String sllrNo; // sllrNo 변수를 추가합니다.

  PointNotOKDialog({required this.sllrNo}); // 생성자에 추가합니다.

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('캐시가 부족합니다.'),
      content: Text('캐시를 충전하시겠습니까?'),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF63A566),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            // 충전 로직 추가
            //Navigator.of(context).pop(); // 다이얼로그 닫기
            // 충전 다이얼로그 띄우기
            *//*showDialog(
              context: context,
              builder: (BuildContext context) {
                return PointPurchaseDialog();
              },*//*
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CashRecharge(sllrNo: sllrNo)),
            );
          },
          child: Text('캐시충전'),
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
            Navigator.of(context).pop(); // 다이얼로그 닫기
          },
          child: Text('취소'),
        ),
      ],
    );
  }
}*/

/*class PointPurchaseDialog extends StatefulWidget {
  @override
  _PointPurchaseDialogState createState() => _PointPurchaseDialogState();
}*/

/*class _PointPurchaseDialogState extends State<PointPurchaseDialog> {
  int? _selectedPoint;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('캐시충전으로 많은 견적서비스를 이용해보세요~',
        style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.black
        ),),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [3000, 5000, 10000, 30000, 50000, 100000].map((point) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedPoint = point;
                  });
                },
                child: Container(
                  width: 100,
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _selectedPoint == point ? Colors.red : Colors.grey,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text('$point P'),
                ),
              );
            }).toList(),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green, // 초록색 배경
            foregroundColor: Colors.white, // 하얀색 글씨
          ),
          onPressed: () {
            // 결제하기 로직 추가 및 Intro로 이동
            if (_selectedPoint != null) {
              Navigator.of(context).pop(); // 다이얼로그 닫기
              *//*Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TosspaymentsSampleApp()),
              );*//*
            } else {
              // 포인트가 선택되지 않은 경우 알림
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('구매할 포인트를 선택해주세요.')),
              );
            }
          },
          child: Text('결제하기'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey, // 회색 배경
            foregroundColor: Colors.white, // 하얀색 글씨
          ),
          onPressed: () {
            Navigator.of(context).pop(); // 다이얼로그 닫기
          },
          child: Text('취소'),
        ),
      ],
    );
  }
}*/
