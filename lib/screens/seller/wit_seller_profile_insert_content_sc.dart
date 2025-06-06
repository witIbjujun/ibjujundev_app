import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:witibju/screens/seller/wit_seller_profile_detail_sc.dart';
import 'dart:io';
import 'dart:convert';
import 'package:witibju/screens/seller/wit_seller_profile_insert_bizInfo_sc.dart';
import 'package:witibju/screens/seller/wit_seller_profile_sc.dart';
import '../../util/wit_api_ut.dart';
import '../../util/wit_code_ut.dart';
import '../board/wit_board_detail_sc.dart';
import '../common/wit_ImageViewer_sc.dart';
import '../common/wit_common_widget.dart';
import '../home/wit_home_theme.dart';

class SellerProfileInsertContents extends StatefulWidget {
  final dynamic sllrNo;

  const SellerProfileInsertContents({super.key, required this.sllrNo});

  @override
  State<StatefulWidget> createState() {
    return SellerProfileInsertContentsState();
  }
}

class SellerProfileInsertContentsState
    extends State<SellerProfileInsertContents> {
  dynamic sellerInfo;
  TextEditingController sllrContentController = TextEditingController();
  TextEditingController sllrImageController = TextEditingController();
  String errorMessage = ''; // 판매자명 오류 메시지 변수
  List<String> fileDelInfo = [];

  @override
  void initState() {
    super.initState();
    getSellerInfo(widget.sllrNo);
  }

  /* 이미지추가 S */
  List<File> _images = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        if (_images.length < 5) {
          _images.add(File(pickedFile.path));
        }
      });
    }
  }

  Future<void> _pickMultiImages() async {
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      setState(() {
        for (final xfile in pickedFiles) {
          if (_images.length < 5) {
            _images.add(File(xfile.path));
          }
        }
      });
    }
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

        sllrContentController.text = sellerInfo['sllrContent'] ?? '';
        getSellerDetailImageList();
      });
    } else {
      // 오류 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("파트너 프로필 조회가 실패하였습니다.")),
      );
    }
  }

  // [서비스] 판매자 상세 이미지 조회
  Future<void> getSellerDetailImageList() async {
    // REST ID
    String restId = "getSellerDetailImageList";

    // PARAM
    final param = jsonEncode({
      //"bizCd": bizCd,
      "bizKey": sellerInfo["sllrNo"].toString(),
    });

    // API 호출 (게시판 상세 조회)
    final _boardDetailImageList = await sendPostRequest(restId, param);

    if (_boardDetailImageList.isNotEmpty) {
      // 값이 있을 때 수행할 작업
      print("보드 상세 이미지 리스트에 값이 있습니다: ${_boardDetailImageList.length}개");
    } else {
      // 값이 없을 때 수행할 작업
      print("보드 상세 이미지 리스트가 비어 있습니다.");
    }

    // 결과 셋팅
    setState(() {
      boardDetailImageList.clear();
      boardDetailImageList = _boardDetailImageList
          .where((item) => item['bizCd']?.toString() == 'SR01')
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          bool isConfirmed = await ConfimDialog.show(context: context, title: "확인", content: "조금만 더 입력하면\n파트너 등록이 끝납니다.\n정말 나가시겠어요?");
          if (isConfirmed == true) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => SellerProfileDetail(sllrNo: widget.sllrNo),
              ),
                  (route) => false, // 뒤로가기로 다시 못 돌아오게 루트만 남김
            );
          }
        }
      },
      child: Scaffold(
        backgroundColor: WitHomeTheme.wit_white,
        appBar: AppBar(
          backgroundColor: WitHomeTheme.wit_black,
          iconTheme: const IconThemeData(color: WitHomeTheme.wit_white),
          title: Text(
            '파트너 설명 등록',
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
                            backgroundColor: 1 == index
                                ? WitHomeTheme.wit_lightGreen
                                : WitHomeTheme.wit_gray,
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
                Container(
                  width: double.infinity, // 넓이를 최대로 설정
                  padding: EdgeInsets.all(16.0), // 텍스트 주변에 여백 추가
                  decoration: BoxDecoration(
                    color: WitHomeTheme.wit_lightGreen,
                    //Colors.lightGreen[100], // 연한 녹색 배경
                    borderRadius: BorderRadius.circular(10), // 모서리 둥글게
                  ),
                  child: Text(
                    '파트너님의 업체 설명과 사진을 등록해주세요.',
                    style: WitHomeTheme.title.copyWith(fontSize: 16),
                  ),
                ),

                SizedBox(height: 8), // 레이블과 카드 사이의 간격
                Container(
                  decoration: BoxDecoration(
                    color: WitHomeTheme.white, // 배경색을 하얀색으로
                    border: Border.all(color: Colors.grey, width: 1), // 회색 테두리
                    borderRadius: BorderRadius.circular(10), // 모서리 둥글게
                  ),
                  padding: const EdgeInsets.all(0), // 내부 여백
                  child: TextField(
                    maxLength: 4000,
                    style: WitHomeTheme.subtitle.copyWith(fontSize: 16),
                    controller: sllrContentController,
                    maxLines: 10,
                    decoration: InputDecoration(
                      border: InputBorder.none, // 기본 테두리 제거
                      hintText: '업체 홍보문구를 입력하세요~', // 힌트 텍스트
                      contentPadding: EdgeInsets.all(10), // 왼쪽 패딩만 설정
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
                    style: WitHomeTheme.subtitle
                        .copyWith(fontSize: 14, color: WitHomeTheme.wit_red),
                  ),

                SizedBox(height: 16),
                Padding(
                  // 버튼 주변에 가로 패딩 적용 및 상하 여백 추가
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.0, vertical: 0.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (_images.length >= 10) {
                            alertDialog.show(
                                context: context,
                                title: "알림",
                                content: "이미지는 최대 10건\n입력 가능합니다.");
                            return;
                          }
                          _showImagePickerOptions();
                        },
                        child: Container(
                          width: 85,
                          height: 85,
                          decoration: BoxDecoration(
                            color: WitHomeTheme.wit_white,
                            border: Border.all(
                                width: 1, color: WitHomeTheme.wit_lightgray),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add_a_photo,
                                  size: 40, color: WitHomeTheme.wit_gray),
                              SizedBox(height: 4),
                              Text(
                                '${_images.length}/5',
                                style: WitHomeTheme.subtitle,
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              if (_images.isNotEmpty) ...[
                                Row(
                                  children:
                                      _images.asMap().entries.map((entry) {
                                    int index = entry.key;
                                    var image = entry.value;
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                            child: Image.file(
                                              image,
                                              width: 85,
                                              height: 85,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          Positioned(
                                            right: -7,
                                            top: -7,
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
                                ),
                              ],
                              if (boardDetailImageList != null &&
                                  boardDetailImageList!.isNotEmpty) ...[
                                Row(
                                  children: boardDetailImageList!.map((item) {
                                    var image = apiUrl + item["imagePath"];
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                            child: Image.network(
                                              image,
                                              width: 85,
                                              height: 85,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          Positioned(
                                            right: -7,
                                            top: -7,
                                            child: IconButton(
                                              icon: Icon(Icons.close,
                                                  color: WitHomeTheme.wit_red),
                                              onPressed: () {
                                                setState(() {
                                                  fileDelInfo
                                                      .add(item["imagePath"]);
                                                  boardDetailImageList!
                                                      .remove(item);
                                                });
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Center(
                  // Center 위젯으로 버튼을 감싸서 가운데 정렬
                  child: ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        errorMessage = ''; // 오류 메시지 초기화

                        // 필수 입력 체크
                        bool isSllrContentValid =
                            sllrContentController.text.isNotEmpty;

                        if (!isSllrContentValid) {
                          errorMessage = '업체설명을 입력해주세요.'; // 오류 메시지 설정
                        }
                      });

                      if (errorMessage.isEmpty) {
                        // 사업자 프로필 변경 로직
                        String sllrContent = sllrContentController.text;
                        String sllrImage = sllrImageController.text;

                        await saveImages(sllrContent, sllrImage);
                      }
                      // 이미지 저장 후 프로필 업데이트
                    },
                    child: Text(
                      '다음',
                      style: WitHomeTheme.title.copyWith(
                          fontSize: 14, color: WitHomeTheme.wit_white),
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
      ),
    );
  }

  // [서비스] 이미지 저장
  Future<void> saveImages(
    dynamic sllrContent,
    dynamic sllrImage,
  ) async {
    // 이미지 확인
    if (_images.isEmpty) {
      // 이미지가 없으면 프로필 업데이트 호출
      updateSellerProfile(sllrContent, null);
    } else {
      final fileInfo = await sendFilePostRequest("fileUpload", _images);
      if (fileInfo == "FAIL") {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("파일 업로드 실패")));
      } else {
        // 파일 업로드 성공 후 프로필 업데이트 호출
        updateSellerProfile(sllrContent, fileInfo);
      }
    }
  }

  // [서비스]견적 정보 저장
  Future<void> updateSellerProfile(
    dynamic sllrContent,
    dynamic fileInfo,
  ) async {
    // REST ID
    String restId = "updateSellerInfo";

    // PARAM
    final param = jsonEncode({
      "sllrContent": sllrContent,
      "sllrNo": widget.sllrNo,
      "regiLevel": "02",
      "fileInfo1": fileInfo,
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
          builder: (context) =>
              SellerProfileInsertBizInfo(sllrNo: widget.sllrNo),
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
  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 150,
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.photo),
                title: Text('갤러리에서 선택'),
                onTap: () {
                  _pickMultiImages();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera),
                title: Text('사진 찍기'),
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
