// lib/app/modules/asset_data/views/qr_scanner_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../controllers/qr_scanner_controller.dart';

class QrScannerView extends GetView<QrScannerController> {
  const QrScannerView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        actions: [
          // Flashlight toggle button
          Obx(() => controller.hasTorch.value
              ? IconButton(
                  icon: Icon(
                    controller.isTorchOn.value
                        ? Icons.flash_on
                        : Icons.flash_off,
                  ),
                  onPressed: controller.toggleTorch,
                )
              : const SizedBox()),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: _buildScannerView(),
          ),
          Expanded(
            flex: 2,
            child: _buildInstructions(context),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerView() {
    return Stack(
      children: [
        // QR Scanner
        MobileScanner(
          controller: controller.cameraController,
          onDetect: controller.onBarcodeDetected,
        ),
        
        // Scanner overlay
        CustomPaint(
          painter: ScannerOverlayPainter(),
          child: Container(),
        ),
      ],
    );
  }

  Widget _buildInstructions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.qr_code_scanner,
            size: 40,
            color: Color(0xFF12B1B9),
          ),
          const SizedBox(height: 16),
          const Text(
            'Arahkan kamera ke QR Code aset',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'QR Code akan terdeteksi secara otomatis',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Custom overlay painter for scanner
class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double scanAreaSize = size.width * 0.7;
    final double cornerSize = 32;
    
    // Draw semi-transparent dark background
    final Paint backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    
    // Draw scanner cutout
    final Path backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRect(Rect.fromCenter(
        center: Offset(centerX, centerY),
        width: scanAreaSize,
        height: scanAreaSize,
      ))
      ..fillType = PathFillType.evenOdd;
    
    canvas.drawPath(backgroundPath, backgroundPaint);
    
    // Define scan area corners
    final Paint cornerPaint = Paint()
      ..color = const Color(0xFF12B1B9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    
    final double left = centerX - scanAreaSize / 2;
    final double top = centerY - scanAreaSize / 2;
    final double right = centerX + scanAreaSize / 2;
    final double bottom = centerY + scanAreaSize / 2;
    
    // Top left corner
    canvas.drawPath(
      Path()
        ..moveTo(left, top + cornerSize)
        ..lineTo(left, top)
        ..lineTo(left + cornerSize, top),
      cornerPaint,
    );
    
    // Top right corner
    canvas.drawPath(
      Path()
        ..moveTo(right - cornerSize, top)
        ..lineTo(right, top)
        ..lineTo(right, top + cornerSize),
      cornerPaint,
    );
    
    // Bottom left corner
    canvas.drawPath(
      Path()
        ..moveTo(left, bottom - cornerSize)
        ..lineTo(left, bottom)
        ..lineTo(left + cornerSize, bottom),
      cornerPaint,
    );
    
    // Bottom right corner
    canvas.drawPath(
      Path()
        ..moveTo(right - cornerSize, bottom)
        ..lineTo(right, bottom)
        ..lineTo(right, bottom - cornerSize),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}