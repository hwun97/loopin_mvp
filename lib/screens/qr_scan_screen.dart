import 'dart:io';
import 'package:flutter/foundation.dart'; // 추가!!
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRScanScreen extends StatefulWidget {
  const QRScanScreen({super.key});

  @override
  State<QRScanScreen> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool isScanned = false;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    }
    controller?.resumeCamera();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (!isScanned) {
        isScanned = true;
        Navigator.pop(context, scanData.code);
      }
    });
  }

  bool get _isSimulator {
    if (kIsWeb) return false;
    if (Platform.isIOS || Platform.isAndroid) {
      return kDebugMode; // 디버그 모드면 시뮬레이터로 가정
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR 코드 스캔')),
      body:
          _isSimulator
              ? Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, "umbrella_01"); // 테스트용 ID
                  },
                  child: const Text('테스트용 QR 스캔 (umbrella_01)'),
                ),
              )
              : QRView(
                key: qrKey,
                onQRViewCreated: _onQRViewCreated,
                overlay: QrScannerOverlayShape(
                  borderColor: Colors.blue,
                  borderRadius: 10,
                  borderLength: 30,
                  borderWidth: 10,
                  cutOutSize: 250,
                ),
              ),
    );
  }
}
