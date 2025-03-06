import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:witibju/screens/seller/wit_seller_estimaterequest_detail_sc.dart';
import '../../util/wit_api_ut.dart';

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

  @override
  void initState() {
    super.initState();
    // 견적리스트 조회
    getEstimateRequestList();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView( // 스크롤 가능하게 설정
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: estimateRequestList.map((request) {
          return buildEstimateItem(request, context);
        }).toList(),
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
    });

    // API 호출 (사전 점검 미완료 리스트 조회)
    final _estimateRequestList = await sendPostRequest(restId, param);

    // 결과 셋팅
    setState(() {
      estimateRequestList = _estimateRequestList;
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

    // 내용이 3줄 이상인지 확인
    bool hasMoreThanThreeLines = (reqContents.split('\n').length > 3);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8), // 카드 간의 간격 설정
      decoration: BoxDecoration(
        color: Colors.grey[200], // 회색 배경
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // 양 끝 정렬
              children: [
                // 왼쪽에 사진
                Container(
                  width: 50,
                  height: 50, // 이미지 높이 설정
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8), // 모서리 둥글게
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8), // 모서리 둥글게
                    child: Image.asset(
                      request['itemImage'], // 광고 이미지 URL
                      fit: BoxFit.cover, // 이미지가 Container를 채우도록 설정
                      errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                        // 이미지 로드 실패 시 대체 텍스트 표시
                        return Center(child: Text('사진 로드 실패'));
                      },
                    ),
                  ),
                ),
                SizedBox(width: 8), // 사진과 텍스트 사이의 간격
                // 오른쪽 텍스트
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween, // 양 끝 정렬
                        children: [
                          Text(
                            request['estDt'], // 날짜
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
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
                              padding: EdgeInsets.zero, // 패딩 제거
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap, // 버튼 크기 조정
                            ),
                            child: Text(
                              request['stat'],
                              style: TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.bold), // 버튼 글씨 스타일
                            ),
                          ),
                        ],
                      ),
                      Text(
                        request['prsnName'] ?? '요청자명 없음', // 요청자명
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        request['aptName'], // 아파트명
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8), // 텍스트와 내용 사이의 간격
            Align(
              alignment: Alignment.centerLeft, // 왼쪽 정렬
              child: Text(
                reqContents, // 내용
                style: TextStyle(fontSize: 16, color: Colors.blueAccent), // 파란색 글씨
                textAlign: TextAlign.left, // 텍스트 왼쪽 정렬
                maxLines: isExpanded ? null : 3, // 기본 3줄 표시
                overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis, // 줄 넘침 처리
              ),
            ),
            // 내용이 비어있지 않고 3줄 이상일 경우에만 버튼 표시
            if (hasMoreThanThreeLines)
              Container(
                width: double.infinity, // 버튼을 가로로 꽉 차게 설정
                child: TextButton(
                  onPressed: () {
                    onExpandToggle(!isExpanded); // 상세보기 상태 토글
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Color(0xFFAFCB54), // 연두색 배경
                    foregroundColor: Colors.white, // 글자색을 하얀색으로 설정
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16), // 패딩 추가
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), // 둥근 모서리
                    ),
                  ),
                  child: Text(
                    isExpanded ? '접기' : '상세보기', // 버튼 텍스트 변경
                  ),
                ),
              ),
            SizedBox(height: 16), // 항목 간의 간격 추가
          ],
        ),
      ),
    );
  }
}
