import 'package:fenix/model/event.dart';
import 'package:fenix/model/polls.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PresentationPage extends StatefulWidget {
  final Event? event;
  final List<Poll>? polls;

  const PresentationPage({super.key, this.event, this.polls});

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
      child: widget.event?.presentationBytes != null
          ? ClipRect(
              child: SfPdfViewer.memory(
                widget.event!.presentationBytes!,
                canShowScrollHead: false,
                canShowScrollStatus: false,
                pageSpacing: 0,
                enableDoubleTapZooming: false,
              ),
            )
          : const Center(child: Text('Презентация не загружена')),
    ),
  );

  Widget get materials => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: Text(
            "Материалы",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF484C52),
            ),
          ),
        ),
        if (widget.polls == null || widget.polls!.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text("Материалы отсутствуют"),
            ),
          )
        else
          Column(
            children: widget.polls!.map((poll) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  title: Text(
                    poll.title ?? "Без названия",
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    poll.url ?? "",
                    style: const TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.open_in_new, color: Colors.blue),
                  onTap: () async {
                    final url = poll.url;
                    if (url != null && url.isNotEmpty) {
                      final uri = Uri.parse(url);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    }
                  },
                ),
              );
            }).toList(),
          ),
      ],
    ),
  );

  final chat = Column(
    children: [
      Expanded(
        child: SingleChildScrollView(
          reverse: true,
          child: Column(
            spacing: 20,
            children: const [Text("Здесь будет чат с докладчиком")],
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event?.title ?? "Презентация"),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF484C52),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        // ← Добавил
        child: Column(
          children: [
            const SizedBox(height: 16), // ← Уменьшил с 20
            presentation,
            SizedBox(height: 10),
            // Кнопки переключения
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
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF484C52),
                        ),
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
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF484C52),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10), // ← Добавил небольшой отступ
            // Основной контент
            Container(
              width: 381,
              height: 380,
              margin: const EdgeInsets.only(top: 8),
              // ← уменьшил margin
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color(0xFFD9D9D9),
              ),
              clipBehavior: Clip.hardEdge,
              child: showChat ? chat : materials,
            ),

            const SizedBox(height: 16), // ← уменьшил
          ],
        ),
      ),
    );
  }
}
