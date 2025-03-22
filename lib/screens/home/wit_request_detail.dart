import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:witibju/screens/home/widgets/wit_home_widgets2.dart';
import 'package:witibju/screens/home/wit_home_theme.dart';
import '../../util/wit_code_ut.dart';
import '../chat/chatMain.dart';
import 'models/requestInfo.dart';

class RequestDetailScreen extends StatefulWidget {
  final List<RequestInfo> requests;
  final RequestInfo? selectedRequest;
  final String categoryName;

  const RequestDetailScreen({
    Key? key,
    required this.requests,
    this.selectedRequest,
    required this.categoryName,
  }) : super(key: key);

  @override
  State<RequestDetailScreen> createState() => _RequestDetailScreenState();
}

class _RequestDetailScreenState extends State<RequestDetailScreen> {
  late RequestInfo _selectedRequest;

  @override
  void initState() {
    super.initState();
    // 기본 선택된 요청 설정
    _selectedRequest = widget.selectedRequest ?? widget.requests.first;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: WitHomeTheme.white,
        title: Text(widget.categoryName), // AppBar에 categoryName 표시
      ),
      body: Column(
        children: [
          // 헤더: 총 받은 견적
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            alignment: Alignment.centerLeft,
            child: Text("총 받은 견적 ${widget.requests.length}개"),
          ),
          // 선택 가능한 견적 목록 (가로 스크롤)
          Container(
            color: Colors.white,
            height: MediaQuery.of(context).size.height * 0.12,
            padding: const EdgeInsets.all(13.0),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.requests.length,
              itemBuilder: (BuildContext context, int index) {
                final request = widget.requests[index];
                final isSelected = _selectedRequest == request;
                String companyName = request.companyNm.length > 8
                    ? request.companyNm.substring(0, 8) + '...'
                    : request.companyNm;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedRequest = request; // 선택된 요청 업데이트
                    });
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.3,
                    margin: const EdgeInsets.symmetric(horizontal: 8.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        color: isSelected ? Color(0xFFAFCB54) : Colors.grey,
                        width: isSelected ? 2.0 : 1.0,
                      ),
                      color: Colors.white,
                    ),
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // 이미지 표시
                        CircleAvatar(
                          radius: 16.0, // 이미지 크기
                          backgroundImage: NetworkImage(apiUrl + '${request.imageFilePath}'),
                          onBackgroundImageError: (error, stackTrace) {
                            print('이미지 로드 실패: $error'); // 오류 처리
                          },
                          backgroundColor: Colors.grey[200], // 이미지 로드 실패 시 배경색
                        ),
                        SizedBox(width: 8.0), // 이미지와 텍스트 사이 간격
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 회사명 표시
                              Text(
                                companyName,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                                overflow: TextOverflow.ellipsis, // 텍스트 길이가 길면 말줄임표 처리
                              ),
                              SizedBox(height: 10.0),
                              // 금액 표시
                              Text(
                                request.estimateAmount.isEmpty || request.estimateAmount == "-"
                                    ? '견적 금액: -'
                                    : '견적 금액: ${FormatUtils.formatCurrency(request.estimateAmount)} 원',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            color: Colors.white, // 구분선의 배경색을 흰색으로 설정
            child: Divider(
              thickness: 1,
              color: Colors.black, // 구분선 자체의 색 (원하는 색으로 변경 가능)
            ),
          ),
          // 상세 정보
          Expanded(
            child: Container( // Container로 감싸고 배경색 추가
              color: Colors.white, // 배경색을 흰색으로 설정
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildRequestDetail(_selectedRequest),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestDetail(RequestInfo request) {

    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [

              CircleAvatar(
                radius: 24.0, // 이미지 크기
                backgroundImage: NetworkImage(apiUrl + '${request.imageFilePath}'),
                onBackgroundImageError: (error, stackTrace) {
                  print('이미지 로드 실패: $error'); // 오류 처리
                },
                backgroundColor: Colors.grey[200], // 이미지 로드 실패 시 배경색
              ),
              SizedBox(width: 8.0), // 이미지와 텍스트 사이 간격
              Text(
                '${request.companyNm}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 4.0),
              Image.asset(
                'assets/images/star.png',
                width: 16.0,
                height: 16.0,
              ),
              SizedBox(width: 4.0),
              Text('${request.rate}', style: TextStyle(fontSize: 16)),
            ],
          ),
          SizedBox(height: 8.0),
          Text(
            request.estimateAmount.isEmpty || request.estimateAmount == "-"
                ? '견적 금액: -'
                : '견적 금액: ${FormatUtils.formatCurrency(request.estimateAmount)} 원',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.0),

          // "견적 설명" 문구 추가
          Text(
            "견적 설명",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.0),

          // 견적 내용을 텍스트로 표시
          Text(
            request.estimateContents,
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          SizedBox(height: 16.0),

          // 상태 버튼 추가 (크기 키움)
          Center(
            child: SizedBox(
              width: double.infinity, // 버튼 너비를 화면 너비로 설정
              height: 50.0, // 버튼 높이를 늘림
              child: ElevatedButton(
                onPressed: request.reqState == '02'
                    ? () {
                  _handleRequestAction(request);
                }
                    : null, // 다른 상태에서는 비활성화
                style: ElevatedButton.styleFrom(
                  backgroundColor: request.reqState == '02' ? Color(0xFFAFCB54) : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text(
                  '${request.reqStateNm}',
                  style: TextStyle(color: Colors.white, fontSize: 16), // 버튼 글자 크기 키움
                ),
              ),
            ),
          ),
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChatPage()),
                );
              },
              child: Text(
                "메시지 대화하기",
                style: TextStyle(color: Colors.blue),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, // 기존 'primary'를 'backgroundColor'로 변경
                side: BorderSide(color: Colors.blue),
              ),
            ),
          ),
        ],
      ),
    );
  }




  void _handleRequestAction(RequestInfo request) {
    // 예시: 요청 상태를 업데이트하거나 추가 작업을 수행
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('작업 진행'),
          content: Text('${request.companyNm} 업체에 작업을 진행하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                // 작업 진행 로직
                Navigator.pop(context); // 다이얼로그 닫기
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('작업이 진행되었습니다.')),
                );
              },
              child: Text('확인'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // 다이얼로그 닫기
              },
              child: Text('취소'),
            ),
          ],
        );
      },
    );
  }

}
