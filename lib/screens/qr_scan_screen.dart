import 'dart:io';
import 'package:flutter/foundation.dart';
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

  // 시뮬레이터 환경인지 확인
  bool get isSimulatorDevice {
    if (kIsWeb) return false;
    return !(Platform.isAndroid || Platform.isIOS) || kDebugMode;
  }

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

  // QR 카메라 뷰가 생성될 때 호출되는 콜백
  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (isScanned) return;

      final code = scanData.code;

      if (code == null || code.isEmpty) {
        // QR 인식 실패
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('QR 코드 인식 실패')));
        controller.resumeCamera();
        return;
      }

      // QR 인식 성공
      isScanned = true;
      Navigator.pop(context, code);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR 코드 스캔')),
      body:
          isSimulatorDevice
              ? Center(
                child: ElevatedButton(
                  onPressed: () {
                    // 시뮬레이터에서는 테스트용 ID 리턴
                    Navigator.pop(context, "umbrella_01");
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
