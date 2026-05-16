import 'package:fenix/view/event.dart';
import 'package:flutter/material.dart';

class SchedulePage {
  late final eventWidget = EventWidget();

  late final Container event = eventWidget.getEvent(
    'assets/images/main_page/pafnuti.png',
    "Встреча фан клуба Пафнутия Львовича Чубышева",
    "12:00",
    "12.07.2027",
    true,
  );

  final Widget welcomeText = Text(
    "Мероприятия",
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
              hintText: 'Введите название',
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

  late final eventBlock = SizedBox(
    width: 381,
    height: 475,
    child: SingleChildScrollView(
      child: Column(spacing: 5, children: [event, event, event, event, event]),
    ),
  );

  Column getPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [welcomeBlock, findArea, eventBlock],
    );
  }
}
