  import 'package:fenix/model/event.dart';
  import 'package:fenix/model/polls.dart';
  import 'package:fenix/repository/event_repository.dart';
  import 'package:fenix/repository/poll_repository.dart';
  import 'package:fenix/view/event_view.dart';
  import 'package:fenix/view/presentation_page.dart';
  import 'package:flutter/material.dart';

  class MainPage extends StatefulWidget {
    final VoidCallback? onFindMeetingPressed;
    final VoidCallback? onEnterByIdPressed;
    final VoidCallback? onScanQrPressed;
    final VoidCallback? onEventPressed;
    final VoidCallback? onDataUpdated;

    const MainPage({
      super.key,
      this.onFindMeetingPressed,
      this.onEnterByIdPressed,
      this.onScanQrPressed,
      this.onEventPressed,
      this.onDataUpdated,
    });

    @override
    State<MainPage> createState() => MainPageState();
  }

  class MainPageState extends State<MainPage> {
    late final eventWidget = EventWidget();
    late final eventRepository = EventRepository();

    void refresh() {
      setState(() {});
    }

    void _onConnectPressed(Event event) async {
      List<Poll> loadedPolls = [];
      final String eventId = event.id ?? '';

      print('🔍 _onConnectPressed вызван');
      print('📌 Event ID: $eventId');

      if (eventId.isNotEmpty) {
        try {
          loadedPolls = await PollRepository().findAllByEventId(eventId);
          print('✅ Найдено опросов в БД: ${loadedPolls.length}');

          for (var poll in loadedPolls) {
            print('   • Poll: ${poll.title} | URL: ${poll.url}');
          }
        } catch (e) {
          print('❌ Ошибка при загрузке polls: $e');
        }
      } else {
        print('❌ Event ID пустой!');
      }

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              PresentationPage(event: event, polls: loadedPolls),
        ),
      );
    }

    // Виджет одного события
    Widget buildEventCard(Event event) {
      return GestureDetector(
        onTap: () => _onConnectPressed(event),
        child: eventWidget.getEvent(event, false),
      );
    }

    final TextSpan welcomeText = const TextSpan(
      text: "Добро пожаловать в Феникс",
      style: TextStyle(
        fontSize: 36,
        fontFamily: 'inter',
        color: Color(0xFF484C52),
        fontWeight: FontWeight.w600,
      ),
    );

    final WidgetSpan logoSticker = WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: Padding(
        padding: const EdgeInsets.only(left: 5),
        child: Image.asset('assets/images/main_page/logo_sticker.png'),
      ),
    );

    late final welcomeBlock = SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: 330,
            child: RichText(text: TextSpan(children: [welcomeText, logoSticker])),
          ),
        ),
      ),
    );

    // Исправлено: передаем callback через конструктор
    Widget buildScanner() {
      return GestureDetector(
        onTap: widget.onScanQrPressed ?? () {},
        child: Container(
          width: 125,
          height: 125,
          decoration: BoxDecoration(
            color: const Color(0xFFD9D9D9),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Image.asset(
                  'assets/images/main_page/qr_code.png',
                  width: 90,
                  height: 90,
                ),
              ),
              const Text(
                "Сканировать QR",
                style: TextStyle(color: Color(0xBF484C52)),
              ),
            ],
          ),
        ),
      );
    }

    // Исправлено: передаем callback через конструктор
    Widget buildButtonIdBox() {
      return GestureDetector(
        onTap: widget.onEnterByIdPressed ?? () {},
        child: SizedBox(
          width: 105,
          height: 90,
          child: Column(
            children: [
              Container(
                width: 82,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFD9D9D9), width: 2),
                ),
                child: Image.asset('assets/images/main_page/ID.png'),
              ),
              const Text(
                "Войти по ID",
                style: TextStyle(color: Color(0xBF484C52)),
              ),
            ],
          ),
        ),
      );
    }

    // Исправлено: передаем callback через конструктор
    Widget buildButtonFindBox() {
      return GestureDetector(
        onTap: widget.onFindMeetingPressed ?? () {},
        child: SizedBox(
          width: 100,
          height: 90,
          child: Column(
            children: [
              Container(
                width: 82,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFD9D9D9), width: 2),
                ),
                child: Image.asset('assets/images/main_page/loupe.png'),
              ),
              const Text(
                "Найти встречу",
                style: TextStyle(color: Color(0xBF484C52)),
              ),
            ],
          ),
        ),
      );
    }

    Widget buildButtons() {
      return SizedBox(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [buildButtonIdBox(), buildButtonFindBox()],
        ),
      );
    }

    Widget buildQrBlock() {
      return Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: 350,
          child: Row(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [buildScanner(), buildButtons()],
          ),
        ),
      );
    }

    Widget buildEventBlock() {
      return Container(
        width: 381,
        height: 380,
        margin: const EdgeInsets.only(top: 40),
        padding: const EdgeInsets.only(top: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color(0xFFD9D9D9),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 20),
              child: Text(
                "Вы записаны",
                style: TextStyle(fontSize: 20, color: Color(0xBF484C52)),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: FutureBuilder<List<Event>>(
                key: ValueKey(DateTime.now().millisecondsSinceEpoch), // ← Добавь это
                future: eventRepository.findAll(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(child: Text("Ошибка загрузки событий"));
                  }

                  final events = snapshot.data ?? [];

                  if (events.isEmpty) {
                    return const Center(
                      child: Text(
                        "Пока нет записей",
                        style: TextStyle(color: Color(0xBF484C52), fontSize: 16),
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: events
                          .map(
                            (event) => Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: buildEventCard(event),
                        ),
                      )
                          .toList(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    }

    @override
    Widget build(BuildContext context) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [welcomeBlock, buildQrBlock(), buildEventBlock()],
      );
    }
  }
