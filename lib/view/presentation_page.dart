import 'package:easy_docs_viewer/easy_docs_viewer.dart';
import 'package:flutter/material.dart';

class PresentationPage extends StatefulWidget {
  const PresentationPage({super.key});

  @override
  State<PresentationPage> createState() => _PresentationPageState();
}

class _PresentationPageState extends State<PresentationPage> {
  bool showChat = true;

  late final presentation = Align(
    alignment: Alignment.center,
    child: SizedBox(
      width: 388,
      height: 238,
      child: EasyDocsViewer(
        url:
            "https://iro-49.ru/wp-content/uploads/2025/05/%D0%9F%D1%80%D0%B5%D0%B7%D0%B5%D0%BD%D1%82%D0%B0%D1%86%D0%B8%D1%8F-%D0%BA-%D0%B7%D0%B0%D0%BD%D1%8F%D1%82%D0%B8%D1%8E-4.pdf?ysclid=mpbf02ytdo604141228",
      ),
    ),
  );

  final materials = SingleChildScrollView(
    child: Column(spacing: 20, children: const [Text("какой то материал")]),
  );

  final chat = Column(
    children: [
      Expanded(
        child: SingleChildScrollView(
          reverse: true,
          child: Column(
            spacing: 20,
            children: const [Text("какие-то там сообщения")],
          ),
        ),
      ),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 34,
              width: 290,
              child: TextField(
                cursorColor: const Color(0xFFC67C4E),
                style: const TextStyle(color: Color(0xFFC67C4E)),
                decoration: InputDecoration(
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFC67C4E)),
                  ),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFC67C4E)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              child: Image.asset(
                "assets/images/presentation/send.png",
                width: 34,
                height: 34,
              ),
            ),
          ],
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        presentation,

        // Кнопки
        SizedBox(
          width: 300,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => setState(() => showChat = true),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: showChat
                        ? const Color(0xFFC67C4E)
                        : const Color(0xFFD9D9D9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Вопрос докладчику",
                    style: TextStyle(fontSize: 16, color: Color(0xFF484C52)),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => showChat = false),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: !showChat
                        ? const Color(0xFFC67C4E)
                        : const Color(0xFFD9D9D9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "материалы",
                    style: TextStyle(fontSize: 16, color: Color(0xFF484C52)),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Основной блок (меняется)
        Container(
          width: 381,
          height: 380,
          margin: const EdgeInsets.only(top: 40),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: const Color(0xFFD9D9D9),
          ),
          clipBehavior: Clip.hardEdge,
          child: showChat ? chat : materials,
        ),
      ],
    );
  }
}
