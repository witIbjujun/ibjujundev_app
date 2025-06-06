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
  // 사진 최대 건수
  int maxPhotoCnt = 5;

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
        child: Column(
          children: [
            Expanded( // 이 Expanded가 부모 위젯(예: Row/Column)의 남은 공간을 모두 차지합니다.
              child: Padding( // 전체 내용에 패딩을 적용합니다.
                padding: EdgeInsets.all(20.0),
                child: Column( // 이 Column이 Expanded가 제공하는 공간을 채웁니다.
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- 고정된 상단 요소들 ---
                    // bordTypeGbn이 "UH"일 때의 요소들
                    if (bordTypeGbn == "UH")...[
                      Center( // 가운데 정렬을 위해 Center로 감쌈
                        child: Text(
                          "이용 후기는 어떠셨나요?", // 별점 레이블
                          style: WitHomeTheme.title,
                        ),
                      ),
                      SizedBox(height: 10),
                      Center( // 가운데 정렬을 위해 Center로 감쌈
                        child: Row(
                          mainAxisSize: MainAxisSize.min, // Row의 크기를 자식 크기에 맞게 최소화
                          children: List.generate(5, (index) => _buildStar(index)),
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                    // bordTypeGbn이 "UH"가 아닐 때의 제목 입력 필드
                    if (bordTypeGbn != "UH")...[
                      Text(
                        "제목",
                        style: WitHomeTheme.subtitle.copyWith(fontWeight: FontWeight.bold),
                      ),
                      TextField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "제목을 입력하세요",
                          hintStyle: WitHomeTheme.caption.copyWith(color: WitHomeTheme.wit_lightgray),
                          counterText: "",
                        ),
                        style: WitHomeTheme.subtitle,
                        maxLines: 1,
                        maxLength: 30,
                      ),
                    ],
                    Container(
                      height: 1,
                      color: WitHomeTheme.wit_extraLightGrey,
                    ),
                    SizedBox(height: 10),
                    if (bordTypeGbn == "UH")...[
                      Text("후기 작성",
                        style: WitHomeTheme.subtitle.copyWith(fontWeight: FontWeight.bold),),
                    ] else ...[
                      Text("내용",
                        style: WitHomeTheme.subtitle.copyWith(fontWeight: FontWeight.bold),),
                    ],
                    Expanded(
                      child: TextField(
                        controller: _contentController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "내용을 입력하세요",
                          hintStyle: WitHomeTheme.caption.copyWith(color: WitHomeTheme.wit_lightgray),
                        ),
                        style: WitHomeTheme.subtitle,
                        maxLines: null,
                        maxLength: 1000,
                        keyboardType: TextInputType.multiline,
                        expands: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding( // 버튼 주변에 가로 패딩 적용 및 상하 여백 추가
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 0.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (_images.length >= maxPhotoCnt) {
                        alertDialog.show(context: context, title:"알림", content: "이미지는 최대 " + maxPhotoCnt.toString() + "건\n입력 가능합니다.");
                        return;
                      }
                      _showImagePickerOptions(maxPhotoCnt);
                    },
                    child: Container(
                      width: 75,
                      height: 75,
                      decoration: BoxDecoration(
                        color: WitHomeTheme.wit_white,
                        border: Border.all(width: 1, color: WitHomeTheme.wit_lightgray),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_a_photo, size: 30, color: WitHomeTheme.wit_gray),
                          SizedBox(height: 4),
                          Text(
                            '${_images.length}/' + maxPhotoCnt.toString(),
                            style: WitHomeTheme.caption,
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
                                          width: 75,
                                          height: 75,
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
                                          width: 75,
                                          height: 75,
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
                                              widget.imageList!.remove(item);
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
            Padding( // 버튼 주변에 가로 패딩 적용 및 상하 여백 추가
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: SizedBox( // 버튼을 좌우 가득 채우도록 설정
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                    );
                    await saveImages();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: WitHomeTheme.wit_lightBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text("작성", style: WitHomeTheme.title.copyWith(color: WitHomeTheme.wit_white)),
                ),
              ),
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
  void _showImagePickerOptions(int maxCnt) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 150,
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.photo,size: 30),
                title: Text('갤러리에서 선택', style: WitHomeTheme.subtitle),
                onTap: () {
                  _pickMultiImages(maxCnt);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera,size: 30),
                title: Text('사진 찍기', style: WitHomeTheme.subtitle),
                onTap: () {
                  _pickImage(ImageSource.camera, maxCnt);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source, int maxCnt) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      maxHeight: 1200,
      maxWidth: 1200,
      imageQuality: 30,
    );

    if (pickedFile != null) {
      setState(() {
        if (_images.length < 5) {
          _images.add(File(pickedFile.path));
        }
      });
    }
  }

  Future<void> _pickMultiImages(int maxCnt) async {
    final List<XFile>? pickedFiles = await _picker.pickMultiImage(
      maxHeight: 1200,
      maxWidth: 1200,
      imageQuality: 30,
    );
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
