import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:witibju/util/wit_api_ut.dart';
import 'package:witibju/screens/common/wit_common_util.dart';
import 'package:witibju/util/wit_code_ut.dart';
import 'package:witibju/screens/common/wit_ImageViewer_sc.dart';
import 'package:witibju/screens/common/wit_common_widget.dart';

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

  bool _isLoading = false; // 로딩 상태 변수

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

    });
  }

  @override
  void dispose() {
    _checkComtController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              height: 50,
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF91C58C),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                ),
                alignment: Alignment.center,
                child: Text(
                  "하자 등록 [" + widget.checkInfoLv3["inspNm"] + "]",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ),
          // 여기 아래에 추가할 위젯을 넣으세요
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(35, 20, 35, 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /*Container(height: 10),
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
                  Container(height: 20),*/
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 첫번째 이미지 영역
                      GestureDetector(
                        onTap: () async {
                          if (imageFile1 == null && imageUrl1 == "") {
                            _showImagePickerOptions(1);
                          } else {
                            List<String> imageUrls = [imageUrl1!];
                            await Navigator.push(
                              context,
                              SlideRoute(
                                  page: ImageViewer(
                                    imageUrls: imageUrls.map((item) => apiUrl + item).toList(),
                                    initialIndex: 0,
                                  )
                              ),
                            );
                          }
                        },
                        child: Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: imageFile1 != null
                                    ? Image.file(
                                  imageFile1!,
                                  fit: BoxFit.cover,
                                  width: 160,
                                  height: 160,
                                )
                                    : imageUrl1 != ""
                                    ? Image.network(
                                  apiUrl + imageUrl1!,
                                  fit: BoxFit.cover,
                                  width: 160,
                                  height: 160,
                                )
                                    : Center(
                                  child: Icon(
                                    Icons.add_a_photo,
                                    size: 40,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                              if (imageFile1 != null || imageUrl1 != "")
                                Positioned(
                                  right: 8,
                                  top: 8,
                                  child: GestureDetector(
                                    onTap: () {
                                      // 엑스 아이콘 클릭 시 이벤트 처리
                                      setState(() {
                                        imageFile1 = null;
                                        imageUrl1 = "";
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.red,
                                      ),
                                      padding: EdgeInsets.all(4),
                                      child: Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 20),

                      // 두번째 이미지 영역
                      GestureDetector(
                        onTap: () async {
                          if (imageFile2 == null && imageUrl2 == "") {
                            _showImagePickerOptions(2);
                          } else {
                            List<String> imageUrls = [imageUrl2!];
                            await Navigator.push(
                              context,
                              SlideRoute(
                                  page: ImageViewer(
                                    imageUrls: imageUrls.map((item) => apiUrl + item).toList(),
                                    initialIndex: 0,
                                  )
                              ),
                            );
                          }
                        },
                        child: Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: imageFile2 != null
                                    ? Image.file(
                                  imageFile2!,
                                  fit: BoxFit.cover,
                                  width: 160,
                                  height: 160,
                                )
                                    : imageUrl2 != ""
                                    ? Image.network(
                                  apiUrl + imageUrl2!,
                                  fit: BoxFit.cover,
                                  width: 160,
                                  height: 160,
                                )
                                    : Center(
                                  child: Icon(
                                    Icons.add_a_photo,
                                    size: 40,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                              if (imageFile2 != null || imageUrl2 != "")
                                Positioned(
                                  right: 8,
                                  top: 8,
                                  child: GestureDetector(
                                    onTap: () {
                                      // 엑스 아이콘 클릭 시 이벤트 처리
                                      setState(() {
                                        imageFile2 = null;
                                        imageUrl2 = "";
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.red,
                                      ),
                                      padding: EdgeInsets.all(4),
                                      child: Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
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
                    height: 100,
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
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 버튼 간격을 일정하게
                    children: [
                      // 하자완료 버튼
                      /*Expanded(
                        child: TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Color(0xFF7BB5C9),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () async {
                            setState(() {
                              _isLoading = true;
                            });
                            // 하자완료
                            await save(true);

                            setState(() {
                              _isLoading = false;
                            });

                            Navigator.of(context).pop();
                          },
                          child: Text("하자 완료",
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(width: 20),*/
                      // 하자등록 버튼
                      Expanded(
                        child: TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Color(0xFFE5767B),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () async {
                            setState(() {
                              _isLoading = true;
                            });
                            // 하자등록
                            await save(false);

                            setState(() {
                              _isLoading = false;
                            });

                            Navigator.of(context).pop();
                          },
                          child: Text("하자 등록",
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          /*if (_isLoading) // 로딩 상태일 때만 표시
            Container(
              width: double.infinity, // 전체 너비를 차지하도록 설정
              child: Center(
                child: CircularProgressIndicator(), // 로딩 인디케이터
              ),
            ),*/
        ],
      ),
    );
  }

  // [서비스] 이미지 저장
  Future<void> save(bool checkflag) async {

    // REST ID
    String restId = "fileUpload";

    // 이미지 없으면
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

      List<File> images = [];
      if (imageFile1 != null) {
        images.add(imageFile1!);
      }
      if (imageFile2 != null) {
        images.add(imageFile2!);
      }

      final fileInfo = await sendFilePostRequest(restId, images);

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

  // [팝업] 갤러리, 카메라 팝업 호출
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
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera),
                title: Text('사진 찍기'),
                onTap: () {
                  _pickImage(ImageSource.camera, index);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // [유틸] 갤러리, 카메라 피커 호출
  Future<void> _pickImage(ImageSource source, index) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      // 이미지 파일을 바이트로 읽기
      final bytes = await File(pickedFile.path).readAsBytes();

      // 이미지 디코딩
      img.Image? image = img.decodeImage(bytes);

      // 이미지 오른쪽으로 90도 회전
      img.Image rotatedImage = img.copyRotate(image!, angle: 360);

      // 회전된 이미지를 파일로 저장
      final rotatedFile = File(pickedFile.path);
      await rotatedFile.writeAsBytes(img.encodeJpg(rotatedImage));

      setState(() {
        if (index == 1) {
          imageFile1 = rotatedFile;
          imageUrl1 = null;
        }
        if (index == 2) {
          imageFile2 = rotatedFile;
          imageUrl2 = null;
        }
      });
    }
  }

}