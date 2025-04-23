import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:witibju/screens/checkList/widget/wit_checkList_write_widget.dart';
import 'package:witibju/util/wit_api_ut.dart';
import 'package:witibju/screens/common/wit_common_util.dart';
import 'package:witibju/util/wit_code_ut.dart';
import 'package:witibju/screens/common/wit_ImageViewer_sc.dart';
import 'package:witibju/screens/common/wit_common_widget.dart';

import '../home/wit_home_theme.dart';

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

  bool isLoading = false;     // 하자 전체 저장
  bool isImgLoading1 = false; // 이미지 1
  bool isImgLoading2 = false; // 이미지 2

  DateTime? checkDate;
  DateTime? reprDate;
  String checkComt = "";
  String? checkImg1;
  String? checkImg2;

  File? imageFile1;
  String? imageUrl1 = "";
  File? imageFile2;
  String? imageUrl2 = "";

  final TextEditingController _checkComtController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    setState(() {
      // checkDate 설정
      /*checkDate = widget.checkInfoLv3["checkDate"] != null
          ? DateTime.parse(widget.checkInfoLv3["checkDate"])
          : DateTime.now();*/

      // reprDate 설정
      /*reprDate = widget.checkInfoLv3["reprDate"] != null
          ? DateTime.parse(widget.checkInfoLv3["reprDate"])
          : null;*/

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
      child: Stack( // Stack으로 전체 위젯을 감싸서 겹쳐서 배치
        children: [
          Column(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  height: 60,
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      color: WitHomeTheme.wit_lightGreen,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 3, // 막대의 두께
                          width: 60, // 막대의 길이
                          color: WitHomeTheme.wit_white, // 막대 색상
                        ),
                        SizedBox(height: 15), // 아이콘과 텍스트 사이의 간격
                        Text(
                          "하자 등록 [" + widget.checkInfoLv3["inspNm"] + "]",
                          style: WitHomeTheme.title.copyWith(color: WitHomeTheme.wit_white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(35, 20, 35, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "하자 이미지",
                            style: WitHomeTheme.subtitle.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // 첫번째 이미지 영역
                          ImagePickerWidget(
                            imageFile: imageFile1,
                            imageUrl: imageUrl1 ?? "", // null일 경우 빈 문자열로 변환
                            isImgLoading: isImgLoading1,
                            onTap: () async {
                              if (imageFile1 == null && (imageUrl1 == null || imageUrl1!.isEmpty)) {
                                _showImagePickerOptions(1);
                              } else {
                                List<String> imageUrls = [imageUrl1!];
                                await Navigator.push(
                                  context,
                                  SlideRoute(
                                    page: ImageViewer(
                                      imageUrls: imageUrls.map((item) => apiUrl + item).toList(),
                                      initialIndex: 0,
                                    ),
                                  ),
                                );
                              }
                            },
                            onRemove: () {
                              setState(() {
                                imageFile1 = null;
                                imageUrl1 = null; // null로 설정
                              });
                            },
                          ),
                          SizedBox(width: 10),
                          // 두번째 이미지 영역
                          ImagePickerWidget(
                            imageFile: imageFile2,
                            imageUrl: imageUrl2 ?? "", // null일 경우 빈 문자열로 변환
                            isImgLoading: isImgLoading2,
                            onTap: () async {
                              if (imageFile2 == null && (imageUrl2 == null || imageUrl2!.isEmpty)) {
                                _showImagePickerOptions(2);
                              } else {
                                List<String> imageUrls = [imageUrl2!];
                                await Navigator.push(
                                  context,
                                  SlideRoute(
                                    page: ImageViewer(
                                      imageUrls: imageUrls.map((item) => apiUrl + item).toList(),
                                      initialIndex: 0,
                                    ),
                                  ),
                                );
                              }
                            },
                            onRemove: () {
                              setState(() {
                                imageFile2 = null;
                                imageUrl2 = null; // null로 설정
                              });
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "하자 내용",
                            style: WitHomeTheme.subtitle.copyWith(fontWeight: FontWeight.bold),
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
                              borderSide: BorderSide(color: WitHomeTheme.wit_gray),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: WitHomeTheme.wit_gray),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: WitHomeTheme.wit_gray),
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
                          // 하자등록 버튼
                          Expanded(
                            child: TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: WitHomeTheme.wit_lightCoral,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () async {
                                setState(() {
                                  isLoading = true;
                                });

                                // UI가 즉시 업데이트 되도록 잠깐 지연
                                await Future.delayed(Duration(milliseconds: 500));

                                // 하자등록
                                await save(false);

                                setState(() {
                                  isLoading = false;
                                });

                                Navigator.of(context).pop();
                              },
                              child: Text("하자 등록",
                                style: WitHomeTheme.subtitle.copyWith(fontWeight: FontWeight.bold, color: WitHomeTheme.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // 로딩 인디케이터 추가
          if (isLoading) // 로딩 상태일 때만 표시
            Container(
              color: Colors.black54, // 반투명 배경
              child: Center(
                child: CircularProgressIndicator(), // 로딩 인디케이터
              ),
            ),
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
        widget.checkInfoLv3["checkDate"] = formatDateYYYYMMDD(DateTime.now());
        widget.checkInfoLv3["reprDate"] = formatDateYYYYMMDD(reprDate);
        widget.checkInfoLv3["checkComt"] = _checkComtController.text;
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
          widget.checkInfoLv3["checkComt"] = _checkComtController.text;
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

      setState(() {
        if (index == 1) {
          isImgLoading1 = true;
        } else {
          isImgLoading2 = true;
        }
      });

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
          isImgLoading1 = false;
          imageFile1 = rotatedFile;
          imageUrl1 = "";
        }
        if (index == 2) {
          isImgLoading2 = false;
          imageFile2 = rotatedFile;
          imageUrl2 = null;
        }
      });
    }
  }

}