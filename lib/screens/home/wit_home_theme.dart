import 'package:flutter/material.dart';

class WitHomeTheme {
  WitHomeTheme._();

  static const Color notWhite = Color(0xFFEDF0F2);
  static const Color nearlyWhite = Color(0xFFFFFFFF);
  static const Color nearlyBlue = Color(0xFF7BBCEF);
  static const Color nearlyslowBlue = Color(0xa31d8fda);
  static const Color nearlysYellow = Color(0xffe2184b);
  static const Color white = Color(0xFFFFFFFF);
  static const Color nearlyBlack = Color(0xFF213333);
  static const Color grey = Color(0xFF3A5160);
  static const Color dark_grey = Color(0xFF313A44);

  static const Color darkText = Color(0xFF253840);
  static const Color darkerText = Color(0xFF17262A);
  static const Color lightText = Color(0xFF4A6572);
  static const Color deactivatedText = Color(0xFF767676);
  static const Color dismissibleBackground = Color(0xFF364A54);
  static const Color chipBackground = Color(0xFFEEF1F3);
  static const Color spacer = Color(0xFFF2F2F2);
  static const String fontName = 'WorkSans';

  static const Color kBackgroundColor = Color(0xFFD4DEF7);
  static const Color kTextColor = Color(0xFF4879C5);

  // APP 전용 색상
  static const Color wit_lightGoldenrodYellow = Color(0xFFF5A855);
  static const Color wit_lightSteelBlue = Color(0xFF7294CC);
  static const Color wit_lightGreen = Color(0xFF91C58C);
  static const Color wit_lightOrchid = Color(0xFFC19AC6);
  static const Color wit_lightSalmon = Color(0xFFED9C79);
  static const Color wit_lightYellow = Color(0xFFFFF294);
  static const Color wit_lightCoral = Color(0xFFE5767B);
  static const Color wit_tan = Color(0xFFA68150);
  static const Color wit_lightBlue = Color(0xFF7BB5C9);
  static const Color wit_mediumSeaGreen = Color(0xFF63A566);
  static const Color wit_black = Color(0xFF000000);
  static const Color wit_gray = Color(0xFF8D8D8D);
  static const Color wit_white = Color(0xFFFFFFFF);

  static const InputDecoration kTextInputDecoration = InputDecoration(
    border: InputBorder.none,
    hintText: '',
    // ),
  );


  static const TextTheme textTheme = TextTheme(
    headlineMedium: display1,
    headlineSmall: headline,
    titleLarge: title,
    titleSmall: subtitle,
    bodyLarge: body2,
    bodyMedium: body1,
    bodySmall: caption,
  );

  static const TextStyle display1 = TextStyle(
    // h4 -> display1
    fontFamily: 'WorkSans',
    fontWeight: FontWeight.bold,
    fontSize: 36,
    letterSpacing: 0.4,
    height: 0.9,
    color: darkerText,
  );

  static const TextStyle headline = TextStyle(
    // h5 -> headline
    fontFamily: 'WorkSans',
    fontWeight: FontWeight.bold,
    fontSize: 24,
    letterSpacing: 0.27,
    color: darkerText,
  );

  static const TextStyle headline1 = TextStyle(
    // h5 -> headline
    fontFamily: 'WorkSans',
   /// fontWeight: FontWeight.bold,
    fontSize: 24,
    letterSpacing: 0.27,
    color: darkerText,
  );

  static const TextStyle title = TextStyle(
    // h6 -> title
    fontFamily: 'WorkSans',
    fontWeight: FontWeight.bold,
    fontSize: 16,
    letterSpacing: 0.18,
    color: darkerText,
  );

  static const TextStyle subtitle = TextStyle(
    // subtitle2 -> subtitle
    fontFamily: 'WorkSans',
    fontWeight: FontWeight.w400,
    fontSize: 14,
    letterSpacing: -0.04,
    color: darkText,
  );

  static const TextStyle body2 = TextStyle(
    // body1 -> body2
    fontFamily: 'WorkSans',
    fontWeight: FontWeight.w400,
    fontSize: 14,
    letterSpacing: 0.2,
    color: darkText,
  );

  static const TextStyle body1 = TextStyle(
    // body2 -> body1
    fontFamily: 'WorkSans',
    fontWeight: FontWeight.w400,
    fontSize: 16,
    letterSpacing: -0.05,
    color: darkText,
  );

  static const TextStyle caption = TextStyle(
    // Caption -> caption
    fontFamily: 'WorkSans',
    fontWeight: FontWeight.w400,
    fontSize: 12,
    letterSpacing: 0.2,
    color: lightText, // was lightText
  );
}

class HexColor extends Color {
  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));

  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF' + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }
}
