import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:witibju/screens/home/widgets/wit_home_bottom_nav_bar.dart';
import 'package:witibju/screens/home/widgets/wit_home_widgets.dart';
import 'package:witibju/screens/home/widgets/wit_home_widgets2.dart';
import 'package:witibju/screens/home/login/wit_user_login.dart';
import 'package:witibju/screens/home/wit_company_detail_sc.dart';
import 'package:witibju/screens/home/wit_compay_view_sc_.dart';
import 'package:witibju/screens/home/wit_gongu_request.dart';
import 'package:witibju/screens/home/wit_home_get_estimate.dart';
import 'package:witibju/screens/home/wit_home_theme.dart';
import 'package:witibju/screens/home/wit_estimate_detail.dart';
import 'package:witibju/screens/home/wit_myprofile_sc.dart';
import 'dart:convert';
import '../../main.dart';
import '../../util/wit_api_ut.dart';
import '../../util/wit_apppush.dart';
import '../board/wit_board_main_sc.dart';
import '../chat/CustomChatScreen.dart';
import '../checkList/wit_checkList_main_sc.dart';
import '../preInspaction/wit_preInsp_main_sc.dart';
import '../question/wit_question_main_sc.dart';
import '../seller/wit_seller_profile_detail_sc.dart';
import 'login/wit_user_loginStep.dart';
import 'login/wit_user_loginStep1.dart';
import 'models/main_view_model.dart';
import 'login/wit_login_pop_home_sc.dart'; // 로그인 파송창 파일을 임포트
import 'models/category.dart';
import 'models/userInfo.dart';
///메인 홈
class HomeScreen extends StatefulWidget  {
  const HomeScreen({super.key});

  @override
 State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  ///로그인 상태를 true로 설정해서 테스트 (실제로는 로그인 여부를 판단하는 로직이 필요)

  int _selectedIndex = 2; // 기본으로 Home (1번 인덱스) 선택

  DateTime? _lastBackPressed;
  // SelectBox에 표시할 옵션 리스트
  Map<String, String> options = {};
  String selectedOption = ""; // 기본 선택된 옵션
  String? nickname; // 닉네임 값을 저장할 변수
  UserInfo? userInfo; // 사용자 정보를 저장할 변수
  final secureStorage = FlutterSecureStorage(); // Flutter Secure Storage 인스턴스
  String  isLogined = "false";


  @override
  void initState() {
    super.initState();
      setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final mainViewModel = Provider.of<MainViewModel>(context);
    FirebaseMessageService.initialize(context);

    return WillPopScope( // 📆 2025.04.01 - WillPopScope로 감싸기
      onWillPop: () async {
        if (_lastBackPressed == null ||
            DateTime.now().difference(_lastBackPressed!) > Duration(seconds: 2)) {
          _lastBackPressed = DateTime.now();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('뒤로 버튼을 한 번 더 누르시면 종료됩니다.')),
          );
          return false;
        }
        return true; // 종료 허용
      },
      child: Container(
        color: WitHomeTheme.white,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: WitHomeTheme.white,
            iconTheme: const IconThemeData(color: Colors.black),
            titleSpacing: 20.0,
            leading: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: IconButton(
                iconSize: 35.0,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SellerProfileDetail(sllrNo: 17),
                    ),
                  );
                },
                icon: Image.asset(
                  'assets/home/logo.png',
                  width: 30,
                  height: 30,
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Row(
                  children: [
                    IconButton(
                      iconSize: 35.0,
                      onPressed: () async {
                        bool isLoggedIn = await checkLoginStatus();
                        if (isLoggedIn) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => EstimateScreen(),
                            ),
                          );
                        } else {
                          _showLoginDialog(context);
                        }
                      },
                      icon: FutureBuilder<String?>( // 📦 FutureBuilder 그대로 유지
                        future: secureStorage.read(key: 'mainAptNm'),
                        builder: (context, snapshot) {
                          String aptName = snapshot.data ?? '';
                          return Row(
                            mainAxisSize: MainAxisSize.min, // ✅ Row가 자식 크기에 맞게
                            crossAxisAlignment: CrossAxisAlignment.center, // ✅ 세로 중앙 정렬
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 2.0), // ✅ 미세 보정
                                child: Image.asset(
                                  'assets/home/locationMain.png',
                                  width: 30,
                                  height: 30,
                                ),
                              ),
                              if (aptName.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(left: 5.0),
                                  child: Text(
                                    aptName,
                                    style: WitHomeTheme.body1.copyWith(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                    if (nickname != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(
                          nickname!,
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ),
                    IconButton(
                      iconSize: 35.0,
                      onPressed: () async {
                        bool isLoggedIn = await checkLoginStatus();
                        if (isLoggedIn) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => EstimateScreen(),
                            ),
                          );
                        } else {
                          _showLoginDialog(context);
                        }
                      },
                      icon: Image.asset(
                        'assets/home/message.png',
                        width: 30,
                        height: 30,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: Colors.transparent,
          //backgroundColor: Colors.red,
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        APTStatusWidget(
                          width: MediaQuery.of(context).size.width * 0.9,
                          height: MediaQuery.of(context).size.height * 0.23,
                        ),
                        const SizedBox(height: 6.0),
                        Container(
                          height: 98,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildIconWithLabel(
                                  imagePath: 'assets/home/FloorPlan.png',
                                  label: '평면도',
                                  onTap: () {
                                    showImagePopup(
                                      context: context,
                                      imageUrl: '/WIT/12345.png',
                                    );
                                  },
                                ),
                                _buildIconWithLabel(
                                  imagePath: 'assets/home/guide.png',
                                  label: '가이드',
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (context) =>
                                          //  Question(qustCd: 'Q10001'))
                                      CustomChatScreen('S2025051200003', '3','userView')),
                                    );
                                  },
                                ),
                                _buildIconWithLabel(
                                  imagePath: 'assets/home/apt.png',
                                  label: '아파트',
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (context) =>
                                        // Board(bordType: "CM01", bordKey: "5"))
                                     CustomChatScreen('S2025051200003', '3','sellerView')),
                                    );
                                  },
                                ),
                                _buildIconWithLabel(
                                  imagePath: 'assets/home/best.png',
                                  label: '베스트',
                                  onTap: () {
                                    showGuirdDialog(
                                      context: context,
                                      dialogWidth: 340,
                                      dialogHeight: 500,
                                      options: [
                                        {
                                          'text': 'Simple 인테리어',
                                          'textSub': '100~200만',
                                          'bgImage ': 'assets/home/bestBack2.png',
                                        'height'  : 44.0,             // 원하는 크기
                                        'width'   : 300.0,
                                        },
                                        {
                                          'text': 'Standard 인테리어',
                                          'textSub': '300~500만',
                                          'bgImage ': 'assets/home/bestBack1.png',
                                          'height'  : 44.0,             // 원하는 크기
                                          'width'   : 300.0,
                                        },
                                        {
                                          'text': 'Premium 인테리어',
                                          'textSub': '700~1000만',
                                          'bgImage ': 'assets/home/bestBack4.png',
                                          'height'  : 44.0,             // 원하는 크기
                                          'width'   : 300.0,
                                        },
                                        {
                                          'text': 'My Choice 인테리어',
                                          'textSub': '자유선택',
                                          'bgImage ': 'assets/home/bestBack3.png',
                                          'height'  : 44.0,             // 원하는 크기
                                          'width'   : 300.0,
                                        },
                                      ],
                                      onOptionSelected: (selectedOption) {
                                        if (selectedOption == 'Simple 인테리어') {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      getEstimate('S')));
                                        } else if (selectedOption ==
                                            'Standard 인테리어') {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      getEstimate('T')));
                                        } else if (selectedOption ==
                                            'Premium 인테리어') {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      getEstimate('P')));
                                        } else if (selectedOption ==
                                            'My Choice 인테리어') {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      getEstimate('A')));
                                        }
                                      },
                                    );
                                  },
                                ),
                                _buildIconWithLabel(
                                  imagePath: 'assets/home/GroupPurchase.png',
                                  label: '공동구매',
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => GonguRequest()),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.9,
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "견적서비스",
                                        style: WitHomeTheme.title.copyWith(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        getPopularCourseUI(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          /**
           * 하단 네비게이션 바
           */
          bottomNavigationBar: BottomNavBar(selectedIndex: _selectedIndex),
        ),
      ),
    );
  }

/*  /// 홈 상단 버튼 (평면도, 가이드 등)의 UI를 구성하는 함수
  /// RenderFlex overflow를 방지하기 위해 전체 높이를 제한하고, 텍스트 크기 조절 처리
  /// 홈 상단 버튼 (평면도, 가이드 등)의 UI를 구성하는 함수
  /// 아이콘 이미지가 버튼처럼 보이도록 시각 효과 강화 (그림자, 테두리, 눌림 효과 포함)*/
  Widget _buildIconWithLabel({
    required String imagePath,
    required String label,
    VoidCallback? onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ✅ 이미지 버튼 영역
        Material(
          color: Colors.white,
          elevation: 1, // 그림자 효과
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            splashColor: Colors.green.withOpacity(0.2), // 눌림 효과
            child: Container(
              width: 55,
              height: 55,
              /*decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300), // 테두리 강조
              ),*/
              child: Center(
                child: Image.asset(
                  imagePath,
                  width: 30,
                  height: 30,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6.0),

        // ✅ 기존 라벨 유지
        Text(
          label,
          style: WitHomeTheme.subtitle.copyWith(
            fontSize: 12.0,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// 최하단 카테고리 리스트 (Popular Course)
  Widget getPopularCourseUI() {

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0), // 좌우만 여백

      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Flexible(
            fit: FlexFit.loose,
            child: PopularCourseListView(
              callBack: (Category category) async {
                bool isLoggedIn = await checkLoginStatus();
                if (isLoggedIn) {
                  print("✅ 클릭됨: ${category.categoryNm} 이동 중...");
                  moveTo(category); // 로그인 상태일 때만 이동
                } else {
                  _showLoginDialog(context); // 로그인 다이얼로그 표시
                }
              },
            ),
          ),
         /// const SizedBox(height: 4),
        ],
      ),
    );
  }

  /// 특정 카테고리 선택 시 상세 페이지로 이동
  void moveTo(Category category) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DetailCompany(title: category.categoryNm, categoryId: category.categoryId),
      ),
    );
  }

  Widget getCommunityTabs() {
    // 2025-01-16: TabBar 제거, Board 직접 호출
    return Board(bordType: "UH01");// '업체후기' 화면만 표시
  }


  // 🔹 로그인 후 사용자 정보를 AlertDialog로 표시
  void _showAlertDialog({
    required BuildContext context,
    required String title,
    required String content,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("확인"),
            ),
          ],
        );
      },
    );
  }

  /**
   * 로그인 화면이동
   */
  // 2025-04-22: Dialog 내부 높이 제한 문제 해결을 위해 UnconstrainedBox 적용
  void _showLoginDialog(BuildContext parentContext) async {
    bool isLoggedIn = await checkLoginStatus();
    if (!isLoggedIn) {
      // ✅ 기존의 Dialog를 띄우는 방식 삭제하고 직접 페이지 이동
      Navigator.push(
        parentContext,
        MaterialPageRoute(
          builder: (context) => WitUserLoginStep(),
        ),
      );
    }
  }
}