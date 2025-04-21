import 'package:flutter/material.dart';

class ImageViewer extends StatefulWidget {

  final List<String> imageUrls;
  final int initialIndex;

  ImageViewer({required this.imageUrls, this.initialIndex = 0});

  @override
  _ImageViewerState createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex; // 초기 인덱스 설정
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "이미지 뷰어",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black,
            ),
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
          child: Column(
            children: [
              // 큰 이미지 표시
              Expanded(
                flex: 8, // 80% 차지
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20), // 모서리 둥글게
                    image: DecorationImage(
                      image: NetworkImage(widget.imageUrls[currentIndex]),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              Container(
                height: 10,
                color: Colors.grey[200],
              ),
              Expanded(
                flex: 2, // 20% 차지
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 8), // 위아래 여백
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.imageUrls.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          // 클릭 시 큰 이미지 변경
                          setState(() {
                            currentIndex = index;
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.fromLTRB(5, 15, 5, 15), // 오른쪽 여백
                          width: 100, // 너비 100 설정
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: currentIndex == index ? Colors.red : Colors.transparent,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8), // 모서리 둥글게
                            image: DecorationImage(
                              image: NetworkImage(widget.imageUrls[index]),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}