import 'package:fenix/view/find_by_id.dart';
import 'package:fenix/view/main_page.dart';
import 'package:fenix/view/qr_scanner.dart';
import 'package:fenix/view/schedule_page.dart';
import 'package:fenix/view/profile_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainWidget(), // Теперь MaterialApp оборачивает MainWidget
    );
  }
}

class MainWidget extends StatefulWidget {
  const MainWidget({super.key});

  @override
  MainWidgetState createState() => MainWidgetState();
}

class MainWidgetState extends State<MainWidget> {
  int selectedPage = 1;
  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();

    pages = [
      SchedulePage().getPage(),
      MainPage(
        onFindMeetingPressed: () => setState(() => selectedPage = 0),
        onEnterByIdPressed: () => setState(() => selectedPage = 3),
        onScanQrPressed: () {
          Future.microtask(() {
            if (mounted) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const QrScannerPage(),
                ),
              );
            }
          });
        },
      ).getPage(),
      ProfilePage().getPage(),
      FindByIdPage(
        onBackToMenu: () => setState(() => selectedPage = 1),
      ).getPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[selectedPage],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedPage > 2 ? 1 : selectedPage,
        onTap: (index) {
          setState(() {
            selectedPage = index;
          });
        },
        selectedItemColor: const Color(0xFFC67C4E),
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
            activeIcon: Image.asset("assets/images/bottom/user_active.png"),
          ),
        ],
      ),
    );
  }
}