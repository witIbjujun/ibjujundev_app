import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:witibju/screens/home/widgets/wit_home_bottom_nav_bar.dart';
import 'package:witibju/screens/home/widgets/wit_home_widgets.dart';
import 'package:witibju/screens/home/widgets/wit_home_widgets.dart';
import 'package:witibju/screens/home/login/wit_user_login.dart';
import 'package:witibju/screens/home/wit_estimate_detail.dart';
import 'package:witibju/screens/home/wit_home_sc.dart';
import 'package:witibju/screens/home/wit_home_theme.dart';
import 'package:witibju/screens/home/wit_myInfo_sc.dart';

import '../../util/wit_api_ut.dart';
import '../board/widget/wit_board_detail_widget.dart';
import '../board/wit_board_main_sc.dart';
import '../checkList/wit_checkList_main_sc.dart';
import '../common/wit_tableCalendar_sc.dart';
import '../preInspaction/wit_preInsp_main_sc.dart';
import 'package:witibju/screens/home/models/userInfo.dart' as model;


import '../question/wit_question_main_sc.dart';
import '../seller/wit_seller_profile_detail_sc.dart';
import '../seller/wit_seller_profile_insert_name_sc.dart';
import 'login/wit_kakaoLogin.dart';
import 'models/main_view_model.dart';

class MyProfile extends StatefulWidget  {
  const MyProfile({super.key});

  @override
  _MyProfileState createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  String? aptName; // 🔹 클래스 필드로 선언
  String? _sllrNo; // 파트너 번호
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
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      // SecureStorage에서 정보 읽기
      String? loadedNickName = await _storage.read(key: 'nickName');
      String? loadedAptName = await _storage.read(key: 'mainAptNm');
      String? clerkNo = await _storage.read(key: 'clerkNo');
      String? role = await _storage.read(key: 'role');
      String? mainAptNo = await _storage.read(key: 'mainAptNo');
      String? loadedSllrNo = await _storage.read(key: 'sllrNo');

      print('myprofile 고객 번호: $clerkNo');
      print('myprofile 닉네임: $loadedNickName');
      print('myprofile 역할: $role');
      print('myprofile Main아파트 번호: $mainAptNo');
      print('myprofile Main아파트 이름: $loadedAptName');

      // 상태 업데이트
      setState(() {
        if (loadedNickName != null) {
          _controller.text = loadedNickName;
        }
        aptName = loadedAptName ?? 'APT 선택';
        _sllrNo = loadedSllrNo;
      });

    } catch (e) {
      print("UserInfo 로딩 중 오류 발생: $e");
    }
  }


  // MY 닉네임 저장 메서드
  Future<void> updateMyInfo() async {
    if (_controller.text.isNotEmpty) {
      String restId = "updateMyInfo";
      final param = jsonEncode({
        "clerkNo": await _storage.read(key: 'clerkNo'),
        "nickName": _controller.text
      });

      try {
        final response = await sendPostRequest(restId, param);
        if (response != null) {
          await _storage.write(key: 'nickName', value: _controller.text);
          print('### MY 닉네임 저장됨: ${_controller.text}');

          // 저장 후 읽기 전용 상태로 변경
          setState(() {
            _isEditable = false;
          });

          // 저장 완료 후 메시지를 보여줌
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('MY 닉네임이 저장되었습니다.'),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          print("MY 닉네임 저장 실패: ${response['message']}");
        }
      } catch (e) {
        print('요청 상태 업데이트 중 오류 발생: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print("Rendering MyProfile...");

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text(
            'My Profile',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              fontFamily: 'NotoSansKR',
            ),
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonImageBanner(
                  imagePath: 'assets/home/gongguBanner.png',
                  heightRatio: 0.18,
                  widthRatio: 0.85,
                ),
                const SizedBox(height: 16),

                /// 🔹 MY 닉네임, APT Name, 변경 버튼을 감싸는 컨테이너
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyInfo()),
                    );
                  },
                  child: _buildListTile(Icons.account_circle_outlined, ' 내정보'),
                ),

                /// 🔹 기존의 다른 메뉴들 (거래내역, 가이드, 체크리스트 등) 유지
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EstimateScreen()),
                    );
                  },
                  child: _buildListTile(Icons.receipt_long, '거래내역'),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Question(qustCd: 'Q10001')),
                    );
                  },
                  child: _buildListTile(Icons.design_services, '가이드'),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CheckListMain(),
                      ),
                    );
                  },
                  child: _buildListTile(Icons.checklist, 'MY 체크리스트'),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Board(bordType: "CM01")),
                    );
                  },
                  child: _buildListTile(Icons.forum, '커뮤니티'),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Board(bordType: "GJ01")),
                    );
                  },
                  child:_buildListTile(Icons.campaign, '공지사항'),
                ),
                GestureDetector(
                  onTap: () {
                    if (_sllrNo != null && _sllrNo!.isNotEmpty) {
                      // 2025-05-26: sllrNo 존재 → 파트너 상세로 이동
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => SellerProfileDetail(sllrNo: int.parse(_sllrNo!)),
                        ),
                      );
                    } else {
                      // sllrNo 없음 → 파트너 등록으로 이동
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => SellerProfileInsertName(),
                        ),
                      );
                    }
                  },
                  child: _buildListTile(Icons.business_center,
                      _sllrNo != null && _sllrNo!.isNotEmpty ? '파트너 전환' : '파트너 등록'),
                ),
                GestureDetector(
                  onTap: () async {
                    final viewModel = Provider.of<MainViewModel>(context, listen: false); // 2025-04-26: 기존 Provider에서 가져옴
                    await viewModel.getUserInfoProxy(context, '1', 'C');

                    // 팝업 등 필요한 추가 동작이 있다면 여기에 작성 가능
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('로그인되었습니다.')),
                    );
                    // ✅ 로그인 성공 후 HomeScreen으로 이동
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                    );
                  },
                  child: _buildListTile(Icons.logout, '로그인(이)'),
                ),
                GestureDetector(
                  onTap: () async {
                    final viewModel = Provider.of<MainViewModel>(context, listen: false); // 2025-04-26: 기존 Provider에서 가져옴
                    await viewModel.getUserInfoProxy(context, '5', 'C');

                    // 팝업 등 필요한 추가 동작이 있다면 여기에 작성 가능
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('로그인되었습니다.')),
                    );
                    // ✅ 로그인 성공 후 HomeScreen으로 이동
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                    );
                  },
                  child: _buildListTile(Icons.logout, '로그인(우)'),
                ),
                GestureDetector(
                  onTap: () async {
                    final viewModel = Provider.of<MainViewModel>(context, listen: false); // 2025-04-26: 기존 Provider에서 가져옴
                    await viewModel.getUserInfoProxy(context, '３', 'C');

                    // 팝업 등 필요한 추가 동작이 있다면 여기에 작성 가능
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('로그인되었습니다.')),
                    );
                    // ✅ 로그인 성공 후 HomeScreen으로 이동
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                    );
                  },
                  child: _buildListTile(Icons.logout, '로그인(백)'),
                ),
                GestureDetector(
                  onTap: () async {
                    final viewModel = Provider.of<MainViewModel>(context, listen: false); // 2025-04-26: 기존 Provider에서 가져옴
                    await viewModel.getUserInfoProxy(context, '2', 'C');

                    // 팝업 등 필요한 추가 동작이 있다면 여기에 작성 가능
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('로그인되었습니다.')),
                    );
                    // ✅ 로그인 성공 후 HomeScreen으로 이동
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                    );
                  },
                  child: _buildListTile(Icons.logout, '로그인(조)'),
                ),

                GestureDetector(
                  onTap: () async {
                    logOut(context);
                  },
                  child: _buildListTile(Icons.logout, '로그아웃'),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomNavBar(selectedIndex: _selectedIndex),
      ),
    );
  }

  // ListTile을 생성하는 함수
  Widget _buildListTile(IconData iconData, String title) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      margin: EdgeInsets.only(bottom: 10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: Colors.grey.shade100, // 항목 배경색을 그레이로 설정
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(iconData, size: 24.0, color: Colors.grey.shade700), // 왼쪽 아이콘
              SizedBox(width: 16.0),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          Icon(
            Icons.arrow_forward_ios, // 우측에 ">" 아이콘
            color: Colors.grey.shade700,
            size: 18.0,
          ),
        ],
      ),
    );
  }

  // Select Box를 보여주는 함수
  void showSelectBox(BuildContext context, String currentSelection, List<String> options, Function(String) onSelected) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((String option) {
            return ListTile(
              title: Text(
                option,
                style: WitHomeTheme.body1, // 동일한 텍스트 스타일 적용
              ),
              onTap: () {
                Navigator.pop(context); // 선택 후 창 닫기
                onSelected(option); // 선택된 옵션을 반환
              },
            );
          }).toList(),
        );
      },
    );
  }
}