// pre_inspaction_detail_ui.dart
import 'package:flutter/material.dart';

class PreInspactionDetailUI extends StatelessWidget {
  final String inspNm;
  final List<dynamic> preinspactionListByLv2;
  final List<dynamic> preinspactionListByLv3;
  final TabController tabController;
  final Function(String) onTabChanged;
  final Function(dynamic, String) onSwitchChanged;

  const PreInspactionDetailUI({
    Key? key,
    required this.inspNm,
    required this.preinspactionListByLv2,
    required this.preinspactionListByLv3,
    required this.tabController,
    required this.onTabChanged,
    required this.onSwitchChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            inspNm,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              letterSpacing: 1.5,
              color: Colors.black,
            ),
          ),
          bottom: preinspactionListByLv2.isNotEmpty
              ? TabBar(
            controller: tabController,
            isScrollable: false,
            onTap: (index) {
              onTabChanged(preinspactionListByLv2[index]["inspId"]);
            },
            tabs: preinspactionListByLv2.map((item) {
              return Tab(
                child: Container(
                  alignment: Alignment.center,
                  width: double.infinity,
                  child: Text(item["inspNm"]),
                ),
              );
            }).toList(),
          )
              : null,
        ),
        body: ListView.builder(
          itemCount: preinspactionListByLv3.length,
          itemBuilder: (context, index) {
            return Card(
              margin: EdgeInsets.symmetric(vertical: 1, horizontal: 0),
              elevation: 1,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0), // 모서리 둥글기 조절
              ),
              child: ListTile(
                contentPadding: EdgeInsets.all(8),
                title: Text(
                  preinspactionListByLv3[index]["inspNm"],
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                trailing: Transform.scale(
                  scale: 0.7, // 크기를 70%로 설정
                  child: Switch(
                    value: preinspactionListByLv3[index]["checkYn"] == "Y",
                    onChanged: (value) {
                      onSwitchChanged(preinspactionListByLv3[index], value ? "Y" : "N");
                    },
                    activeTrackColor: Colors.blue[200],
                    inactiveTrackColor: Colors.red[200],
                  ),
                ),
                onTap: () {
                  // 카드 클릭 시 동작
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
