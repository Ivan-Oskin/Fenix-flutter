 import 'package:fenix/view/main_widget.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MainWidget());
}


class MainWidget extends StatelessWidget {
  late final MainPage mainPage = MainPage();
  MainWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: mainPage.getMainPage(),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 1,
          selectedItemColor: Color(0xFFC67C4E),
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Image.asset("assets/images/main_widget/calendar.png"),
              label: "Расписание",
            ),
            BottomNavigationBarItem(
              icon: Image.asset("assets/images/main_widget/main_button.png"),
              label: "",
            ),
            BottomNavigationBarItem(
              icon: Image.asset("assets/images/main_widget/user.png"),
              label: "Профиль",
            ),
          ],
        ),
      ),
    );
  }
}