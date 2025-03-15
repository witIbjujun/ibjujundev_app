import 'package:flutter/material.dart';
import 'package:witibju/screens/seller/wit_seller_profile_appbar_sc.dart';

import '../home/wit_home_theme.dart';

class CardInfo extends StatefulWidget {
  final dynamic sllrNo;
  const CardInfo({Key? key, required this.sllrNo}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return CardInfoState();
  }
}

class CardInfoState extends State<CardInfo> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*appBar: SellerAppBar(
        sllrNo: widget.sllrNo,
      ),*/
      appBar: AppBar(
        backgroundColor: WitHomeTheme.nearlyWhite,
        iconTheme: const IconThemeData(color: WitHomeTheme.nearlyBlack),
        title: Text(
          '결제정보 등록',
          style: WitHomeTheme.title, // 제목에 동일한 폰트 스타일 적용
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /*Text(
                '결재정보등록',
                style: WitHomeTheme.title.copyWith(fontSize: 24),
              ),*/
              SizedBox(height: 20),
              Row(
                children: [
                  Radio(value: 1, groupValue: 0, onChanged: (value) {}),
                  Text('법인카드',
                    style: WitHomeTheme.title.copyWith(fontSize: 16),
                  ),
                ],
              ),
              TextFormField(
                controller: _cardNumberController,
                decoration: InputDecoration(
                  labelText: '카드 번호',
                  hintText: '0000 0000 0000 0000',
                  labelStyle: WitHomeTheme.subtitle.copyWith(fontSize: 16),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '카드 번호를 입력하세요.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _expiryDateController,
                decoration: InputDecoration(
                  labelText: '유효기간',
                  hintText: 'MM / YY',
                  labelStyle: WitHomeTheme.subtitle.copyWith(fontSize: 16),
                ),
                keyboardType: TextInputType.datetime,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '유효기간을 입력하세요.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _cvvController,
                decoration: InputDecoration(
                  labelText: '카드비밀번호',
                  hintText: '비밀번호 앞 2자리 숫자',
                  labelStyle: WitHomeTheme.subtitle.copyWith(fontSize: 16),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '카드 비밀번호를 입력하세요.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _birthDateController,
                decoration: InputDecoration(
                  labelText: '생년월일',
                  labelStyle: WitHomeTheme.subtitle.copyWith(fontSize: 16),
                  hintText: 'YYMMDD',
                ),
                keyboardType: TextInputType.datetime,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '생년월일을 입력하세요.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Center( // 버튼을 Center로 감싸서 가운데 정렬
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: WitHomeTheme.wit_mediumSeaGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // 등록 로직 추가
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('카드가 등록되었습니다.')),
                      );
                    }
                  },
                  child: Text('등록하기',
                      style: WitHomeTheme.title.copyWith(fontSize: 16, color: WitHomeTheme.wit_white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
