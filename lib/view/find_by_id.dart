import 'package:fenix/view/event_view.dart';
import 'package:flutter/material.dart';

class FindByIdPage {
  late final eventWidget = EventWidget();

  final VoidCallback? onBackToMenu;

  FindByIdPage({this.onBackToMenu});

  final Widget welcomeText = Text(
    "Вход по ID",
    textAlign: TextAlign.center,
    style: TextStyle(
      fontSize: 36,
      fontFamily: 'inter',
      color: Color(0xFF484C52),
      fontWeight: FontWeight.w600,
    ),
  );

  late final welcomeBlock = SafeArea(
    child: Padding(
      padding: EdgeInsets.only(top: 10),
      child: Align(
        alignment: Alignment.topCenter,
        child: SizedBox(width: 330, child: welcomeText),
      ),
    ),
  );

  late final findArea = SizedBox(
    width: 351,
    height: 85,
    child: Row(
      children: [
        Expanded(
          child: TextField(
            cursorColor: Color(0xFFC67C4E),
            style: TextStyle(color: Color(0xBF484C52)),
            decoration: InputDecoration(
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xBF484C52)),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFC67C4E)),
              ),
              hintText: 'Введите ID',
              hintStyle: TextStyle(color: Color(0xBF484C52)),
            ),
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: Image.asset(
            "assets/images/main_page/loupe.png",
            width: 41,
            height: 41,
          ),
        ),
      ],
    ),
  );

  late final backButton = GestureDetector(
    onTap: onBackToMenu ?? () {},
    child: Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        "Выйти в меню",
        style: TextStyle(fontSize: 18, color: Color(0xFF484C52)),
      ),
    ),
  );

  Column getPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [welcomeBlock, findArea, backButton],
    );
  }
}
