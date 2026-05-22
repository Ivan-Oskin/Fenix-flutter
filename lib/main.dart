import 'package:fenix/repository/event_repository.dart';
import 'package:fenix/repository/poll_repository.dart';
import 'package:fenix/repository/profile_repository.dart';
import 'package:fenix/repository/waiting_repository.dart';
import 'package:fenix/view/auth_screen.dart';
import 'package:fenix/view/find_by_id.dart';
import 'package:fenix/view/main_page.dart';
import 'package:fenix/view/qr_scanner.dart';
import 'package:fenix/view/schedule_page.dart';
import 'package:fenix/view/profile_page.dart';
import 'package:fenix/view/presentation_page.dart';
import 'package:flutter/material.dart';
import 'package:fenix/repository/file_repository.dart';
import 'package:fenix/model/event.dart';
import 'package:fenix/model/polls.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:fenix/view/information_page.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FileStorageService().init();
  // Проверяем есть ли профиль;
  final hasProfile = await ProfileRepository()
      .isProfileEmpty(); // твой метод проверки

  runApp(MyApp(startWithAuth: hasProfile));
}

class MyApp extends StatelessWidget {
  final bool startWithAuth;

  const MyApp({super.key, required this.startWithAuth});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: startWithAuth ? AuthScreen() : MainWidget());
  }
}

class MainWidget extends StatefulWidget {
  const MainWidget({super.key});

  @override
  MainWidgetState createState() => MainWidgetState();
}

class MainWidgetState extends State<MainWidget> {
  final GlobalKey<MainPageState> mainPageKey = GlobalKey<MainPageState>();
  int selectedPage = 1;
  late final List<Widget> pages;
  bool _hasInternet = true;
  bool _wasOffline = false;

  @override
  void initState() {
    super.initState();

    pages = [
      SchedulePage(),
      MainPage(
        key: mainPageKey,
        onScanQrPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const QrScannerPage()),
          );

          if (result == null) return; // пользователь просто закрыл сканер

          if (result is Event) {
            final storage = const FlutterSecureStorage();
            final String? token = await storage.read(key: 'jwt_token');
            // Успешно отсканировали мероприятие
            print("✅ Получено событие: ${result.title}");
            try {
              final photoUrl =
                  'http://llvvv.ru:8080/api/meetings/${result.id}/photo/';

              final photoResponse = await http.get(
                Uri.parse(photoUrl),
                headers: {
                  'Authorization': 'Bearer $token',
                  // используем уже полученный token
                },
              );

              print(
                "📸 Фото ID=${result.id} → ${photoResponse.statusCode} | ${photoResponse.bodyBytes.length} байт",
              );

              if (photoResponse.statusCode == 200 &&
                  photoResponse.bodyBytes.isNotEmpty) {
                result.photoBytes = photoResponse.bodyBytes;
              }
            } catch (e) {
              print("❌ Ошибка фото ID=${result.id}: $e");
            }

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => InformationPage(
                    event: result,
                    onDataChanged: () => mainPageKey.currentState?.refresh()
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Неверный QR-код."),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        onFindMeetingPressed: () => setState(() => selectedPage = 0),
        onEnterByIdPressed: () => setState(() => selectedPage = 3),
        onEventPressed: () => setState(() => selectedPage = 4),
        onDataUpdated: () => setState(() {}),
      ),
      ProfilePage(),
      FindByIdPage(
        onBackToMenu: () => setState(() => selectedPage = 1),
      ).getPage(),
      PresentationPage(),
    ];

    _startInternetListener();
  }

  void _startInternetListener() {
    Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      final bool hasInternetNow =
          results.contains(ConnectivityResult.wifi) ||
          results.contains(ConnectivityResult.mobile);

      setState(() {
        _hasInternet = hasInternetNow;
      });

      // Интернет появился после отсутствия
      if (hasInternetNow && _wasOffline) {
        _onInternetRestored();
      }

      _wasOffline = !hasInternetNow;
    });
  }

  void _onInternetRestored() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("🌐 Интернет восстановлен"),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
    _checkWaitList();
  }

  Future<void> _checkWaitList() async {
    try {
      List<String> wait_list = await WaitingRepository().get();

      print("📋 Найдено ожидающих данных: ${wait_list.length}");

      if (wait_list.isNotEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              "🌐 Интернет восстановлен\nЕсть непрогруженные данные",
            ),
            backgroundColor: Colors.green.shade700,
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: "Загрузить",
              textColor: Colors.white,
              onPressed: () async {
                final storage = const FlutterSecureStorage();
                final String? token = await storage.read(key: 'jwt_token');

                if (token == null) {
                  print("❌ Токен не найден");
                  return;
                }

                int successCount = 0;

                for (String id in wait_list) {
                  try {
                    print("🔄 Загружаем ID: $id");

                    final response = await http.get(
                      Uri.parse('http://llvvv.ru:8080/api/meetings/$id'),
                      headers: {
                        'Content-Type': 'application/json',
                        'Authorization': 'Bearer $token',
                      },
                    );

                    final responsePresentation = await http.get(
                      Uri.parse('http://llvvv.ru:8080/api/meetings/$id/presentation'),
                      headers: {
                        'Content-Type': 'application/json',
                        'Authorization': 'Bearer $token',
                      },
                    );

                    final photoResponse = await http.get(
                      Uri.parse('http://llvvv.ru:8080/api/meetings/$id/photo/'),
                      headers: {'Authorization': 'Bearer $token'},
                    );

                    if (response.statusCode == 200) {
                      final Map<String, dynamic> data = json.decode(response.body);
                      Event event = Event.fromMap(data);

                      // Фото
                      if (photoResponse.statusCode == 200 && photoResponse.bodyBytes.isNotEmpty) {
                        event.photoBytes = photoResponse.bodyBytes;
                      }

                      // Презентация
                      if (responsePresentation.statusCode == 200 &&
                          responsePresentation.bodyBytes.isNotEmpty) {
                        event.presentationBytes = responsePresentation.bodyBytes;
                      }

                      // Опросы
                      List<Poll> polls = [];
                      if (data['polls'] != null) {
                        polls = (data['polls'] as List)
                            .map((item) => Poll.fromMap(item as Map<String, dynamic>))
                            .toList();
                      }

                      // Сохраняем
                      await EventRepository().saveEvent(event);
                      for (var poll in polls) {
                        await PollRepository().save(poll);
                      }

                      // Удаляем из ожидания только при успехе
                      await WaitingRepository().delete(id);
                      successCount++;

                      print("✅ Успешно загружено: ${event.title}");
                    } else {
                      print("⚠️ Сервер вернул ошибку для ID $id");
                    }
                  } catch (e) {
                    print("❌ Ошибка при загрузке ID $id: $e");
                  }
                }

                // === После завершения всего цикла ===
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("✅ Всё обновлено! Загружено $successCount мероприятий"),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 3),
                    ),
                  );

                  // Обновляем текущую страницу
                  setState(() {});
                  mainPageKey.currentState?.refresh();
                }
              },
            ),
          ),
        );
      }
    } catch (e) {
      print("❌ Ошибка в _checkWaitList: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[selectedPage],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedPage > 2 ? 1 : selectedPage,
        onTap: (index) {
          setState(() {
            selectedPage = index;
          });
        },
        selectedItemColor: const Color(0xFFC67C4E),
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Image.asset("assets/images/bottom/calendar.png"),
            activeIcon: Image.asset("assets/images/bottom/calendar_active.png"),
            label: "Расписание",
          ),
          BottomNavigationBarItem(
            icon: Image.asset("assets/images/bottom/main_button.png"),
            activeIcon: Image.asset(
              "assets/images/bottom/main_button_active.png",
            ),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Image.asset("assets/images/bottom/user.png"),
            label: "Профиль",
            activeIcon: Image.asset("assets/images/bottom/user_active.png"),
          ),
        ],
      ),
    );
  }
}
