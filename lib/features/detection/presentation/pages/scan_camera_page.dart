import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:opencv_dart/opencv_dart.dart' as cv;
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pepperlens_ai/core/constants/colors.dart';
import 'package:pepperlens_ai/core/constants/text_style.dart';
import 'package:pepperlens_ai/core/controllers/navigation_controller.dart';
import 'package:pepperlens_ai/features/detection/data/repositories/detection_repository.dart';
import 'package:pepperlens_ai/features/detection/presentation/widgets/camera_exposure_controller.dart';
import 'package:pepperlens_ai/features/detection/presentation/widgets/focus_marker_painter.dart';
import 'package:pepperlens_ai/features/detection/presentation/pages/detection_result_page.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

// Halaman utama untuk menampilkan ambil gambar menggunakan kamera maupun upload gambar dari penyimpanan
class ScanCameraPage extends StatefulWidget {
  const ScanCameraPage({super.key});

  @override
  State<ScanCameraPage> createState() => _ScanCameraPageState();
}

class _ScanCameraPageState extends State<ScanCameraPage> {
  // Controller utama kamera
  CameraController? _controller;

  // Penerjemah untuk menjalankan model AI
  Interpreter? _interpreter;

  // List kamera yang tersedia di perangkat
  List<CameraDescription>? _cameras;

  // Status flash (on/off)
  bool _isFlashOn = false;

  // Variabel exposure dan fokus
  Offset? _tapPosition;
  double _exposureOffset = 0.0;
  double _minExposure = 0.0;
  double _maxExposure = 0.0;
  bool _showFocusCircle = false;
  Timer? _focusTimer;

  // Variabel zoom
  double _currentZoomLevel = 1.0;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _baseZoomLevel = 1.0;

  // Variabel loading dan error
  bool _isProcessing = false;
  String _loadingMessage = "";
  String? _errorMessage;

  // Image picker untuk ambil gambar dari galeri
  final ImagePicker _picker = ImagePicker();

  // Variabel pengunci picker
  bool _isPickerActive = false;

  // Label penyakit
  final List<String> _pepperLabels = ["BPB", "Hawar", "Keriting", "Kuning"];

  // Panggil saat widget pertama kali dibuat
  @override
  void initState() {
    super.initState();
    Future.wait([_initializeCamera(), _loadModel()]);
  }

  // Inisialisasi kamera
  Future<void> _initializeCamera() async {
    // Minta izin kamera dan storage sekaligus di awal
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.storage,
    ].request();

    // Cek apakah ada izin yang ditolak
    if (statuses[Permission.camera]!.isDenied ||
        statuses[Permission.storage]!.isDenied) {
      setState(() {
        _errorMessage = "Wajib mengizinkan kamera dan penyimpanan";
      });
      return;
    }

    // Ambil daftar kamera yang tersedia
    _cameras = await availableCameras();

    // Pastikan kamera tersedia
    if (_cameras != null && _cameras!.isNotEmpty) {
      // Gunakan kamera belakang
      _controller = CameraController(
        _cameras![0],
        ResolutionPreset.max,
        enableAudio: false,
      );

      // Inisialisasi kamera
      await _controller!.initialize();

      // Ambil range exposure
      _minExposure = await _controller!.getMinExposureOffset();
      _maxExposure = await _controller!.getMaxExposureOffset();

      // Ambil batas minimun dan maksimum zoom
      _minAvailableZoom = await _controller!.getMinZoomLevel();
      _maxAvailableZoom = await _controller!.getMaxZoomLevel();

      // Update tampilan jika widget masih aktif
      if (mounted) setState(() {});
    }
  }

  // Bersihkan resource saat widget dihapus
  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  // Panggil saat layar diketuk
  void _onTapCanvas(TapUpDetails details, BoxConstraints constraints) async {
    if (_controller == null || !mounted) return;

    // Batalkan timer sebelumnya jika ada ketukan baru
    _focusTimer?.cancel();

    // Hitung koordinat titik fokus (0.0 sampai 1.0)
    final Offset offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );

    // Gerakkan lensa fokus dan exposure kamera ke titik tersebut
    await _controller!.setFocusPoint(offset);
    await _controller!.setExposurePoint(offset);

    if (mounted) {
      setState(() {
        _tapPosition = details.localPosition;
        _showFocusCircle = true;
      });
    }

    // Hilangkan otomatis pengontrol jika tidak disentuh
    _focusTimer = Timer(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() => _showFocusCircle = false);
      }
    });
  }

  // Panggil saat gesture zoom dimulai
  void _handleScaleStart(ScaleStartDetails details) {
    _baseZoomLevel = _currentZoomLevel;
  }

  // Panggil saat gesture zoom berubah
  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (_controller == null) return;

    // Hitung level zoom baru
    double newZoomLevel = (_baseZoomLevel * details.scale).clamp(
      _minAvailableZoom,
      _maxAvailableZoom,
    );

    // Update state dan kamera
    setState(() => _currentZoomLevel = newZoomLevel);
    _controller!.setZoomLevel(newZoomLevel);
  }

  // Ambil gambar dari galeri dan proses gambar hingga terdeteksi penyakit
  Future<void> _pickImageFromGalleryAndProcessing() async {
    if (_isPickerActive) return;

    // Mulai hitung waktu
    Stopwatch stopwatch = Stopwatch()..start();

    try {
      _isPickerActive = true;

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );

      // Jika gambar tidak ditemukan
      if (image == null) {
        _isPickerActive = false;
        return;
      }

      setState(() {
        _isProcessing = true;
        _errorMessage = null;
        _loadingMessage = "Membaca gambar";
      });

      // Alamat path gambar
      final String sourcePath = image.path;
      setState(() => _loadingMessage = "Memproses gambar");
      await Future.delayed(const Duration(milliseconds: 100));

      // Validasi kualitas gambar
      await _validateImageQuality(sourcePath);

      // Ambil resolusi asli gambar
      cv.Mat matSize = cv.imread(sourcePath);
      int originalW = matSize.cols;
      int originalH = matSize.rows;
      matSize.release();

      // Simpan gambar mentah ke internal (kompresi 70%)
      final directory = await getApplicationDocumentsDirectory();
      final String internalPath =
          '${directory.path}/mentah_${DateTime.now().millisecondsSinceEpoch}.jpg';

      cv.Mat matRaw = cv.imread(sourcePath);
      cv.imwrite(
        internalPath,
        matRaw,
        params: cv.VecI32.fromList([cv.IMWRITE_JPEG_QUALITY, 70]),
      );
      matRaw.release();

      // Tahap pre-processing gambar
      final inputData = await preProcessYOLO(sourcePath);

      // Tahap inference
      List<Map<String, dynamic>> results = await _runInference(
        inputData,
        originalW,
        originalH,
      );

      // Jika tidak terdeteksi penyakit
      if (results.isEmpty) {
        setState(() {
          _isProcessing = false;
          _errorMessage = "Tidak terdeteksi penyakit";
        });

        // Hilangkan pesan error setelah 2 detik
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() => _errorMessage = null);
          }
        });

        // Hapus gambar mentah
        if (await File(sourcePath).exists()) await File(sourcePath).delete();

        // Keluar dari fungsi
        return;
      }

      // Tahap penyimpanan hasil
      cv.Mat matResult = cv.imread(sourcePath);
      _drawBoundingBoxes(matResult, results);

      final String resultPath =
          '${directory.path}/hasil_${DateTime.now().millisecondsSinceEpoch}.jpg';

      cv.imwrite(
        resultPath,
        matResult,
        params: cv.VecI32.fromList([cv.IMWRITE_JPEG_QUALITY, 95]),
      );

      await Gal.putImage(resultPath, album: 'PepperLens AI');
      matResult.release();

      // Hentikan hitung waktu
      stopwatch.stop();

      // Konversi ke detik
      double timeProcess = stopwatch.elapsedMilliseconds / 1000.0;

      // Tahap penyimpanan sqlite
      final repo = DetectionRepository();

      int idNewResult = await repo.insertResultDetectionToDatabase(
        pathOriginal: internalPath,
        pathResult: resultPath,
        timeProcess: timeProcess,
        yoloResults: results,
      );

      // Navigasi ke halaman hasil deteksi
      if (mounted) {
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 100),
            pageBuilder: (context, animation, secondaryAnimation) =>
                DetectionResultPage(idResult: idNewResult),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return child;
                },
          ),
        );
      }

      setState(() => _isProcessing = false);
    } catch (e) {
      debugPrint(e.toString());
      setState(() {
        _isProcessing = false;
        _errorMessage = e.toString();
      });

      // Hilangkan pesan error setelah 2 detik
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _errorMessage = null);
        }
      });
    } finally {
      _isPickerActive = false;
    }
  }

  // Potret objek dan crop gambar dan proses gambar hingga terdeteksi penyakit
  Future<void> _takePictureAndProcessing() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    // Mulai hitung waktu
    Stopwatch stopwatch = Stopwatch()..start();

    try {
      setState(() {
        _isProcessing = true;
        _errorMessage = null;
        _loadingMessage = "Mengambil gambar";
      });

      // Ambil gambar asli dari kamera
      final XFile rawImage = await _controller!.takePicture();
      final String cachePath = rawImage.path;

      // Jeda agar file siap diakses
      setState(() => _loadingMessage = "Memproses gambar");
      await Future.delayed(const Duration(milliseconds: 100));

      // Validasi kualitas gambar
      await _validateImageQuality(cachePath);

      // Ambil resolusi asli gambar
      cv.Mat matSize = cv.imread(cachePath);
      int originalW = matSize.cols;
      int originalH = matSize.rows;
      matSize.release();

      // Simpan gambar mentah ke internal (kompresi 70%)
      final directory = await getApplicationDocumentsDirectory();
      final String internalPath =
          '${directory.path}/mentah_${DateTime.now().millisecondsSinceEpoch}.jpg';

      cv.Mat matRaw = cv.imread(cachePath);
      cv.imwrite(
        internalPath,
        matRaw,
        params: cv.VecI32.fromList([cv.IMWRITE_JPEG_QUALITY, 70]),
      );
      matRaw.release();

      // Tahap pre-processing gambar
      final inputData = await preProcessYOLO(cachePath);

      // Tahap inference
      List<Map<String, dynamic>> results = await _runInference(
        inputData,
        originalW,
        originalH,
      );

      // Jika tidak terdeteksi penyakit
      if (results.isEmpty) {
        setState(() {
          _isProcessing = false;
          _errorMessage = "Tidak terdeteksi penyakit";
        });

        // Hilangkan pesan error setelah 2 detik
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() => _errorMessage = null);
          }
        });

        // Hapus gambar mentah
        if (await File(cachePath).exists()) await File(cachePath).delete();

        // Keluar dari fungsi
        return;
      }

      // Tahap penyimpanan hasil
      cv.Mat matResult = cv.imread(cachePath);
      _drawBoundingBoxes(matResult, results);

      final String resultCachePath = cachePath.replaceAll(
        '.jpg',
        '_result.jpg',
      );
      cv.imwrite(
        resultCachePath,
        matResult,
        params: cv.VecI32.fromList([cv.IMWRITE_JPEG_QUALITY, 95]),
      );
      await Gal.putImage(resultCachePath, album: 'PepperLens AI');
      matResult.release();

      // Hentikan hitung waktu
      stopwatch.stop();

      // Konversi ke detik
      double timeProcess = stopwatch.elapsedMilliseconds / 1000.0;

      // Tahap penyimpanan sqlite
      final repo = DetectionRepository();

      int idNewResult = await repo.insertResultDetectionToDatabase(
        pathOriginal: internalPath,
        pathResult: resultCachePath,
        timeProcess: timeProcess,
        yoloResults: results,
      );

      // Navigasi ke halaman hasil deteksi
      if (mounted) {
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 100),
            pageBuilder: (context, animation, secondaryAnimation) =>
                DetectionResultPage(idResult: idNewResult),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return child;
                },
          ),
        );
      }

      // Bersihkan cache
      if (await File(cachePath).exists()) await File(cachePath).delete();

      setState(() => _isProcessing = false);
    } catch (e) {
      debugPrint(e.toString());
      setState(() {
        _isProcessing = false;
        _errorMessage = e.toString();
      });

      // Hilangkan pesan error setelah 2 detik
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _errorMessage = null);
        }
      });
    }
  }

  // Validasi kualitas gambar
  Future<void> _validateImageQuality(String path) async {
    // Deklarasi variabel
    cv.Mat? mat;
    cv.Mat? gray;
    cv.Mat? laplacian;

    try {
      // CEK RESOLUSI
      setState(() => _loadingMessage = "Memeriksa resolusi");
      await Future.delayed(const Duration(milliseconds: 500));

      // Baca gambar pakai opencv
      mat = cv.imread(path);
      if (mat.isEmpty) throw "Gagal membaca gambar";

      // Jika lebar di bawah 640 px atau tinggi di bawah 640 px
      if (mat.width < 640 || mat.height < 640) {
        throw "Resolusi gambar terlalu kecil\nMinimal 640x640px";
      }

      // CEK PENCAHAYAAN (LUMINANCE)
      setState(() => _loadingMessage = "Menganalisis pencahayaan");
      await Future.delayed(const Duration(milliseconds: 500));

      // Konversi ke grayscale
      gray = cv.cvtColor(mat, cv.COLOR_BGR2GRAY);

      // Hitung pencahayaan (luminance)
      final meanValue = cv.mean(gray);
      double avgLuminance = meanValue.val[0];

      // Jika threshold di bawah 30 (gelap)
      if (avgLuminance < 30) throw "Gambar terlalu gelap";
      // Jika threshold di atas 240 (silau)
      if (avgLuminance > 240) throw "Gambar terlalu terang";

      // CEK BLUR (LAPLACIAN VARIANCE)
      setState(() => _loadingMessage = "Menganalisis fokus gambar");
      await Future.delayed(const Duration(milliseconds: 500));

      // Pengecekan blur (laplacian variance)
      laplacian = await cv.laplacianAsync(gray, cv.MatType.CV_64F);
      final (_, stddev) = cv.meanStdDev(laplacian);
      double blurScore = stddev.val[0] * stddev.val[0];

      // Jika threshold di bawah 40 (blur)
      if (blurScore < 40) throw "Gambar terlalu blur";

      // Jika berhasil lolos ketiga validasi tersebut
      setState(() => _loadingMessage = "Lolos cek kualitas");
      await Future.delayed(const Duration(milliseconds: 500));

      // Tampilkan pesan loading bahwa proses deteksi akan berjalan
      setState(() => _loadingMessage = "Mendeteksi penyakit");
      await Future.delayed(const Duration(milliseconds: 100));
    } catch (e) {
      rethrow;
    } finally {
      // Hapus mat dari memori C++
      mat?.release();
      gray?.release();
      laplacian?.release();
      // Sementara selesai proses
      setState(() => _isProcessing = false);
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

  // Load model AI
  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset(
        'assets/model/best_float32.tflite',
      );
      debugPrint("Model AI berhasil dimuat");
    } catch (e) {
      debugPrint("Gagal memuat model AI: $e");
      if (mounted) {
        setState(() => _errorMessage = "Gagal memuat mesin AI: $e");
      }
    }
  }

  // Inference
  Future<List<Map<String, dynamic>>> _runInference(
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

  // Ambil warna berdasarkan label penyakit (format BGR)
  cv.Scalar _getColorByLabel(String label) {
    switch (label) {
      case "BPB":
        return cv.Scalar(0, 0, 255);
      case "Hawar":
        return cv.Scalar(255, 0, 255);
      case "Keriting":
        return cv.Scalar(255, 255, 0);
      case "Kuning":
        return cv.Scalar(255, 255, 255);
      default:
        return cv.Scalar(0, 255, 0);
    }
  }

  // Gambar kotak di sekitar objek yang terdeteksi
  void _drawBoundingBoxes(cv.Mat mat, List<Map<String, dynamic>> results) {
    debugPrint("Menggambar ${results.length} kotak ke matriks");
    if (results.isEmpty) return;

    // Ambil resolusi gambar asli
    final int imgW = mat.cols;
    final int imgH = mat.rows;
    final int maxDim = imgW > imgH ? imgW : imgH;

    // Hitung skala ketebalan garis
    final int lineThickness = (maxDim / 120).clamp(4, 35).toInt();

    // Hitung skala font
    final double fontScale = (maxDim / 720).clamp(1.0, 10.0);

    // Hitung ketebalan font
    final int fontThickness = (lineThickness * 0.8).clamp(2, 25).toInt();

    // Hitung offset teks
    final int textOffset = (lineThickness * 2.2).toInt();

    for (var res in results) {
      // Ambil warna sesuai label hasil deteksi
      final color = _getColorByLabel(res['label']);

      // Gambar kotak
      cv.rectangle(
        mat,
        cv.Rect(res['x'], res['y'], res['w'], res['h']),
        color,
        thickness: lineThickness,
      );

      // Siapkan teks label dan skor (%)
      String labelText = "${res['label']} ${res['score']}%";

      // Tulis teks di atas kotak
      cv.putText(
        mat,
        labelText,
        cv.Point(res['x'], res['y'] - textOffset),
        cv.FONT_HERSHEY_SIMPLEX,
        fontScale,
        color,
        thickness: fontThickness,
      );
    }
  }

  // Bangun tampilan utama
  @override
  Widget build(BuildContext context) {
    // Ukuran lebar dan tinggi focus marker
    double boxWidth = MediaQuery.of(context).size.width * 0.8;
    double boxHeight = boxWidth * (4 / 3);

    // Jika kamera belum siap, tampilkan loading
    if (_controller == null || !_controller!.value.isInitialized) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.mysticJade),
        ),
      );
    }

    // AnnotatedRegion untuk mengontrol tampilan status bar dan navigasi sistem
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.honeydew,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.mysticJade,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;

          // Jika sedang proses validasi, jangan dilakukan back
          if (_isProcessing) return;

          // Paksa indeks kembali ke beranda
          Get.find<NavigationController>().changeIndex(0);

          // Tutup halaman kamera
          if (context.mounted) {
            Navigator.pop(context);
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.black,
          body: Stack(
            children: [
              // Kamera preview, gesture zoom, exposure, dan fokus kamera
              LayoutBuilder(
                builder: (context, constraints) {
                  return GestureDetector(
                    onScaleStart: _isProcessing ? null : _handleScaleStart,
                    onScaleUpdate: _isProcessing ? null : _handleScaleUpdate,
                    onTapUp: _isProcessing
                        ? null
                        : (details) => _onTapCanvas(details, constraints),
                    child: Stack(
                      children: [
                        // Preview kamera
                        SizedBox.expand(child: CameraPreview(_controller!)),

                        // Widget untuk exposure dan fokus kamera
                        if (_showFocusCircle && _tapPosition != null)
                          Positioned(
                            left: _tapPosition!.dx - 35,
                            top: _tapPosition!.dy - 60,
                            child: CameraExposureController(
                              controller: _controller,
                              exposureValue: _exposureOffset,
                              minExposure: _minExposure,
                              maxExposure: _maxExposure,
                              onChanged: (value) {
                                if (mounted) {
                                  setState(() => _exposureOffset = value);
                                }
                              },
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),

              SafeArea(
                child: Column(
                  children: [
                    // Tombol close
                    Padding(
                      padding: const EdgeInsets.only(top: 20, left: 20),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: InkWell(
                          onTap: _isProcessing
                              ? null
                              : () {
                                  Get.find<NavigationController>().changeIndex(
                                    0,
                                  );
                                  Navigator.pop(context);
                                },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppColors.mysticJade,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: AppColors.honeydew,
                              size: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Frame kotak untuk tanda fokus kamera
                    IgnorePointer(
                      child: SizedBox(
                        width: boxWidth,
                        height: boxHeight,

                        child: CustomPaint(
                          painter: FocusMarkerPainter(
                            color: AppColors.honeydew,
                            strokeWidth: 3.0,
                            cornerLength: 30.0,
                          ),
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Area instruksi dan tombol
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Teks instruksi
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 20,
                          ),
                          child: Text(
                            "Arahkan kamera ke daun lada",
                            textAlign: TextAlign.center,
                            style: AppTextStyles.manropeEleven,
                          ),
                        ),

                        const SizedBox(height: 5),

                        // Area tombol
                        Container(
                          height: 125,
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          decoration: const BoxDecoration(
                            color: AppColors.mysticJade,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Ikon folder untuk membuka penyimpanan perangkat
                              IconButton(
                                icon: const Icon(
                                  Icons.folder,
                                  color: AppColors.honeydew,
                                  size: 30,
                                ),
                                onPressed: _isProcessing
                                    ? null
                                    : _pickImageFromGalleryAndProcessing,
                              ),

                              // Tombol capture (ambil gambar)
                              GestureDetector(
                                onTap: _isProcessing
                                    ? null
                                    : () async {
                                        await _takePictureAndProcessing();
                                      },
                                child: Container(
                                  width: 75,
                                  height: 75,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.honeydew,
                                      width: 5,
                                    ),
                                    color: AppColors.transparent,
                                  ),
                                  child: Center(
                                    child: Container(
                                      width: 55,
                                      height: 55,
                                      decoration: const BoxDecoration(
                                        color: AppColors.honeydew,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // Ikon flash
                              IconButton(
                                icon: Icon(
                                  _isFlashOn ? Icons.flash_on : Icons.flash_off,
                                  color: AppColors.honeydew,
                                  size: 30,
                                ),
                                onPressed: _isProcessing
                                    ? null
                                    : () {
                                        setState(() {
                                          _isFlashOn = !_isFlashOn;
                                          _controller!.setFlashMode(
                                            _isFlashOn
                                                ? FlashMode.torch
                                                : FlashMode.off,
                                          );
                                        });
                                      },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Overlay untuk loading dan error
              if (_isProcessing || _errorMessage != null)
                Container(
                  color: AppColors.black.withAlpha((255 * 0.7).round()),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_isProcessing) ...[
                          const SizedBox(
                            width: 50,
                            height: 50,
                            child: Padding(
                              padding: EdgeInsets.all(5.0),
                              child: CircularProgressIndicator(
                                color: AppColors.mysticJade,
                                strokeWidth: 4,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _loadingMessage,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.manropeEleven,
                          ),
                        ],

                        if (_errorMessage != null && !_isProcessing) ...[
                          const Icon(
                            Icons.error_outline,
                            color: Colors.redAccent,
                            size: 50,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.manropeEleven,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
