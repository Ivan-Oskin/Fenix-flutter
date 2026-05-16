import 'package:flutter/material.dart';

class ProfilePage {
  final Widget welcomeText = Text(
    "Профиль",
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

  late final information = SizedBox(
    width: 351,
    height: 350,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 20,
      children: [
        getInformationFiled("Имя"),
        getInformationFiled("Фамилия"),
        getInformationFiled("Возраст"),
        getInformationFiled("Университет"),
        getInformationFiled("Направление"),
        getInformationFiled("Курс"),
      ],
    ),
  );

  Column getPage() {
    return Column(children: [welcomeBlock, information]);
  }

  SizedBox getInformationFiled(String title) {
    return SizedBox(
      width: 351,
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("$title:", style: TextStyle(color: Color(0xBF484C52))),
          SizedBox(
            width: 220,
            height: 40,
            child: TextField(
              cursorColor: Color(0xFFC67C4E),
              style: TextStyle(color: Color(0xBF484C52)),
              decoration: InputDecoration(
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFC67C4E)),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xBF484C52)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
