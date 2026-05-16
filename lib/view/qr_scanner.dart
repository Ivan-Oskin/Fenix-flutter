import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  bool isScanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Сканирование QR-кода"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: MobileScanner(
        onDetect: (capture) {
          if (isScanned) return;

          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            if (barcode.rawValue != null) {
              isScanned = true;
              final String code = barcode.rawValue!;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Отсканировано: $code")),
              );

              // Можно здесь добавить логику перехода на встречу по QR
              Future.delayed(const Duration(seconds: 2), () {
                if (mounted) Navigator.pop(context);
              });
              break;
            }
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pop(context),
        backgroundColor: Colors.red,
        child: const Icon(Icons.close),
      ),
    );
  }
}