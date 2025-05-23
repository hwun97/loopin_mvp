import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScanScreen extends StatefulWidget {
  const QRScanScreen({super.key});

  @override
  State<QRScanScreen> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  bool isScanned = false;
  final MobileScannerController cameraController = MobileScannerController();

  // 시뮬레이터 환경인지 확인
  bool get isSimulatorDevice {
    if (kIsWeb) return false;
    return !(Platform.isAndroid || Platform.isIOS) || kDebugMode;
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void onDetect(BarcodeCapture capture) {
    if (isScanned) return;
    final barcode = capture.barcodes.first;
    final code = barcode.rawValue;

    if (code == null || code.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('QR 코드 인식 실패')));
      return;
    }

    isScanned = true;
    Navigator.pop(context, code);
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
                    Navigator.pop(context, "station_01");
                  },
                  child: const Text('테스트용 QR 스캔 (station_01)'),
                ),
              )
              : MobileScanner(
                controller: cameraController,
                onDetect: onDetect,
                // overlay: ScannerOverlay(), // 사용자에게 인식 범위를 시각적으로 안내
              ),
    );
  }
}

/// 선택사항: 기존 QrScannerOverlayShape 비슷한 느낌의 오버레이 위젯
class ScannerOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: ScannerOverlayPainter(), size: Size.infinite);
  }
}

class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint =
        Paint()
          ..color = Colors.black.withOpacity(0.5)
          ..style = PaintingStyle.fill;

    final double cutOutSize = 250;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final Rect cutOutRect = Rect.fromCenter(
      center: center,
      width: cutOutSize,
      height: cutOutSize,
    );

    final Path background =
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final Path cutOut = Path()..addRect(cutOutRect);
    final Path overlayPath = Path.combine(
      PathOperation.difference,
      background,
      cutOut,
    );

    canvas.drawPath(overlayPath, paint);

    final borderPaint =
        Paint()
          ..color = Colors.blue
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4;

    canvas.drawRect(cutOutRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
