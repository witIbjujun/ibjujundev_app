import 'package:flutter/material.dart';

import '../home/wit_home_theme.dart';

class DotWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // 화면 전체 너비
      height: 3, // 점선 높이 (얇은 선)
      child: CustomPaint(
        painter: DashedLinePainter(
          color: WitHomeTheme.wit_gray,
          strokeWidth: 1.0,
          dashLength: 5.0,
          dashGapLength: 3.0,
        ),
      ),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  final double strokeWidth;
  final Color color;
  final double dashLength;
  final double dashGapLength;

  DashedLinePainter({
    this.strokeWidth = 1.0,
    this.color = Colors.black,
    this.dashLength = 5.0,
    this.dashGapLength = 5.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashLength, 0),
        paint,
      );
      startX += dashLength + dashGapLength;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false; // 변경 사항이 없다면 다시 그리지 않음
  }
}
