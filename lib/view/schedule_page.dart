import 'package:fenix/view/event_view.dart';
import 'package:flutter/material.dart';
import 'package:fenix/model/event.dart';
import 'package:fenix/view/information_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  Future<List<Event>> fetchEvents() async {
    try {
      print("📡 Загружаем список мероприятий...");

      final response = await http.get(
        Uri.parse('http://llvvv.ru:8080/api/meetings'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3NzkyODUyOTcsInR5cGUiOiJzcGVha2VyIiwidXNlcl9pZCI6MiwidXNlcm5hbWUiOiJJdmFuIn0.4OV6vvNvY4GzCA8ojB4Dvs9Hv8sQsavsSq8GGKHroSk',
        },
      );

      print("📡 Статус списка: ${response.statusCode}");

      if (response.statusCode != 200) {
        throw Exception('Ошибка сервера: ${response.statusCode}');
      }

      final List<dynamic> data = jsonDecode(response.body);
      List<Event> events = [];

      for (var json in data) {
        Event event = Event.fromMap(json);
        print("✅ Мероприятие ID=${event.id}, Title=${event.title}");

        // === Загрузка фото ===
        try {
          final photoUrl = 'http://llvvv.ru:8080/api/meetings/${event.id}/photo/';
          print("📸 Загружаем фото: $photoUrl");

          final photoResponse = await http.get(
            Uri.parse(photoUrl),
            headers: {
              'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3NzkyODUyOTcsInR5cGUiOiJzcGVha2VyIiwidXNlcl9pZCI6MiwidXNlcm5hbWUiOiJJdmFuIn0.4OV6vvNvY4GzCA8ojB4Dvs9Hv8sQsavsSq8GGKHroSk',
            },
          );

          print("📸 Фото ID=${event.id} → Статус: ${photoResponse.statusCode} | Размер: ${photoResponse.bodyBytes.length} байт");

          if (photoResponse.statusCode == 200 && photoResponse.bodyBytes.isNotEmpty) {
            event.photoBytes = photoResponse.bodyBytes;
            print("✅ Фото успешно загружено для ID=${event.id}");
          } else {
            print("❌ Фото не загружено (пустое или ошибка)");
          }
        } catch (e) {
          print("❌ Ошибка при загрузке фото для ID=${event.id}: $e");
        }

        events.add(event);
      }

      return events;
    } catch (e) {
      print("🔥 Общая ошибка: $e");
      throw Exception('Не удалось загрузить данные: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Welcome блок
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: 330,
                child: Text(
                  "Мероприятия",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 36,
                    fontFamily: 'inter',
                    color: const Color(0xFF484C52),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),

        // Поиск (оставил как было)
        SizedBox(
          width: 351,
          height: 85,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  cursorColor: const Color(0xFFC67C4E),
                  style: const TextStyle(color: Color(0xBF484C52)),
                  decoration: InputDecoration(
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xBF484C52)),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFC67C4E)),
                    ),
                    hintText: 'Введите название',
                    hintStyle: const TextStyle(color: Color(0xBF484C52)),
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
        ),

        // Список мероприятий
        Expanded(
          child: SizedBox(
            width: 381,
            child: FutureBuilder<List<Event>>(
              future: fetchEvents(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Ошибка:\n${snapshot.error}'));
                }

                final events = snapshot.data ?? [];

                if (events.isEmpty) {
                  return const Center(child: Text('Мероприятия не найдены'));
                }

                return SingleChildScrollView(
                  child: Column(
                    spacing: 5,
                    children: events.map((event) {
                      final eventWidget = EventWidget();
                      final container = eventWidget.getEvent(
                        event,
                        false,
                      );

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => InformationPage(event: event),
                            ),
                          );
                        },
                        child: container,
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}