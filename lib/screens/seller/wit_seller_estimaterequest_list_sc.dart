import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:witibju/screens/seller/wit_seller_estimaterequest_detail_sc.dart';
import '../../util/wit_api_ut.dart';
import 'package:witibju/screens/home/wit_home_theme.dart';

import '../chat/CustomChatScreen.dart';


class EstimateRequestList extends StatefulWidget {
  final String stat; // stat을 멤버 변수로 추가
  final String sllrNo; // sllrNo를 멤버 변수로 추가

  const EstimateRequestList({Key? key, required this.stat, required this.sllrNo}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return EstimateRequestListState();
  }
}

class EstimateRequestListState extends State<EstimateRequestList> {
  List<dynamic> estimateRequestList = [];
  bool isLoading = true; // 로딩 상태 추가

  @override
  void initState() {
    super.initState();
    // 견적리스트 조회
    getEstimateRequestList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 배경색을 흰색으로 설정
      body: isLoading // 로딩 상태에 따라 다르게 표시
          ? Center(child: CircularProgressIndicator()) // 로딩 인디케이터 표시
          : SingleChildScrollView( // 스크롤 가능하게 설정
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (estimateRequestList.isNotEmpty) ...[
              // 리스트가 비어있지 않을 경우
              ...estimateRequestList.map((request) {
                return buildEstimateItem(request, context);
              }).toList(),
            ] else ...[
              // 리스트가 비어있을 경우
              Container(
                height: MediaQuery.of(context).size.height - 100, // 여유 공간 설정
                child: Center( // Center 위젯으로 텍스트 중앙 정렬
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.40,  // 화면 높이의 18%
                    width: MediaQuery.of(context).size.width * 0.85,    // 화면 너비의 85%
                    child: Image.asset(
                      'assets/images/조회된 내용 (1).png', // 광고 이미지 URL
                      fit: BoxFit.contain, // 이미지 비율 유지
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget buildEstimateItem(dynamic request, BuildContext context) {
    return EstimateItem(
      request: request,
      sllrNo: widget.sllrNo,
      onExpandToggle: (bool isExpanded) {
        setState(() {
          request['isExpanded'] = isExpanded; // 상태를 업데이트
        });
      },
    );
  }

  // [서비스] 견적리스트 조회
  Future<void> getEstimateRequestList() async {
    // REST ID
    String restId = "getEstimateRequestList";
    print('sllrNo: ' + widget.sllrNo);
    print('stat: ' + widget.stat);

    // PARAM
    final param = jsonEncode({
      "stat": widget.stat, // stat을 사용하여 API에 전달
      "sllrNo": widget.sllrNo,
      // "reqGubun" : ""
    });

    // API 호출 (사전 점검 미완료 리스트 조회)
    final _estimateRequestList = await sendPostRequest(restId, param);

    // 결과 셋팅
    setState(() {
      estimateRequestList = _estimateRequestList;
      isLoading = false; // 로딩 상태 종료
    });
  }
}

class EstimateItem extends StatelessWidget {
  final Map<String, dynamic> request;
  final String sllrNo;
  final ValueChanged<bool> onExpandToggle;

  EstimateItem({required this.request, required this.sllrNo, required this.onExpandToggle});

  @override
  Widget build(BuildContext context) {
    bool isExpanded = request['isExpanded'] ?? false; // 상세보기 상태 관리
    String reqContents = request['reqContents'] ?? '내용 없음'; // 내용
    String itemName = request['itemName'] ?? '품목 없음'; // 내용

    // 내용이 3줄 이상인지 확인
    bool hasMoreThanThreeLines = (reqContents.split('\n').length > 3);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8), // 카드 간의 간격 설정
      decoration: BoxDecoration(
        color: Colors.grey[100], // 카드 배경색
        borderRadius: BorderRadius.circular(8), // 모서리 둥글게
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3), // 그림자 위치
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16), // 내부 여백 추가
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
          children: [
            Row(
              children: [
                // 왼쪽에 사진
                Container(
                  width: 50,
                  height: 50, // 이미지 높이 설정
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25), // 둥근 프로필 사진
                    image: DecorationImage(
                      image: AssetImage('assets/images/profile1.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: 10), // 이미지와 텍스트 사이의 간격 추가
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 날짜를 이름 위로 배치
                      Text(
                        request['estDt'] ?? '', // 날짜
                        style: WitHomeTheme.title.copyWith(fontSize: 12, color: WitHomeTheme.wit_gray),
                      ),
                      SizedBox(height: 4), // 날짜와 이름 사이의 간격
                      Text(
                        request['prsnName'] ?? '요청자명 없음', // 요청자명
                        style: WitHomeTheme.title.copyWith(fontSize: 18),
                      ),
                      SizedBox(height: 1), // 이름과 아파트명 사이의 간격
                      Text(
                        request['aptName'] ?? '', // 아파트명
                        style: WitHomeTheme.title.copyWith(fontSize: 12, color: WitHomeTheme.wit_gray),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 10), // 상태 텍스트와의 간격
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 상태 텍스트
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EstimateRequestDetail(
                              estNo: request['estNo'],
                              seq: request['seq'],
                              sllrNo: sllrNo,
                            ),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        ),
                      ),
                      child: Text(
                        request['stat'] ?? '',
                        style: WitHomeTheme.title.copyWith(fontSize: 14, color: WitHomeTheme.wit_lightBlue),
                      ),
                    ),

                    // stat이 10이나 20이 아니면 메시지 보기 버튼 보여주기
                    if (request['reqState'] != "10" && request['reqState'] != "20")
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CustomChatScreen(
                                request["estNo"], // 첫 번째 인자: 요청 번호
                                request["seq"], // 두 번째 인자: 시퀀스 (chatId)
                                "sellerView", // 세 번째 인자: 뷰 타입
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(50, 36),
                          backgroundColor: WitHomeTheme.wit_lightGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          '메시지 보기',
                          style: WitHomeTheme.subtitle.copyWith(fontSize: 12, color: Colors.white),
                        ),
                      ),
                  ],
                ),

              ],
            ),
            SizedBox(height: 10), // 텍스트와 내용 사이의 간격
            GestureDetector(
              onTap: () {
                onExpandToggle(!isExpanded);
              },
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final textStyle = WitHomeTheme.subtitle.copyWith(fontSize: 14);
                  final textSpan = TextSpan(text: reqContents, style: textStyle);

                  final textPainter = TextPainter(
                    text: textSpan,
                    maxLines: 3,
                    textDirection: TextDirection.ltr,
                  )..layout(maxWidth: constraints.maxWidth);

                  final bool isLong = textPainter.didExceedMaxLines;

                  return Container(
                    width: double.infinity, // ✅ 너비 고정
                    padding: const EdgeInsets.all(12),
                    constraints: const BoxConstraints(
                      minHeight: 70, // ✅ 최소 높이 고정
                      minWidth: double.infinity, // ✅ 너비 유지
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ✅ itemName 텍스트 추가
                        Text(
                          "요청품목 : " + itemName,
                          style: textStyle.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 6), // 간격 추가
                        Text(
                          reqContents,
                          style: textStyle,
                          textAlign: TextAlign.left,
                          maxLines: isExpanded ? null : 3,
                          overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                        ),
                        if (!isExpanded && isLong)
                          const SizedBox(height: 4),
                        if (!isExpanded && isLong)
                          Text(
                            '... 더보기',
                            style: textStyle.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[500],
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),


          ],
        ),
      ),
    );
  }
}
