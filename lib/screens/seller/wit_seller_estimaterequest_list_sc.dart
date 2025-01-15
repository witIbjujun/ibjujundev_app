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
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: estimateRequestList.map((request) {
          return buildEstimateItem(request, context);
        }).toList(),
      ),
    );
  }

  Widget buildEstimateItem(dynamic request, BuildContext context) {
    return EstimateItem(request: request, sllrNo: widget.sllrNo); // EstimateItem 위젯 사용
  }

  // [서비스] 견적리스트 조회
  Future<void> getEstimateRequestList() async {
    // REST ID
    String restId = "getEstimateRequestList";
    print('sllrNo123123123: ' + widget.sllrNo);
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

class EstimateItem extends StatefulWidget {
  final dynamic request;
  final String sllrNo;

  EstimateItem({required this.request, required this.sllrNo});

  @override
  _EstimateItemState createState() => _EstimateItemState();
}

class _EstimateItemState extends State<EstimateItem> {
  bool _isExpanded = false; // 상세보기 상태 관리

  @override
  Widget build(BuildContext context) {
    String reqContents = widget.request['reqContents'] ?? '내용 없음'; // 내용

    // 내용이 3줄 이상인지 확인
    bool hasMoreThanThreeLines = (reqContents.split('\n').length > 3);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            widget.request['estDt'],
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ), // 날짜
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Text(
                    widget.request['aptName'], // 아파트명
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(width: 8), // 아파트명과 이름 사이의 간격
                  Text(
                    widget.request['prsnName'] ?? '요청자명 없음', // null 체크 추가
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () {
                // 견적 요청 관련 작업 추가
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EstimateRequestDetail(
                      estNo: widget.request['estNo'],
                      seq: widget.request['seq'],
                      sllrNo: widget.sllrNo,
                    ),
                  ),
                );
              },
              child: Icon(
                Icons.edit_note, // 원하는 아이콘으로 변경 가능
                size: 24, // 아이콘 크기 설정 (필요에 따라 조정)
                color: widget.request['reqState'] == '01' ? Colors.black : Colors.black, // 글자색
              ),
              splashColor: Colors.grey.withOpacity(0.2), // 클릭 시 스플래시 효과
              highlightColor: Colors.transparent, // 클릭 시 하이라이트 색상
            ),
          ],
        ),
        SizedBox(height: 1),
        Row(
          children: [
            // 사진과 방충망 텍스트
            Column(
              children: [
                Container(
                  width: 50,
                  height: 50, // 이미지 높이 설정
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8), // 모서리 둥글게
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8), // 모서리 둥글게
                    child: Image.asset(
                      widget.request['itemImage'], // 광고 이미지 URL
                      fit: BoxFit.cover, // 이미지가 Container를 채우도록 설정
                      errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                        // 이미지 로드 실패 시 대체 텍스트 표시
                        return Center(child: Text('사진 로드 실패'));
                      },
                    ),
                  ),
                ),
                SizedBox(height: 4), // 이미지와 텍스트 사이의 간격
                Text(
                  widget.request['categoryNm'], // 품목명
                  style: TextStyle(fontSize: 12, color: Colors.black), // 텍스트 스타일 설정
                ),
              ],
            ),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                children: [
                  Container(
                    color: Colors.green[100], // 연한 회색 배경색 설정
                    padding: EdgeInsets.all(8), // 내부 여백 추가
                    constraints: BoxConstraints(
                      minHeight: 60, // 최소 높이 설정 (3줄 정도의 높이)
                    ),
                    child: Center(
                      child: Text(
                        reqContents, // 내용
                        style: TextStyle(fontSize: 14),
                        textAlign: TextAlign.center, // 텍스트 중앙 정렬
                        maxLines: _isExpanded ? null : 3, // 기본 3줄 표시
                        overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis, // 줄 넘침 처리
                      ),
                    ),
                  ),
                  // 내용이 비어있지 않고 3줄 이상일 경우에만 버튼 표시
                  if (hasMoreThanThreeLines)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isExpanded = !_isExpanded; // 상세보기 상태 토글
                        });
                      },
                      child: Text(
                        _isExpanded ? '접기' : '상세보기', // 버튼 텍스트 변경
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 16), // 항목 간의 간격 추가
      ],
    );
  }
}
