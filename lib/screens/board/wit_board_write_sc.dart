import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:witibju/screens/common/wit_common_widget.dart';
import 'package:witibju/util/wit_api_ut.dart';
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
  // 게시판 구분
  String bordTypeGbn = "";

  // 제목
  final TextEditingController _titleController = TextEditingController();
  // 내용
  final TextEditingController _contentController = TextEditingController();
  // 이미지 picker
  final ImagePicker _picker = ImagePicker();
  // 별점 상태 변수 (0: 선택 안됨, 1~5: 선택된 별점)
  int starRating = 0;

  @override
  void initState() {
    super.initState();

    // 게시판 타입 앞 2자리 추출
    setState(() {
      bordTypeGbn = widget.bordType.substring(0, 2);
    });

    // boardInfo가 있을 경우 제목과 내용 설정
    if (widget.boardInfo != null) {
      _titleController.text = widget.boardInfo['bordTitle'] ?? '';
      _contentController.text = widget.boardInfo['bordContent'] ?? '';
    }
  }

  // 별 아이콘을 생성하는 위젯
  Widget _buildStar(int starIndex) {
    return InkWell( // 탭 감지를 위해 InkWell 사용
      onTap: () {
        setState(() {
          starRating = starIndex + 1; // 탭한 별 인덱스에 1을 더하여 별점 설정
        });
      },
      child: Icon(
        Icons.star, // 별 아이콘
        color: starRating > starIndex ? WitHomeTheme.wit_lightYellow : WitHomeTheme.wit_lightgray, // 선택된 별보다 작거나 같으면 노란색, 아니면 회색
        size: 60.0, // 별 크기
      ),
    );
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
                if (bordTypeGbn == "UH")...[
                  Center( // 이 부분을 Center로 감싸서 가운데 정렬
                    child: Text(
                      "이용 후기는 어떠셨나요?", // 별점 레이블
                      style: WitHomeTheme.title,
                    ),
                  ),
                  SizedBox(height: 10),
                  Center( // 이 부분을 Center로 감싸서 가운데 정렬
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(5, (index) => _buildStar(index)),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
                if (bordTypeGbn != "UH")...[
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
                  ],
                Container(
                  height: 1,
                  color: WitHomeTheme.wit_extraLightGrey,
                ),
                SizedBox(height: 10),
                if (bordTypeGbn == "UH")...[
                  Text("후기 작성", style: WitHomeTheme.title),
                ] else ...[
                  Text("내용", style: WitHomeTheme.title),
                ],
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
                  onTap: () {
                    if (_images.length >= 5) {
                      alertDialog.show(context: context, title:"알림", content: "이미지는 최대 5건\n입력 가능합니다.");
                      return;
                    }
                    _showImagePickerOptions();
                  },
                  child: Container(
                    width: 85,
                    height: 85,
                    decoration: BoxDecoration(
                      color: WitHomeTheme.wit_white,
                      border: Border.all(width: 1, color: WitHomeTheme.wit_lightgray),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    // 아이콘과 텍스트를 세로로 배치하기 위해 Column 사용
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center, // 세로 중앙 정렬
                      crossAxisAlignment: CrossAxisAlignment.center, // 가로 중앙 정렬
                      mainAxisSize: MainAxisSize.min, // Column의 크기를 자식 위젯들 크기에 맞게 최소화
                      children: [
                        Icon(Icons.add_a_photo, size: 40, color: WitHomeTheme.wit_gray), // 사진기 아이콘
                        SizedBox(height: 4), // 아이콘과 텍스트 사이 간격 추가 (조절 가능)
                        Text(
                          '${_images.length}/5', // <--- 이 부분을 수정했습니다.
                          style: WitHomeTheme.subtitle, // 텍스트 색상 조절
                        ),
                      ],
                    ),
                    // Container 자체의 정렬은 Column의 중앙 정렬과 함께 사용되어 효과적으로 중앙 배치
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
                                      right: -7,
                                      top: -7,
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
                                      right: -7,
                                      top: -7,
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

    // 별점 입력 체크
    if (starRating == 0 && bordTypeGbn == "UH") {
      alertDialog.show(context: context, title: "알림", content: "별점을 입력해주세요.");
      return;
    }

    // 제목 입력 체크
    if (_titleController.text.trim().isEmpty && bordTypeGbn != "UH") {
      alertDialog.show(context: context, title: "알림", content: "제목을 입력해주세요.");
      return;
    }

    // 내용 입력 체크
    if (_contentController.text.trim().isEmpty) {
      String txt = "내용";
      if (bordTypeGbn == "UH") {
        txt = "후기";
      }
      alertDialog.show(context: context, title: "알림", content: txt + "을 입력해주세요.");
      return;
    }

    await Future.delayed(Duration(milliseconds: 500));

    // 이미지 확인
    if (_images.isEmpty) {
      saveBoardInfo(null);
    } else {
      final fileInfo = await sendFilePostRequest("fileUpload", _images);
      if (fileInfo == "FAIL") {
        alertDialog.show(context: context, title: "알림", content: "파일 업로드 실패하였습니다.");
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
        "starRating": starRating,
        "creUser": loginClerkNo,
        "fileInfo": fileInfo
      });

    } else {
      restId = "updateBoardInfo";
      param = jsonEncode({
        "bordTitle": _titleController.text,
        "bordContent": _contentController.text,
        "bordNo" : widget.boardInfo["bordNo"],
        "bordKey": widget.boardInfo["bordKey"],
        "bordType": widget.boardInfo["bordType"],
        "aptNo": widget.boardInfo["aptNo"],
        "sllrNo": widget.boardInfo["sllrNo"],
        "reqNo": widget.boardInfo["reqNo"],
        "ctgrId": widget.boardInfo["ctgrId"],
        "creUser": loginClerkNo,
        "updUser": loginClerkNo,
        "fileInfo": fileInfo,
        "fileDelInfo": fileDelInfo,
        "starRating": starRating,
      });
    }

    final result = await sendPostRequest(restId, param);

    if (result != null) {
      Navigator.pop(context);
      alertDialog.show(context: context, title: "알림", content: "저장 성공 하였습니다.");
    } else {
      Navigator.pop(context);
      alertDialog.show(context: context, title: "알림", content: "저장 실패 하였습니다.");
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
}
