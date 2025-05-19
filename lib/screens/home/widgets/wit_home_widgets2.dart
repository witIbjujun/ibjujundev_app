import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:witibju/screens/preInspaction/wit_preInsp_main_sc.dart';

import '../../../util/wit_code_ut.dart';
import '../../checkList/wit_checkList_main_sc.dart';
import '../../common/wit_common_util.dart';
import '../../question/wit_question_main_sc.dart';
import '../models/requestInfo.dart';
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





/**
 * 이미지 배너
 */
class CommonImageBanner extends StatelessWidget {
  final String imagePath;
  final double heightRatio; // 화면 높이의 비율
  final double widthRatio;  // 화면 너비의 비율

  const CommonImageBanner({
    Key? key,
    required this.imagePath,
    this.heightRatio = 0.10, // 기본값: 10%
    this.widthRatio = 0.90,  // 기본값: 90%
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * widthRatio,  // 화면 너비의 % 적용
        height: MediaQuery.of(context).size.height * heightRatio, // 화면 높이의 % 적용
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0), // 모서리 둥글게
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1), // 그림자 효과
              blurRadius: 5.0,
              spreadRadius: 2.0,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0), // 모서리 둥글게 적용
          child: Image.asset(
            imagePath,
            fit: BoxFit.fill, // 이미지 비율 유지하면서 꽉 차게
          ),
        ),
      ),
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
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white, // 배경색 설정
            borderRadius: BorderRadius.circular(12.0), // 모서리 둥글게
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/home/bannerCheck.png', // 여기에 이미지 경로를 지정하세요.
                width: 900.0, // 원하는 너비
                height: 174.0, // 원하는 높이
                fit: BoxFit.fill, // 이미지 크기 조절 옵션
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
// 2025-04-22: 배경색을 검정으로, 상단 이미지/문구 추가 및 강조 텍스트 적용
void showGuirdDialog({
  required BuildContext context,
  required List<Map<String, dynamic>> options,
  required Function(String) onOptionSelected,
  double dialogWidth  = 320.0,
  double dialogHeight = 420.0,
}) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext dialogContext) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 12.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        backgroundColor: Colors.transparent,
        child: Container(
          width : dialogWidth,
          height: dialogHeight,
          decoration: BoxDecoration(
            color: Colors.black, // 2025-04-22: 배경색을 이미지 대신 검정색으로 고정
            borderRadius: BorderRadius.circular(20.0),
          ),
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 2025-04-22: 상단 이미지 추가
              Image.asset(
                'assets/home/bestBack.png',
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 12),

              // 2025-04-22: 강조 텍스트 포함 문구
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(color: Colors.white, fontSize: 15),
                  children: [
                    TextSpan(
                      text:'예산별 ',
                      style: TextStyle(
                        color: Colors.white,             // 텍스트 색상
                        fontSize: 20.0,                  // 폰트 크기
                        fontWeight: FontWeight.bold,     // 굵기
                        fontFamily: 'NotoSansKR',        // 폰트 지정 (선택)
                      ),
                    ),
                    TextSpan(
                      text:'시공 품목 ',
                      style: TextStyle(
                        color: WitHomeTheme.wit_lightGreen,             // 텍스트 색상
                        fontSize: 20.0,                  // 폰트 크기
                        fontFamily: 'NotoSansKR',        // 폰트 지정 (선택)
                      ),
                    ),
                    TextSpan(
                      text:'가이드 입니다.!\n',
                      style: TextStyle(
                        color: Colors.white,             // 텍스트 색상
                        fontSize: 20.0,                  // 폰트 크기
                        fontFamily: 'NotoSansKR',        // 폰트 지정 (선택)
                      ),
                    ),
                    TextSpan(
                      text:'각 품목별',
                      style: TextStyle(
                        color: Colors.white,             // 텍스트 색상
                        fontSize: 20.0,                  // 폰트 크기
                        fontFamily: 'NotoSansKR',        // 폰트 지정 (선택)
                      ),
                    ),
                    TextSpan(
                      text:' 비교견적',
                      style: TextStyle(
                        color: WitHomeTheme.wit_lightGreen,             // 텍스트 색상
                        fontSize: 20.0,                  // 폰트 크기
                        fontFamily: 'NotoSansKR',        // 폰트 지정 (선택)
                      ),
                    ),
                    TextSpan(
                      text:'을 받아보세요',
                      style: TextStyle(
                        color: Colors.white,             // 텍스트 색상
                        fontSize: 20.0,                  // 폰트 크기
                        fontFamily: 'NotoSansKR',        // 폰트 지정 (선택)
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 옵션 버튼 리스트
              ...options.asMap().entries.map((entry) {
                final int idx = entry.key;
                final Map<String, dynamic> opt = entry.value;

                // 필드 파싱
                final String text      = opt['text'];
                final String? sub      = opt['textSub'];
                final String? bgImgRaw = opt['bgImage'] ?? opt['bgImage '];
                final Color   bgColor  = (opt['color'] as Color?) ?? Colors.grey;
                final double  btnH     = (opt['height'] as double?) ?? 56.0;
                final double  btnW     = (opt['width']  as double?) ?? double.infinity;

                // 경로 자동 보정
                String? resolvedImg;
                if (bgImgRaw != null && bgImgRaw.isNotEmpty) {
                  resolvedImg = bgImgRaw.startsWith('assets/') ? bgImgRaw : 'assets/home/$bgImgRaw';
                }

                return Container(
                  width : btnW,
                  height: btnH,
                  margin: EdgeInsets.only(
                    top   : idx == 0 ? 0 : 14, // 2025-04-22: 첫 번째 버튼 상단 마진 제거
                    bottom: idx == options.length - 1 ? 0 : 14,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    image: resolvedImg != null
                        ? DecorationImage(
                      image: AssetImage(resolvedImg),
                      fit: BoxFit.cover,
                    )
                        : null,
                    color : resolvedImg == null ? bgColor.withOpacity(0.9) : null,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(30),
                      onTap: () {
                        Navigator.of(dialogContext).pop();
                        onOptionSelected(text);
                      },
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              text,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (sub != null) ...[
                              const SizedBox(width: 6),
                              Text(
                                '($sub)',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.bold, // ← 굵게 적용됨
                                ),
                              ),
                            ]
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
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
        // 2025.04.03: 다이얼로그 테마 어둡게 변경
        return AlertDialog(
          backgroundColor: Colors.black, // 배경 검정색
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white, // 제목 흰색
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            content,
            style: const TextStyle(
              color: Colors.white, // 본문 흰색
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey, // 회색 버튼 배경
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text(
                cancelButtonText,
                style: const TextStyle(
                  color: Colors.white, // 흰색 텍스트
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey, // 회색 버튼 배경
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text(
                confirmButtonText,
                style: const TextStyle(
                  color: Colors.white, // 흰색 텍스트
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
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
                  backgroundColor: WitHomeTheme.wit_lightGreen, // 버튼 배경색
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

  /**
   * 아이폰 형식
   */
  static Future<bool> showIPhoneConfirmDialog({
    required BuildContext context,
    required String title,
    required String content,
    String confirmText = '확인',
    String cancelText = '취소',
    Color confirmColor = Colors.blue,
    Color cancelColor = Colors.grey,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,  // 🔹 글씨 크기 키움
            ),
          ),
          content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              content,
              style: const TextStyle(
                fontSize: 16,  // 🔹 글씨 크기 키움
              ),
            ),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop(false); // 🚫 취소 시 false 반환
              },
              child: Text(
                cancelText,
                style: TextStyle(color: cancelColor),
              ),
            ),
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop(true); // ✅ 확인 시 true 반환
              },
              child: Text(
                confirmText,
                style: TextStyle(color: confirmColor),
              ),
            ),
          ],
        );
      },
    );

    return result ?? false; // 결과가 null이면 false 반환
  }
}
// 글씨 더보기
// 2025-05-18: OverflowText 수정 - 클릭 시 확장 및 축소 기능 추가
class OverflowText extends StatefulWidget {
  const OverflowText({
    Key? key,
    required this.text,
    required this.maxLines,
  }) : super(key: key);

  final String text;
  final int maxLines;

  @override
  State<OverflowText> createState() => _OverflowTextState();
}

class _OverflowTextState extends State<OverflowText> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: ConstrainedBox(
            constraints: _isExpanded
                ? const BoxConstraints()
                : BoxConstraints(maxHeight: widget.maxLines * 20.0),
            child: Text(
              widget.text,
              softWrap: true,
              overflow: TextOverflow.fade,
              style: const TextStyle(height: 1.5),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              _isExpanded ? "" : "...",
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}




class proFlieImage {
  /// 🔹 이미지 경로에 맞는 ImageProvider를 반환
  static ImageProvider getImageProvider(String imagePath) {
    print("이미지========"+imagePath);
   if (imagePath != "") {
      // 🔹 네트워크 이미지
      return NetworkImage(apiUrl +imagePath);
    } else {
      // 🔹 기본 이미지 (없을 경우 대체)
      return AssetImage('assets/images/profile1.png');
    }
  }
}

// 2025-03-25 공통 위젯으로 분리
class EstimateTable extends StatelessWidget {
  final List<RequestInfo> estimates;

  const EstimateTable({
    Key? key,
    required this.estimates,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal, // 많을 경우 대응
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue),
        ),
        child: Table(
          border: TableBorder.all(color: Colors.grey),
          columnWidths: {
            0: const FlexColumnWidth(2),
            for (int i = 0; i < estimates.length; i++) i + 1: const FlexColumnWidth(3),
          },
          children: [
            _buildRow("업체", (e) => e.companyNm),
            _buildRow("견적가", (e) => '${formatCash(e.estimateAmount)}원'),
            _buildRow("평점", (e) => e.rate, isRating: true),
          ///  _buildRow("시공건수", (e) => '${e.constructCount ?? "-"}건'),
            _buildRow("시공건수", (e) => '11건'),
            //_buildRow("입주전인증", (e) => e.certifiedBeforeMove == "Y" ? "인증완료" : "미인증"),
            _buildRow("입주전인증", (e) => "Y" == "Y" ? "인증완료" : "미인증"),
            //_buildRow("AS 가능여부", (e) => e.asAvailable == "Y" ? "가능" : "불가"),
            _buildRow("AS 가능여부", (e) => "Y" == "Y" ? "가능" : "불가"),
            //_buildRow("창업년도", (e) => e.foundYear ?? "-"),
            _buildRow("창업년도", (e) => "2019년" ?? "-"),
          ],
        ),
      ),
    );
  }

  TableRow _buildRow(String title, String Function(RequestInfo) valueBuilder, {bool isRating = false}) {
    return TableRow(
      decoration: title == "업체" ? BoxDecoration(color: Colors.grey[200]) : null,
      children: [
        _cell(title, isHeader: true),
        ...estimates.map((e) => isRating ? _ratingCell(valueBuilder(e)) : _cell(valueBuilder(e))).toList(),
      ],
    );
  }

  Widget _cell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: TextStyle(fontWeight: isHeader ? FontWeight.bold : FontWeight.normal),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _ratingCell(String rate) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/star.png', width: 16.0, height: 16.0),
          const SizedBox(width: 4.0),
          Text(rate),
        ],
      ),
    );
  }
}

