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

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void onDetect(BarcodeCapture capture) async {
    try {
      if (isScanned) return;
      final barcode = capture.barcodes.first;
      final code = barcode.rawValue;

      debugPrint('[QRScanScreen] 감지된 코드: $code');

      if (code == null || code.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('QR 코드 인식 실패')));
        }
        return;
      }

      isScanned = true;
      debugPrint('[QRScanScreen] Navigator.pop 시작');
      if (mounted) {
        Navigator.pop(context, code);
      }
      debugPrint('[QRScanScreen] Navigator.pop 완료');
    } catch (e, stack) {
      debugPrint('[QRScanScreen] QR 처리 중 예외 발생: $e');
      debugPrint('[QRScanScreen] 스택트레이스: $stack');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('QR 처리 중 오류 발생: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF21c3c5),
        title: const Text('QR 코드 스캔'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () {
              debugPrint('[QRScanScreen] 테스트용 강제 입력: station_01');
              if (!isScanned && mounted) {
                isScanned = true;
                Navigator.pop(context, 'station_01');
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(controller: cameraController, onDetect: onDetect),
          const ScannerOverlay(),
        ],
      ),
    );
  }
}

class ScannerOverlay extends StatelessWidget {
  const ScannerOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: ScannerOverlayPainter(), size: Size.infinite);
  }
}

class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
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

    final background =
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final cutOut = Path()..addRect(cutOutRect);
    final overlayPath = Path.combine(
      PathOperation.difference,
      background,
      cutOut,
    );

    canvas.drawPath(overlayPath, paint);

    final borderPaint =
        Paint()
          ..color = const Color(0xFF21c3c5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4;

    canvas.drawRect(cutOutRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
