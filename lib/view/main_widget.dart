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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Scaffold(body: welcomeBlock));
  }
}
