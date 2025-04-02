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
      // _loadOptions();
      setState(() {});
  }




  // 데이터를 조회하는 비동기 함수
  Future<void> getUserInfo1(String kakaoId,String Idnum) async {
    String restId = "getUserInfo";
    final param = jsonEncode({"kakaoId": kakaoId,
      "clerkNo": Idnum});

    try {
      final response = await sendPostRequest(restId, param);
      setState(() {
        if (response is Map<String, dynamic>) {
          userInfo = UserInfo.fromJson(response);
        } else {
          userInfo = UserInfo.fromJson(jsonDecode(response));
        }

        print('고객 번호: ' + (userInfo!.clerkNo ?? 'Unknown'));
        print('닉네임: '+(userInfo!.nickName??''));
        print('역할: '+(userInfo!.role??''));
        print('Main아파트 번호: '+(userInfo!.mainAptNo??''));
        print('Main아파트 이름: '+(userInfo!.mainAptNm??''));
        // 사용자 정보를 Flutter Secure Storage에 저장
        secureStorage.write(key: 'clerkNo', value: userInfo!.clerkNo);
        secureStorage.write(key: 'nickName', value: userInfo!.nickName);
        secureStorage.write(key: 'mainAptNo', value: userInfo!.mainAptNo);
        secureStorage.write(key: 'mainAptNm', value: userInfo!.mainAptNm);
        secureStorage.write(key: 'role', value: userInfo!.role);
        secureStorage.write(key: 'aptNo', value: userInfo!.aptNo?.join(',') ?? '');
        secureStorage.write(key: 'aptName', value: userInfo!.aptName?.join(',') ?? '');

      });
    } catch (e) {
      print('사용자 정보 조회 중 오류 발생1111: $e');
    }
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
                      icon: FutureBuilder<String?>(
                        future: secureStorage.read(key: 'mainAptNm'),
                        builder: (context, snapshot) {
                          String aptName = snapshot.data ?? '';
                          return Row(
                            children: [
                              Image.asset(
                                'assets/home/locationMain.png',
                                width: 30,
                                height: 30,
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
                    IconButton(
                      iconSize: 25.0,
                      onPressed: () {
                        logOut(context);
                      },
                      icon: const Icon(Icons.logout),
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
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        APTStatusWidget(
                          width: MediaQuery.of(context).size.width * 0.9,
                          height: MediaQuery.of(context).size.height * 0.20,
                        ),
                        const SizedBox(height: 6.0),
                        Container(
                          height: 80,
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
                                              CustomChatScreen('1', '72091587')),
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
                                              CustomChatScreen('1', '1')),
                                    );
                                  },
                                ),
                                _buildIconWithLabel(
                                  imagePath: 'assets/home/best.png',
                                  label: '베스트',
                                  onTap: () {
                                    showGuirdDialog(
                                      context: context,
                                      description:
                                      "예산별 시공 품목 가이드입니다!\n\n각 품목별 비교견적을 받아세요",
                                      descriptionStyle: WitHomeTheme.subtitle,
                                      options: [
                                        {
                                          'text': 'Simple 인테리어',
                                          'color': Color(0xFF7294CC)
                                        },
                                        {
                                          'text': 'Standard 인테리어',
                                          'color': Color(0xFFC19AC6)
                                        },
                                        {
                                          'text': 'Premium 인테리어',
                                          'color': Color(0xFFA68150)
                                        },
                                        {
                                          'text': 'My Choice 인테리어',
                                          'color': Color(0xFF91C58C)
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
          bottomNavigationBar: BottomNavBar(selectedIndex: _selectedIndex),
        ),
      ),
    );
  }

  Widget _buildIconWithLabel({required String imagePath, required String label, VoidCallback? onTap}) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4.0), // 이미지와 텍스트 간격 조정
        Text(
          label,
         // style: WitHomeTheme.title.copyWith(fontSize: 12.0, fontWeight: FontWeight.bold, color: Colors.black),
          style: WitHomeTheme.subtitle.copyWith(fontSize: 12.0,color: Colors.black, fontWeight: FontWeight.bold),
    ),
      ],
    );
  }

  /// 개별 항목을 생성하는 함수
  /*Widget _buildGridItem(String bgImage, String iconImage, String title) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(bgImage), // 배경 이미지 적용
          fit: BoxFit.cover, // 전체 크기에 맞게 조정
        ),
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4.0,
            spreadRadius: 1.0,
          ),
        ],
      ),
      padding: const EdgeInsets.all(12.0),
      child: Stack(
        children: [
          /// 우측 상단 아이콘
          Positioned(
            top: 8,
            right: 8,
            child: Image.asset(
              iconImage,
              width: 50, // 아이콘 크기 조절
              height: 50,
            ),
          ),

          /// 좌측 하단 텍스트
          Positioned(
            bottom: 8,
            left: 8,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
                color: Colors.white, // 흰색 글씨 적용
              ),
            ),
          ),
        ],
      ),
    );
  }*/

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
    return Board(1, 'C1'); // '업체후기' 화면만 표시
  }



  // 각 탭에 해당하는 위젯 생성 함수
  Widget _buildSelectedScreen() {
    switch (_selectedIndex) {
      case 0:
        return CheckListMain(); // Check List 화면
      case 1:
        return HomeScreen(); // Home 화면
      case 2:
        return EstimateScreen(); // 견적정보 화면
      case 3:
        return MyProfile(); // 내정보 화면
      default:
        return HomeScreen();
    }
  }

  /**
   * 로그인 팝업
   */
  void _showLoginDialog(BuildContext parentContext) async {
    bool isLoggedIn = await checkLoginStatus();
    if (!isLoggedIn) {
      showDialog(
        context: parentContext,
        barrierDismissible: true, // 팝업 외부 클릭 방지
        builder: (BuildContext dialogContext) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Consumer<MainViewModel>(
              builder: (context, viewModel, child) {
                return Container(
                  width: MediaQuery.of(parentContext).size.width * 0.8,
                  height: 300,
                  padding: const EdgeInsets.all(20.0),
                  child: loingPopHome(
                    onLoginSuccess: (MainViewModel updatedViewModel) async {
                      print("🔹 로그인 후 업데이트할 userInfo.id: ${updatedViewModel.userInfo?.id}");
                      print("🔹 로그인 후 업데이트할 userInfo.tempClerkNo: ${updatedViewModel.userInfo?.tempClerkNo}");
                      if (updatedViewModel.userInfo?.id == null && updatedViewModel.userInfo?.tempClerkNo == null) {
                        print("🚨 userInfo.id가 null! 로그인 데이터가 없음");
                        if (mounted) {
                          Navigator.of(dialogContext).pop();
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            Navigator.of(parentContext).push(
                              MaterialPageRoute(
                                builder: (context) => WitUserLoginStep1(),
                              ),
                            );
                          });
                        }
                      }
                      else {
                        print("✅ 정보가 있음 ! userInfo.id: ${updatedViewModel.userInfo?.id}");
                        print("✅ 정보가 있음 ! userInfo.tempClerkNo: ${updatedViewModel.userInfo?.tempClerkNo}");
                        String tempClerkNo = updatedViewModel.userInfo?.tempClerkNo ?? '';
                        await getUserInfo(context, viewModel, tempClerkNo);
                        if (mounted) {
                          Navigator.of(dialogContext).pop();
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            Navigator.of(parentContext).push(
                              MaterialPageRoute(
                                builder: (context) => HomeScreen(),
                              ),
                            );
                          });
                        }
                      }
                    },
                  ),
                );
              },
            ),
          );
        },
      );
    }
  }
}