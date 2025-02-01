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
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.checklist_outlined),
          label: 'Check List',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.info_outline),
          label: '견적정보',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: '내정보',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.forum_outlined),
          label: '커뮤니티',
        ),
      ],
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      elevation: 5.0,
    );
  }
}
