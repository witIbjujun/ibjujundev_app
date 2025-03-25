import 'dart:io';
import 'package:flutter/material.dart';
import '../../../util/wit_code_ut.dart';
import '../../home/wit_home_theme.dart';

class ImagePickerWidget extends StatelessWidget {
  final File? imageFile;
  final String imageUrl;
  final bool isImgLoading;
  final Function onTap;
  final Function onRemove;

  const ImagePickerWidget({
    Key? key,
    this.imageFile,
    required this.imageUrl,
    required this.isImgLoading,
    required this.onTap,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        onTap();
      },
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: WitHomeTheme.wit_gray),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: imageFile != null
                  ? Image.file(
                imageFile!,
                fit: BoxFit.cover,
                width: 140,
                height: 140,
              )
                  : imageUrl.isNotEmpty
                  ? Image.network(
                apiUrl + imageUrl,
                fit: BoxFit.cover,
                width: 140,
                height: 140,
              )
                  : Center(
                child: Icon(
                  Icons.add_a_photo,
                  size: 40,
                  color: WitHomeTheme.wit_lightgray,
                ),
              ),
            ),
            if (isImgLoading) // 로딩 중일 때 프로그래스 인디케이터 표시
              Center(
                child: CircularProgressIndicator(),
              ),
            if (imageFile != null || imageUrl.isNotEmpty)
              Positioned(
                right: 8,
                top: 8,
                child: GestureDetector(
                  onTap: () {
                    onRemove();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: WitHomeTheme.wit_red,
                    ),
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.close,
                      color: WitHomeTheme.wit_white,
                      size: 16,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}