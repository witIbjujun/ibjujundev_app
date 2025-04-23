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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          '공동구매',
          style: TextStyle(
            color: Colors.white,             // 텍스트 색상
            fontSize: 20.0,                  // 폰트 크기
            fontWeight: FontWeight.bold,     // 굵기
            fontFamily: 'NotoSansKR',        // 폰트 지정 (선택)
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white), // ← 아이콘 색상도 검정으로 맞추려면 추가
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
                // 2025.04.03: 공동구매 리스트 추가
                Column(
                  children: [
                    _buildGonguItem(
                      title: 'D-20 미세방충망',
                      description: '초미세철망으로 확~터효과!',
                      current: 38,
                      max: 30,
                      icon: Icons.grid_4x4,
                      iconColor: Colors.grey[700]!,
                    ),
                    _buildGonguItem(
                      title: '입주청소',
                      description: '전문팀 새집증후군 해결!',
                      current: null,
                      max: null,
                      icon: Icons.cleaning_services,
                      iconColor: Colors.blue,
                    ),
                    _buildGonguItem(
                      title: 'D-5 탄성코팅',
                      description: '방수 곰팡이 차단!',
                      current: 15,
                      max: 14,
                      icon: Icons.eco,
                      iconColor: Colors.green,
                    ),
                    _buildGonguItem(
                      title: '가구/가전',
                      description: '조합부터 단독, 완벽한 스타일매치',
                      current: null,
                      max: null,
                      icon: Icons.chair,
                      iconColor: Colors.purple,
                    ),
                    _buildGonguItem(
                      title: 'D-13 암막커튼',
                      description: '만족도 92%, 최고의 선택',
                      current: 50,
                      max: 32,
                      icon: Icons.curtains,
                      iconColor: Colors.redAccent,
                    ),
                  ],
                ),

              ],
            ),
          )
        ),
      ),
      bottomNavigationBar: BottomNavBar(selectedIndex: _selectedIndex),  // ✅ 공통 네비게이션 적용
    );
  }

  // 2025.04.03: 공동구매 항목 카드 위젯
  Widget _buildGonguItem({
    required String title,
    required String description,
    int? current,
    int? max,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: iconColor.withOpacity(0.2),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      )),
                  Text(description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                      )),
                  if (current != null && max != null)
                    Text(
                      '현재 $current/$max 신청',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                ],
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              // 신청 버튼 눌렀을 때 동작
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              '신청',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }


}