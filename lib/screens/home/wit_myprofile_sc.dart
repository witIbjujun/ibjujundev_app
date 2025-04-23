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
import '../common/wit_tableCalendar_sc.dart';
import '../preInspaction/wit_preInsp_main_sc.dart';
import '../question/wit_question_main_sc.dart';
import '../seller/wit_seller_profile_insert_name_sc.dart';

class MyProfile extends StatefulWidget  {
  const MyProfile({super.key});

  @override
  _MyProfileState createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
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
    _loadOptions();
    if (options.isNotEmpty) {
      selectedOption = options.first;
    }

    _loadNickName();
  }

  Future<void> _loadNickName() async {
    String? nickName = await _storage.read(key: 'nickName');

    if (nickName != null) {
      setState(() {
        _controller.text = nickName;
      });
    }
  }

  Future<void> _loadOptions() async {
    String? aptName = await _storage.read(key: 'aptName');
    String? clerkNo = await _storage.read(key: 'clerkNo');
    String? nickName = await _storage.read(key: 'nickName');
    String? role = await _storage.read(key: 'role');
    String? mainAptNo = await _storage.read(key: 'mainAptNo');

    print('myprofile 고객 번호: $clerkNo');
    print('myprofile 닉네임: $nickName');
    print('myprofile 역할: $role');
    print('myprofile Main아파트 번호: $mainAptNo');
    print('myprofile Main아파트 이름: $aptName');

    if (aptName != null) {
      setState(() {
        options = aptName.split(',');
      });
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonImageBanner(
                  imagePath: 'assets/home/gongguBanner.png',
                  heightRatio: 0.18,
                  widthRatio: 0.85,
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isEditable = true;
                      _focusNode.requestFocus();
                    });
                  },
                  child: AbsorbPointer(
                    absorbing: !_isEditable,
                    child: TextFormField(
                      focusNode: _focusNode,
                      controller: _controller,
                      decoration: InputDecoration(
                        labelText: 'MY 닉네임',
                        labelStyle: const TextStyle(
                          color: Color(0xFFAFCB54),
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.blue,
                            width: 1.0,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.lightBlue,
                            width: 2.0,
                          ),
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 20.0,
                        color: Colors.black,
                      ),
                      readOnly: !_isEditable,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    String initialSelection = options.isNotEmpty ? options.first : '';
                    WitHomeWidgets.showSelectBox(context, initialSelection, options,
                            (option) {
                          setState(() {
                            selectedOption = option;
                          });
                        });
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: 50.0,
                    decoration: BoxDecoration(
                      border: Border.all(color: WitHomeTheme.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Text(
                            selectedOption.isNotEmpty
                                ? selectedOption
                                : (options.isNotEmpty ? options.first : 'APT 선택'),
                            style: WitHomeTheme.title,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(right: 16.0),
                          child: Icon(Icons.arrow_drop_down,
                              color: WitHomeTheme.darkText),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      updateMyInfo();
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(200, 50),
                      backgroundColor: Color(0xFFAFCB54),
                    ),
                    child: Text(
                      '변경',
                      style: WitHomeTheme.body2.copyWith(color: Colors.white),
                    ),
                  ),
                ),
      /*          const SizedBox(height: 16),
                _buildListTile(Icons.attach_money, '캐시'),*/
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
                      MaterialPageRoute(builder: (context) => Board(1, 'B1', bordTitle: "커뮤니티", appBarFlag: true)),
                    );
                  },
                  child: _buildListTile(Icons.forum, '커뮤니티'),
                ),

                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Board(1, 'B1', bordTitle: "공지사항", appBarFlag: true)),
                    );
                  },
                  child:_buildListTile(Icons.campaign, '공지사항'),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => SellerProfileInsertName(),
                      ),
                    );
                  },
                  child: _buildListTile(Icons.business_center, '파트너 등록'),
                ),
                GestureDetector(
                  onTap: () async {
                    logOut(context);
                  },
                  child: _buildListTile(Icons.logout, '로그인(이)'),
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