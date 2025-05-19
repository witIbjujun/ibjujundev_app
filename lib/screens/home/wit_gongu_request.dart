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
import 'models/gonguInfo.dart';

//공동구매
class GonguRequest extends StatefulWidget  {

  final secureStorage = FlutterSecureStorage(); // Flutter Secure Storage 인스턴스

  GonguRequest({super.key});


  @override
  _GonguRequeststState createState() => _GonguRequeststState();
}

class _GonguRequeststState extends State<GonguRequest> {
  String selectedOption = ''; // 기본 선택 값

  List<String> options = [];
  int _selectedIndex = 3; // ✅ "내정보" 탭이 기본 선택

  List<GonguInfo> gonguRequest = [];

  GonguInfo? _selectedGonguList;

  // 컨설리더 설정
  final _storage = const FlutterSecureStorage();
  TextEditingController _controller = TextEditingController();

  // 컨트리로 조회한 단순 정보를 표시
  bool _isEditable = false;
  FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    gonguList();
  }

  Future<void> gonguList() async {
    print("📡 데이터 조회 시작");
    String restId = "getGonguList";

    String? aptNo = await widget.secureStorage.read(key: 'mainAptNo');
    String? clerkNo = await widget.secureStorage.read(key: 'clerkNo');

    final param = jsonEncode({
      "aptNo": aptNo,
      "reqUser": clerkNo,
    });

    try {
      final response = await sendPostRequest(restId, param);
      print("📡 응답 받음: ${jsonEncode(response)}");

      final parsed = GonguInfo().parseRequestList(response) ?? [];
      setState(() {
        gonguRequest = parsed;
        _selectedGonguList = parsed.isNotEmpty ? parsed.first : null;
        print("🔎 UI 업데이트 완료");
      });

      print("📡 requests 업데이트됨, 길이: ${gonguRequest.length}");
    } catch (e) {
      print("❌ 신청 목록 조회 중 오류 발생: $e");
    }
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
                  children:
                    gonguRequest.map((gonguItem) {
                      return _buildGonguItem(
                        title:  gonguItem.gpEndDate +' '+ gonguItem.categoryNm ?? '제목 없음',
                        description: gonguItem.detail ?? '설명 없음',
                        current: gonguItem.reqCount ??'0', // 현재 신청 수
                        max: gonguItem.limitCount ??'0',         // 최대 신청 수
                        iconName: gonguItem.imagePath ?? 'image_not_supported',
                        gonguItem: gonguItem, // 아이콘은 임의로 설정
                      );
                    }).toList(),
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
    required GonguInfo gonguItem, // 🔹 GonguInfo 자체를 전달
    String? current,
    String? max,
    required String iconName, // 🔹 String으로 아이콘 이름 받기
  }) {
    // 🔹 아이콘과 색상을 동시에 받아오기
    final iconData = _getIconAndColor(iconName);

    // 🔸 신청 상태에 따른 버튼 설정
    final bool isRequestable = (gonguItem.reqState == null || gonguItem.reqState.isEmpty);

    // 🔹 버튼 상태 및 텍스트 설정
    String buttonText = "";
    Color buttonColor = Colors.grey;
    VoidCallback? onPressed;

    if (gonguItem.gpStat == "10") {
      buttonText = isRequestable ? '신청' : '신청완료';
      buttonColor = isRequestable ? Colors.black : Colors.grey;
      onPressed = isRequestable
          ? () async {
        bool isConfirmed = await DialogUtils.showIPhoneConfirmDialog(
          context: context,
          title: '공구신청',
          content: '신청 하시겠습니까?',
        );

        if (isConfirmed) {
          sendRequestInfo(gonguItem); // ✅ 신청하기
        }
      }
          : null;
    } else if (gonguItem.gpStat == "20") {
      buttonText = '조기마감';
      buttonColor = Colors.grey;
      onPressed = null; // 비활성화
    } else if (gonguItem.gpStat == "30") {
      buttonText = '매진';
      buttonColor = Colors.redAccent;
      onPressed = null; // 비활성화
    }

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
                backgroundColor: iconData['color']!.withOpacity(0.2),
                child: Icon(
                  iconData['icon'],
                  color: iconData['color'],
                ),
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
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              buttonText,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }


  /**
   * 견적요청하기
   */
  Future<void> sendRequestInfo(GonguInfo gonguItem) async {
    String restId = "saveRequestInfo";
    String? aptNo = await widget.secureStorage.read(key: 'mainAptNo');
    String? clerkNo = await widget.secureStorage.read(key: 'clerkNo');

    print("========== 📝 GonguInfo 정보 ==========");
    print("categoryId: ${gonguItem.categoryId}");
    print("categoryNm: ${gonguItem.categoryNm}");
    print("detail: ${gonguItem.detail}");
    print("imagePath: ${gonguItem.imagePath}");
    print("gpStartDate: ${gonguItem.gpStartDate}");
    print("gpEndDate: ${gonguItem.gpEndDate}");
    print("gpStat: ${gonguItem.gpStat}");
    print("limitCount: ${gonguItem.limitCount}");
    print("reqCount: ${gonguItem.reqCount}");
    print("saleRate: ${gonguItem.saleRate}");
    print("saleAmt: ${gonguItem.saleAmt}");
    print("========================================");

    final param = jsonEncode({
      "reqGubun": 'G',
      "reqUser": clerkNo,
      "aptNo": aptNo,
      "categoryId": gonguItem.categoryId,
    });

    try {
      final response = await sendPostRequest(restId, param);

      if (response != null) {
        await DialogUtils.showCustomDialog(
          context: context,
          title: '견적 요청 완료',
          content: '견적 요청이 성공적으로 완료되었습니다.',
          confirmButtonText: '확인',
          onConfirm: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          },
        );
      } else {
        throw Exception('응답 없음');
      }
    } catch (e) {
      print('견적 요청 실패: $e');
      await DialogUtils.showCustomDialog(
        context: context,
        title: '요청 실패',
        content: '견적 요청에 실패했습니다. 다시 시도해 주세요.',
        confirmButtonText: '확인',
        onConfirm: () => Navigator.pop(context),
      );
    }
  }



  /// 🔹 String을 IconData와 Color로 변환하는 매핑 함수
  Map<String, dynamic> _getIconAndColor(String iconName) {
    switch (iconName) {
      case 'grid_4x4':
        return {
          'icon': Icons.grid_4x4,
          'color': Colors.grey[700]!,
        };
      case 'cleaning_services':
        return {
          'icon': Icons.cleaning_services,
          'color': Colors.blue,
        };
      case 'eco':
        return {
          'icon': Icons.eco,
          'color': Colors.green,
        };
      case 'chair':
        return {
          'icon': Icons.chair,
          'color': Colors.purple,
        };
      case 'curtains':
        return {
          'icon': Icons.curtains,
          'color': Colors.redAccent,
        };
      case 'border_all':
        return {
          'icon': Icons.border_all,
          'color': Colors.purple,
        };
      default:
        return {
          'icon': Icons.border_all,
          'color': Colors.grey,
        };
    }
  }

}

