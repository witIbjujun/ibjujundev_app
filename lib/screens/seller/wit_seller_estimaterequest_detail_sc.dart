import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:witibju/screens/seller/wit_common_imageViewer_sc.dart';
import 'package:witibju/screens/seller/wit_seller_cash_recharge_sc.dart';
import 'package:flutter/material.dart';
import 'package:witibju/screens/seller/wit_seller_profile_appbar_sc.dart';
import 'package:witibju/screens/seller/wit_seller_profile_child_view_sc.dart';
import 'package:witibju/screens/seller/wit_seller_profile_view_sc.dart';

// import '../../main_toss.dart';
import '../../util/wit_api_ut.dart';
import 'package:witibju/screens/seller/wit_seller_profile_detail_sc.dart';

import '../../util/wit_code_ut.dart';
import '../board/wit_board_detail_sc.dart';
import '../chat/CustomChatScreen.dart';
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

  const EstimateRequestDetail(
      {super.key, required this.estNo, required this.seq, required this.sllrNo});

  @override
  State<StatefulWidget> createState() {
    return EstimateRequestDetailState();
  }
}

class EstimateRequestDetailState extends State<EstimateRequestDetail> {
  Map estimateRequestInfoForSend = new Map<String, dynamic>();

  TextEditingController itemPrice1Controller = TextEditingController();
  TextEditingController estimateContentController = TextEditingController();
  TextEditingController endReasonController = TextEditingController();

  String? contentError;
  String? priceError;

  Future<void> _pickImages(ImageSource source) async {
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _images =
            pickedFiles.map((pickedFile) => File(pickedFile.path)).toList();
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

    estimateContentController.addListener(() {
      if (contentError != null &&
          estimateContentController.text.trim().isNotEmpty) {
        setState(() {
          contentError = null;
        });
      }
    });

    itemPrice1Controller.addListener(() {
      if (priceError != null && itemPrice1Controller.text.trim().isNotEmpty) {
        setState(() {
          priceError = null;
        });
      }
    });

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
    getEstimateRequestInfoForSend(widget.estNo, widget.seq);

  }

  @override
  Widget build(BuildContext context) {


    String estNo = estimateRequestInfoForSend['estNo'] ?? "";
    String seq = estimateRequestInfoForSend['seq'] ?? "";
    String aptName = estimateRequestInfoForSend['aptName'] ?? "고객 APT 정보 없음";
    String reqContents =
        estimateRequestInfoForSend['reqContents'] ?? "content 정보 없음";
    String itemImage =
        estimateRequestInfoForSend['itemImage'] ?? "itemImage 정보 없음";
    String itemName =
        estimateRequestInfoForSend['itemName'] ?? "itemName 정보 없음";
    String estimateContent =
        estimateRequestInfoForSend['estimateContent'] ?? "";
    String itemPrice1 = estimateRequestInfoForSend['itemPrice1'] ?? "";
    String sllrNo = estimateRequestInfoForSend['sllrNo'] ?? "sllrNo 정보 없음";
    String sllrClerkNo =
        estimateRequestInfoForSend['sllrClerkNo'] ?? "itemPrice1 정보 없음";
    String reqState =
        estimateRequestInfoForSend['reqState'] ?? "reqState 정보 없음";

    // 이건 위젯 함수 안 어딘가 (예: build 메서드 안)에 위치
    String rawDate = estimateRequestInfoForSend['estimateDate'] ?? '';
    String formattedDate = '없음';
    if (rawDate.length == 8) {
      formattedDate =
          '${rawDate.substring(0, 4)}/${rawDate.substring(4, 6)}/${rawDate.substring(6, 8)}';
    }

    // 입력 필드에 초기값 설정
    if (reqState != "10") {
      itemPrice1Controller.text = itemPrice1; // reqState가 01이 아닐 때 기존 값 표시
      estimateContentController.text = estimateContent; // 기존 설명 표시
    }

    return Scaffold(
      backgroundColor: WitHomeTheme.wit_white,

      /*appBar: SellerAppBar(
          sllrNo: widget.sllrNo,
        ),*/
      appBar: AppBar(
        backgroundColor: WitHomeTheme.wit_black,
        iconTheme: const IconThemeData(color: WitHomeTheme.wit_white),
        title: Text(
          '견적 요청 상세',
          style: WitHomeTheme.title.copyWith(color: WitHomeTheme.wit_white),
        ),
        automaticallyImplyLeading: true, // <<--- 뒤로가기 버튼 자동 추가
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
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              image: DecorationImage(
                                image: estimateRequestInfoForSend[
                                                'prsnImageUrl'] !=
                                            null &&
                                        estimateRequestInfoForSend[
                                                'prsnImageUrl']
                                            .isNotEmpty
                                    ? NetworkImage(estimateRequestInfoForSend[
                                        'prsnImageUrl'])
                                    : AssetImage('assets/images/profile1.png')
                                        as ImageProvider,
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
                                  estimateRequestInfoForSend['estDt'] ??
                                      '날짜 없음', // 날짜
                                  style: WitHomeTheme.title.copyWith(
                                      fontSize: 12,
                                      color: WitHomeTheme.wit_gray),
                                ),
                                SizedBox(height: 4), // 날짜와 이름 사이의 간격
                                Text(
                                  estimateRequestInfoForSend['prsnName'] ??
                                      '요청자명 없음', // 요청자명
                                  style:
                                      WitHomeTheme.title.copyWith(fontSize: 18),
                                ),
                                SizedBox(height: 1), // 이름과 아파트명 사이의 간격
                                Text(
                                  estimateRequestInfoForSend['aptName'] ??
                                      '아파트명 없음', // 아파트명
                                  style: WitHomeTheme.title.copyWith(
                                      fontSize: 12,
                                      color: WitHomeTheme.wit_gray),
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
                                borderRadius:
                                    BorderRadius.circular(0), // 테두리 없애기
                              ),
                            ),
                            child: Text(
                              estimateRequestInfoForSend['stat'] ?? '상태 없음',
                              // 상태
                              style: WitHomeTheme.title.copyWith(
                                  fontSize: 14,
                                  color: WitHomeTheme.wit_lightBlue),
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
                        ),
                        padding: EdgeInsets.all(12), // 내부 여백
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          // 왼쪽 정렬
                          children: [
                            Text(
                              estimateRequestInfoForSend['reqType'] ?? '',
                              style: WitHomeTheme.title.copyWith(fontSize: 14),
                            ),
                            const SizedBox(height: 6), // 간격 추가
                            // ✅ itemName 텍스트 추가
                            Text(
                              "[${estimateRequestInfoForSend['itemName'] ?? ''}]",
                              style: WitHomeTheme.subtitle.copyWith(fontSize: 14),
                            ),
                            const SizedBox(height: 15),
                            Align(
                              alignment: Alignment.centerLeft, // 왼쪽 정렬
                              child: Text(
                                reqContents, // 내용
                                style: WitHomeTheme.subtitle
                                    .copyWith(fontSize: 14),
                                textAlign: TextAlign.left, // 텍스트 왼쪽 정렬
                              ),
                            ),
                            SizedBox(height: 15), // 내용과 작업 요청 예상일 사이의 간격
                            Text(
                              '작업요청예상일 : $formattedDate',
                              style: WitHomeTheme.title.copyWith(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // if (reqState == "10") ...[ // 조건이 만족할 때만 해당 위젯을 추가
                /*Row(
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
                    ),*/
                // 체크박스가 체크된 경우 SellerProfileView 표시
                //if (_isChecked)

                //],

                SizedBox(height: 10), // 금액 입력란 카드
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "견적 금액 ",
                            style: WitHomeTheme.title.copyWith(
                              fontSize: 16,
                              color: WitHomeTheme.wit_lightSteelBlue,
                            ),
                          ),
                          SizedBox(height: 10),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: TextField(
                                controller: itemPrice1Controller,
                                keyboardType: TextInputType.number,
                                style: WitHomeTheme.subtitle
                                    .copyWith(fontSize: 16),
                                textAlign: TextAlign.right,
                                decoration: InputDecoration(
                                  hintText: "금액을 입력하세요",
                                  hintStyle: WitHomeTheme.subtitle
                                      .copyWith(fontSize: 16),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 10),
                                ),
                                enabled: reqState == "10",
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                onChanged: (value) {
                                  // 값이 변경될 때 에러 메시지 삭제
                                  if (value.isNotEmpty && priceError != null) {
                                    setState(() {
                                      priceError = null; // 에러 메시지 삭제
                                    });
                                  }
                                },
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
                      if (priceError != null && priceError!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            priceError!,
                            style: WitHomeTheme.subtitle.copyWith(
                                fontSize: 14, color: WitHomeTheme.wit_red),
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
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "견적 추가 설명",
                        style: WitHomeTheme.title.copyWith(
                          fontSize: 16,
                          color: WitHomeTheme.wit_lightSteelBlue,
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          maxLength: 4000,
                          controller: estimateContentController,
                          style: WitHomeTheme.subtitle.copyWith(fontSize: 16),
                          minLines: 3,
                          maxLines: null,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: '여기에 추가 설명을 입력하세요',
                            hintStyle:
                                WitHomeTheme.subtitle.copyWith(fontSize: 16),
                            contentPadding: EdgeInsets.all(8),
                          ),
                          enabled: reqState == "10",
                          onChanged: (value) {
                            if (value.trim().isNotEmpty &&
                                contentError != null) {
                              setState(() {
                                contentError = null;
                              });
                            }
                          },
                        ),
                      ),
                      if (contentError != null && contentError!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            contentError!,
                            style: WitHomeTheme.subtitle.copyWith(
                                fontSize: 14, color: WitHomeTheme.wit_red),
                          ),
                        ),
                    ],
                  ),
                ),

                SizedBox(height: 5),
                Text(
                  "* 업체 전화번호나 위치 설명 금지",
                  style: WitHomeTheme.subtitle
                      .copyWith(fontSize: 14, color: WitHomeTheme.wit_red),
                ),
                SizedBox(height: 16),
                //if (reqState == "01") ...[ // reqState가 "01"일 때만 이 부분이 렌더링됨

                Column(
                  children: [
                    if (reqState != "10")
                      CommonImageViewer(
                        key: ValueKey("${estimateRequestInfoForSend['estNo']}_${estimateRequestInfoForSend['seq']}"),
                        estNo: estimateRequestInfoForSend['estNo'] ?? '',
                        seq: estimateRequestInfoForSend['seq'] ?? '',
                        imageGubun: 'RQ01',
                      ),
                  ],
                ),
                if (reqState == "10")
                Container(
                  height: 120,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                          GestureDetector(
                            onTap: () => _showImagePickerOptions(),
                            child: Container(
                              width: 85,
                              height: 85,
                              margin: EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: WitHomeTheme.wit_white,
                                border: Border.all(
                                  width: 1,
                                  color: WitHomeTheme.wit_lightgray,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.add_a_photo,
                                size: 40,
                                color: WitHomeTheme.wit_gray,
                              ),
                              alignment: Alignment.center,
                            ),
                          ),

                        // 등록된 이미지 리스트
                        ...boardDetailImageList.asMap().entries.map((entry) {
                          int index = entry.key;
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ImageViewer(
                                    imageUrls: boardDetailImageList
                                        .map((item) =>
                                            apiUrl + item["imagePath"])
                                        .toList(),
                                    initialIndex: index,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              width: 85,
                              height: 85,
                              margin: EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image: DecorationImage(
                                  image: NetworkImage(apiUrl +
                                      boardDetailImageList[index]["imagePath"]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        }).toList(),

                        // 선택한 이미지 리스트
                        ..._images.asMap().entries.map((entry) {
                          int index = entry.key;
                          var image = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12.0),
                                  child: Image.file(
                                    image,
                                    width: 85,
                                    height: 85,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: IconButton(
                                    icon: Icon(Icons.close,
                                        color: WitHomeTheme.wit_red),
                                    onPressed: () {
                                      setState(() {
                                        _images.removeAt(index);
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
                SizedBox(height: 10),
                Text(
                  "내 프로필",
                  style: WitHomeTheme.title.copyWith(
                    fontSize: 16,
                    color: WitHomeTheme.wit_lightSteelBlue,
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black), // 테두리 색상 설정
                    borderRadius: BorderRadius.circular(12), // 둥근 모서리 설정
                  ),
                  child: SellerProfileChildView(
                      sllrNo: widget.sllrNo, appbarYn: "N"),
                ),
                SizedBox(height: 8),
                Text(
                  "* 파트너님의 프로필 정보가 견적요청시 전송됩니다.",
                  style: WitHomeTheme.subtitle
                      .copyWith(fontSize: 14, color: WitHomeTheme.wit_red),
                ),
                //],
                SizedBox(height: 20),
                Row(
                  children: [
                    if (!['99', '60', '70'].contains(reqState)) ...[
                      // 🔹 작업중지 버튼
                      Expanded(
                        flex: 1,
                        child: ElevatedButton(
                          onPressed: () {
                            TextEditingController endReasonController =
                                TextEditingController();

                            showDialog(
                              context: context,
                              builder: (context) {
                                final width = MediaQuery.of(context).size.width;

                                return Dialog(
                                  backgroundColor: WitHomeTheme.wit_white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Container(
                                    width: width * 0.9,
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          '작업중지 사유 입력',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 16),
                                        TextField(
                                          maxLength: 1000,
                                          controller: endReasonController,
                                          maxLines: 3,
                                          decoration: const InputDecoration(
                                            hintText: '작업 중지 사유를 입력하세요',
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            ElevatedButton(
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.grey[300],
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 20,
                                                        vertical: 12),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                elevation: 0,
                                              ),
                                              child: const Text(
                                                '취소',
                                                style: TextStyle(
                                                    color: Colors.black),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            ElevatedButton(
                                              onPressed: () {
                                                String reason =
                                                    endReasonController.text
                                                        .trim();

                                                if (reason.isNotEmpty) {
                                                  updateEstimateEnd(
                                                    context,
                                                    estimateRequestInfoForSend[
                                                            'companyId'] ??
                                                        "",
                                                    estimateRequestInfoForSend[
                                                            'sllrClerkNo'] ??
                                                        "",
                                                    estimateRequestInfoForSend[
                                                            'estNo'] ??
                                                        "",
                                                    estimateRequestInfoForSend[
                                                            'seq'] ??
                                                        "",
                                                    '99',
                                                    reason,
                                                    estimateContentController
                                                        .text,
                                                    itemPrice1Controller.text,
                                                  );
                                                  Navigator.of(context).pop();
                                                } else {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                          '작업 중지 사유를 입력해주세요.'),
                                                      duration:
                                                          Duration(seconds: 2),
                                                      behavior: SnackBarBehavior
                                                          .floating,
                                                    ),
                                                  );
                                                }
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    WitHomeTheme.wit_lightGreen,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 20,
                                                        vertical: 12),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                elevation: 0,
                                              ),
                                              child: const Text(
                                                '확인',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          child: Text(
                            '작업중지',
                            style: WitHomeTheme.title.copyWith(
                                fontSize: 14, color: WitHomeTheme.wit_black),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[100],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // 🔹 작업완료 버튼 (reqState == 10, 20이면 숨김)
                      if (!['10', '20'].contains(reqState)) ...[
                        Expanded(
                          flex: 1,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                contentError = estimateContentController.text
                                        .trim()
                                        .isEmpty
                                    ? '견적 내용을 입력해주세요.'
                                    : null;
                                priceError =
                                    itemPrice1Controller.text.trim().isEmpty
                                        ? '견적 금액을 입력해주세요.'
                                        : null;
                              });

                              if (contentError == null && priceError == null) {
                                updateEstimateInfo(
                                  estimateRequestInfoForSend['companyId'] ?? "",
                                  estimateRequestInfoForSend['sllrClerkNo'] ??
                                      "",
                                  estimateRequestInfoForSend['estNo'] ?? "",
                                  estimateRequestInfoForSend['seq'] ?? "",
                                  estimateContentController.text,
                                  itemPrice1Controller.text,
                                  '60',
                                );
                              }
                            },
                            child: Text(
                              '작업완료',
                              style: WitHomeTheme.title.copyWith(
                                  fontSize: 14, color: WitHomeTheme.wit_white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: WitHomeTheme.wit_lightBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                    ] else ...[
                      // 🔹 버튼 대신 Spacer
                      const Spacer(flex: 1),
                      const SizedBox(width: 10),
                      const Spacer(flex: 1),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: (reqState == "04")
                            ? null
                            : () {
                                String sllrNo =
                                    estimateRequestInfoForSend['companyId'] ??
                                        "";
                                String sllrClerkNo =
                                    estimateRequestInfoForSend['sllrClerkNo'] ??
                                        "";
                                String estNo =
                                    estimateRequestInfoForSend['estNo'] ?? "";
                                String seq =
                                    estimateRequestInfoForSend['seq'] ?? "";
                                String estimateContent =
                                    estimateContentController.text;
                                String inputItemPrice1 =
                                    itemPrice1Controller.text;

                                setState(() {
                                  contentError = estimateContentController.text
                                          .trim()
                                          .isEmpty
                                      ? '견적 내용을 입력해주세요.'
                                      : null;
                                  priceError =
                                      itemPrice1Controller.text.trim().isEmpty
                                          ? '견적 금액을 입력해주세요.'
                                          : null;
                                });

                                if (contentError == null &&
                                    priceError == null) {
                                  if (reqState == "10") {
                                    // 견적 보내기 로직
                                    updateEstimateInfo(
                                      sllrNo,
                                      sllrClerkNo,
                                      estNo,
                                      seq,
                                      estimateContent,
                                      inputItemPrice1,
                                      '20', // 상태를 '02'로 변경
                                    );
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CustomChatScreen(
                                          estNo, // 첫 번째 인자: 요청 번호
                                          seq, // 두 번째 인자: 시퀀스 (chatId)
                                          "sellerView", // 세 번째 인자: 뷰 타입
                                        ),
                                      ),
                                    ).then((_) {
                                      // 이 부분에서 리로드할 작업 실행
                                      // 예: 데이터 다시 불러오기
                                      _loadProfile(); // 또는 setState(() { ... })
                                    });
                                  }
                                }
                              },
                        child: Text(
                          reqState == "10"
                              ? '견적보내기'
                              : reqState == "20" ||
                                      reqState == "30" ||
                                      reqState == "40" ||
                                      reqState == "50"
                                  ? '메시지 대화하기'
                                  : '메시지 보기',
                          style: WitHomeTheme.title.copyWith(
                              fontSize: 14, color: WitHomeTheme.wit_white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: WitHomeTheme.wit_lightGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // [팝업] 갤러리, 카메라 팝업 호출
  void _showImagePickerOptions() {
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
                title: Text('갤러리에서 선택', style: WitHomeTheme.title),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera),
                title: Text('사진 찍기', style: WitHomeTheme.title),
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
    final reqState = _estimateRequestInfoForSend['reqState'] ?? "";

    setState(() {
      estimateRequestInfoForSend = _estimateRequestInfoForSend;
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
    if (reqState != "20") {
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

    saveImages(context, sllrNo, sllrClerkNo, estNo, seq, estimateContent,
        inputItemPrice1, null, reqState);

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

      */ /*if (cashInt == 0) {
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
      }*/ /*
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
  Future<void> saveImages(
      BuildContext context,
      dynamic sllrNo,
      dynamic sllrClerkNo,
      dynamic estNo,
      dynamic seq,
      dynamic estimateContent,
      dynamic inputItemPrice1,
      dynamic cash,
      dynamic reqState) async {
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

          updateEstimateInfo2(context, sllrNo, sllrClerkNo, estNo, seq,
              estimateContent, inputItemPrice1, cash, reqState, null);

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
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("파일 업로드 실패")));
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

            updateEstimateInfo2(context, sllrNo, sllrClerkNo, estNo, seq,
                estimateContent, inputItemPrice1, cash, reqState, fileInfo);

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

    // ✅ 이 두 개 다 초기화
    boardDetailImageList.clear();
    _images.clear();
    // API 호출 (게시판 상세 조회)
    final _boardDetailImageList = await sendPostRequest(restId, param);

    // 결과 셋팅
    setState(() {
      boardDetailImageList = _boardDetailImageList;
    });
  }

  Future<void> updateEstimateInfo3(
      BuildContext context,
      dynamic sllrNo,
      dynamic sllrClerkNo,
      dynamic estNo,
      dynamic seq,
      dynamic estimateContent,
      dynamic inputItemPrice1,
      dynamic cash,
      dynamic reqState,
      dynamic fileInfo) async {
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
      "fileInfo": fileInfo,
      "endReason": endReasonController.text,
    });

    // API 호출
    final response = await sendPostRequest(restId, param);

    // API 응답 처리
    if (response != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SellerProfileDetail(sllrNo: sllrNo)),
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
Future<void> updateEstimateInfo2(
    BuildContext context,
    dynamic sllrNo,
    dynamic sllrClerkNo,
    dynamic estNo,
    dynamic seq,
    dynamic estimateContent,
    dynamic inputItemPrice1,
    dynamic cash,
    dynamic reqState,
    dynamic fileInfo) async {
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
      MaterialPageRoute(
          builder: (context) => SellerProfileDetail(sllrNo: sllrNo)),
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

// [서비스]견적 정보 저장
Future<void> updateEstimateEnd(
  BuildContext context,
  dynamic sllrNo,
  dynamic sllrClerkNo,
  dynamic estNo,
  dynamic seq,
  dynamic reqState,
  dynamic endReason,
  dynamic estimateContent,
  dynamic inputItemPrice1,
) async {
  // REST ID
  String restId = "updateEstimateInfo";

  // PARAM
  final param = jsonEncode({
    "sllrNo": sllrNo,
    "sllrClerkNo": sllrClerkNo,
    "estNo": estNo,
    "seq": seq,
    "stat": reqState, // 02 : 판매자가 견적발송
    "endReason": endReason, // 02 : 판매자가 견적발송
    "estimateContent": estimateContent,
    "itemPrice1": inputItemPrice1,
  });

  // API 호출
  final response = await sendPostRequest(restId, param);

  // API 응답 처리
  if (response != null) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => SellerProfileDetail(sllrNo: sllrNo)),
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
