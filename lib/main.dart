import 'package:fenix/view/main_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MainWidget());
}

class MainWidget extends StatefulWidget {
  // ← StatefulWidget
  const MainWidget({super.key});
  @override
  MainWidgetState createState() => MainWidgetState();
}

class MainWidgetState extends State<MainWidget> {
  // ← StatefulWidget
  int selectedPage = 1;
  late final MainPage mainPage = MainPage();
  final List<Column> pages = [Column(), MainPage().getMainPage()];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: pages[selectedPage],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: selectedPage,
          onTap: (index) {
            setState(() {
              selectedPage = index;
            });
          },
          selectedItemColor: Color(0xFFC67C4E),
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Image.asset("assets/images/bottom/calendar.png"),
              activeIcon: Image.asset(
                "assets/images/bottom/calendar_active.png",
              ),
              label: "Расписание",
            ),
            BottomNavigationBarItem(
              icon: Image.asset("assets/images/bottom/main_button.png"),
              activeIcon: Image.asset(
                "assets/images/bottom/main_button_active.png",
              ),
              label: "",
            ),
            BottomNavigationBarItem(
              icon: Image.asset("assets/images/bottom/user.png"),
              label: "Профиль",
            ),
          ],
        ),
      ),
    );
  }
}
