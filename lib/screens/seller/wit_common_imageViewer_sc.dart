import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../util/wit_api_ut.dart';
import '../../util/wit_code_ut.dart';
import '../common/wit_ImageViewer_sc.dart';

class CommonImageViewer extends StatefulWidget {
  final String estNo;
  final String seq;
  final String imageGubun; // bizCd: RQ01, SR01 등

  const CommonImageViewer({
    required this.estNo,
    required this.seq,
    required this.imageGubun,
    //required this.reqState,
    //required this.images,
    //required this.onImageListChanged,
    super.key,
  });

  @override
  State<CommonImageViewer> createState() => _CommonImageViewerState();
}

class _CommonImageViewerState extends State<CommonImageViewer> {
  List<dynamic> boardDetailImageList1 = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    getSellerDetailImageList();
  }

  @override
  void didUpdateWidget(covariant CommonImageViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.estNo != widget.estNo || oldWidget.seq != widget.seq) {
      getSellerDetailImageList();
    }
  }

  Future<void> getSellerDetailImageList() async {
    // REST ID
    String restId = "getSellerDetailImageList";

    String bizKey = widget.estNo + "^" + widget.seq;

    // PARAM
    final param = jsonEncode({
      "bizCd": "RQ01",
      "bizKey": bizKey,
    });

    // API 호출 (게시판 상세 조회)
    final _boardDetailImageList1 = await sendPostRequest(restId, param);
    print("이미지 응답: $_boardDetailImageList1"); // <- 이거 추가!

    print("이미지 응답: _boardDetailImageList1 : " + _boardDetailImageList1.length.toString()); // <- 이거 추가!

    // 결과 셋팅
    setState(() {
      boardDetailImageList1.clear(); // 중복 방지용 초기화
      boardDetailImageList1 = _boardDetailImageList1;
    });

  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 120,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [

            // 서버 이미지 리스트
            ...boardDetailImageList1.asMap().entries.map((entry) {
              int index = entry.key;
              String imageUrl = apiUrl + entry.value["imagePath"];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ImageViewer(
                        imageUrls: boardDetailImageList1.map((e) => apiUrl + e["imagePath"]).toList(),
                        initialIndex: index,
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 85,
                  height: 85,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
