import 'package:fenix/model/event.dart';
import 'package:fenix/view/information_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FindByIdPage extends StatefulWidget {
  final VoidCallback? onBackToMenu;

  const FindByIdPage({super.key, this.onBackToMenu});

  @override
  State<FindByIdPage> createState() => _FindByIdPageState();
}

class _FindByIdPageState extends State<FindByIdPage> {
  final TextEditingController _idController = TextEditingController();
  bool _isLoading = false;

  final welcomeText = const Text(
    "Вход по ID",
    textAlign: TextAlign.center,
    style: TextStyle(
      fontSize: 36,
      fontFamily: 'inter',
      color: Color(0xFF484C52),
      fontWeight: FontWeight.w600,
    ),
  );

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  Future<void> _searchById() async {
    final idText = _idController.text.trim();

    if (idText.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Введите ID мероприятия")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final storage = const FlutterSecureStorage();
      final String? token = await storage.read(key: 'jwt_token');

      if (token == null) {
        throw Exception("Токен не найден");
      }

      final response = await http.get(
        Uri.parse('http://llvvv.ru:8080/api/meetings/$idText'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        throw Exception("Мероприятие не найдено");
      }

      final Map<String, dynamic> data = json.decode(response.body);
      Event event = Event.fromMap(data);

      try {
        final photoResponse = await http.get(
          Uri.parse('http://llvvv.ru:8080/api/meetings/${event.id}/photo/'),
          headers: {'Authorization': 'Bearer $token'},
        );

        if (photoResponse.statusCode == 200 &&
            photoResponse.bodyBytes.isNotEmpty) {
          event.photoBytes = photoResponse.bodyBytes;
        }
      } catch (e) {
        print("Ошибка загрузки фото: $e");
      }

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                InformationPage(event: event, onDataChanged: () {}),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Не удалось найти мероприятие: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Welcome Block
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Align(
              alignment: Alignment.topCenter,
              child: SizedBox(width: 330, child: welcomeText),
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
                  controller: _idController,
                  keyboardType: TextInputType.number,
                  cursorColor: const Color(0xFFC67C4E),
                  style: const TextStyle(color: Color(0xBF484C52)),
                  decoration: InputDecoration(
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xBF484C52)),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFC67C4E)),
                    ),
                    hintText: 'Введите ID',
                    hintStyle: const TextStyle(color: Color(0xBF484C52)),
                  ),
                ),
              ),
              IconButton(
                onPressed: _isLoading ? null : _searchById,
                icon: _isLoading
                    ? const SizedBox(
                        width: 41,
                        height: 41,
                        child: CircularProgressIndicator(strokeWidth: 3),
                      )
                    : Image.asset(
                        "assets/images/main_page/loupe.png",
                        width: 41,
                        height: 41,
                      ),
              ),
            ],
          ),
        ),

        // Кнопка назад
        GestureDetector(
          onTap: widget.onBackToMenu ?? () {},
          child: Container(
            margin: const EdgeInsets.only(top: 20),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFD9D9D9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              "Выйти в меню",
              style: TextStyle(fontSize: 18, color: Color(0xFF484C52)),
            ),
          ),
        ),
      ],
    );
  }
}
