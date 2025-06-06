import 'dart:convert';
import 'dart:math';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:image_picker/image_picker.dart';

import 'package:witibju/util/wit_api_ut.dart';
import 'package:witibju/screens/seller/wit_seller_profile_insert_name_sc.dart';
import 'package:witibju/screens/seller/wit_seller_profile_insert_content_sc.dart';
import 'package:witibju/screens/seller/wit_seller_profile_insert_bizInfo_sc.dart';
import 'package:witibju/screens/seller/wit_seller_profile_insert_hpInfo_sc.dart';
import 'package:witibju/screens/seller/wit_seller_profile_detail_sc.dart';
import 'package:witibju/screens/home/wit_home_sc.dart';
import 'package:witibju/screens/home/wit_home_theme.dart';

/// 앱 전역에 선언된 RouteObserver 인스턴스를 가져옵니다.
final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

class SellerAppBar extends StatefulWidget implements PreferredSizeWidget {
  final dynamic sllrNo;
  //final Function(dynamic) onSllrNoChanged;

  const SellerAppBar({
    super.key,
    required this.sllrNo,
    // , required this.onSllrNoChanged,
    // required this.onSllrNoChanged,
  });

  @override
  State<StatefulWidget> createState() => SellerAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class SellerAppBarState extends State<SellerAppBar> with RouteAware {
  dynamic sellerInfo;
  String storeName = "";
  dynamic sllrNo;
  // late final Function(dynamic) onSllrNoChanged;
  final TextEditingController _sllrNoController = TextEditingController();
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    // onSllrNoChanged = widget.onSllrNoChanged;
    initAsync();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    print("뒤로 오면서 sllrNo 재조회");
    initAsync(); // sllrNo와 판매자 정보 다시 조회
  }

  Future<void> initAsync() async {
    if (sllrNo == null) {
      await secureStorage.write(key: 'sllrNo', value: "260");
      sllrNo = await secureStorage.read(key: 'sllrNo');
      print("sllrNo from secureStorage ::: $sllrNo");
    }
    await getSellerInfo();
  }

  Future<void> getSellerInfo() async {
    const restId = "getSellerInfo";

    if (sllrNo == null) {
      sllrNo = await secureStorage.read(key: 'sllrNo');
      print("getSellerInfo에서 sllrNo 다시 읽음: $sllrNo");
    }
    else {
      print("sllrNosllrNosllrNo: " + sllrNo);

    }

    final param = jsonEncode({"sllrNo": sllrNo});
    final response = await sendPostRequest(restId, param);

    if (response != null) {
      setState(() {
        sellerInfo = response;
        storeName = response['storeName'] ?? '';
        sllrNo = response['sllrNo'] ?? '';
        print("SellerInfo 조회 완료: ${sellerInfo['sllrNo']}");
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("사업자 프로필 조회가 실패하였습니다.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leadingWidth: 200,
      leading: Padding(
        padding: const EdgeInsets.only(left: 20.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            storeName,
            style: WitHomeTheme.title.copyWith(color: WitHomeTheme.wit_black),
            textAlign: TextAlign.left,
          ),
        ),
      ),
      centerTitle: true,
      backgroundColor: WitHomeTheme.wit_white,
      actions: [
        /*Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: SizedBox(
            width: 100,
            child: TextField(
              controller: _sllrNoController,
              decoration: InputDecoration(
                hintText: 'sllrNo 입력',
                border: OutlineInputBorder(),
                hintStyle: WitHomeTheme.title.copyWith(color: WitHomeTheme.wit_black),
              ),
              style: WitHomeTheme.title.copyWith(color: WitHomeTheme.wit_black),
              keyboardType: TextInputType.number,
            ),
          ),
        ),
        IconButton(
          onPressed: () {
            final newSllrNo = _sllrNoController.text;
            if (newSllrNo.isNotEmpty) {
              setState(() {
                sllrNo = int.tryParse(newSllrNo);
                // widget.onSllrNoChanged(sllrNo);
              });
              getSellerInfo();
            }
          },
          icon: Icon(Icons.search, color: WitHomeTheme.wit_black),
        ),*/
        IconButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => HomeScreen()));
          },
          icon: Icon(Icons.swap_horiz, color: WitHomeTheme.wit_black),
        ),
        IconButton(
          padding: const EdgeInsets.only(right: 20.0),
          onPressed: () {
            final regiLevel = sellerInfo?['regiLevel'];
            late Widget targetScreen;

            if (regiLevel == null) {
              targetScreen = SellerProfileInsertName();
            } else if (regiLevel == '01') {
              targetScreen = SellerProfileInsertContents(sllrNo: sellerInfo['sllrNo'].toString());
            } else if (regiLevel == '02') {
              targetScreen = SellerProfileInsertBizInfo(sllrNo: sellerInfo['sllrNo'].toString());
            } else if (regiLevel == '03') {
              targetScreen = SellerProfileInsertHpInfo(sllrNo: sellerInfo['sllrNo'].toString());
            } else {
              targetScreen = SellerProfileDetail(sllrNo: sellerInfo['sllrNo'].toString());
            }

            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => targetScreen),
            ).then((_) {
              initAsync(); // 돌아오면 다시 seller 정보 갱신
            });
          },
          icon: Image.asset('assets/home/message.png', width: 30, height: 30),
        ),
      ],
    );
  }
}
