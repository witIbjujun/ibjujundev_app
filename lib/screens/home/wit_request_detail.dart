import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:witibju/screens/home/widgets/wit_home_widgets2.dart';
import 'package:witibju/screens/home/wit_estimate_detail.dart';
import 'package:witibju/screens/home/wit_home_theme.dart';
import '../../util/wit_api_ut.dart';
import '../../util/wit_code_ut.dart';
import '../chat/CustomChatScreen.dart';
import '../chat/chatMain.dart';
import 'models/requestInfo.dart';

/**
 * 비교견적 상세
 */
class RequestDetailScreen extends StatefulWidget {
  final String categoryId;
  final String reqNo;

  const RequestDetailScreen({
    Key? key,
    required this.categoryId,
    required this.reqNo,
  }) : super(key: key);

  @override
  State<RequestDetailScreen> createState() => _RequestDetailScreenState();
}

class _RequestDetailScreenState extends State<RequestDetailScreen> {
  List<RequestInfo> requests = [];
  RequestInfo? _selectedRequest;
  final secureStorage = FlutterSecureStorage();
  bool isLoading = true; // 조회 구분
  bool isExpanded = false; // 접시 / 상세보기
  @override
  void initState() {
    super.initState();
    fetchRequestDetailList();
  }

  Future<void> fetchRequestDetailList() async {
    String restId = "getRequesDetailtList";
    String? clerkNo = await secureStorage.read(key: 'clerkNo');

    final param = jsonEncode({
      "categoryId": widget.categoryId,
      "reqNo": widget.reqNo,
      "reqUser": clerkNo,
    });

    try {
      final response = await sendPostRequest(restId, param);
      final parsed = RequestInfo().parseRequestList(response) ?? [];

      setState(() {
        requests = parsed;
        _selectedRequest = parsed.isNotEmpty ? parsed.first : null;
        isLoading = false; // 2025-03-24: 로딩 완료
      });

      print('📡 상세 조회 응답: ${jsonEncode(response)}');
    } catch (e) {
      print('신청 목록 조회 중 오류 발생: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text(
            '비교 견적 상세',
            style: TextStyle(
              color: Colors.white,             // 텍스트 색상
              fontSize: 20.0,                  // 폰트 크기
              fontWeight: FontWeight.bold,     // 굵기
              fontFamily: 'NotoSansKR',        // 폰트 지정 (선택)
            ),
          ),
          iconTheme: IconThemeData(color: Colors.white), // ← 아이콘 색상도 검정으로 맞추려면 추가
        ),
        body: Center(
          child: CircularProgressIndicator(), // 또는 '로딩 중...' 텍스트
        ),
      );
    }

    // 로딩이 끝난 이후의 화면
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          '비교 견적 상세',
          style: TextStyle(
            color: Colors.white,             // 텍스트 색상
            fontSize: 20.0,                  // 폰트 크기
            fontWeight: FontWeight.bold,     // 굵기
            fontFamily: 'NotoSansKR',        // 폰트 지정 (선택)
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white), // ← 아이콘 색상도 검정으로 맞추려면 추가
      ),
      body: Column(
        children: [
          // 요청 내역 정보 박스
          SizedBox(height: 16), // 상단 간격 추가
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            margin: const EdgeInsets.symmetric(horizontal: 16.0), // ← 좌우 여백 추가
            decoration: BoxDecoration(
              color: Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${requests[0].categoryNm}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 8),

                // 설명 + 더보기
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isExpanded = !isExpanded;
                    });
                  },
                  child: RichText(
                    maxLines: isExpanded ? null : 2,
                    overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                    text: TextSpan(
                      text: '${requests[0].reqContents}',
                      style: WitHomeTheme.subtitle.copyWith(fontSize: 14),
                      children: [
                        TextSpan(
                          text: isExpanded ? ' [더보기]' : '<<<접기',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildTag('# 총 ${requests.length}건 견적 도착'),
                    _buildTag('# 하루 전'),
                  ],
                ),
              ],
            ),
          ),

          // 총 받은 견적
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            alignment: Alignment.centerLeft,
            child: Text("총 받은 견적 ${requests.length}개"),
          ),

          // 가로 스크롤 견적 목록
          // 2025-04-02: index별 백그라운드 이미지 적용 및 오버레이 추가
          Container(
            color: Colors.white,
            height: MediaQuery.of(context).size.height * 0.28,
            padding: const EdgeInsets.all(13.0),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: requests.length,
              itemBuilder: (BuildContext context, int index) {
                final request = requests[index];
                final isSelected = _selectedRequest == request;
                String companyName = request.companyNm.length > 8
                    ? request.companyNm.substring(0, 8) + '...'
                    : request.companyNm;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedRequest = request;
                    });
                  },
                  child: Container(
                    height: MediaQuery.of(context).size.width * 0.35,
                    width: MediaQuery.of(context).size.width * 0.35,
                    margin: const EdgeInsets.symmetric(horizontal: 8.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        color: isSelected ? WitHomeTheme.wit_black : Colors.grey,
                        width: isSelected ? 2.0 : 1.0,
                      ),
                      image: DecorationImage(
                        image: AssetImage('assets/home/request${index + 1}.png'),
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                      ),
                    ),
                    child: Container(
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Stack(
                        children: [
                          // 🔹 텍스트 내용 전체 영역
                          Padding(
                            padding: const EdgeInsets.only(bottom: 40.0), // 하단 아이콘 공간 확보
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  companyName,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 10.0),

                                _buildTag('# 견적 ${request.estimateAmount.isEmpty || request.estimateAmount == "-" ? '-' : FormatUtils.formatCurrency(request.estimateAmount) + ' 원'}'),
                                SizedBox(height: 10.0),
                                _buildTag('# 시공건수 11건'),
                                SizedBox(height: 10.0),
                                _buildTag('# A/S 가능'),
                              ],
                            ),
                          ),

                          // 🔹 왼쪽 하단: 별점 + 인증 아이콘
                          Positioned(
                            bottom: 0,
                            left: 0,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ⭐️ 별 + 평점 한 줄
                                Row(
                                  children: [
                                    Image.asset('assets/home/star.png', width: 16, height: 16),
                                    SizedBox(width: 4.0),
                                    Text(
                                      '${request.rate}',
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4), // 별점과 인증 사이 간격
                                // ✅ 인증완료 아이콘
                                Image.asset(
                                  'assets/home/confirmok.png',
                                  height: 13,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // 구분선
          Container(
            color: Colors.white,
            child: Divider(
              thickness: 1,
              color: Colors.black,
            ),
          ),

          // 상세 내용
          Expanded(
            child: Container(
              color: Colors.white,
              child: SingleChildScrollView(
                child: _buildRequestDetail(_selectedRequest ?? requests.first), // 2025-04-02: 선택된 견적 보여주도록 수정

              ),
            ),
          ),

        ],
      ),
    );
  }

  /**
   * 테두리 글씨
   */
  Widget _buildTag(String text) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/home/estimateback_detail1.png'),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 9,
          color: Colors.black,
          fontWeight: FontWeight.normal,
          shadows: [
            Shadow(
              offset: Offset(0.5, 0.5),
              blurRadius: 2,
              color: Colors.black26,
            ),
          ],
        ),
      ),
    );
  }

  /**
   * 최하단 상세보기
   */
  Widget _buildRequestDetail(RequestInfo request) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔹 상단: 프로필 + 업체명 + 견적 금액
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage('https://picsum.photos/200'),
                    backgroundColor: Color(0xFFF2F2F2),
                    onBackgroundImageError: (error, stackTrace) {
                      print('이미지 로드 실패: $error');
                    },
                  ),
                  SizedBox(width: 8),
                  Text(
                    '${request.companyNm}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  request.estimateAmount.isEmpty || request.estimateAmount == "-"
                      ? '견적 금액: -'
                      : '견적 금액: ${FormatUtils.formatCurrency(request.estimateAmount)}',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),

          SizedBox(height: 10),

          /// 🔹 견적 설명 제목 + 내용 + 더보기
          Text(
            '견적 설명',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 6),
          LayoutBuilder(
            builder: (context, constraints) {
              final textSpan = TextSpan(
                text: request.estimateContents,
                style: TextStyle(fontSize: 14, color: Colors.black87),
              );

              final textPainter = TextPainter(
                text: textSpan,
                maxLines: 2,
                textDirection: Directionality.of(context), // ✅ 현재 앱의 방향 가져오기
              )..layout(maxWidth: constraints.maxWidth);

              final isOverflowing = textPainter.didExceedMaxLines;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
                child: Text(
                      () {
                    final content = request.estimateContents;
                    if (isExpanded) {
                      return '$content [접기]';
                    } else if (content.length > 20) {
                      return '${content.substring(0, 20)}... [더보기]';
                    } else {
                      return content;
                    }
                  }(),
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
              );
            },
          ),

          SizedBox(height: 20),

          /// 🔹 진행 요청 버튼 + 메시지 버튼
          Row(
            children: [
              // 왼쪽: 진행 요청 버튼
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: request.reqState == '02'
                        ? () => _handleRequestAction(request)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      '진행 요청',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ),

              SizedBox(width: 8),

              // 오른쪽: 메시지 아이콘 박스
              Container(
                width: 42,
                height: 42,
                child: Center(
                  child: Image.asset(
                    'assets/home/message.png',
                    width: 40,
                    height: 40,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 2025.04.16: 진행 요청 시 updateRequestState 호출 후 EstimateScreen 이동 처리
  // 2025.04.16: 진행 요청 시 updateRequestState 호출 후 CustomChatScreen 이동 처리
  // 2025.04.16: 진행 요청 시 updateRequestState 호출 후 CustomChatScreen 이동 처리
  void _handleRequestAction(RequestInfo request) async {
    String? clerkNo = await secureStorage.read(key: 'clerkNo'); // 🔹 스토리지에서 clerkNo 읽기

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          title: Text(
            '작업 진행',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            '${request.companyNm} 업체에 작업을 진행하시겠습니까?',
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onPressed: () async {
                Navigator.pop(context); // 다이얼로그 닫기

                /// ✅ Chat 화면으로 이동
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => CustomChatScreen(
                      '1',                    // chatId
                      clerkNo ?? '',          // clerkNo (스토리지에서 가져옴)
                      request.companyNm,      // 세 번째 인자 예: 업체 이름
                    ),
                  ),
                );
              },
              child: const Text(
                '확인',
                style: TextStyle(color: Colors.white),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                '취소',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}

// 2025-03-25 추가: SectionWidget에서 사용하는 데이터 클래스
class ListItem {
  final String categoryId;
  final String reqNo;
  final String reqContents;
  final List<RequestInfo> receivedEstimates;

  ListItem({
    required this.categoryId,
    required this.reqNo,
    required this.reqContents,
    required this.receivedEstimates,
  });
}

