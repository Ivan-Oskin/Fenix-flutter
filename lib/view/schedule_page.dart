import 'package:fenix/view/event_view.dart';
import 'package:fenix/view/information_page.dart';
import 'package:flutter/material.dart';
import 'package:fenix/model/event.dart';
import 'package:http/http.dart' as http;        // ← Добавили
import 'dart:convert';                         // ← Добавили

class SchedulePage extends StatelessWidget {
  final VoidCallback? onEventPressed;

  const SchedulePage({super.key, this.onEventPressed});

  // ====================== GET ЗАПРОС ======================
  Future<List<Event>> fetchEvents() async {
    try {
      final response = await http.get(
        Uri.parse('http://llvvv.ru:8080/api/meetings'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3NzkyNzg0ODEsInR5cGUiOiJzcGVha2VyIiwidXNlcl9pZCI6MiwidXNlcm5hbWUiOiJJdmFuIn0.fGnZ7hfRgHatYqHp1wq9r2_FAqd1QETuR6Cil4qeMBk',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Event.fromMap(json)).toList();
      } else {
        throw Exception('Ошибка сервера: ${response.statusCode}');
      }
    } catch (e) {
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

        // Поиск
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
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Ошибка:\n${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  );
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
                        'assets/images/main_page/pafnuti.png', // потом можно сделать динамическим
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