import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sms_autofill/sms_autofill.dart';
import 'package:witibju/screens/seller/wit_seller_profile_detail_sc.dart';
import '../../util/wit_api_ut.dart';
import 'package:kpostal/kpostal.dart';

import '../../util/wit_code_ut.dart';
import '../common/wit_ImageViewer_sc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:witibju/screens/home/wit_home_theme.dart';
import 'package:witibju/screens/seller/wit_seller_profile_appbar_sc.dart';

class SellerProfileView extends StatefulWidget {
  final dynamic sllrNo;

  const SellerProfileView({Key? key, required this.sllrNo}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SellerProfileViewState();
  }
}

class SellerProfileViewState extends State<SellerProfileView> {
  dynamic sellerInfo;
  String storeName = "";
  String serviceArea = "";
  String serviceItem = "";
  String itemPrice1 = "";
  String sllrContent = "";
  String categoryContent = "";
  String sllrImage = "";
  String name = "";
  String ceoName = "";
  String email = "";
  String openDate = "";
  String storeCode = "";
  String storeImage = "";
  String hp = "";
  String zipCode = "";
  String address1 = "";
  String address2 = "";
  String asGbn = "";
  String bizCertification = "";
  String selectedServiceWithAsPeriodCd = "";
  List<dynamic> storeImageList = [];
  String buttonText = "인증요청";

  /* 이미지추가 S */
  List<File> _images = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImages(ImageSource source) async {
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _images =
            pickedFiles.map((pickedFile) => File(pickedFile.path)).toList();
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _images.add(File(pickedFile.path));
      });
    }
  }

  /* 이미지추가 E */

  @override
  void initState() {
    /*Firebase.initializeApp().whenComplete(() {
      print("completed");
      setState(() {});
    });*/
    super.initState();
    getSellerInfo(widget.sllrNo);
  }

  /*Future<void> getSellerInfo(dynamic sllrNo) async {
    // API 호출 로직 (여기서는 가상의 데이터 사용)
    setState(() {
      sellerInfo = {
        'storeName': '친절한 사장',
        'businessImage': 'https://via.placeholder.com/150', // 사업자 이미지
        'businessCertification': '사업자 인증중',
        'bestRecommendation': 'Best 추천',
        'serviceItems': '미세방향망, 냉방 방충망, 고양이망',
        'servicePeriod': '2년 무상 AS',
        'location': '서울시 영동포구 / 경기도 일대',
        'description': '12년 경력의 전문 업체입니다. 고객님께 최선을 다하겠습니다.',
        'photos': [
          '/WIT/8399af87-e59d-4e28-980f-255508c2f27e8655804894939968359.jpg',
          */ /*'https://via.placeholder.com/100',
          'https://via.placeholder.com/100'*/ /*
        ],
        'reviews': '소중한 리뷰 감사합니다! 모든 부분 꼼꼼하게 체크하여 이상 있는 부분은 꼭 저희한테 말씀해 주시는게 제일 좋은 방법입니다.',
        'rating': '⭐ 3.5'
      };
      storeName = sellerInfo['storeName'];
    });
  }*/

  Future<void> getSellerInfo(dynamic sllrNo) async {
    String restId = "getSellerInfo";
    // PARAM
    final param = jsonEncode({
      "sllrNo": sllrNo,
    });

    print("sllrNo :" + sllrNo.toString());

    // API 호출
    final response = await sendPostRequest(restId, param);

    if (response != null) {
      setState(() {
        sellerInfo = response;

        // 기본값 설정 및 null 체크
        storeName = sellerInfo['storeName'] ?? '';
        storeNameController.text = storeName;

        serviceArea = sellerInfo['serviceArea'] ?? '';
        serviceItem = sellerInfo['serviceItem'] ?? '';
        asGbn = sellerInfo['asGbn'] ?? '';

        print("serviceItem : " + serviceItem);
        print("asGbn : " + asGbn);

        // 선택된 지역이 있으면 selectedLocations에 추가
        if (serviceArea.isNotEmpty) {
          var matchedArea = areaList.firstWhere(
            (area) => area['cd'] == serviceArea,
            orElse: () => {'cd': '', 'cdNm': ''}, // 매칭되는 값이 없을 경우 기본값 반환
          );

          // matchedArea가 기본값이 아닌 경우에만 추가
          if (matchedArea['cd'] != '') {
            selectedLocations.add(matchedArea); // 매칭된 지역 코드 추가
          }
        }

        // 선택된 서비스 항목과 AS 기간을 매칭하여 추가
        if (serviceItem.isNotEmpty) {
          var matchedServiceItem = categoryList.firstWhere(
            (category) => category['categoryId'] == serviceItem,
            orElse: () =>
                {'categoryId': '', 'categoryNm': ''}, // 기본값으로 빈 Map 반환
          );

          print("Matched matchedServiceItem: $matchedServiceItem");

          if (matchedServiceItem['categoryId'] != '') {
            String serviceName = matchedServiceItem['categoryNm'] ??
                'Unknown Service'; // null 체크 추가
            String serviceNameCd = matchedServiceItem['categoryId'] ??
                'Unknown Service'; // null 체크 추가
            // asGbn이 있을 경우 매칭하여 추가
            String combinedService = serviceName; // 기본값으로 서비스 이름 설정
            String combineCd = serviceNameCd;

            if (asGbn.isNotEmpty) {
              var matchedAsGbn = asList.firstWhere(
                (as) => as['cd'] == asGbn,
                orElse: () => {'cd': '', 'cdNm': ''}, // 기본값으로 빈 Map 반환
              );

              print("Matched asGbn: $matchedAsGbn");

              if (matchedAsGbn['cd'] != '') {
                String asName =
                    matchedAsGbn['cdNm'] ?? 'Unknown AS'; // null 체크 추가
                String asCd = matchedAsGbn['cd'] ?? 'Unknown AS'; // null 체크 추가
                combinedService += ' ($asName)'; // 예: "서비스 이름 (AS 기간)"
                combineCd += '/$asCd';
              }
            }

            // 최종 조합된 서비스 이름을 리스트에 추가
            selectedServiceWithAsPeriod.add(combinedService);
            selectedServiceWithAsPeriodCd = combineCd;
          }
        }

        // 나머지 필드 설정
        itemPrice1 = sellerInfo['itemPrice1'] ?? '';
        itemPrice1Controller.text = itemPrice1;

        sllrContent = sellerInfo['sllrContent'] ?? '';
        sllrContentController.text = sllrContent;

        categoryContent = sellerInfo['categoryContent'] ?? '';
        categoryContentController.text = categoryContent;

        name = sellerInfo['name'] ?? '';
        nameController.text = name;

        ceoName = sellerInfo['ceoName'] ?? '';
        ceoNameController.text = ceoName;

        email = sellerInfo['email'] ?? '';
        emailController.text = email;

        openDate = sellerInfo['openDate'] ?? '';
        openDateController.text = openDate;

        storeCode = sellerInfo['storeCode'] ?? '';
        storeCodeController.text = storeCode;

        hp = sellerInfo['hp'] ?? '';
        hp1Controller.text = hp;

        zipCode = sellerInfo['zipCode'] ?? '';
        receiverZipController.text = zipCode;

        address1 = sellerInfo['address1'] ?? '';
        receiverAddress1Controller.text = address1;

        address2 = sellerInfo['address2'] ?? '';
        receiverAddress2Controller.text = address2;

        buttonText = sellerInfo['bizCertificationNm'] != null &&
                sellerInfo['bizCertificationNm'].isNotEmpty
            ? sellerInfo['bizCertificationNm']
            : '인증요청';
        
        // 판매자 상세 이미지
        getSellerDetailImageList("SR01");
      });
    } else {
      // 오류 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("사업자 프로필 조회가 실패하였습니다.")),
      );
    }
  }

  TextEditingController storeNameController = TextEditingController();
  TextEditingController itemPrice1Controller = TextEditingController();
  TextEditingController itemPrice2Controller = TextEditingController();
  TextEditingController itemPrice3Controller = TextEditingController();
  TextEditingController sllrContentController = TextEditingController();
  TextEditingController sllrImageController = TextEditingController();
  TextEditingController categoryContentController = TextEditingController();

  //TextEditingController sllrImageController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController ceoNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController openDateController = TextEditingController();
  TextEditingController storeCodeController = TextEditingController();
  TextEditingController storeImageController = TextEditingController();
  TextEditingController hp1Controller = TextEditingController();
  TextEditingController hp2Controller = TextEditingController();
  TextEditingController hp3Controller = TextEditingController();
  TextEditingController zipCodeController = TextEditingController();

  TextEditingController receiverZipController = TextEditingController();
  TextEditingController receiverAddress1Controller = TextEditingController();
  TextEditingController receiverAddress2Controller = TextEditingController();

  final TextEditingController _smsController = TextEditingController();
  String? _verificationId;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<dynamic> selectedLocations = [];
  List<String> selectedServiceTypes = [];
  List<dynamic> selectedServiceWithAsPeriod = [];
  List<dynamic> selectedAsPeriods = []; // AS 기간 선택 변수 추가
  List<XFile>? _imageFiles = [];

  String? selectedLocation;
  String? selectedServiceType;
  String? selectedAsPeriod;

  // 샘플 이미지 경로
  final List<String> sampleImages = [
    'assets/seller/aaa.jpg',
    'assets/seller/aaa.jpg',
  ];

  List<dynamic> areaList = []; // 지역 정보를 담을 리스트
  List<dynamic> areaCd = [];
  List<dynamic> asList = []; // 지역 정보를 담을 리스트
  List<dynamic> asCd = [];
  List<dynamic> codeList = [];
  List<dynamic> categoryList = [];

  final TextEditingController generalPriceController = TextEditingController();
  final TextEditingController premiumPriceController = TextEditingController();
  final TextEditingController specialPriceController = TextEditingController();

  final TextEditingController contact1Controller = TextEditingController();
  final TextEditingController contact2Controller = TextEditingController();
  final TextEditingController contact3Controller = TextEditingController();
  final TextEditingController verificationCodeController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        /*appBar: SellerAppBar(
          sllrNo: widget.sllrNo,
        ),*/
        appBar: AppBar(
          backgroundColor: WitHomeTheme.wit_gray,
          iconTheme: const IconThemeData(color: WitHomeTheme.wit_white),
          title: Text(
            '파트너 프로필',
            style: WitHomeTheme.title.copyWith(color: WitHomeTheme.wit_white),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              // 첫 번째 영역: 사업자 이미지 및 이름, 인증 정보
              _buildCard(
                title: '업체명',
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start, // 수직 정렬을 위해 상단 정렬
                      children: [
                        // 사업자 이미지
                        Container(
                          width: 70,
                          height: 70, // 이미지 높이 설정
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8), // 모서리 둥글게
                          ),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: storeImageList.isNotEmpty ? 1 : 0, // 리스트가 비어있지 않은 경우 1로 설정
                            itemBuilder: (context, index) {
                              if (storeImageList.isEmpty) {
                                return Center(child: Text('이미지가 없습니다.')); // 이미지가 없을 때 표시할 위젯
                              }
                              return GestureDetector(
                                onTap: () {
                                  // 클릭 시 ImageViewer로 이동
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ImageViewer(
                                        imageUrls: storeImageList.map((item) => apiUrl + item["imagePath"]).toList(),
                                        initialIndex: 0, // 첫 번째 이미지를 항상 표시
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 70,
                                  height: 70,
                                  margin: EdgeInsets.only(right: 8), // 이미지 간격
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12), // 둥글게 처리
                                    image: DecorationImage(
                                      image: NetworkImage(apiUrl + storeImageList[0]["imagePath"]), // 첫 번째 이미지를 사용
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                        ),
                        SizedBox(width: 10), // 이미지와 판매자명 간격
                        // 판매자명 및 인증 정보
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start, // 판매자명을 왼쪽 정렬
                            children: [
                              // 판매자명
                              Text(
                                sellerInfo?['storeName'] ?? '판매자명 없음', // null 체크 및 기본값 설정
                                style: WitHomeTheme.subtitle.copyWith(fontSize: 16),
                              ),
                              SizedBox(height: 8), // 사업자명과 인증 정보 간격
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [

                                  if (sellerInfo?['bizCertification'] == '02')
                                    Image.asset(
                                    'assets/images/인증완료.png', // 이미지 경로
                                  ),
                                  SizedBox(width: 5), // 두 컨테이너 간격
                                  // rateFlag가 'Y'일 때만 'BEST 추천' 표시
                                  if (sellerInfo?['rateFlag'] == 'Y')
                                    Image.asset(
                                      'assets/images/베스트 추천.png', // 이미지 경로
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 두 번째 영역: 서비스 품목 및 AS 기간
              _buildCard(
                title: '서비스 품목',
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // 서비스 품목 버튼
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: WitHomeTheme.wit_white, // 초록색 배경
                        borderRadius: BorderRadius.circular(8), // 둥근 모서리
                      ),
                      child: Text(
                        sellerInfo?['categoryNm'] ?? '카테고리 없음',
                        style: WitHomeTheme.title.copyWith(fontSize: 16),                      ),
                    ),
                    SizedBox(width: 10), // 버튼 간격
                    Container(
                      child: Row(
                        children: [
                          Text(
                            sellerInfo?['asGbnNm'] ?? '', // 서비스 기간 텍스트
                            style: WitHomeTheme.subtitle.copyWith(fontSize: 16),
                          ),
                          SizedBox(width: 5), // 텍스트와 아이콘 간격
                          if (asGbn.isNotEmpty)
                            Image.asset(
                              'assets/images/인증 아이콘.png', // 이미지 경로
                              height: 18, // 아이콘 높이를 설정 (필요에 따라 조정)
                              width: 18, // 아이콘 너비를 설정 (필요에 따라 조정)
                            ),
                        ],
                      ),
                    ),

                  ],
                ),
              ),

              // 세 번째 영역: 업체 주소
              _buildCard(
                title: '업체 주소',
                content: Text(
                  style: WitHomeTheme.subtitle.copyWith(fontSize: 16),
                  (sellerInfo?['address1'] ?? '주소 없음') + " / " + (sellerInfo?['serviceAreaNm'] ?? '서비스 지역 없음'),
                ),
              ),

              // 네 번째 영역: 업체 설명
              _buildCard(
                title: '업체 설명',
                content: Text(sellerInfo?['sllrContent'] ?? '', style: WitHomeTheme.subtitle.copyWith(fontSize: 16),),
              ),
              // 다섯 번째 영역: 시공 사진/동영상
              _buildCard(
                title: '시공 사진/동영상',
                content: Container(
                  height: 120, // 높이 설정
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: storeImageList.length > 0 ? storeImageList.length : 1, // 기본값 설정
                    itemBuilder: (context, index) {
                      if (storeImageList.isEmpty) {
                        return Center(child: Text('이미지가 없습니다.')); // 이미지가 없을 때 표시할 위젯
                      }
                      return GestureDetector(
                        onTap: () {
                          // 클릭 시 ImageViewer로 이동
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ImageViewer(
                                imageUrls: storeImageList.map((item) => apiUrl + item["imagePath"]).toList(),
                                initialIndex: index, // 클릭한 이미지 인덱스 전달
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: 110,
                          height: 100,
                          margin: EdgeInsets.only(right: 8), // 이미지 간격
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12), // 둥글게 처리
                            image: DecorationImage(
                              image: NetworkImage(apiUrl + storeImageList[index]["imagePath"]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              // 여섯 번째 영역: 후기 및 별점
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[100], // 카드 배경색 (연한 회색)
                  borderRadius: BorderRadius.circular(10), // 모서리 둥글게
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "후기", // 제목 추가
                      style: WitHomeTheme.title.copyWith(fontSize: 24),
                    ),
                    SizedBox(height: 10), // 제목과 사용자 정보 영역 간격
                    Container(
                      padding: EdgeInsets.all(10), // 사용자 정보 영역의 패딩
                      decoration: BoxDecoration(
                        color: WitHomeTheme.wit_lightGrey, // 사용자 닉네임 영역 배경색 (진한 회색)
                        borderRadius: BorderRadius.circular(50), // 모서리 둥글게
                      ),
                      child: Row(
                        children: [
                          // 사용자 이미지
                          Container(
                            width: 40, // 이미지 너비
                            height: 40, // 이미지 높이
                            decoration: BoxDecoration(
                              shape: BoxShape.circle, // 원형으로 설정
                              image: DecorationImage(
                                image: AssetImage('assets/images/profile1.png'), // 사용자 이미지 경로
                                fit: BoxFit.cover, // 이미지 크기 조정
                              ),
                            ),
                          ),
                          SizedBox(width: 10), // 아이콘과 텍스트 간격
                          Text(
                            '이재명', // 사용자 이름
                            style: WitHomeTheme.title.copyWith(fontSize: 16), // 텍스트 색상 흰색
                          ),
                          Spacer(), // 남은 공간을 차지하여 별점 오른쪽 정렬
                          Row(
                            children: List.generate(5, (index) {
                              return Icon(
                                index < 4 ? Icons.star : Icons.star_border, // 4개는 채워진 별, 1개는 빈 별
                                color: Colors.amber, // 별 색상
                                size: 20, // 별 크기
                              );
                            }),
                          ),
                          /*Row(
                            children: List.generate(5, (index) {
                              return Icon(
                                index < (sellerInfo?['rating'] ?? 0) ? Icons.star : Icons.star_border,
                                color: Colors.amber, // 별 색상
                                size: 20, // 별 크기
                              );
                            }),
                          ),*/
                        ],
                      ),
                    ),
                    SizedBox(height: 10), // 제목과 후기사이 간격
                    Text(
                      "업체명: ABC 방충망\n"
                          "위치: 서울 강남구\n\n"
                          "ABC 방충망에서 방충망을 구매하고 설치했습니다. 제품의 품질이 매우 뛰어나고, "
                          "재질이 튼튼하여 오래 사용할 수 있을 것 같습니다. 디자인도 깔끔해서 집 인테리어와 잘 어울립니다.\n\n"
                          "설치 서비스도 매우 만족스러웠습니다. 설치팀이 친절하고 전문적이었으며, "
                          "예상보다 빠르게 작업을 마쳤습니다.\n\n"
                          "가격은 다른 업체들과 비교했을 때 적당한 편이었고, 가성비가 좋다고 느꼈습니다.\n\n"
                          "전체적으로 매우 만족하며, 방충망을 설치한 이후로 벌레 걱정이 없어져서 기쁩니다. "
                          "다음에도 필요할 경우 다시 이용할 생각입니다.",
                      style: WitHomeTheme.subtitle.copyWith(fontSize: 16),
                      maxLines: null,
                      overflow: TextOverflow.visible,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
    );
  }

  Widget _buildCard({String? title, required Widget content}) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      color: Colors.grey[100], // 배경색 설정
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null)
              Text(
                title,
                style: WitHomeTheme.title.copyWith(fontSize: 24),
              ),
            SizedBox(height: 10),
            content,
          ],
        ),
      ),
    );
  }


// [서비스] 판매자 상세 이미지 조회
  Future<void> getSellerDetailImageList(dynamic bizCd) async {
    // REST ID
    String restId = "getSellerDetailImageList";

    // PARAM
    final param = jsonEncode({
      "bizCd": bizCd,
      "bizKey": sellerInfo["sllrNo"],
    });

    if (bizCd == "SR01") {
      // API 호출 (게시판 상세 조회)
      final _storeImageList = await sendPostRequest(restId, param);

      if (_storeImageList.isNotEmpty) {
        // 값이 있을 때 수행할 작업
        print("보드 상세 이미지 리스트에 값이 있습니다: ${_storeImageList.length}개");
      } else {
        // 값이 없을 때 수행할 작업
        print("보드 상세 이미지 리스트가 비어 있습니다.");
      }

      // 결과 셋팅
      setState(() {
        storeImageList = _storeImageList;
      });
    }

  }

  /*Future<void> getSellerBoardList() async {
    // REST ID
    String restId = "getSellerBoardList";

    // PARAM
    final param = jsonEncode({
      "bizCd": bizCd,
      "bizKey": sellerInfo["sllrNo"],
    });

    if (bizCd == "SR01") {
      // API 호출 (게시판 상세 조회)
      final _storeImageList = await sendPostRequest(restId, param);

      if (_storeImageList.isNotEmpty) {
        // 값이 있을 때 수행할 작업
        print("보드 상세 이미지 리스트에 값이 있습니다: ${_storeImageList.length}개");
      } else {
        // 값이 없을 때 수행할 작업
        print("보드 상세 이미지 리스트가 비어 있습니다.");
      }

      // 결과 셋팅
      setState(() {
        storeImageList = _storeImageList;
      });
    }

  }*/
}
