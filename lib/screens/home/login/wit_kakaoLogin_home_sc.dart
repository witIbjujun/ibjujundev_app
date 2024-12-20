import 'package:flutter/material.dart';
import 'package:witibju/screens/home/carousel_slider.dart';
import 'package:witibju/screens/home/models/main_view_model.dart';
import 'package:witibju/screens/home/wit_home_theme.dart';
import 'package:witibju/screens/home/login/wit_kakaoLogin.dart';

class kakoLoingHome extends StatefulWidget {
  @override
  State<kakoLoingHome> createState() => _kakoLoingHomeState();
}

class _kakoLoingHomeState extends State<kakoLoingHome> {
  final viewModel = MainViewModel(KaKaoLogin());

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ///Image.network(viewModel.user?.kakaoAccount?.profile?.profileImageUrl??''),
          Text(
            '${viewModel.isLogined}',
            style: WitHomeTheme.title,
          ),
          const SizedBox(height: 16), // 간격 추가
          if (viewModel.userInfo != null) ...[
            Text('회원번호: ${viewModel.userInfo?.id ?? "정보 없음"}'),
            Text('닉네임: ${viewModel.userInfo?.nickName ?? "정보 없음"}'),
            Text('이미지 URL: ${viewModel.userInfo?.profileImageUrl ?? "정보 없음"}'),
            Text('이메일: ${viewModel.userInfo?.email ?? "정보 없음"}'),
          ]else
            const Text('로그인하지 않았습니다.'),
          ElevatedButton(
            onPressed: () async{
              await viewModel.login(context);
              setState(() {  });
            },
            child: const Text('Login'),
          ),
          ElevatedButton(
            onPressed: () async{
              await viewModel.logout();
              setState(() {  });
            },
            child: const Text('LogOut'),
          ),
        ],
      ),
    );
  }
}
