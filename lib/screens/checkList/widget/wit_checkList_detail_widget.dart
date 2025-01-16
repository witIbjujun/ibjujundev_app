import 'dart:io';

import 'package:flutter/material.dart';
import 'package:witibju/util/wit_code_ut.dart';
import 'package:image_picker/image_picker.dart';
import '../../../util/wit_api_ut.dart';
import '../../common/wit_common_util.dart';

/**
 * 체크리스트 상세 화면 UI
 */
class CheckListDetailView extends StatefulWidget {
  final dynamic checkInfoLv1;
  final List<dynamic> checkListByLv2;
  final List<dynamic> checkListByLv3;
  final TabController tabController;
  final Function(String) onTabChanged;
  final Function(dynamic, String) onSwitchChanged;

  const CheckListDetailView({
    Key? key,
    required this.checkInfoLv1,
    required this.checkListByLv2,
    required this.checkListByLv3,
    required this.tabController,
    required this.onTabChanged,
    required this.onSwitchChanged,
  }) : super(key: key);

  @override
  _CheckListDetailViewState createState() => _CheckListDetailViewState();
}

class _CheckListDetailViewState extends State<CheckListDetailView> {
  int? expandedIndex = 0; // 클릭된 항목의 인덱스를 저장
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose(); // ScrollController 메모리 해제
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            TabBarWidget(
              checkInfoLv1 : widget.checkInfoLv1,
              checkListByLv2: widget.checkListByLv2,
              tabController: widget.tabController,
              onTabChanged: (inspId) {
                setState(() {
                  expandedIndex = 0;
                });
                widget.onTabChanged(inspId);
              },
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: widget.checkListByLv3.length,
                itemBuilder: (context, index) {
                  bool isExpanded = expandedIndex == index;
                  return ExpandableItem(
                    checkInfoLv1 : widget.checkInfoLv1,
                    checkInfoLv3: widget.checkListByLv3[index],
                    isExpanded: isExpanded,
                    onSwitchChanged: (value) {
                      setState(() {
                        widget.checkListByLv3[index]["checkYn"] = value ? "N" : "Y";
                      });
                      widget.onSwitchChanged(widget.checkListByLv3[index], value ? "N" : "Y");
                    },
                    onTap: () {
                      setState(() {
                        expandedIndex = isExpanded ? null : index;
                        if (!isExpanded) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _scrollController.animateTo(
                              (index - 1) * 82.5,
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          });
                        }
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/**
 * 체크리스트 상세 TabBar Widget
 */
class TabBarWidget extends StatelessWidget {
  final dynamic checkInfoLv1;
  final List<dynamic> checkListByLv2;
  final TabController tabController;
  final Function(String) onTabChanged;

  const TabBarWidget({
    Key? key,
    required this.checkInfoLv1,
    required this.checkListByLv2,
    required this.tabController,
    required this.onTabChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (checkListByLv2.isNotEmpty) {
      return Container(
        color: Colors.white,
        child: TabBar(
          controller: tabController,
          isScrollable: false,
          onTap: (index) {
            onTabChanged(checkListByLv2[index]["inspId"]);
          },
          tabs: checkListByLv2.map((item) {
            return Tab(
              child: Container(
                alignment: Alignment.center,
                width: double.infinity,
                child: Text(
                  item["inspNm"] + " (" + (item["checkCnt"] ?? 0).toString() + ")",
                ),
              ),
            );
          }).toList(),
        ),
      );
    } else {
      return SizedBox.shrink(); // 리스트가 비어있을 경우 빈 위젯 반환
    }
  }
}

/**
 * 체크리스트 상세 TabBar 상세 Widget
 */
class ExpandableItem extends StatelessWidget {
  final dynamic checkInfoLv1;
  final dynamic checkInfoLv3;
  final bool isExpanded;
  final Function(bool) onSwitchChanged;
  final VoidCallback onTap;

  const ExpandableItem({
    Key? key,
    required this.checkInfoLv1,
    required this.checkInfoLv3,
    required this.isExpanded,
    required this.onSwitchChanged,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(10, 6, 10, 6),
      decoration: BoxDecoration(
        color: Colors.white, // 배경색 설정
        borderRadius: BorderRadius.circular(10), // 라운드 처리
        border: Border.all(
          color: isExpanded == false ? Colors.grey[200]! : Colors.grey[400]!, // 찐한 회색 테두리 색상
          width: 2, // 테두리 두께
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onTap, // 클릭 이벤트 처리
            child: Container(
              height: 70,
              width: double.infinity,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isExpanded ? Colors.white : Colors.white,
                borderRadius: isExpanded ?
                  BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10),)
                    : BorderRadius.all(Radius.circular(10)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: isExpanded ? Colors.blue : Colors.black,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      checkInfoLv3["inspNm"],
                      style: isExpanded ?
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)
                      : TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    child: IconButton(
                      icon: Text(
                        checkInfoLv3["checkYn"] == "Y" ? "🔴"  // 축하 이모티콘
                            : checkInfoLv3["checkYn"] == "D" ? "⚪️"  // 손握기 이모티콘
                            : "🔵",  // 빨간 따봉 뒤집힌 것
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white, // 텍스트 색상
                        ),
                      ),
                      onPressed: () {
                        onSwitchChanged(checkInfoLv3["checkYn"] == "Y"); // Y일 경우 false, 나머지 경우 true
                      },
                    ),
                  ),
                  /*Transform.scale(
                    scale: 0.5,
                    child: Switch(
                      value: checkYn == "N" || checkYn == "D",
                      onChanged: onSwitchChanged,
                      activeTrackColor: checkYn == "D" ? Colors.grey[400] : Colors.blue[200],
                      inactiveTrackColor: Colors.red[200],
                    ),
                  ),*/
                ],
              ),
            ),
          ),
          AnimatedContainer(
            duration: Duration(milliseconds: 700),
            curve: Curves.easeInOut,
            height: isExpanded ? 500 : 0,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(height: 0),
                  Container(
                    height: 320,
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: PageView.builder(
                      itemCount: 5,
                      itemBuilder: (context, imageIndex) {
                        final imageUrlList = [
                          apiUrl + "/WIT/66b83d90-6dde-46f5-9005-2cfdf615bdfc5292261861812877321.jpg", // 첫 번째 이미지
                          apiUrl + "/WIT/66b83d90-6dde-46f5-9005-2cfdf615bdfc5292261861812877321.jpg", // 두 번째 이미지
                          apiUrl + "/WIT/66b83d90-6dde-46f5-9005-2cfdf615bdfc5292261861812877321.jpg", // 세 번째 이미지
                          apiUrl + "/WIT/66b83d90-6dde-46f5-9005-2cfdf615bdfc5292261861812877321.jpg", // 네 번째 이미지
                          apiUrl + "/WIT/66b83d90-6dde-46f5-9005-2cfdf615bdfc5292261861812877321.jpg", // 다섯 번째 이미지
                        ];

                        return Container(
                          width: 0,
                          margin: EdgeInsets.symmetric(horizontal: 0),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(imageUrlList[imageIndex]),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(0),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    height: 120,
                    alignment: Alignment.topLeft,
                    color: Colors.white,
                    padding: EdgeInsets.all(20),
                    child: Text(checkInfoLv3["inspComt"] ?? "",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),
                  Container(height: 10),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) {
                          return ExamplePhotoPopup(
                              checkInfoLv3 : checkInfoLv3,
                              onSwitchChanged : onSwitchChanged
                          );
                        },
                      );
                    },
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.blue[200],
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(6),
                          bottomRight: Radius.circular(6),
                        ),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.comment, color: Colors.white),
                            SizedBox(width: 8),
                            Text("COMMENT / 하자 작성",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ],
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
    );
  }
}

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

  List<File> _images = [];
  final TextEditingController _checkComtController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    print(widget.checkInfoLv3["checkDate"]);
    print(widget.checkInfoLv3["reprDate"]);
    print(widget.checkInfoLv3["checkComt"]);
    print(widget.checkInfoLv3["checkImg1"]);
    print(widget.checkInfoLv3["checkImg2"]);

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
                  "하자 이미지 등록 (최대 2건)",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 10),
            Container(
              height: 150,
              width: 350,
              child:Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                if (_images[0] == null)
                  GestureDetector(
                    onTap: () async {
                      _showImagePickerOptions(0);
                    },
                    child: Container(
                      height: 120,
                      width: 120,
                      color: Colors.grey[200],
                      child: Center(
                        child: Icon(
                          Icons.add_a_photo,
                          size: 30,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                if (_images[0] != null)
                  Image.network(
                    apiUrl + widget.checkInfoLv3["checkImg1"],
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                if (_images[1] == null)
                  GestureDetector(
                    onTap: () async {
                      _showImagePickerOptions(1);
                    },
                    child: Container(
                      height: 120,
                      width: 120,
                      color: Colors.grey[200],
                      child: Center(
                        child: Icon(
                          Icons.add_a_photo,
                          size: 30,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                if (_images[1] != null)
                  Image.network(
                    apiUrl + widget.checkInfoLv3["checkImg2"],
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ],
              ),
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
                    backgroundColor: Colors.red[200], // 취소 버튼 색상
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // 라운드 없애기
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(); // 다이얼로그 닫기
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
                    backgroundColor: Colors.blue[200], // 확인 버튼 색상
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // 라운드 없애기
                    ),
                  ),
                  onPressed: () {
                    // 이미지 선저장
                    saveImages();
                  },
                  child: Text(
                    "저장",
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
  Future<void> saveImages() async {

    // REST ID
    String restId = "fileUpload";

    if (_images.isEmpty) {

      setState(() {
        widget.checkInfoLv3["checkDate"] = formatDateYYYYMMDD(checkDate);
        widget.checkInfoLv3["reprDate"] = formatDateYYYYMMDD(reprDate);
        widget.checkInfoLv3["checkComt"] = checkComt;
        widget.onSwitchChanged(false);
      });

    } else {
      final fileInfo = await sendFilePostRequest(restId, _images);

      if (fileInfo == "FAIL") {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("파일 업로드 실패")));
      } else {
        setState(() {
          widget.checkInfoLv3["checkDate"] = formatDateYYYYMMDD(checkDate);
          widget.checkInfoLv3["reprDate"] = formatDateYYYYMMDD(reprDate);
          widget.checkInfoLv3["checkComt"] = checkComt;
          if (fileInfo[0] != null) {
            widget.checkInfoLv3["checkImg1"] = fileInfo[0]["fileId"];
          }
          if (fileInfo[1] != null) {
            widget.checkInfoLv3["checkImg2"] = fileInfo[1]["fileId"];
          }
          widget.onSwitchChanged(false);
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

  Future<void> _pickImage(ImageSource source, int index) async {
    final XFile? image = await _picker.pickImage(source: source);

    if (image != null) {
      setState(() {
        print(image.path);
        _images[index] = File(image.path); // 선택된 이미지 경로 저장
      });
    }
  }
}
