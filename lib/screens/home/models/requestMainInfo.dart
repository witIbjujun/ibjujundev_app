class RequestMainInfo {
  RequestMainInfo({
    this.reqNo = '',
    this.reqGubun = '',
    this.reqDate = '',
    this.type = '',
    this.mainReqName = '',
    this.categoryNm = '',
    this.reqContents = '',
    this.categoryId = '',
    this.estimateCount = '',

  });

  String reqNo;
  String reqGubun;
  String reqDate;
  String type;
  String mainReqName;
  String categoryNm;
  String reqContents;
  String categoryId;
  String estimateCount;


  // JSON 데이터를 받아 RequestInfo 리스트로 변환하는 함수
  List<RequestMainInfo>? parseMainRequestList(List<dynamic> rquestMainInfoList) {
    return rquestMainInfoList.map((requestMainInfo) {
      return RequestMainInfo(
        reqNo: requestMainInfo['reqNo'] ?? '',
        reqGubun: requestMainInfo['reqGubun'] ?? '',
        reqDate: requestMainInfo['reqDate'] ?? '',
        type: requestMainInfo['type'] ?? '',
        mainReqName: requestMainInfo['mainReqName'] ?? '',
        categoryNm: requestMainInfo['categoryNm'] ?? '',
        reqContents: requestMainInfo['reqContents'] ?? '',
        categoryId: requestMainInfo['categoryId'] ?? '',
        estimateCount: requestMainInfo['estimateCount'] ?? '',

      );
    }).toList();
  }
}
