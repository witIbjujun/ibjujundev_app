import 'dart:math';
import 'package:witibju/screens/seller/wit_seller_card_info_sc.dart';
import 'package:witibju/screens/seller/wit_seller_cash_history_sc.dart';
import 'package:witibju/screens/seller/wit_seller_esitmaterequest_directsetList_sc.dart';
import 'package:witibju/screens/seller/wit_seller_esitmaterequest_directset_sc.dart';
import 'package:witibju/screens/seller/wit_seller_profile_detail_sc.dart';
import 'package:flutter/material.dart';
import 'package:witibju/screens/seller/wit_seller_profile_insert_name_sc.dart';
import 'package:witibju/screens/seller/wit_seller_profile_sc.dart';
import 'package:witibju/screens/seller/wit_seller_profile_view_sc.dart';
import 'dart:convert';
import 'package:witibju/util/wit_api_ut.dart';
import 'package:intl/intl.dart';

import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:witibju/screens/seller/wit_seller_community_sc.dart';
import 'package:witibju/screens/seller/wit_seller_estimaterequest_detail_sc.dart';
import 'package:witibju/screens/seller/wit_seller_estimaterequest_list_sc.dart';
import 'package:witibju/screens/seller/wit_seller_profile_modify_sc.dart';

// import '../../main_toss.dart';
import '../board/wit_board_main_sc.dart';
import '../home/wit_home_sc.dart';
import 'package:witibju/screens/home/wit_home_theme.dart';


//import '../intro.dart';
class SellerAppBar extends StatefulWidget implements PreferredSizeWidget {
  final dynamic sllrNo;
  final Function(dynamic) onSllrNoChanged; // 콜백 추가
  const SellerAppBar({super.key, required this.sllrNo, required this.onSllrNoChanged});

  @override
  State<StatefulWidget> createState() => SellerAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight); // AppBar 높이 설정
}

class SellerAppBarState extends State<SellerAppBar> {
  dynamic sellerInfo;
  String storeName = "";
  Map cashInfo = {};
  dynamic sllrNo; // 새로운 sllrNo 변수 추가
  late final Function(dynamic) onSllrNoChanged; // 콜백 추가
  final TextEditingController _sllrNoController =
  TextEditingController(); // 입력 필드 컨트롤러

  @override
  void initState() {
    super.initState();
    sllrNo = widget.sllrNo.toString(); // 초기값 설정
    print("상세 sllrNo : " + sllrNo.toString());
    getSellerInfo(sllrNo);
    getCashInfo(sllrNo); // 초기화 시 캐시정보를 가져옵니다.
  }

  Future<void> getSellerInfo(dynamic sllrNo) async {
    String restId = "getSellerInfo";

    // PARAM
    final param = jsonEncode({
      "sllrNo": sllrNo,
    });

    // API 호출
    final response = await sendPostRequest(restId, param);

    if (response != null) {
      setState(() {
        sellerInfo = response;
        storeName = sellerInfo['storeName'];
        sllrNo = sellerInfo['sllrNo'];
        print("12331223131323123132312123 : " + sllrNo.toString());
      });
    } else {
      // 오류 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("사업자 프로필 조회가 실패하였습니다.")),
      );
    }
  }

  Future<void> getCashInfo(dynamic sllrNo) async {
    // REST ID
    String restId = "getCashInfo";

    // PARAM
    final param = jsonEncode({
      "sllrNo": sllrNo,
    });

    print("getCashInfo : " + sllrNo.toString());

    try {
      // API 호출 (사전 점검 미완료 리스트 조회)
      final response = await sendPostRequest(restId, param);

      if (response != null && response.isNotEmpty) {
        setState(() {
          cashInfo = response; // 유효한 응답일 경우 cashInfo 설정
        });
      } else {
        setState(() {
          cashInfo = {}; // 응답이 null이거나 비어있으면 빈 맵으로 초기화
        });
      }
    } catch (e) {
      print("Error occurred: $e"); // 오류 출력
      setState(() {
        cashInfo = {}; // 오류 발생 시 빈 맵으로 초기화
      });
      /*ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("서버와의 통신 중 오류가 발생했습니다.")),
      );*/
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leadingWidth: 150,
      leading: Container(
        height: double.infinity,
        child: Center(
          child: Text(
            storeName,
            style: WitHomeTheme.title.copyWith(color: WitHomeTheme.wit_white),
            // 글씨 굵게 및 하얀색 설정
            textAlign: TextAlign.center,
          ),
        ),
      ),
      /*title: Text(
        "Profile",
        style: WitHomeTheme.title.copyWith(color: Colors.white),

      ),*/
      centerTitle: true,
      backgroundColor: WitHomeTheme.wit_gray,
      actions: [
        // 입력 필드 추가
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: SizedBox(
            width: 100, // 입력 필드의 너비 설정
            child: TextField(
              controller: _sllrNoController,
              decoration: InputDecoration(
                hintText: 'sllrNo 입력',
                border: OutlineInputBorder(),
                hintStyle:  WitHomeTheme.title.copyWith(color: Colors.white),

              ),
              style:  WitHomeTheme.title.copyWith(color: Colors.white),

              keyboardType: TextInputType.number, // 숫자 키패드로 설정
            ),
          ),
        ),
        // 버튼 추가
       IconButton(
          onPressed: () {
            // 입력된 값을 sllrNo로 변경
            dynamic newSllrNo = _sllrNoController.text;
            if (newSllrNo.isNotEmpty) {
              setState(() {
                sllrNo = int.tryParse(newSllrNo); // sllrNo 업데이트
                widget.onSllrNoChanged(sllrNo); // 부모 위젯에 sllrNo 변경 알림
                getSellerInfo(sllrNo); // 화면 재조회
                getCashInfo(sllrNo); // 화면 재조회
              });
            }
          },
          icon: Icon(Icons.search, color: Colors.white), // 아이콘 색상 하얀색으로 설정
        ),

        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => HomeScreen()), // HomeScreen으로 이동
            );
          },
          icon: Icon(
              Icons.perm_identity, color: Colors.white), // 아이콘 색상 하얀색으로 설정
        ),
        IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SellerProfileInsertName()), // HomeScreen으로 이동
              );

            }, icon: Icon(Icons.mail, color: Colors.white)),
        // 아이콘 색상 하얀색으로 설정
        /*IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SellerProfile()), // SellerProfile로 이동
            );
          },
          icon: Icon(Icons.logout, color: Colors.white), // 아이콘 색상 하얀색으로 설정
        ),*/
      ],
    );
  }
}
