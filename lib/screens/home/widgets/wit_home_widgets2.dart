import 'dart:async';
import 'package:flutter/material.dart';
import 'package:witibju/screens/preInspaction/wit_preInsp_main_sc.dart'; // PreInspaction 화면 import

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
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
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

    return Column(
      mainAxisSize: MainAxisSize.min,
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
                  }
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16), // 둥근 모서리 추가
                  child: Image.asset(
                    _images[index],
                    fit: BoxFit.cover,
                    width: width,
                    height: height,
                  ),
                ),
              );
            },
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 8.0),
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
        ),
      ],
    );
  }
}
