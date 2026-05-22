import 'package:fenix/model/event.dart';
import 'package:fenix/model/polls.dart';
import 'package:fenix/repository/event_repository.dart';
import 'package:fenix/repository/poll_repository.dart';
import 'package:fenix/repository/waiting_repository.dart';
import 'package:fenix/service/ConnectionService.dart';
import 'package:fenix/view/presentation_page.dart'; // ← Добавь импорт
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class InformationPage extends StatefulWidget {
  final Event event;
  final VoidCallback? onDataChanged;

  const InformationPage({super.key,
    required this.event,
    this.onDataChanged,
  });

  @override
  State<InformationPage> createState() => _InformationPageState();
}

class _InformationPageState extends State<InformationPage> {
  late Event _event;
  List<Poll> _polls = [];
  bool _isRegistered = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _event = widget.event;
    _checkIfRegisteredInDB();
  }

  Future<void> _checkIfRegisteredInDB() async {
    final eventRepository = EventRepository();
    final exists = await eventRepository.isEventExists(_event.id ?? '');

    setState(() {
      _isRegistered = exists;
      _isLoading = false;
    });
  }

  Future<void> _registerAndSave() async {
    final hasNet = await ConnectionService.hasInternet();
    final storage = const FlutterSecureStorage();
    final String? token = await storage.read(key: 'jwt_token');
    if (!hasNet) {
      final eventRepository = EventRepository();

      await eventRepository.saveEvent(_event);
      final waitingRepository = WaitingRepository();

      await waitingRepository.save(_event.id!);
      setState(() {
        _isRegistered = true;
      });
      widget.onDataChanged?.call();
    } else {
      setState(() => _isLoading = true);
      try {
        final response = await http.get(
          Uri.parse('http://llvvv.ru:8080/api/meetings/${widget.event.id}'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        final responsePresentation = await http.get(
          Uri.parse(
            'http://llvvv.ru:8080/api/meetings/${widget.event.id}/presentation',
          ),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);

          if (data['polls'] != null) {
            _polls = (data['polls'] as List)
                .map((item) => Poll.fromMap(item as Map<String, dynamic>))
                .toList();
          }

          final pollRepository = PollRepository();

          for (var poll in _polls) {
            await pollRepository.save(poll);
          }

          if (responsePresentation.statusCode == 200) {
            print("сохраянем презентацию");
            final Uint8List presentationBytes = responsePresentation.bodyBytes;
            _event.presentationBytes = presentationBytes;
          }

          final eventRepository = EventRepository();

          await eventRepository.saveEvent(_event);

          setState(() {
            _isRegistered = true;
            widget.onDataChanged?.call();
          });
        }
      } catch (e) {
        print('Ошибка при записи: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onRegisterPressed() async {
    await _registerAndSave();
  }

  // ←←← НОВЫЙ МЕТОД ←←←
  void _onConnectPressed() async {
    List<Poll> loadedPolls = [];
    Event? loadedEvent; // Делаем nullable
    final String eventId = _event.id ?? '';

    print('🔍 _onConnectPressed вызван');
    print('📌 Event ID: $eventId');

    if (eventId.isNotEmpty) {
      try {
        // Загружаем опросы и событие параллельно
        final results = await Future.wait([
          PollRepository().findAllByEventId(eventId),
          EventRepository().findById(eventId),
        ]);

        loadedPolls = results[0] as List<Poll>;
        loadedEvent = results[1] as Event?;

        print('✅ Найдено опросов в БД: ${loadedPolls.length}');

        if (loadedEvent != null) {
          print('✅ Событие загружено: ${loadedEvent.title}');
        } else {
          print('⚠️ Событие не найдено в БД');
        }

        for (var poll in loadedPolls) {
          print('   • Poll: ${poll.title} | URL: ${poll.url}');
        }
      } catch (e) {
        print('❌ Ошибка при загрузке данных: $e');
      }
    } else {
      print('❌ Event ID пустой!');
    }

    if (!mounted) return;

    // Проверяем, что событие загружено
    if (loadedEvent == null) {
      // Показываем ошибку пользователю
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Не удалось загрузить данные мероприятия'),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PresentationPage(
              event: loadedEvent, // Теперь точно не null
              polls: loadedPolls,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Мероприятие"),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF484C52),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                child: Text(
                  _event.title!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontFamily: 'inter',
                    color: Color(0xFF484C52),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            SizedBox(
              width: 330,
              child: Column(
                children: [
                  Text(
                    _event.startDate!,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _event.location ?? "Место не указано",
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildActionButton(
                    "Записаться",
                    _isRegistered ? Colors.grey : const Color(0xFFC67C4E),
                    _isRegistered ? null : _onRegisterPressed,
                  ),
                  _buildActionButton(
                    "Подключиться",
                    _isRegistered ? Colors.green : Colors.grey,
                    _isRegistered
                        ? _onConnectPressed
                        : null, // ← Изменено
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: _buildEventImage(),
              ),
            ),

            const SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                _event.description ?? "Описание мероприятия отсутствует.",
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF484C52),
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildEventImage() {
    if (_event.photoBytes != null && _event.photoBytes!.isNotEmpty) {
      return Image.memory(_event.photoBytes!, width: 285, fit: BoxFit.contain);
    }
    return Image.asset(
      "assets/images/reg/logo.png",
      width: 285,
      fit: BoxFit.contain,
    );
  }

  Widget _buildActionButton(String text, Color color, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
