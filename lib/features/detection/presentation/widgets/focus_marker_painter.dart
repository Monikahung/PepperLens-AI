import 'package:flutter/material.dart';

// Widget untuk membuat kotak tanda fokus kamera
class FocusMarkerPainter extends CustomPainter {
  // Atribut untuk warna, tebal garis, dan panjang garis
  final Color color;
  final double strokeWidth;
  final double cornerLength;

  // Instance dari FokusMarkerPainter yang wajib diisi
  FocusMarkerPainter({
    required this.color,
    required this.strokeWidth,
    required this.cornerLength,
  });

  // Bangun tampilan kotak tanda fokus kamera
  @override
  void paint(Canvas canvas, Size size) {
    // Konfigurasi kuas untuk menggambar garis
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final path = Path();

    // Sudut kiri atas
    path.moveTo(0, cornerLength);
    path.lineTo(0, 0);
    path.lineTo(cornerLength, 0);

    // Sudut kanan atas
    path.moveTo(size.width - cornerLength, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, cornerLength);

    // Sudut kanan bawah
    path.moveTo(size.width, size.height - cornerLength);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width - cornerLength, size.height);

    // Sudut kiri bawah
    path.moveTo(cornerLength, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, size.height - cornerLength);

    // Render seluruh jalur yang telah dibuat ke kanvas
    canvas.drawPath(path, paint);
  }

  // Pastikan tidak perlu konfigurasi ulang painter (false)
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
