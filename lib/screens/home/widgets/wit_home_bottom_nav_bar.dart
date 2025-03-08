import 'package:flutter/material.dart';
import 'package:witibju/screens/home/wit_home_sc.dart';
import 'package:witibju/screens/home/wit_myprofile_sc.dart';
import 'package:witibju/screens/home/wit_estimate_detail.dart';
import 'package:witibju/screens/home/wit_company_detail_sc.dart';
import 'package:witibju/screens/board/wit_board_main_sc.dart';
import 'package:witibju/screens/checkList/wit_checkList_main_sc.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  const BottomNavBar({Key? key, required this.selectedIndex}) : super(key: key);

  void _onItemTapped(BuildContext context, int index) {
    if (index == selectedIndex) return; // 현재 선택된 탭이면 아무 작업 안 함

    Widget nextScreen;
    switch (index) {
      case 0:
        nextScreen = CheckListMain();
        break;
      case 1:
        nextScreen = EstimateScreen();
        break;
      case 2:
        nextScreen = HomeScreen();
        break;
      case 3:
        nextScreen = MyProfile();
        break;
      case 4:
        nextScreen = Board(1, 'C1');
        break;
      default:
        nextScreen = HomeScreen();
    }

    // 화면 전환
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => nextScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      currentIndex: selectedIndex,
      onTap: (index) => _onItemTapped(context, index), // ✅ 내부에서 화면 이동 처리
      items: [
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/home/checkList_Bottom.png', // 이미지 경로
            width: 24, // 아이콘 크기 조절
            height: 24,
          ),
          label: '체크리스트',
        ),

        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/home/info_Bottom.png', // 이미지 경로
            width: 24, // 아이콘 크기 조절
            height: 24,
          ),
          label: '견적정보',
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/home/home_BottomNew.png', // 이미지 경로
            width: 24, // 아이콘 크기 조절
            height: 24,
          ),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/home/myInfo_Bottom.png', // 이미지 경로
            width: 24, // 아이콘 크기 조절
            height: 24,
          ),
          label: '내정보',
        ),
      ],
      selectedItemColor: Color(0xFFAFCB54),
      unselectedItemColor: Color(0xFF8D8D8D),
      selectedLabelStyle: TextStyle(color: Color(0xFFAFCB54)), // 선택된 라벨 색상
      unselectedLabelStyle: TextStyle(color: Color(0xFF8D8D8D)), // 선택되지 않은 라벨 색상

      showSelectedLabels: true,  // 선택된 아이템의 라벨 숨기기
      showUnselectedLabels: true,  // 선택되지 않은 아이템의 라벨 숨기기
      elevation: 5.0,
    );
  }
}
