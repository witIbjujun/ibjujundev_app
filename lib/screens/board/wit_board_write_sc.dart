import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:witibju/screens/common/wit_common_widget.dart';
import 'package:witibju/util/wit_api_ut.dart';
import 'package:witibju/screens/board/wit_board_main_sc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:witibju/screens/home/wit_home_theme.dart';

import '../../util/wit_code_ut.dart';

class BoardWrite extends StatefulWidget {

  final dynamic? boardInfo;
  final List<dynamic>? imageList;
  final String bordNo;
  final String bordType;
  final String bordKey;
  final String aptNo;      // 아파트ID
  final String sllrNo;     // 판매자ID
  final String reqNo;      // 신청ID
  final String ctgrId;     // 카테고리ID
  final String creUserId;  // 생성유저ID

  const BoardWrite({super.key, this.boardInfo, this.imageList, required this.bordNo, required this.bordType
    , this.bordKey = "", this.aptNo = "", this.sllrNo = "", this.reqNo = "", this.ctgrId = "", this.creUserId = ""});

  @override
  _BoardWriteState createState() => _BoardWriteState();
}

class _BoardWriteState extends State<BoardWrite> {

  final secureStorage = FlutterSecureStorage();

  List<File> _images = [];
  List<String> fileDelInfo = [];

  // 제목
  final TextEditingController _titleController = TextEditingController();
  // 내용
  final TextEditingController _contentController = TextEditingController();
  // 이미지 picker
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    // boardInfo가 있을 경우 제목과 내용 설정
    if (widget.boardInfo != null) {
      _titleController.text = widget.boardInfo['bordTitle'] ?? '';
      _contentController.text = widget.boardInfo['bordContent'] ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("글 작성", style: WitHomeTheme.title.copyWith(color: WitHomeTheme.wit_white)),
        iconTheme: IconThemeData(color: WitHomeTheme.wit_white),
        backgroundColor: WitHomeTheme.wit_black,
      ),
      backgroundColor: WitHomeTheme.wit_white,
      body: SafeArea(
        child: SingleChildScrollView( // 화면 전체 스크롤을 위해 Column을 SingleChildScrollView로 감쌉니다.
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "제목",
                  style: WitHomeTheme.title,
                ),
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "제목을 입력하세요",
                    hintStyle: WitHomeTheme.subtitle.copyWith(color: WitHomeTheme.wit_lightgray),
                  ),
                  style: WitHomeTheme.subtitle,
                  maxLines: 1,
                ),
                SizedBox(height: 10),
                Container(
                  height: 1,
                  color: WitHomeTheme.wit_extraLightGrey,
                ),
                SizedBox(height: 10),
                Text("내용", style: WitHomeTheme.title),
                TextField(
                    controller: _contentController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "내용을 입력하세요",
                      hintStyle: WitHomeTheme.subtitle.copyWith(color: WitHomeTheme.wit_lightgray),
                    ),
                    style: WitHomeTheme.subtitle,
                    maxLines: null, // 자동 조절
                    minLines: 15,
                    keyboardType: TextInputType.multiline,
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10), // 패딩 10 설정
        child: Column( // 세로로 위젯을 배치하기 위해 Column 사용
          mainAxisSize: MainAxisSize.min, // Column의 크기를 자식들의 크기에 맞게 최소화
          crossAxisAlignment: CrossAxisAlignment.stretch, // 버튼이 가로로 꽉 차도록 스트레치
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start, // 왼쪽 정렬
              children: [
                GestureDetector(
                  onTap: () => _showImagePickerOptions(),
                  child: Container(
                    width: 85,
                    height: 85,
                    decoration: BoxDecoration(
                      color: WitHomeTheme.wit_white,
                      border: Border.all(width: 1, color: WitHomeTheme.wit_lightgray),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.add_a_photo, size: 40, color: WitHomeTheme.wit_gray), // 사진기 아이콘
                    alignment: Alignment.center,
                  ),
                ),
                SizedBox(width: 15), // GestureDetector와 이미지 리스트 간격 추가
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // 첫 번째 이미지 리스트
                        if (_images.isNotEmpty) ...[
                          Row(
                            children: _images.asMap().entries.map((entry) {
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
                                        icon: Icon(Icons.close, color: WitHomeTheme.wit_red),
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
                        // 두 번째 이미지 URL 리스트
                        // 이미지 URL 리스트
                        if (widget.imageList != null && widget.imageList!.isNotEmpty) ...[
                          Row(
                            children: widget.imageList!.map((item) {
                              var image = apiUrl + item["imagePath"];
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12.0),
                                      child: Image.network(
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
                                        icon: Icon(Icons.close, color: WitHomeTheme.wit_red),
                                        onPressed: () {
                                          setState(() {
                                            fileDelInfo.add(item["imagePath"]);
                                            widget.imageList!.remove(item); // URL 이미지 삭제
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
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                showDialog(
                  context: context,
                  barrierDismissible: false, // 배경 클릭으로 닫히지 않도록 설정
                  builder: (BuildContext context) {
                    return Center(
                      child: CircularProgressIndicator(), // 프로그래스 바
                    );
                  },
                );
                // UI가 즉시 업데이트 되도록 잠깐 지연
                await Future.delayed(Duration(milliseconds: 500));
                await saveImages();
                Navigator.of(context).pop(); // 프로그래스 바 닫기
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: WitHomeTheme.wit_lightBlue, // 옅은 녹색 배경
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text("작성", style: WitHomeTheme.title.copyWith(color: WitHomeTheme.wit_white)),
            ),
          ],
        ),
      ),
    );
  }

  // [서비스] 이미지 저장
  Future<void> saveImages() async {

    // 제목 입력 체크
    if (_titleController.text.trim().isEmpty) {
      alertDialog.show(context, "제목을 입력해주세요.");
      return;
    }

    // 내용 입력 체크
    if (_contentController.text.trim().isEmpty) {
      alertDialog.show(context, "내용을 입력해주세요.");
      return;
    }
    
    // 이미지 확인
    if (_images.isEmpty) {
      saveBoardInfo(null);
    } else {
      final fileInfo = await sendFilePostRequest("fileUpload", _images);
      if (fileInfo == "FAIL") {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("파일 업로드 실패")));
      } else {
        saveBoardInfo(fileInfo);
      }
    }
  }

  // [서비스] 게시판 저장
  Future<void> saveBoardInfo(dynamic fileInfo) async {

    // 로그인 사번
    String? loginClerkNo = await secureStorage.read(key: 'clerkNo');

    String restId = "";
    var param;

    if (widget.boardInfo == null) {
      restId = "saveBoardInfo";
      param = jsonEncode({
        "bordTitle": _titleController.text,
        "bordContent": _contentController.text,
        "bordKey": widget.bordKey,
        "bordType": widget.bordType,
        "aptNo": widget.aptNo,
        "sllrNo": widget.sllrNo,
        "reqNo": widget.reqNo,
        "ctgrId": widget.ctgrId,
        "creUser": loginClerkNo,
        "fileInfo": fileInfo
      });

    } else {
      restId = "updateBoardInfo";
      param = jsonEncode({
        "bordTitle": _titleController.text,
        "bordContent": _contentController.text,
        "bordNo" : widget.boardInfo["bordNo"],
        "bordKey": widget.bordKey,
        "bordType": widget.boardInfo["bordType"],
        "creUser": loginClerkNo,
        "updUser": loginClerkNo,
        "fileInfo": fileInfo,
        "fileDelInfo": fileDelInfo,
      });
    }

    final result = await sendPostRequest(restId, param);

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("저장 성공!")));
      Navigator.pop(context,

        SlideRoute(page: Board(bordType: widget.bordType,
                          bordKey: widget.bordKey,
                          aptNo: widget.aptNo,
                          sllrNo: widget.aptNo,
                          reqNo: widget.aptNo,
                          ctgrId: widget.aptNo,
                          creUserId: widget.creUserId)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("저장 실패!")));
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
                  _pickImage(ImageSource.gallery);
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

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _images.add(File(pickedFile.path));
      });
    }
  }
}
