class GonguInfo {
  GonguInfo({
    this.categoryId = '',
    this.categoryNm = '',
    this.detail = '',
    this.imagePath = '',
    this.gpStartDate = '',
    this.gpEndDate = '',
    this.gpStat = '',
    this.limitCount = '',
    this.reqCount = '',
    this.saleRate = '',
    this.reqState = '',
    this.saleAmt = '',
  });

  String categoryId;
  String categoryNm;
  String detail;
  String imagePath;
  String gpStartDate;
  String gpEndDate;
  String gpStat;
  String limitCount;
  String reqCount;
  String saleRate;
  String saleAmt;
  String reqState;

  // JSON 데이터를 받아 RequestInfo 리스트로 변환하는 함수
  List<GonguInfo>? parseRequestList(List<dynamic> gonguInfoList) {
    return gonguInfoList.map((gonguInfo) {
      return GonguInfo(
        categoryId: gonguInfo['categoryId'] ?? '',
        categoryNm: gonguInfo['categoryNm'] ?? '',
        detail: gonguInfo['detail'] ?? '',
        imagePath: gonguInfo['imagePath'] ?? '',
        gpStartDate: gonguInfo['gpStartDate'] ?? '',
        gpEndDate: gonguInfo['gpEndDate'] ?? '',
        gpStat: gonguInfo['gpStat'] ?? '',
        limitCount: gonguInfo['limitCount'] ?? '',
        reqCount: gonguInfo['reqCount'] ?? '',
        saleRate: gonguInfo['saleRate'] ?? '',
        saleAmt: gonguInfo['saleAmt'] ?? '',
        reqState: gonguInfo['reqState'] ?? '',
      );
    }).toList();
  }
}


