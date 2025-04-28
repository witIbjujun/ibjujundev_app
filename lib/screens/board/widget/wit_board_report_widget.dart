import 'package:flutter/material.dart';

import '../../home/wit_home_theme.dart';

class reportTitle extends StatelessWidget {

  final dynamic boardInfo;

  reportTitle({
    required this.boardInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            "작성자 | " + boardInfo["bordTitle"] ?? "",
            style: WitHomeTheme.title,
          ),
        ),
      ],
    );
  }
}