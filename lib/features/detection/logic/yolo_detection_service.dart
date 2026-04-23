import 'package:flutter/foundation.dart';
import 'package:opencv_dart/opencv_dart.dart' as cv;
import 'package:tflite_flutter/tflite_flutter.dart';

// Logic untuk menangani model dan proses deteksi
class YoloDetectionService {
  // Penerjemah untuk menjalankan model AI
  Interpreter? _interpreter;

  // Label penyakit
  final List<String> _pepperLabels = ["BPB", "Hawar", "Keriting", "Kuning"];

  // Buka model AI
  Future<void> initModel() async {
    try {
      _interpreter = await Interpreter.fromAsset(
        'assets/model/best_float32.tflite',
      );
      debugPrint("Model AI berhasil dimuat");
    } catch (e) {
      debugPrint("Gagal memuat model AI: $e");
      rethrow;
    }
  }

  // Pre-processing gambar
  Future<Uint8List> preProcessYOLO(String imagePath) async {
    // Deklarasi variabel pembersihan memori
    cv.Mat? mat;
    cv.Mat? resized;
    cv.Mat? letterboxed;
    cv.Mat? rgbMat;
    cv.Mat? normalized;

    try {
      // Ambil gambar asli
      mat = cv.imread(imagePath);
      if (mat.isEmpty) throw "Gagal membaca gambar";

      int targetSize = 640;
      int w = mat.cols;
      int h = mat.rows;

      // Hitung rasio (letterboxing)
      double r = targetSize / (w > h ? w : h);
      int newW = (w * r).round();
      int newH = (h * r).round();

      // Resize dengan tetap menjaga rasio gambar asli
      resized = cv.resize(mat, (newW, newH), interpolation: cv.INTER_AREA);

      // Tambahkan padding hitam agar ukurannya 640x640
      int top = (targetSize - newH) ~/ 2;
      int bottom = targetSize - newH - top;
      int left = (targetSize - newW) ~/ 2;
      int right = targetSize - newW - left;

      letterboxed = cv.copyMakeBorder(
        resized,
        top,
        bottom,
        left,
        right,
        cv.BORDER_CONSTANT,
        value: cv.Scalar(114, 114, 114),
      );

      // Konversi warna BGR ke RGB
      rgbMat = cv.cvtColor(letterboxed, cv.COLOR_BGR2RGB);

      // Normalisasi dan konversi ke float32 (0.0 - 1.0)
      normalized = rgbMat.convertTo(cv.MatType.CV_32FC3, alpha: 1.0 / 255.0);

      // Ambil data mentah dengan tipe Float32
      final inputData = normalized.data.sublist(0);

      // Kembalikan sebagai Float32List
      return inputData;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    } finally {
      // Bersihkan memori
      mat?.release();
      resized?.release();
      letterboxed?.release();
      rgbMat?.release();
      normalized?.release();
    }
  }

  // Inference
  Future<List<Map<String, dynamic>>> runInference(
    Uint8List inputData,
    int imgW,
    int imgH,
  ) async {
    if (_interpreter == null) throw "Mesin AI belum siap";

    // Siapkan variabel output sesuai arsitektur YOLOv11
    var output = List<double>.filled(1 * 8 * 8400, 0.0).reshape([1, 8, 8400]);

    // Jalankan proses AI
    _interpreter!.run(inputData, output);

    // Olah hasil output (saring skor tinggi dan mapping koordinat)
    List<Map<String, dynamic>> finalResults = _processYOLOOutput(
      output[0],
      imgW,
      imgH,
    );

    return finalResults;
  }

  // Pengolah output
  List<Map<String, dynamic>> _processYOLOOutput(
    List<List<double>> rawOutput,
    int imgW,
    int imgH,
  ) {
    // Deklarasi variabel untuk menampung hasil deteksi
    List<Map<String, dynamic>> detections = [];

    // Ambil bounding box dengan akurasi di atas 40%
    double confidenceThreshold = 0.4;

    // YOLOv11 output
    for (int i = 0; i < 8400; i++) {
      double maxScore = 0.0;
      int classId = -1;

      // Cari skor tertinggi
      for (int j = 4; j < 8; j++) {
        double currentRawScore = rawOutput[j][i];

        if (currentRawScore > maxScore) {
          maxScore = currentRawScore;
          classId = j - 4;
        }
      }

      // Filter berdasarkan threshold
      if (maxScore > confidenceThreshold) {
        if (classId != -1) {
          // Hitung scaling dan padding
          double gain = 640 / (imgW > imgH ? imgW : imgH);
          double padX = (640 - imgW * gain) / 2;
          double padY = (640 - imgH * gain) / 2;

          // Ambil koordinat center
          double centerX = rawOutput[0][i] * 640;
          double centerY = rawOutput[1][i] * 640;
          double width = rawOutput[2][i] * 640;
          double height = rawOutput[3][i] * 640;

          // Balikkan ke koordinat gambar asli
          double x1 = ((centerX - (width / 2)) - padX) / gain;
          double y1 = ((centerY - (height / 2)) - padY) / gain;
          double wOriginal = width / gain;
          double hOriginal = height / gain;

          detections.add({
            "x": x1.toInt().clamp(0, imgW),
            "y": y1.toInt().clamp(0, imgH),
            "w": wOriginal.toInt().clamp(0, imgW),
            "h": hOriginal.toInt().clamp(0, imgH),
            "score": (maxScore * 100).toInt(),
            "label": _pepperLabels[classId],
          });

          debugPrint(
            "Penyakit: ${_pepperLabels[classId]} Skor: ${(maxScore * 100).toStringAsFixed(0)}%",
          );
        }
      }
    }

    return _applyNMS(detections);
  }

  // NMS (Non-Maximum Suppression) untuk menangani kotak tumpang tindih
  List<Map<String, dynamic>> _applyNMS(List<Map<String, dynamic>> boxes) {
    if (boxes.isEmpty) return [];

    // Urutkan kotak dari skor tertinggi
    boxes.sort((a, b) => b["score"].compareTo(a["score"]));

    List<Map<String, dynamic>> selectedBoxes = [];

    // List penanda kotak yang dibuang
    List<bool> isRemoved = List.filled(boxes.length, false);

    for (int i = 0; i < boxes.length; i++) {
      if (isRemoved[i]) continue;

      // Masukkan kotak terbaik ke hasil akhir
      var current = boxes[i];
      selectedBoxes.add(current);

      // Bandingkan dengan kotak setelahnya
      for (int j = i + 1; j < boxes.length; j++) {
        if (isRemoved[j]) continue;

        // Hitung seberapa banyak tumpang tindihnya (IoU)
        double iou = _calculateIoU(current, boxes[j]);

        // Jika IoU > 0.45, tandai untuk dihapus
        if (iou > 0.45) {
          isRemoved[j] = true;
        }
      }
    }

    return selectedBoxes;
  }

  // IoU (Intersection over Union) untuk menghitung persentase area yang saling beririsan
  double _calculateIoU(Map<String, dynamic> box1, Map<String, dynamic> box2) {
    // Hitung koordinat area irisan (intersection)
    int x1 = box1['x'] > box2['x'] ? box1['x'] : box2['x'];
    int y1 = box1['y'] > box2['y'] ? box1['y'] : box2['y'];
    int x2 = (box1['x'] + box1['w']) < (box2['x'] + box2['w'])
        ? (box1['x'] + box1['w'])
        : (box2['x'] + box2['w']);
    int y2 = (box1['y'] + box1['h']) < (box2['y'] + box2['h'])
        ? (box1['y'] + box1['h'])
        : (box2['y'] + box2['h']);

    // Hitung luas area irisan
    int intersectionWidth = (x2 - x1).clamp(0, 1000000);
    int intersectionHeight = (y2 - y1).clamp(0, 1000000);
    int intersectionArea = intersectionWidth * intersectionHeight;

    // Hitung luas area gabungan (union)
    int box1Area = box1['w'] * box1['h'];
    int box2Area = box2['w'] * box2['h'];
    int unionArea = box1Area + box2Area - intersectionArea;

    if (unionArea <= 0) return 0.0;

    // Hitung IoU
    return intersectionArea / unionArea;
  }
}
