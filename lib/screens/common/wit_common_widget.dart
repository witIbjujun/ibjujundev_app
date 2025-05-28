// ConfirmationDialog 위젯 정의
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:witibju/screens/home/wit_home_theme.dart';

// [유틸] 컴펌 팝업
class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onConfirm;
  final VoidCallback onCencel;

  ConfirmationDialog({
    required this.title,
    required this.content,
    required this.onConfirm,
    required this.onCencel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: <Widget>[
        TextButton(
          child: Text("취소"),
          onPressed: () {
            onCencel();
            Navigator.of(context).pop(); // 대화상자 닫기
          },
        ),
        TextButton(
          child: Text("확인"),
          onPressed: () {
            onConfirm(); // 삭제 함수 호출
            Navigator.of(context).pop(); // 대화상자 닫기
          },
        ),
      ],
    );
  }
}

/*******************************
 * [위젯] 검색 앱바
 ******************************/
class SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String appBarTitle;
  final bool isSearching;
  final TextEditingController searchController;
  final VoidCallback onSearchToggle;
  final ValueChanged<String> onSearchSubmit;

  const SearchAppBar({
    required this.appBarTitle,
    required this.isSearching,
    required this.searchController,
    required this.onSearchToggle,
    required this.onSearchSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: isSearching ?
      TextField(
        controller: searchController,
        onSubmitted: (value) {
          onSearchSubmit(value);
        },
        decoration: InputDecoration(
          hintText: "업체명을 입력해주세요...",
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        ),
      ) : Text(appBarTitle,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(
          icon: Icon(isSearching ? Icons.close : Icons.search),
          onPressed: onSearchToggle,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

/*******************************
 * [이벤트] 화면 전환
 ******************************/
class SlideRoute extends PageRouteBuilder {
  final Widget page;

  SlideRoute({required this.page})
      : super(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
  );
}

/*******************************
 * [이벤트] 컨펌 팝업 호출
 ******************************/
class ConfimDialog {
  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String content,
    String confirmText = '확인',
    String cancelText = '취소',
    Color confirmColor = WitHomeTheme.wit_lightSteelBlue,
    Color cancelColor = WitHomeTheme.wit_gray,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,  // 🔹 글씨 크기 키움
            ),
          ),
          content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              content,
              style: const TextStyle(
                fontSize: 16,  // 🔹 글씨 크기 키움
              ),
            ),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text(
                cancelText,
                style: TextStyle(color: cancelColor),
              ),
            ),
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text(
                confirmText,
                style: TextStyle(color: confirmColor),
              ),
            ),
          ],
        );
      },
    );

    return result ?? false; // 결과가 null이면 false 반환
  }
}

/*******************************
 * [이벤트] 알림 팝업 호출
 ******************************/
class alertDialog {
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String content,
    String confirmText = '확인',
    Color confirmColor = WitHomeTheme.wit_lightSteelBlue,
    VoidCallback? onConfirm,
  }) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false, // 바깥 클릭으로 닫히지 않음
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              content,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop(); // 창 닫기
                if (onConfirm != null) {
                  onConfirm();
                }
              },
              child: Text(
                confirmText,
                style: TextStyle(color: confirmColor),
              ),
            ),
          ],
        );
      },
    );
  }
}