import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:witibju/util/wit_api_ut.dart';
import 'package:witibju/screens/board/wit_board_main_sc.dart';
import 'package:image_picker/image_picker.dart';

class BoardWrite extends StatefulWidget {

  final int? bordNo;
  final String? bordType;
  final dynamic? boardInfo;
  final List<dynamic>? imageList;

  const BoardWrite({super.key, this.boardInfo, this.imageList, this.bordNo, this.bordType});

  @override
  _BoardWriteState createState() => _BoardWriteState();
}

class _BoardWriteState extends State<BoardWrite> {

  List<File> _images = [];
  List<String> _imageUrl = [];

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
    // boardImageList가 있을 경우 이미지 목록 설정
    if (widget.imageList?.isNotEmpty ?? false) {

      /*widget.imageList!.forEach((item) {
        _images.add(Image.network(apiUrl + item["imagePath"]) as File);
      });*/
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("글 작성",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "제목",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "제목을 입력하세요",
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                style: TextStyle(fontSize: 14),
                maxLines: 1,
              ),
              SizedBox(height: 10),
              Divider(),
              SizedBox(height: 10),
              Text(
                "내용",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Expanded( // Expanded 추가
                child: TextField(
                  controller: _contentController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "내용을 입력하세요",
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                  style: TextStyle(fontSize: 14),
                  maxLines: null, // 자동 조절
                  keyboardType: TextInputType.multiline,
                ),
              ),
              SizedBox(height: 10),
              Divider(),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.start, // 왼쪽 정렬
                children: [
                  GestureDetector(
                    onTap: () => _showImagePickerOptions(),
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.camera_alt, size: 40), // 사진기 아이콘
                      alignment: Alignment.center,
                    ),
                  ),
                  SizedBox(width: 16), // GestureDetector와 이미지 리스트 간격 추가
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _images.asMap().entries.map((entry) {
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
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(10), // 패딩 10 설정
        child: ElevatedButton(
          onPressed: () async {
            await saveImages();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[200], // 옅은 녹색 배경
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
          ),
          child: Text("작성"),
        ),
      ),
    );
  }

  // [서비스] 이미지 저장
  Future<void> saveImages() async {

    // 제목 입력 체크
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("제목을 입력해 주세요.")),
      );
      return;
    }

    // 내용 입력 체크
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("내용을 입력해주세요.")),
      );
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

    String restId = "";
    var param = null;

    if (widget.boardInfo == null) {

      restId = "saveBoardInfo";
      param = jsonEncode({
        "bordTitle": _titleController.text,
        "bordContent": _contentController.text,
        "bordNo": widget.bordNo,
        "bordType": widget.bordType,
        "creUser": "user1",
        "fileInfo": fileInfo
      });

    } else {

      restId = "updateBoardInfo";
      param = jsonEncode({
        "bordTitle": _titleController.text,
        "bordContent": _contentController.text,
        "bordNo" : widget.boardInfo["bordNo"],
        "bordType": widget.boardInfo["bordType"],
        "bordSeq" : widget.boardInfo["bordSeq"],
        "updUser": "user1",
        "fileInfo": fileInfo
      });
    }

    final result = await sendPostRequest(restId, param);

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("저장 성공!")));
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Board(widget.bordNo, widget.bordType),
        ),
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
}
