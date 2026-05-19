import 'package:fenix/model/event.dart';
import 'package:fenix/repository/event_repository.dart';
import 'package:fenix/view/event_view.dart';
import 'package:flutter/material.dart';

class MainPage {
  final VoidCallback? onFindMeetingPressed;
  final VoidCallback? onEnterByIdPressed;
  final VoidCallback? onScanQrPressed;
  final VoidCallback? onEventPressed;

  MainPage({
    this.onFindMeetingPressed,
    this.onEnterByIdPressed,
    this.onScanQrPressed,
    this.onEventPressed,
  });

  late final eventWidget = EventWidget();
  late final eventRepository = EventRepository();

  late final Container event = eventWidget.getEvent(
    Event(title: "пафнутий", startDate: "12.12.2026 12:00"),
    false,
  );

  late final GestureDetector eventButton = GestureDetector(
    onTap: onEventPressed ?? () {},
    child: event,
  );

  final TextSpan welcomeText = TextSpan(
    text: "Добро пожаловать в Феникс",
    style: TextStyle(
      fontSize: 36,
      fontFamily: 'inter',
      color: Color(0xFF484C52),
      fontWeight: FontWeight(600),
    ),
  );

  final WidgetSpan logoSticker = WidgetSpan(
    alignment: PlaceholderAlignment.middle,
    child: Padding(
      padding: EdgeInsets.only(left: 5),
      child: Image.asset('assets/images/main_page/logo_sticker.png'),
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

  late final scanner = GestureDetector(
    onTap: onScanQrPressed ?? () {},
    child: Container(
      width: 125,
      height: 125,
      decoration: BoxDecoration(
        color: Color(0xFFD9D9D9),
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
          Text("Сканировать QR", style: TextStyle(color: Color(0xBF484C52))),
        ],
      ),
    ),
  );

  late final buttonIdBox = GestureDetector(
    onTap: onEnterByIdPressed ?? () {},
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
              border: Border.all(color: Color(0xFFD9D9D9), width: 2),
            ),
            child: Image.asset('assets/images/main_page/ID.png'),
          ),
          Text("Войти по ID", style: TextStyle(color: Color(0xBF484C52))),
        ],
      ),
    ),
  );

  late final buttonFindBox = GestureDetector(
    onTap: onFindMeetingPressed ?? () {},
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
              border: Border.all(color: Color(0xFFD9D9D9), width: 2),
            ),
            child: Image.asset('assets/images/main_page/loupe.png'),
          ),
          Text("Найти встречу", style: TextStyle(color: Color(0xBF484C52))),
        ],
      ),
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
      width: 350,
      child: Row(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [scanner, buttons],
      ),
    ),
  );

  late final eventBlock = Container(
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
            future: eventRepository.findAll(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return const Center(child: Text("Ошибка загрузки событий"));
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text(
                    "Пока нет записей",
                    style: TextStyle(color: Color(0xBF484C52), fontSize: 16),
                  ),
                );
              }

              final events = snapshot.data!;

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: events
                      .map((event) => Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: buildEventCard(event),
                  ))
                      .toList(),
                ),
              );
            },
          ),
        ),
      ],
    ),
  );

  Column getPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [welcomeBlock, qrBlock, eventBlock],
    );
  }

  // Виджет одного события
  Widget buildEventCard(Event event) {
    return GestureDetector(
      onTap: onEventPressed ?? () {},
      child: eventWidget.getEvent(
        event,
        false,
      ),
    );
  }
}

