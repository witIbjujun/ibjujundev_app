import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:witibju/util/wit_api_ut.dart';
import 'package:witibju/screens/common/wit_common_util.dart';
import 'package:witibju/util/wit_code_ut.dart';

// 하자등록 팝업
class ExamplePhotoPopup extends StatefulWidget {

  final dynamic checkInfoLv3;
  final Function(bool) onSwitchChanged;

  const ExamplePhotoPopup({
    Key? key,
    required this.checkInfoLv3,
    required this.onSwitchChanged,
  }) : super(key: key);

  @override
  _ExamplePhotoPopupState createState() => _ExamplePhotoPopupState();
}

class _ExamplePhotoPopupState extends State<ExamplePhotoPopup> {

  DateTime? checkDate;
  DateTime? reprDate;
  String checkComt = "";
  String? checkImg1;
  String? checkImg2;

  File? imageFile1;
  String? imageUrl1;
  File? imageFile2;
  String? imageUrl2;

  final TextEditingController _checkComtController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    setState(() {
      // checkDate 설정
      checkDate = widget.checkInfoLv3["checkDate"] != null
          ? DateTime.parse(widget.checkInfoLv3["checkDate"])
          : DateTime.now();

      // reprDate 설정
      reprDate = widget.checkInfoLv3["reprDate"] != null
          ? DateTime.parse(widget.checkInfoLv3["reprDate"])
          : null;

      // checkComt 설정
      _checkComtController.text = widget.checkInfoLv3["checkComt"] ?? "";

      // checkImg1 설정
      checkImg1 = widget.checkInfoLv3["checkImg1"] != null
          ? widget.checkInfoLv3["checkImg1"] : "";

      imageFile1 = null;
      imageUrl1 = checkImg1!;

      // checkImg2 설정
      checkImg2 = widget.checkInfoLv3["checkImg2"] != null
          ? widget.checkInfoLv3["checkImg2"] : "";

      imageFile2 = null;
      imageUrl2 = checkImg2!;


      print(imageUrl1);
      print(imageUrl2);
    });
  }

  @override
  void dispose() {
    _checkComtController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Container(
        height: 50,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.blue[200],
          borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
        ),
        alignment: Alignment.center,
        child: Text("하자 등록 [" + widget.checkInfoLv3["inspNm"] + "]",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("하자 일자",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Container(height: 10),
            GestureDetector(
              onTap: () => _selectDate(context, true),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      checkDate != null ? '${checkDate!.toLocal()}'.split(' ')[0] : '날짜 선택',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
            Container(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("수리 일자",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Container(height: 10),
            GestureDetector(
              onTap: () => _selectDate(context, false),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      reprDate != null ? '${reprDate!.toLocal()}'.split(' ')[0] : '날짜 선택',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
            Container(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "하자 내용",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Container(height: 10),
            Container(
              height: 150,
              width: 350,
              child: TextField(
                controller: _checkComtController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                ),
                onChanged: (value) {
                  setState(() {
                    checkComt = value;
                  });
                },
                maxLines: 5,
                style: TextStyle(height: 1.5),
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "하자 이미지",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // 중앙 정렬
              children: [
                GestureDetector(
                  onTap: () => _showImagePickerOptions(1), // 첫 번째 이미지 클릭 시 호출
                  child: Container(
                    width: 120, // 너비 120 설정
                    height: 120, // 높이 120 설정
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10), // 라운드 설정
                      border: Border.all(color: Colors.grey), // 테두리 색상
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10), // 라운드 적용
                      child: imageFile1 != null
                          ? Image.file(
                        imageFile1!,
                        fit: BoxFit.cover, // 이미지 비율 유지
                      )
                          : imageUrl1 != ""
                          ? Image.network(
                        apiUrl + imageUrl1!,
                        fit: BoxFit.cover, // 이미지 비율 유지
                      ) : Center(
                          child: Icon(
                          Icons.add_a_photo, // 이미지 추가 아이콘
                          size: 40, // 아이콘 크기
                          color: Colors.grey[600], // 아이콘 색상
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 20), // 이미지 사이 간격
                GestureDetector(
                  onTap: () => _showImagePickerOptions(2), // 두 번째 이미지 클릭 시 호출
                  child: Container(
                    width: 120, // 너비 120 설정
                    height: 120, // 높이 120 설정
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10), // 라운드 설정
                      border: Border.all(color: Colors.grey), // 테두리 색상
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10), // 라운드 적용
                      child: imageFile2 != null
                          ? Image.file(
                        imageFile2!,
                        fit: BoxFit.cover, // 이미지 비율 유지
                      )
                          : imageUrl2 != ""
                          ? Image.network(
                        apiUrl + imageUrl2!,
                        fit: BoxFit.cover, // 이미지 비율 유지
                      ) : Center(
                        child: Icon(
                          Icons.add_a_photo, // 이미지 추가 아이콘
                          size: 40, // 아이콘 크기
                          color: Colors.grey[600], // 아이콘 색상
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        Container(
          height: 50,
          width: double.infinity,
          child: Row(
            children: [
              Expanded(
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey[500], // 취소 버튼 색상
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // 라운드 없애기
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "취소",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              SizedBox(width: 10), // 간격 조정
              Expanded(
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.red[200], // 확인 버튼 색상
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // 라운드 없애기
                    ),
                  ),
                  onPressed: () async {
                    // 하자등록
                    await save(false);
                    Navigator.of(context).pop();
                  },
                  child: Text("하자등록",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              SizedBox(width: 10), // 간격 조정
              Expanded(
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blue[200], // 확인 버튼 색상
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // 라운드 없애기
                    ),
                  ),
                  onPressed: () async {
                    // 하자완료
                    await save(true);
                    Navigator.of(context).pop();
                  },
                  child: Text("하자완료",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // [서비스] 이미지 저장
  Future<void> save(bool checkflag) async {

    // REST ID
    String restId = "fileUpload";

    // 이미지 없으면....
    if (imageFile1 == null && imageFile2 == null) {
      setState(() {
        widget.checkInfoLv3["checkDate"] = formatDateYYYYMMDD(checkDate);
        widget.checkInfoLv3["reprDate"] = formatDateYYYYMMDD(reprDate);
        widget.checkInfoLv3["checkComt"] = checkComt;
        widget.checkInfoLv3["checkImg1"] = imageUrl1;
        widget.checkInfoLv3["checkImg2"] = imageUrl2;
        widget.onSwitchChanged(checkflag);
      });

    // 이미지 있으면
    } else {

      List<File> _images = [];
      if (imageFile1 != null) {
        _images.add(imageFile1!);
      }
      if (imageFile2 != null) {
        _images.add(imageFile2!);
      }

      final fileInfo = await sendFilePostRequest(restId, _images);

      // 이미지 등록 실패
      if (fileInfo == "FAIL") {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("파일 업로드 실패")));

      // 이미지 등록 성공
      } else {
        setState(() {
          widget.checkInfoLv3["checkDate"] = formatDateYYYYMMDD(checkDate);
          widget.checkInfoLv3["reprDate"] = formatDateYYYYMMDD(reprDate);
          widget.checkInfoLv3["checkComt"] = checkComt;
          widget.checkInfoLv3["checkImg1"] = imageFile1 == null ? imageUrl1 : "/WIT/" + imageFile1!.path.split('/').last ;
          widget.checkInfoLv3["checkImg2"] = imageFile2 == null ? imageUrl2 : "/WIT/" + imageFile2!.path.split('/').last ;
          widget.onSwitchChanged(checkflag);

        });
      }
    }
  }

  // [달력] 달력 호출
  Future<void> _selectDate(BuildContext context, bool isDefectDate) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (selectedDate != null) {
      setState(() {
        if (isDefectDate) {
          checkDate = selectedDate;
        } else {
          reprDate = selectedDate;
        }
      });
    }
  }

  void _showImagePickerOptions(int index) {
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
                  _pickImage(ImageSource.gallery, index);
                  Navigator.pop(context); // 모달 닫기

                },
              ),
              ListTile(
                leading: Icon(Icons.camera),
                title: Text('사진 찍기'),
                onTap: () {
                  _pickImage(ImageSource.camera, index);
                  Navigator.pop(context); // 모달 닫기

                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source, index) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        if (index == 1) {
          imageFile1 = File(pickedFile.path);
          imageUrl1 = null;
        }
        if (index == 2) {
          imageFile2 = File(pickedFile.path);
          imageUrl2 = null;
        }
      });
    }
  }

}