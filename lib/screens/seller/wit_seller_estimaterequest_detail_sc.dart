import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:witibju/screens/seller/wit_seller_cash_recharge_sc.dart';
import 'package:flutter/material.dart';

// import '../../main_toss.dart';
import '../../util/wit_api_ut.dart';
import 'package:witibju/screens/seller/wit_seller_profile_detail_sc.dart';

import '../../util/wit_code_ut.dart';
import '../board/wit_board_detail_sc.dart';
import '../common/wit_ImageViewer_sc.dart';


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

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          leadingWidth: 90,
          leading: Container(
            height: double.infinity,
            child: Center(
              child: Text(
                "친절한 사장님",
                style: TextStyle(fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          title: Text("Profile"),
          centerTitle: true,
          backgroundColor: Colors.blueAccent,
          actions: [
            IconButton(onPressed: () {}, icon: Icon(Icons.perm_identity)),
            IconButton(onPressed: () {}, icon: Icon(Icons.mail)),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        color: Colors.blue,
                        padding: EdgeInsets.all(10),
                        child: Text(
                          "고객 APT",
                          style: TextStyle(fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          aptName,
                          style: TextStyle(fontSize: 22,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey[300],
                        child: Image.asset(
                          itemImage,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: 10),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              reqContents,
                              style: TextStyle(fontSize: 20,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              itemName,
                              style: TextStyle(
                                  fontSize: 18, color: Colors.grey[800]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "고객님\n 추가 조건/\n요구사항",
                        style: TextStyle(fontSize: 12, color: Colors.black),
                      ),
                      SizedBox(width: 35),
                      Expanded(
                        child: Text(
                          reqContents,
                          style: TextStyle(fontSize: 16, color: Colors.blue),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text("* 견적금액:", style: TextStyle(fontSize: 16)),
                      SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: itemPrice1Controller,
                          decoration: InputDecoration(
                            hintText: "금액을 입력하세요",
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          enabled: reqState == "01", // reqState가 01일 때만 활성화
                        ),
                      ),
                      SizedBox(width: 8),
                      Text("원", style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  Text(
                    "견적 추가 설명",
                    style: TextStyle(fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: estimateContentController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '여기에 추가 설명을 입력하세요',
                        contentPadding: EdgeInsets.all(8),
                        enabled: reqState == "01", // reqState가 01일 때만 활성화
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
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
                  SizedBox(height: 20),
                  Center(
                    child: reqState == "05" ? Container() : ElevatedButton(
                      onPressed: () {
                        if (reqState == "01") {
                          // 견적 보내기 로직
                          String sllrNo = estimateRequestInfoForSend['companyId'] ?? "";
                          String sllrClerkNo = estimateRequestInfoForSend['sllrClerkNo'] ?? "";
                          String estNo = estimateRequestInfoForSend['estNo'] ?? "";
                          String seq = estimateRequestInfoForSend['seq'] ?? "";
                          String estimateContent = estimateContentController.text;
                          String inputItemPrice1 = itemPrice1Controller.text;
                          String reqState = '02';
                          updateEstimateInfo(
                              sllrNo,
                              sllrClerkNo,
                              estNo,
                              seq,
                              estimateContent,
                              inputItemPrice1,
                              '02'
                          );
                        } else {
                          String sllrNo = estimateRequestInfoForSend['companyId'] ?? "";
                          String sllrClerkNo = estimateRequestInfoForSend['sllrClerkNo'] ?? "";
                          String estNo = estimateRequestInfoForSend['estNo'] ?? "";
                          String seq = estimateRequestInfoForSend['seq'] ?? "";
                          String estimateContent = estimateContentController.text;
                          String inputItemPrice1 = itemPrice1Controller.text;
                          String reqState = '05';
                          updateEstimateInfo(
                              sllrNo,
                              sllrClerkNo,
                              estNo,
                              seq,
                              estimateContent,
                              inputItemPrice1,
                              '05'
                          );
                        }
                      },
                      child: Text(reqState == "01" ? '견적보내기' : '견적취소'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 3, 199, 90),
                        foregroundColor: Colors.white,
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
  Future<void> updateEstimateInfo(dynamic sllrNo,
      dynamic sllrClerkNo,
      dynamic estNo,
      dynamic seq,
      dynamic estimateContent,
      dynamic inputItemPrice1,
      dynamic reqState, // 인자로 전달된 reqState를 그대로 사용
      ) async {
    String restId = "getCashInfo";

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

      if (cashInt == 0) {
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
      } else {
        print("캐시가 충분합니다: " + cashInt.toString());
        // 다이얼로그 표시
        WidgetsBinding.instance?.addPostFrameCallback((_) {
          if (context.mounted) {
            // 필요한 데이터 수집
            String sllrNo = estimateRequestInfoForSend['companyId'];
            String sllrClerkNo = estimateRequestInfoForSend['sllrClerkNo'];
            String estNo = estimateRequestInfoForSend['estNo'];
            String seq = estimateRequestInfoForSend['seq'];
            String estimateContent = estimateContentController.text;
            String inputItemPrice1 = itemPrice1Controller.text;

            showDialog(
              context: context,
              builder: (BuildContext context) {
                return PointOKDialog(
                  sllrNo: sllrNo,
                  sllrClerkNo: sllrClerkNo,
                  estNo: estNo,
                  seq: seq,
                  estimateContent: estimateContent,
                  inputItemPrice1: inputItemPrice1,
                  reqState: reqState, // 인자로 전달된 reqState 사용
                );
              },
            );
          }
        });
      }
    } else {
      // 오류 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("캐시 조회가 실패하였습니다.")),
      );
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

}

class PointOKDialog extends StatelessWidget {
  final String sllrNo;
  final String sllrClerkNo;
  final String estNo;
  final String seq;
  final String estimateContent;
  final String inputItemPrice1;
  final String reqState;

  PointOKDialog({required this.sllrNo, required this.sllrClerkNo, required this.estNo, required this.seq, required this.estimateContent, required this.inputItemPrice1, required this.reqState});

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
            // Navigator.of(context).pop(); // 다이얼로그 닫기
            //String estNo = estimateRequestInfoForSend['estNo'] ?? "";
            String sllrNo = this.sllrNo;
            String sllrClerkNo = this.sllrClerkNo;
            String estNo = this.estNo;
            String seq = this.seq;
            String estimateContent = this.estimateContent;
            String inputItemPrice1 = this.inputItemPrice1;
            String reqState = this.reqState;
            
            // 견적발송 당 차감 캐쉬도 정의 해야함
            String cash = "1200";

            saveImages(context, sllrNo, sllrClerkNo, estNo, seq, estimateContent, inputItemPrice1, cash, reqState);
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
  }

  // [서비스] 이미지 저장
  Future<void> saveImages(BuildContext context, dynamic sllrNo, dynamic sllrClerkNo,
      dynamic estNo, dynamic seq, dynamic estimateContent, dynamic inputItemPrice1
      , dynamic cash, dynamic reqState) async {

    // 이미지 확인
    if (_images.isEmpty) {
      // 이미지가 없으면 프로필 업데이트 호출
      updateEstimateInfo2(
          context, sllrNo, sllrClerkNo, estNo, seq, estimateContent, inputItemPrice1, cash, reqState, null
      );
    } else {
      final fileInfo = await sendFilePostRequest("fileUpload", _images);
      if (fileInfo == "FAIL") {
        print("파일 실패");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("파일 업로드 실패")));
      } else {
        // 파일 업로드 성공, 프로필 업데이트 호출
        print("파일 성공");
        updateEstimateInfo2(
            context, sllrNo, sllrClerkNo, estNo, seq, estimateContent, inputItemPrice1, cash, reqState, fileInfo
        );
      }
    }
  }

  // [서비스]견적 정보 저장
  Future<void> updateEstimateInfo2(BuildContext context, dynamic sllrNo, dynamic sllrClerkNo,
      dynamic estNo, dynamic seq, dynamic estimateContent, dynamic inputItemPrice1
      , dynamic cash, dynamic reqState, dynamic fileInfo) async {
    // REST ID
    String restId = "updateEstimateInfo";

    print("estNo : " + estNo);
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
      // 성공적으로 저장된 경우 처리
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSuccessDialog(context); // 다이얼로그 표시
      });
    } else {
      // 오류 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("견적 저장에 실패했습니다.")),
      );
    }
  }

  // 성공 다이얼로그를 표시하는 메서드
  void _showSuccessDialog(BuildContext context) {
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
  }
}


class PointNotOKDialog extends StatelessWidget {
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
            backgroundColor: Colors.green, // 초록색 배경
            foregroundColor: Colors.white, // 하얀색 글씨
          ),
          onPressed: () {
            // 충전 로직 추가
            //Navigator.of(context).pop(); // 다이얼로그 닫기
            // 충전 다이얼로그 띄우기
            /*showDialog(
              context: context,
              builder: (BuildContext context) {
                return PointPurchaseDialog();
              },*/
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CashRecharge(sllrNo: sllrNo)),
            );
          },
          child: Text('캐시충전'),
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
}

class PointPurchaseDialog extends StatefulWidget {
  @override
  _PointPurchaseDialogState createState() => _PointPurchaseDialogState();
}

class _PointPurchaseDialogState extends State<PointPurchaseDialog> {
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
              /*Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TosspaymentsSampleApp()),
              );*/
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
}
