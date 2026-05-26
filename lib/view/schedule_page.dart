import 'package:flutter/material.dart';
import 'package:fenix/model/event.dart';
import 'package:fenix/view/event_view.dart';
import 'package:fenix/view/information_page.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:async';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  // Ключ для принудительного обновления FutureBuilder
  Key _futureKey = UniqueKey();

  Future<List<Event>> fetchEvents() async {
    try {
      final storage = const FlutterSecureStorage();
      final String? token = await storage.read(key: 'jwt_token');

      final response = await http
          .get(
        Uri.parse('http://llvvv.ru:8080/api/meetings'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode != 200) {
        throw Exception('Server error: ${response.statusCode}');
      }

      final List<dynamic> data = jsonDecode(response.body);
      List<Event> events = [];

      for (var json in data) {
        Event event = Event.fromMap(json);

        try {
          final photoUrl =
              'http://llvvv.ru:8080/api/meetings/${event.id}/photo/';
          final photoResponse = await http.get(
            Uri.parse(photoUrl),
            headers: {'Authorization': 'Bearer $token'},
          );

          if (photoResponse.statusCode == 200 &&
              photoResponse.bodyBytes.isNotEmpty) {
            event.photoBytes = photoResponse.bodyBytes;
          }
        } catch (_) {
          // Игнорируем ошибки загрузки фото
        }

        events.add(event);
      }

      return events;
    } on SocketException {
      throw Exception('NO_INTERNET');
    } on TimeoutException {
      throw Exception('NO_INTERNET');
    } catch (e) {
      print("🔥 Другая ошибка: $e");
      rethrow;
    }
  }

  void _refresh() {
    setState(() {
      _futureKey = UniqueKey(); // Принудительно обновляем FutureBuilder
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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

        Expanded(
          child: SizedBox(
            width: 381,
            child: FutureBuilder<List<Event>>(
              key: _futureKey,                    // ← Важно!
              future: fetchEvents(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  final errorMsg = snapshot.error.toString();

                  if (errorMsg.contains('NO_INTERNET')) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.wifi_off,
                            size: 70,
                            color: Colors.orange,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Проблемы с интернетом",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF484C52),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Проверьте подключение\nи попробуйте снова",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _refresh,
                            icon: const Icon(Icons.refresh),
                            label: const Text("Повторить"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFC67C4E),
                              foregroundColor: Colors.white,           // ← Это меняет цвет текста и иконки
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return const SizedBox.shrink();
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
                      final container = eventWidget.getEvent(event, false);

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