class RequestInfo {
  RequestInfo({
    this.reqNo = '',
    this.reqGubun = '',
    this.reqDate = '',
    this.reqDateInfo = '',
    this.reqStateNm = '',
    this.reqState = '',
    this.companyId = '',
    this.categoryId = '',
    this.categoryNm = '',
    this.companyNm = '',
    this.rate = '',
    this.reqContents = '',
    this.inProgress = '',
    this.timeAgo = '',
    this.estimateAmount = '',
    this.estimateContents = '',
    this.companyCnt = '',
    this.imageFilePath = '',
    this.seq = '',
    this.formatReqNo = '',
    this.selCategoryNm = '',
    this.estimateDate = '',
    this.receivedEstimates = const [], // 🔹 기본값을 빈 리스트([])로 설정하여 null 방지
  });

  String reqNo;
  String formatReqNo;
  String reqGubun;
  String reqDate;
  String reqDateInfo;
  String inProgress;
  String reqStateNm;
  String reqState;
  String companyId;
  String categoryId;
  String categoryNm;
  String rate;
  String companyNm;
  String reqContents;
  String timeAgo;
  String estimateAmount;
  String estimateContents;
  String imageFilePath;
  String seq;
  String companyCnt;
  String estimateDate;
  String selCategoryNm;

  List<EstimateItem> receivedEstimates; // 🔹 필수 필드 추가

  // JSON 데이터를 받아 RequestInfo 리스트로 변환하는 함수
  List<RequestInfo>? parseRequestList(List<dynamic> rquestInfoList) {
    return rquestInfoList.map((requestInfo) {
      return RequestInfo(
        reqNo: requestInfo['reqNo'] ?? '',
        formatReqNo: requestInfo['formatReqNo'] ?? '',
        reqGubun: requestInfo['reqGubun'] ?? '',
        reqDate: requestInfo['reqDate'] ?? '',
        reqDateInfo: requestInfo['reqDateInfo'] ?? '',
        reqStateNm: requestInfo['reqStateNm'] ?? '',
        reqState: requestInfo['reqState'] ?? '',
        companyId: requestInfo['companyId'] ?? '',
        categoryId: requestInfo['categoryId'] ?? '',
        categoryNm: requestInfo['categoryNm'] ?? '',
        companyNm: requestInfo['companyNm'] ?? '',
        inProgress: requestInfo['inProgress'] ?? '',
        rate: requestInfo['rate'] ?? '',
        seq: requestInfo['seq'] ?? '',
        timeAgo: requestInfo['timeAgo'] ?? '',
        imageFilePath: requestInfo['imageFilePath'] ?? '',
        companyCnt: requestInfo['companyCnt'] ?? '',
        estimateAmount: requestInfo['estimateAmount'] ?? '',
        estimateContents: requestInfo['estimateContents'] ?? '',
        reqContents: requestInfo['reqContents'] ?? '',
        estimateDate: requestInfo['estimateDate'] ?? '',
        selCategoryNm: requestInfo['selCategoryNm'] ?? '',
        receivedEstimates: (requestInfo['receivedEstimates'] as List<dynamic>?)?.map((e) => EstimateItem.fromJson(e)).toList() ?? [], // 🔹 데이터 파싱 추가
      );
    }).toList();
  }
}

// 🔹 EstimateItem 모델 추가 (받은 견적 데이터 모델)
class EstimateItem {
  final String companyNm;
  final String estimateAmount;
  final String rate;

  EstimateItem({
    required this.companyNm,
    required this.estimateAmount,
    required this.rate,
  });

  // JSON에서 데이터를 변환하는 팩토리 생성자 추가
  factory EstimateItem.fromJson(Map<String, dynamic> json) {
    return EstimateItem(
      companyNm: json['companyNm'] ?? '',
      estimateAmount: json['estimateAmount'] ?? '',
      rate: json['rate'] ?? '',
    );
  }
}
