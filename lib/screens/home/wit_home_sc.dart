import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
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

class _HomeScreenState extends State<HomeScreen> {
  ///로그인 상태를 true로 설정해서 테스트 (실제로는 로그인 여부를 판단하는 로직이 필요)

  // SelectBox에 표시할 옵션 리스트
  Map<String, String> options = {};
  String selectedOption = ""; // 기본 선택된 옵션

  UserInfo? userInfo; // 사용자 정보를 저장할 변수
  final secureStorage = FlutterSecureStorage(); // Flutter Secure Storage 인스턴스
  String  isLogined = "false";

  @override
  void initState() {
    super.initState();
    _loadOptions();

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

    print('_loadOptions 아파트 이름: $aptNameString');
    print('_loadOptions 아파트 번호: $aptNoString');

    if (aptNameString != null && aptNoString != null) {

      List<String> aptNames = aptNameString.split(',');
      List<String> aptNos = aptNoString.split(',');

      setState(() {
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
        body: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: MediaQuery.of(context).padding.top,
              ),
              // SelectBox 추가 (하단 파올 표시)
              if (options.isNotEmpty) GestureDetector(
                onTap: () async {

                // 세션 상태 확인
                bool isLoggedIn = await checkLoginStatus();
                if (isLoggedIn) {
                  _loadOptions();
                }

                  WitHomeWidgets.showSelectBox(context, selectedOption, options.keys.toList(), (option) {
                    setState(() {
                      selectedOption = option;
                      secureStorage.write(key: 'aptName', value: option);
                    });
                    if (options.containsKey(selectedOption)) {
                      String selectedAptNo = options[selectedOption]!;
                      ///updateMyInfo(selectedAptNo); // updateMyInfo 호출
                    } else {
                      print('선택한 옵션에 해당하는 번호를 찾을 수 없습니다.');
                    }
                  });
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
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
                          options.isEmpty ? "입주 할 APT 선택하세요" : selectedOption,
                          style: WitHomeTheme.title, // 폰트 스타일 적용
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              // ImageBox를 화면에 표시
              SizedBox(
                height: 180,
                child: Column(
                  children: [

                   /** Expanded(
                      child: ImageSlider(
                        heightRatio: 0.18, // 화면 높이의 18%
                        widthRatio: 0.9,  // 화면 너비의 90%
                      ),
                    ),**/

                    // 오늘의 내APT 체크현황 및 날씨 정보 공통 위젯 사용
                    APTStatusWidget(width: MediaQuery.of(context).size.width * 0.9, height: MediaQuery.of(context).size.height * 0.12),

                    GestureDetector(
                      onTap: () {
                        // getEstimate() 호출 시 화면 이동
                        showModalBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
                          ),
                          builder: (BuildContext context) {
                            return Container(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    title: const Text('Simple 인테리어 추천'),
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => getEstimate('S'),
                                        ),
                                      );
                                    },
                                  ),
                                  ListTile(
                                    title: const Text('Standard 인테리어 추천'),
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => getEstimate('T'),
                                        ),
                                      );
                                    },
                                  ),
                                  ListTile(
                                    title: const Text('Premium 인테리어 추천'),
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => getEstimate('P'),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      child: Container(
                        // 01/14: 버튼 디자인 개선 및 패딩 추가
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
                              offset: Offset(0, 2), // 그림자 위치
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.lightbulb_outline, // 가이드 관련 아이콘
                                  color: Colors.blue,
                                  size: 24.0,
                                ),
                                const SizedBox(width: 8.0),
                                Text(
                                  "내예산에 맞춰 부분시공 입주가이드",
                                  style: WitHomeTheme.title, // 01/14: 텍스트 스타일 적용
                                ),
                              ],
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),  //이미지 슬라이스 위젯
              ),
              const SizedBox(height: 2),

              /**
              Text(
                "우리 입주할때 인테리어 비교경제를 받아보세요~",
                style: WitHomeTheme.title,
              ),

              const SizedBox(height: 8),
              // 견적받으러 가기 버튼
              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: 50.0,
                decoration: BoxDecoration(
                  color: WitHomeTheme.nearlyslowBlue,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: ElevatedButton(
                  onPressed: () async {
                    bool isLoggedIn = await checkLoginStatus(); // 로그인 상태 확인
                    if (isLoggedIn) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => getEstimate('A'),
                        ),
                      );
                    }else{
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.8,
                              height: 300,
                              padding: const EdgeInsets.all(20.0),
                              child: loingPopHome(
                                onLoginSuccess: (String result) {
                                  setState(() {
                                    isLogined = "true";
                                    // _loadOptions();
                                  });
                                },
                              ),
                            ),
                          );
                        },
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ),
                  child: const Text(
                    "견적받으러 가기",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),**/
              const SizedBox(height: 4),
              getPopularCourseUI(),  /// 견적받으러 가기
            ],
          ),
        ),
      ),
    );
  }

  /// 최하단 카테고리 리스트 (Popular Course)
  Widget getPopularCourseUI() {
    return Container(
      padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
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
          const SizedBox(height: 4),
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

  /**
   * 로그인 팝업
   */
  void _showLoginDialog(BuildContext parentContext) async {
    bool isLoggedIn = await checkLoginStatus();
    if (!isLoggedIn) {
      showDialog(
        context: parentContext,
        barrierDismissible: false, // 팝업 외부 클릭 방지
        builder: (BuildContext dialogContext) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Container(
              width: MediaQuery.of(parentContext).size.width * 0.8,
              height: 300,
              padding: const EdgeInsets.all(20.0),
              child: loingPopHome(
                onLoginSuccess: (String result) async {
                  print("뭐가 넘어온거지111111??$result");
                  print("뭐가 넘어온거지111111??$result");
                  print("뭐가 넘어온거지111111??$result");
                  print("뭐가 넘어온거지111111??$result");
                  if (result == '0') {
                    Navigator.of(dialogContext).pop();
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Navigator.of(parentContext).push(
                        MaterialPageRoute(
                          builder: (context) => WitUserLoginStep1(),
                        ),
                      );
                    });
                  } else {
                    print("뭐가 넘어온거지??$result");
                    final viewModel = Provider.of<MainViewModel>(parentContext, listen: false);
                    await getUserInfo(context, viewModel, result);
                    Navigator.of(dialogContext).pop();
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Navigator.of(parentContext).push(
                        MaterialPageRoute(
                          builder: (context) => HomeScreen(),
                        ),
                      );
                    });
                  }
                },
              ),
            ),
          );
        },
      );
    }
  }
}