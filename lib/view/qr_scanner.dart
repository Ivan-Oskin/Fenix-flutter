import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:intl/intl.dart';
import 'package:fenix/model/event.dart';

// ====================== ПАРСЕР QR → Event ======================
// ====================== ПАРСЕР QR → Event ======================
Event? parseEventFromQr(String rawText) {
  try {
    final lines = rawText.split('\n');

    String title = 'Без названия';
    DateTime? date;
    String location = '';
    String id = '';

    for (var line in lines) {
      line = line.trim();
      if (!line.contains(':')) continue;

      final parts = line.split(':');
      final key = parts[0].trim().toLowerCase();
      final value = parts.length > 1 ? parts.sublist(1).join(':').trim() : '';

      print("🔑 Ключ: '$key' | Значение: '$value'"); // для отладки

      switch (key) {
        case 'название':
        case 'title':
          title = value;
          break;

        case 'дата':
        case 'date':
          // Пробуем разные возможные форматы даты
          try {
            date = DateFormat('dd.MM.yyyy HH:mm').parse(value);
          } catch (_) {
            try {
              date = DateFormat('dd.MM.yyyy H:mm').parse(value);
            } catch (_) {}
          }
          break;

        case 'локация':
        case 'location':
        case 'место':
          location = value;
          break;

        case 'id':
        case 'ид':
          id = value;
          break;
      }
    }

    print(
      "📊 Итог парсинга → title: '$title', date: $date, location: '$location', id: '$id'",
    );

    if (date == null) {
      print("❌ Не удалось распарсить дату");
      return null;
    }

    final String dateString = DateFormat('dd.MM.yyyy HH:mm').format(date);
    print("✅ УСПЕШНО: $title | $dateString | $location | $id");

    return Event(
      title: title,
      location: location,
      id: id,
      startDate: dateString,
    );
  } catch (e) {
    print('❌ Ошибка парсинга: $e');
    return null;
  }
}

// ====================== СТРАНИЦА СКАНЕРА ======================
class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  bool isScanned = false;

  void _onDetect(BarcodeCapture capture) {
    if (isScanned) return;

    for (final barcode in capture.barcodes) {
      if (barcode.rawValue == null) continue;

      isScanned = true;
      final String rawCode = barcode.rawValue!;

      final event = parseEventFromQr(rawCode);

      if (event != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Отсканировано: ${event.title}"),
            backgroundColor: Colors.green,
          ),
        );

        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) Navigator.pop(context, event);
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Отсканировано: $rawCode")));
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) Navigator.pop(context, rawCode);
        });
      }
      break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Сканирование QR-кода"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: MobileScanner(onDetect: _onDetect),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pop(context),
        backgroundColor: Colors.red,
        child: const Icon(Icons.close),
      ),
    );
  }
}
