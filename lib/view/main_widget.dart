import 'package:flutter/material.dart';

class MainWidget extends StatelessWidget {
  MainWidget({super.key});

  final TextSpan welcomeText = TextSpan(
    text: "Добро пожаловать в Феникс",
    style: TextStyle(
      fontSize: 36,
      fontFamily: 'Semi Bold',
      color: Color(0xFF484C52),
      fontWeight: FontWeight(600),
    ),
  );

  final WidgetSpan logoSticker = WidgetSpan(
    alignment: PlaceholderAlignment.middle,
    child: Padding(
      padding: EdgeInsets.only(left: 5),
      child: Image.asset('assets/images/main_widget/logo_sticker.png'),
    ),
  );

  late final welcomeBlock = SafeArea(
    child: Padding(
      padding: EdgeInsets.only(top: 10),
      child: Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: 330,
          child: RichText(text: TextSpan(children: [welcomeText, logoSticker])),
        ),
      ),
    ),
  );

  late final scanner = Container(
    width: 125,
    height: 125,
    decoration: BoxDecoration(
      color: Color(0xFFD9D9D9),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      children: [
        Center(
          child: Image.asset(
            'assets/images/main_widget/qr_code.png',
            width: 90,
            height: 90,
          ),
        ),
        Text("Сканировать QR", style: TextStyle(color: Color(0xBF484C52))),
      ],
    ),
  );

  late final buttonIdBox = SizedBox(
    width: 105,
    height: 90,
    child: Column(
      children: [
        Container(
          width: 82,
          height: 70,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Color(0xFFD9D9D9), width: 2),
          ),
          child: Image.asset('assets/images/main_widget/ID.png'),
        ),
        Text("Войти по ID", style: TextStyle(color: Color(0xBF484C52))),
      ],
    ),
  );

  late final buttonFindBox = SizedBox(
    width: 100,
    height: 90,
    child: Column(
      children: [
        Container(
          width: 82,
          height: 70,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Color(0xFFD9D9D9), width: 2),
          ),
          child: Image.asset('assets/images/main_widget/loupe.png'),
        ),
        Text("Найти встречу", style: TextStyle(color: Color(0xBF484C52))),
      ],
    ),
  );

  late final buttons = SizedBox(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [buttonIdBox, buttonFindBox],
    ),
  );

  late final qrBlock = Align(
    alignment: Alignment.topCenter,
    child: SizedBox(
      width: 335,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [scanner, buttons],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(body: Column(children: [welcomeBlock, qrBlock])),
    );
  }
}
