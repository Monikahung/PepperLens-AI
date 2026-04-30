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
import 'package:device_info_plus/device_info_plus.dart';
import 'package:pepperlens_ai/core/constants/colors.dart';
import 'package:pepperlens_ai/core/constants/text_style.dart';
import 'package:pepperlens_ai/core/controllers/navigation_controller.dart';
import 'package:pepperlens_ai/features/detection/data/repositories/detection_repository.dart';
import 'package:pepperlens_ai/features/detection/presentation/widgets/camera_exposure_controller.dart';
import 'package:pepperlens_ai/features/detection/presentation/widgets/focus_marker_painter.dart';
import 'package:pepperlens_ai/features/detection/presentation/pages/detection_result_page.dart';
import 'package:pepperlens_ai/features/detection/logic/yolo_detection_service.dart';
import 'package:pepperlens_ai/features/detection/logic/image_processor.dart';

// Halaman utama untuk menampilkan ambil gambar menggunakan kamera maupun upload gambar dari penyimpanan
class ScanCameraPage extends StatefulWidget {
  const ScanCameraPage({super.key});

  @override
  State<ScanCameraPage> createState() => _ScanCameraPageState();
}

class _ScanCameraPageState extends State<ScanCameraPage> {
  // Controller utama kamera
  CameraController? _controller;

  // Service untuk deteksi penyakit
  final YoloDetectionService _yoloService = YoloDetectionService();

  // Service untuk memproses gambar
  final ImageProcessor _imageProcessor = ImageProcessor();

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

  // Panggil saat widget pertama kali dibuat
  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _yoloService.initModel().catchError((e) {
      setState(() {
        _errorMessage = "Gagal memuat AI: $e";
      });
    });
  }

  // Inisialisasi kamera
  Future<void> _initializeCamera() async {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    final sdkInt = androidInfo.version.sdkInt;

    PermissionStatus cameraStatus;
    PermissionStatus storageStatus;

    if (sdkInt >= 30) {
      // Android 11 ke atas
      cameraStatus = await Permission.camera.request();
      storageStatus = await Permission.manageExternalStorage.request();

      // Khusus manageExternalStorage apabila statusnya denied
      if (storageStatus.isDenied) {
        storageStatus = await Permission.manageExternalStorage.status;
      }
    } else {
      // Android 10 ke bawah
      Map<Permission, PermissionStatus> statuses = await [
        Permission.camera,
        Permission.storage,
      ].request();
      cameraStatus = statuses[Permission.camera]!;
      storageStatus = statuses[Permission.storage]!;
    }

    // Cek apakah ada izin yang ditolak
    if (cameraStatus.isDenied || storageStatus.isDenied) {
      setState(() {
        _errorMessage = "Wajib mengizinkan kamera dan penyimpanan";
      });

      // Jika permanen ditolak, navigasi ke pengaturan
      if (cameraStatus.isPermanentlyDenied ||
          storageStatus.isPermanentlyDenied) {
        openAppSettings();
      }

      return;
    }

    try {
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
    } catch (e) {
      setState(() {
        _errorMessage = "Gagal memuat kamera: $e";
      });
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

      // Cek resolusi gambar
      setState(() => _loadingMessage = "Memeriksa resolusi");
      await Future.delayed(const Duration(milliseconds: 200));

      // Ambil resolusi asli gambar
      cv.Mat matSize = cv.imread(sourcePath);
      int originalW = matSize.cols;
      int originalH = matSize.rows;

      // Jika lebar di bawah 640 px atau tinggi di bawah 640 px
      if (originalW < 640 || originalH < 640) {
        throw "Resolusi gambar terlalu kecil\nMinimal 640x640px";
      }
      matSize.release();

      // Cek kualitas gambar berhasil
      setState(() => _loadingMessage = "Lolos cek kualitas");
      await Future.delayed(const Duration(milliseconds: 200));

      // Simpan gambar mentah ke internal (kompresi 70%)
      setState(() => _loadingMessage = "Menyimpan gambar asli");
      await Future.delayed(const Duration(milliseconds: 200));
      final directory = await getApplicationDocumentsDirectory();
      final String internalPath =
          '${directory.path}/mentah_${DateTime.now().millisecondsSinceEpoch}.jpg';

      cv.Mat matRaw = cv.imread(sourcePath);
      _imageProcessor.saveImage(matRaw, internalPath, quality: 70);
      matRaw.release();

      // Tahap pre-processing gambar
      setState(() => _loadingMessage = "Mendeteksi penyakit");
      await Future.delayed(const Duration(milliseconds: 200));
      final inputData = await _yoloService.preProcessYOLO(sourcePath);

      // Tahap inference
      List<Map<String, dynamic>> results = await _yoloService.runInference(
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

      // Tahap penggambaran kotak hasil deteksi
      setState(() => _loadingMessage = "Mengolah hasil deteksi");
      await Future.delayed(const Duration(milliseconds: 200));
      cv.Mat matResult = cv.imread(sourcePath);
      _imageProcessor.drawBoundingBoxes(matResult, results);

      // Tahap penyimpanan hasil
      setState(() => _loadingMessage = "Menyimpan hasil deteksi");
      await Future.delayed(const Duration(milliseconds: 200));
      final String resultPath =
          '${directory.path}/hasil_${DateTime.now().millisecondsSinceEpoch}.jpg';
      _imageProcessor.saveImage(matResult, resultPath, quality: 95);
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
        Get.to(() => DetectionResultPage(idResult: idNewResult));
      }
    } catch (e) {
      debugPrint(e.toString());
      setState(() {
        _errorMessage = e.toString();
      });

      // Hilangkan pesan error setelah 2 detik
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _errorMessage = null);
        }
      });
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
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

      // Cek resolusi gambar
      setState(() => _loadingMessage = "Memeriksa resolusi");
      await Future.delayed(const Duration(milliseconds: 200));

      // Ambil resolusi asli gambar
      cv.Mat matSize = cv.imread(cachePath);
      int originalW = matSize.cols;
      int originalH = matSize.rows;

      // Jika lebar di bawah 640 px atau tinggi di bawah 640 px
      if (originalW < 640 || originalH < 640) {
        throw "Resolusi gambar terlalu kecil\nMinimal 640x640px";
      }
      matSize.release();

      // Cek kualitas gambar berhasil
      setState(() => _loadingMessage = "Lolos cek kualitas");
      await Future.delayed(const Duration(milliseconds: 200));

      // Simpan gambar mentah ke internal (kompresi 70%)
      setState(() => _loadingMessage = "Menyimpan gambar asli");
      await Future.delayed(const Duration(milliseconds: 200));
      final directory = await getApplicationDocumentsDirectory();
      final String internalPath =
          '${directory.path}/mentah_${DateTime.now().millisecondsSinceEpoch}.jpg';

      cv.Mat matRaw = cv.imread(cachePath);
      _imageProcessor.saveImage(matRaw, internalPath, quality: 70);
      matRaw.release();

      // Tahap pre-processing gambar
      setState(() => _loadingMessage = "Mendeteksi penyakit");
      await Future.delayed(const Duration(milliseconds: 200));
      final inputData = await _yoloService.preProcessYOLO(cachePath);

      // Tahap inference
      List<Map<String, dynamic>> results = await _yoloService.runInference(
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

      // Tahap penggambaran kotak hasil deteksi
      setState(() => _loadingMessage = "Mengolah hasil deteksi");
      await Future.delayed(const Duration(milliseconds: 200));
      cv.Mat matResult = cv.imread(cachePath);
      _imageProcessor.drawBoundingBoxes(matResult, results);

      // Tahap penyimpanan hasil
      setState(() => _loadingMessage = "Menyimpan hasil deteksi");
      await Future.delayed(const Duration(milliseconds: 200));
      final String resultCachePath = cachePath.replaceAll(
        '.jpg',
        '_result.jpg',
      );
      _imageProcessor.saveImage(matResult, resultCachePath, quality: 95);
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
        Get.to(() => DetectionResultPage(idResult: idNewResult));
      }

      // Bersihkan cache
      if (await File(cachePath).exists()) await File(cachePath).delete();
    } catch (e) {
      debugPrint(e.toString());
      setState(() {
        _errorMessage = e.toString();
      });

      // Hilangkan pesan error setelah 2 detik
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _errorMessage = null);
        }
      });
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
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
        systemStatusBarContrastEnforced: false,

        systemNavigationBarColor: AppColors.mysticJade,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarDividerColor: AppColors.transparent,
        systemNavigationBarContrastEnforced: false,
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
            Get.back();
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.black,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(0),
            child: AppBar(
              backgroundColor: AppColors.honeydew,
              elevation: 0,
              automaticallyImplyLeading: false,
            ),
          ),
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
                bottom: true,
                top: true,
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
                                  Get.back();
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
          bottomNavigationBar: Container(
            color: AppColors.mysticJade,
            child: SafeArea(top: false, child: const SizedBox.shrink()),
          ),
        ),
      ),
    );
  }
}
