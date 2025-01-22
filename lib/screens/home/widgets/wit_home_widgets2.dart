import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:witibju/screens/preInspaction/wit_preInsp_main_sc.dart';

import '../../../util/wit_code_ut.dart';
import '../../checkList/wit_checkList_main_sc.dart';
import '../../question/wit_question_main_sc.dart';
import '../wit_home_theme.dart'; // PreInspaction 화면 import

class ImageSlider extends StatefulWidget {
  final double heightRatio; // 높이 비율 파라미터
  final double widthRatio;  // 너비 비율 파라미터

  const ImageSlider({
    Key? key,
    required this.heightRatio,
    required this.widthRatio,
  }) : super(key: key);

  @override
  _ImageSliderState createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> {
  final PageController _pageController = PageController(initialPage: 0);
  final List<String> _images = [
    'assets/home/image1.png',
    'assets/home/image2.png',
  ];

  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _timer?.cancel(); // 기존 타이머 취소
    _timer = Timer.periodic(const Duration(seconds: 8), (_) {
      if (_pageController.hasClients) {
        setState(() {
          _currentPage = (_currentPage + 1) % _images.length;
        });
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
    _startAutoSlide(); // 페이지 변경 시 타이머 재설정
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height * widget.heightRatio; // 외부에서 전달받은 비율로 높이 계산
    final double width = MediaQuery.of(context).size.width * widget.widthRatio;   // 외부에서 전달받은 비율로 너비 계산

    return Stack(
      children: [
        SizedBox(
          height: height,
          width: width,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _images.length,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  if (_images[index] == 'assets/home/image1.png') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PreInspaction()),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Question(qustCd: 'Q10001')),
                    );
                  }
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16), // 둥근 모서리 추가
                  child: Image.asset(
                    _images[index],
                    fit: BoxFit.contain,
                    width: width,
                    height: height,
                  ),
                ),
              );
            },
          ),
        ),
        Positioned(
          bottom: 16.0, // 이미지 하단에서의 위치
          right: 16.0,  // 이미지 우측에서의 위치
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              _images.length,
                  (index) => GestureDetector(
                onTap: () {
                  _onPageChanged(index);
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                },
                child: Container(
                  margin: const EdgeInsets.all(4),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? Colors.blue : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}


// 공통 위젯: 오늘의 내APT 체크현황 및 날씨 정보
class APTStatusWidget extends StatelessWidget {
  final double width;
  final double height;

  const APTStatusWidget({
    required this.width,
    required this.height,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CheckListMain(),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: SizedBox(
          width: width,
          height: height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "오늘의 사전점검 상태",
                textAlign: TextAlign.center,
                style: WitHomeTheme.headline, // subtitle 스타일 적용
              ),
              const SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    children: const [
                      Icon(
                        Icons.wb_sunny,
                        color: Colors.orange,
                        size: 26.0,
                      ),
                      SizedBox(width: 4.0),
                      Text(
                        "120",
                        style: TextStyle(
                          fontSize: 26.0,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: const [
                      Icon(
                        Icons.cloud,
                        color: Colors.grey,
                        size: 26.0,
                      ),
                      SizedBox(width: 4.0),
                      Text(
                        "21",
                        style: TextStyle(
                          fontSize: 26.0,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/**
 *  이미지 팝업
 */
void showImagePopup({
  required BuildContext context,
  required String imageUrl, // 이미지 경로
  String title = '평면도 보기', // 기본 제목
}) {
  showDialog(
    context: context,
    barrierDismissible: true, // 팝업 외부 클릭 시 닫힘
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0), // 팝업 모서리 둥글게
        ),
        contentPadding: const EdgeInsets.all(16.0),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 팝업 제목
            Text(
              title,
              style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16.0),
            // 이미지 표시
            ClipRRect(
              borderRadius: BorderRadius.circular(10.0), // 이미지 모서리 둥글게
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8, // 화면 너비의 80%
                height: MediaQuery.of(context).size.height * 0.4, // 화면 높이의 40%
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(apiUrl + imageUrl), // API URL + 이미지 경로
                    fit: BoxFit.contain, // 이미지 꽉 채우기
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            // 닫기 버튼

          ],
        ),
      );
    },
  );
}

/**
 * 가이드 팝업
 */
// 2025-01-16: 옵션을 버튼 형태로 표시하고, 색상을 옵션별로 설정
void showGuirdDialog({
  required BuildContext context,
  required String description, // 설명 텍스트
  required List<Map<String, dynamic>> options, // 옵션 리스트 (텍스트, 색상)
  required Function(String) onOptionSelected, // 선택 시 호출될 함수
}) {
  showDialog(
    context: context,
    barrierDismissible: true, // 팝업 외부를 클릭해도 닫히지 않도록 설정
    builder: (BuildContext dialogContext) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 설명 문구
              Text(
                description,
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16.0),
              // 옵션 버튼 표시
              ...options.map((option) {
                final text = option['text'] as String;
                final color = option['color'] as Color;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color, // 버튼 색상
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                    ),
                    onPressed: () {
                      Navigator.of(dialogContext).pop(); // 팝업 닫기
                      onOptionSelected(text); // 선택된 옵션 처리
                    },
                    child: Text(
                      text,
                      style: const TextStyle(
                        color: Colors.white, // 텍스트 색상
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                );
              }).toList(),
              const SizedBox(height: 8.0),

            ],
          ),
        ),
      );
    },
  );
}

/*금액표시 UTil*/
class FormatUtils {
  /// 금액 포맷팅 함수
  static String formatCurrency(String amount) {
    if (amount.isEmpty || amount == "-") {
      return "-";
    }
    final formatter = NumberFormat('#,###');
    int intAmount = int.parse(amount);
    return formatter.format(intAmount);
  }
}




class DialogUtils {
  // 12/14: 공통 다이얼로그 메서드
  static Future<bool> showConfirmationDialog({
    required BuildContext context,
    String title = '확인',
    String content = '이 작업을 진행하시겠습니까?',
    String confirmButtonText = '진행',
    String cancelButtonText = '취소',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // 팝업 외부 클릭 시 닫히지 않도록 설정
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: WitHomeTheme.nearlyWhite, // 기본 배경색 흰색
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0), // 다이얼로그 모서리 둥글게
          ),
          title: Text(
            title,
            style: TextStyle(
              color: WitHomeTheme.darkerText, // 제목 색상 테마에 맞춤
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            content,
            style: TextStyle(
              color: WitHomeTheme.darkText, // 본문 색상 테마에 맞춤
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: WitHomeTheme.nearlyWhite, // 취소 버튼
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0), // 버튼 모서리 둥글게
                ),
              ),
              child: Text(
                cancelButtonText,
                style: TextStyle(
                  color: WitHomeTheme.lightText, // 취소 텍스트 색상
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(false); // 취소 시 false 반환
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: WitHomeTheme.nearlyWhite, // 진행 버튼 배경색
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0), // 버튼 모서리 둥글게
                ),
              ),
              child: Text(
                confirmButtonText,
                style: TextStyle(
                  color: WitHomeTheme.nearlyslowBlue, // 진행 버튼 텍스트 색상
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(true); // 확인 시 true 반환
              },
            ),
          ],
        );
      },
    );
    return result ?? false; // result가 null이면 false 반환
  }

  static Future<void> showCustomDialog({
    required BuildContext context,
    String title = '알림',
    String content = '내용이 없습니다.',
    String confirmButtonText = '확인',
    VoidCallback? onConfirm, // 확인 버튼 동작 (null 가능)
    bool barrierDismissible = false, // 다이얼로그 외부 클릭 닫기 여부
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: barrierDismissible, // 외부 클릭으로 닫힘 여부
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: WitHomeTheme.nearlyWhite, // 배경색
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0), // 모서리 둥글게
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: WitHomeTheme.darkerText,
            ),
            textAlign: TextAlign.center, // 제목 가운데 정렬
          ),
          content: Text(
            content,
            style: TextStyle(
              color: WitHomeTheme.darkText,
            ),
            textAlign: TextAlign.center, // 본문 가운데 정렬
          ),
          actionsAlignment: MainAxisAlignment.center, // 버튼 가운데 정렬
          actions: <Widget>[
            SizedBox(
              width: 200, // 버튼 너비 설정
              height: 50, // 버튼 높이 설정
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: WitHomeTheme.nearlyBlue, // 버튼 배경색
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0), // 모서리 둥글게
                  ),
                ),
                child: Text(
                  confirmButtonText,
                  style: TextStyle(
                    color: WitHomeTheme.white, // 텍스트 색상
                    fontWeight: FontWeight.bold,
                    fontSize: 16, // 텍스트 크기
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop(); // 다이얼로그 닫기
                  if (onConfirm != null) {
                    onConfirm(); // 확인 버튼 콜백 실행
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
