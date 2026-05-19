import 'package:fenix/model/event.dart';
import 'package:fenix/model/polls.dart';
import 'package:fenix/repository/event_repository.dart';
import 'package:fenix/repository/poll_repository.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class InformationPage extends StatefulWidget {
  final Event event;

  const InformationPage({
    super.key,
    required this.event,
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
    _checkIfRegisteredInDB();   // Проверяем только регистрацию
  }

  // Проверяем, записан ли уже пользователь
  Future<void> _checkIfRegisteredInDB() async {
    final eventRepository = EventRepository();
    final exists = await eventRepository.isEventExists(_event.id ?? '');

    setState(() {
      _isRegistered = exists;
      _isLoading = false;
    });
  }

  // Загружаем polls + сохраняем Event и Polls
  Future<void> _registerAndSave() async {
    setState(() => _isLoading = true);

    try {
      // 1. Загружаем полные данные (с polls)
      final response = await http.get(
        Uri.parse('http://llvvv.ru:8080/api/meetings/${widget.event.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3NzkyODUyOTcsInR5cGUiOiJzcGVha2VyIiwidXNlcl9pZCI6MiwidXNlcm5hbWUiOiJJdmFuIn0.4OV6vvNvY4GzCA8ojB4Dvs9Hv8sQsavsSq8GGKHroSk',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        setState(() {

          if (data['polls'] != null) {
            _polls = (data['polls'] as List)
                .map((item) => Poll.fromMap(item as Map<String, dynamic>))
                .toList();
          }
        });

        // 2. Сохраняем в БД
        final eventRepository = EventRepository();
        final pollRepository = PollRepository();

        await eventRepository.saveEvent(_event);

        for (var poll in _polls) {
          await pollRepository.save(poll);
        }

        setState(() {
          _isRegistered = true;
        });
      }
    } catch (e) {
      print('Ошибка при записи: $e');
      // Можно показать SnackBar с ошибкой
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onRegisterPressed() async {
    await _registerAndSave();
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
                  _event.title,
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
                    _event.startDate ?? '',
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
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
                    _isRegistered ? () {} : null,
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
      "assets/images/main_page/pafnuti.png",
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