import 'package:fenix/model/event.dart';
import 'package:flutter/material.dart';

class InformationPage extends StatelessWidget {
  final Event event;

  const InformationPage({
    super.key,
    required this.event,
  });

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
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Заголовок
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                child: Text(
                  event.title,
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

            // Дата и место
            SizedBox(
              width: 330,
              child: Column(
                children: [
                  Text(
                    event.startDate ?? '',
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    event.location ?? "Место не указано",
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Кнопки действий
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildActionButton("Записаться", const Color(0xFFC67C4E), () {}),
                  _buildActionButton("Подключиться", const Color(0xFF484C52), () {}),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // === Изображение с сервера ===
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: _buildEventImage(),
              ),
            ),

            const SizedBox(height: 30),

            // Описание
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                event.description ?? "Описание мероприятия отсутствует.",
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

  // Новый метод для отображения фото
  Widget _buildEventImage() {
    if (event.photoBytes != null && event.photoBytes!.isNotEmpty) {
      return Image.memory(
        event.photoBytes!,
        width: 285,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            "assets/images/main_page/pafnuti.png",
            width: 285,
            fit: BoxFit.contain,
          );
        },
      );
    } else {
      // Если фото нет — показываем запасное
      return Image.asset(
        "assets/images/main_page/pafnuti.png",
        width: 285,
        fit: BoxFit.contain,
      );
    }
  }

  Widget _buildActionButton(String text, Color color, VoidCallback onTap) {
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