import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR 코드 스캔')),
      body: MobileScanner(
        allowDuplicates: false,
        onDetect: (barcode, args) {
          final String? code = barcode.rawValue;
          if (code != null) {
            // 스캔 성공하면 ID 반환
            Navigator.of(context).pop(code);
          }
        },
      ),
    );
  }
}
