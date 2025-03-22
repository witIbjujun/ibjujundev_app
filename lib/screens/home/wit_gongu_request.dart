import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:witibju/screens/home/widgets/wit_home_bottom_nav_bar.dart';
import 'package:witibju/screens/home/widgets/wit_home_widgets.dart';
import 'package:witibju/screens/home/widgets/wit_home_widgets2.dart';
import 'package:witibju/screens/home/login/wit_user_login.dart';
import 'package:witibju/screens/home/wit_estimate_detail.dart';
import 'package:witibju/screens/home/wit_home_sc.dart';
import 'package:witibju/screens/home/wit_home_theme.dart';

import '../../util/wit_api_ut.dart';
import '../board/wit_board_main_sc.dart';
import '../checkList/wit_checkList_main_sc.dart';
import '../preInspaction/wit_preInsp_main_sc.dart';

class GonguRequest extends StatefulWidget  {
  const GonguRequest({super.key});

  @override
  _GonguRequeststState createState() => _GonguRequeststState();
}

class _GonguRequeststState extends State<GonguRequest> {
  String selectedOption = ''; // 기본 선택 값
  List<String> options = [];
  int _selectedIndex = 3; // ✅ "내정보" 탭이 기본 선택
  // 컨설리더 설정
  final _storage = const FlutterSecureStorage();
  TextEditingController _controller = TextEditingController();

  // 컨트리로 조회한 단순 정보를 표시
  bool _isEditable = false;
  FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
  }

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: WitHomeTheme.white,
        iconTheme: const IconThemeData(color: WitHomeTheme.nearlyBlack),
        title: Text(
          '공동구매',
          style: WitHomeTheme.title, // 제목에 동일한 폰트 스타일 적용
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            color: Colors.white, // ✅ 배경 흰색 설정
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ImageBox() 호출
                CommonImageBanner(
                  imagePath: 'assets/home/gongguBanner.png', // 원하는 이미지 파일명
                  heightRatio: 0.18,  // 화면 높이의 18%
                  widthRatio: 0.85,   // 화면 너비의 85%
                ),
                const SizedBox(height: 16),
              ],
            ),
          )
        ),
      ),
      bottomNavigationBar: BottomNavBar(selectedIndex: _selectedIndex),  // ✅ 공통 네비게이션 적용
    );
  }

}