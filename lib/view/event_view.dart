import 'package:fenix/model/event.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';

class EventWidget {
  Container getEvent(
      Event event,
      bool borderShow,
      ) {
    Border border = Border.all(color: Colors.white);
    if (borderShow) {
      border = Border.all(color: Color(0xFFD9D9D9));
    }

    // Определяем, какое изображение показывать
    Widget imageWidget;

    if (event.photoBytes != null && event.photoBytes!.isNotEmpty) {
      // Фото пришло с сервера
      imageWidget = Image.memory(
        event.photoBytes!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            "assets/images/main_page/pafnuti.png",
            fit: BoxFit.cover,
          );
        },
      );
    } else {
      // Запасной вариант — картинка из ассетов
      imageWidget = Image.asset(
        "assets/images/main_page/pafnuti.png",
        fit: BoxFit.cover,
      );
    }

    return Container(
      width: 351,
      height: 113,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFFFFFFFF),
        border: border,
      ),
      child: Center(
        child: SizedBox(
          width: 320,
          child: Row(
            spacing: 20,
            children: [
              SizedBox(
                width: 90,
                height: 90,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Center(child: imageWidget),
                ),
              ),
              Expanded(
                child: SizedBox(
                  width: 195,
                  height: 90,
                  child: Column(
                    spacing: 10,
                    children: [
                      SizedBox(
                        width: 205,
                        child: Text(
                          event.title,
                          style: const TextStyle(color: Color(0xBF484C52)),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(
                        width: 205,
                        child: Text(
                          event.startDate ?? '',
                          textAlign: TextAlign.left,
                          style: const TextStyle(color: Color(0xFF484C52)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}