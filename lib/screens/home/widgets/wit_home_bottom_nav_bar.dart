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
      onTap: (index) => _onItemTapped(context, index),
      items: [
        BottomNavigationBarItem(
          icon: Image.asset('assets/home/checkList_Bottom.png', width: 30, height: 30),
          label: '체크리스트',
        ),
        BottomNavigationBarItem(
          icon: Image.asset('assets/home/info_Bottom.png', width: 30, height: 30),
          label: '견적정보',
        ),
        BottomNavigationBarItem(
          icon: Image.asset('assets/home/home_BottomNew.png', width: 30, height: 30),
          label: '홈',
        ),
        BottomNavigationBarItem(
          icon: Image.asset('assets/home/myInfo_Bottom.png', width: 30, height: 30),
          label: '내정보',
        ),
      ],
      selectedItemColor: Colors.black, // 선택된 아이콘 색상도 검정으로 변경
      unselectedItemColor: Color(0xFF8D8D8D),
      selectedLabelStyle: const TextStyle(
        color: Colors.black,
      //  fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: const TextStyle(
        color: Color(0xFF8D8D8D),
      ),
      showSelectedLabels: true,
      showUnselectedLabels: true,
      elevation: 5.0,
    );
  }
}
