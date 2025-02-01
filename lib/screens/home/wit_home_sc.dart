import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:witibju/screens/home/widgets/wit_home_bottom_nav_bar.dart';
import 'package:witibju/screens/home/widgets/wit_home_widgets.dart';
import 'package:witibju/screens/home/widgets/wit_home_widgets2.dart';
import 'package:witibju/screens/home/login/wit_user_login.dart';
import 'package:witibju/screens/home/wit_company_detail_sc.dart';
import 'package:witibju/screens/home/wit_compay_view_sc_.dart';
import 'package:witibju/screens/home/wit_home_get_estimate.dart';
import 'package:witibju/screens/home/wit_home_theme.dart';
import 'package:witibju/screens/home/wit_estimate_detail.dart';
import 'package:witibju/screens/home/wit_myprofile_sc.dart';
import 'dart:convert';
import '../../main.dart';
import '../../util/wit_api_ut.dart';
import '../../util/wit_apppush.dart';
import '../board/wit_board_main_sc.dart';
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
       _loadOptions();
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


  Future<void> _loadOptions() async {
    String? aptNameString  = await secureStorage.read(key: 'mainAptNm'); //아파트 명칭
    String? aptNoString  = await secureStorage.read(key: 'mainAptNo'); //아파트 번호
    String? storedNickname = await secureStorage.read(key: 'nickName');
    print('_loadOptions 아파트 이름: $aptNameString');
    print('_loadOptions 아파트 번호: $aptNoString');

    if (aptNameString != null && aptNoString != null) {

      List<String> aptNames = aptNameString.split(',');
      List<String> aptNos = aptNoString.split(',');

      setState(() {
        nickname = storedNickname; // 상태에 저장
        print('저장된 닉네임: $nickname');
        for (int i = 0; i < aptNames.length; i++) {
          options[aptNames[i]] = aptNos[i];
        }
        if (options.isNotEmpty) {
          selectedOption = options.keys.first;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mainViewModel = Provider.of<MainViewModel>(context);
    // FirebaseMessageService 초기화
    FirebaseMessageService.initialize(context);
    return Container(
      color: WitHomeTheme.nearlyWhite,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: WitHomeTheme.nearlyWhite,
          iconTheme: const IconThemeData(color: Colors.black),
          leading: IconButton(
            iconSize: 35.0,
            onPressed: () {
              // Icons.manage_accounts 선택 시 SellerProfileDetail 화면으로 이동
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SellerProfileDetail(sllrNo: 17),
                ),
              );
            },
            icon: const Icon(
              Icons.manage_accounts,
            ),
          ),

          actions: [
            Row(
              children: [
                if (nickname  != null) // nickName이 null이 아닐 때만 표시
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0), // 닉네임과 아이콘 간 간격 조정
                    child: Text(
                      nickname!, // nickName 값 출력
                      style: TextStyle(fontSize: 16, color: Colors.black), // 텍스트 스타일 설정
                    ),
                  ),
                // account_circle 아이콘 클릭 시 MyProfile 페이지로 이동
                IconButton(
                  iconSize: 25.0,
                  onPressed: () {
                    logOut(context);
                  },
                  icon: const Icon(
                      Icons.logout, // account_circle 아이콘
                  ),
                ),

                IconButton(
                  iconSize: 35.0,
                  onPressed: () async {
                    bool isLoggedIn = await checkLoginStatus(); // 비동기 함수 호출로 로그인 상태 확인
                    if (isLoggedIn) {
                      print("로그인 성공??");
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const MyProfile(), // MyProfile 페이지로 이동
                          ),
                        );

                    } else {
                      print("로그인 안함!!");
                      _showLoginDialog(context); // 로그인 다이얼로그 표시
                    }
                  },
                  icon: const Icon(
                    Icons.account_circle, // account_circle 아이콘
                  ),
                ),
                /// 결제함 아이콘
                IconButton(
                  iconSize: 35.0,
                  onPressed: () async{
                    bool isLoggedIn = await checkLoginStatus();
                    if (isLoggedIn) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => EstimateScreen(), // 결제함 페이지로 이동
                          ),
                        );

                    } else {
                      _showLoginDialog(context); // 로그인 다이얼로그 표시
                    }
                  },
                  icon: const Icon(
                    Icons.email,
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        // 2025-01-16: 기존 UI를 유지하며 하단에 TabBar와 TabBarView 추가
        body: SafeArea(
          child: Column(
            children: [
              // 기존 UI 유지
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // SelectBox UI
                      if (options.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0), // Row 전체 좌우 여백 추가
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                flex: 6, // SelectBox를 5/8 크기로 조정
                                child: GestureDetector(
                                  onTap: () async {
                                    bool isLoggedIn = await checkLoginStatus();
                                    if (isLoggedIn) {
                                      _loadOptions();
                                    }

                                    WitHomeWidgets.showSelectBox(
                                      context,
                                      selectedOption,
                                      options.keys.toList(),
                                          (option) {
                                        setState(() {
                                          selectedOption = option;
                                          secureStorage.write(key: 'aptName', value: option);
                                        });
                                      },
                                    );
                                  },
                                  child: Container(
                                    height: 50.0,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(left: 16.0), // 텍스트 앞에 패딩 추가
                                          child: Text(
                                            options.isEmpty
                                                ? "입주 할 APT 선택하세요"
                                                : selectedOption,
                                            style: WitHomeTheme.title, // 폰트 스타일 적용
                                          ),
                                        ),
                                        const Icon(Icons.arrow_drop_down),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8), // SelectBox와 평면도 간격을 넓게 설정
                              Expanded(
                                flex: 2, // 평면도를 3/8 크기로 조정
                                child: GestureDetector(
                                  onTap: () {
                                    // 평면도 관련 동작 추가
                                    showImagePopup(
                                      context: context,
                                      imageUrl: '/WIT/12345.png',
                                    );
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '평면도',
                                        style: WitHomeTheme.title,
                                      ),
                                      const SizedBox(width: 8), // 텍스트와 아이콘 사이 간격 조정
                                      const Icon(Icons.map_outlined, size: 24.0),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 16.0),
                      // 상태 위젯
                      APTStatusWidget(
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: MediaQuery.of(context).size.height * 0.12,
                      ),
                      const SizedBox(height: 16.0),
                      GestureDetector(
                        onTap: () {
                          showGuirdDialog(
                            context: context,
                            description: "예산별 시공 품목을 가이드 해드려요~\n\n각 품목별 비교견적을 받아세요~",
                            options: [
                              {'text': '100만원대  Simple 인테리어', 'color': Colors.green},
                              {'text': '300만원대  Standard 인테리어', 'color': Colors.blue},
                              {'text': '1000만원대  Premium 인테리어', 'color': Colors.indigo},
                              {'text': 'My Choice 인테리어', 'color': Colors.brown},
                            ],
                            onOptionSelected: (selectedOption) {
                              if (selectedOption == '100만원대  Simple 인테리어') {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) => getEstimate('S')),
                                );
                              } else if (selectedOption == '300만원대  Standard 인테리어') {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) => getEstimate('T')),
                                );
                              } else if (selectedOption == '1000만원대  Premium 인테리어') {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) => getEstimate('P')),
                                );
                              } else if (selectedOption == 'My Choice 인테리어') {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) => getEstimate('A')),
                                );
                              }
                            },
                          );
                        },
                        child: Container(
                          ///color: Colors.blue.withOpacity(0.2), // 시각적 확인용 배경색 추가
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                          margin: const EdgeInsets.symmetric(horizontal: 16.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8.0),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4.0,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.lightbulb_outline,
                                    color: Colors.blue,
                                    size: 24.0,
                                  ),
                                  const SizedBox(width: 8.0),
                                  Text(
                                    "내예산에 맞춰 부분시공 입주가이드",
                                    style: WitHomeTheme.title,
                                  ),
                                ],
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.black,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30.0),
                      // 추가된 문구
                      Align(
                        alignment: Alignment.centerLeft, // 좌측 정렬
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0), // 좌우 여백 추가
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.9, // 컨테이너 너비 설정
                            padding: const EdgeInsets.all(12.0), // 내부 여백 추가
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // "견적서비스"에 밑줄 및 간격 추가
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
                                    const SizedBox(height: 8.0), // 텍스트와 밑줄 사이 간격 추가
                                    Container(
                                      width: double.infinity, // 밑줄 길이를 컨테이너 너비에 맞춤
                                      height: 2.0, // 밑줄 두께 설정
                                      color: Colors.grey, // 밑줄 색상
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8.0), // 텍스트와 설명 사이 간격
                                // "각 시공품목별 견적서비스를 받아보세요."에는 밑줄 효과 없음
                                Text(
                                  "각 시공품목별 견적서비스를 받아보세요.",
                                  style: WitHomeTheme.title.copyWith(fontSize: 14.0),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      ///const SizedBox(height: 2.0),
                      getPopularCourseUI(), // Popular Course 추가
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        bottomNavigationBar: BottomNavBar(selectedIndex: _selectedIndex),

      ),
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