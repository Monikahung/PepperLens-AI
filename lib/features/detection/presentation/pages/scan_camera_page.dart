import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:opencv_dart/opencv_dart.dart' as cv;
import 'package:pepperlens_ai/core/constants/colors.dart';
import 'package:pepperlens_ai/core/constants/text_style.dart';
import 'package:pepperlens_ai/core/controllers/navigation_controller.dart';
import 'package:pepperlens_ai/features/detection/presentation/widgets/camera_exposure_controller.dart';
import 'package:pepperlens_ai/features/detection/presentation/widgets/focus_marker_painter.dart';

// Halaman utama untuk menampilkan ambil gambar menggunakan kamera maupun upload gambar dari penyimpanan
class ScanCameraPage extends StatefulWidget {
  const ScanCameraPage({super.key});

  @override
  State<ScanCameraPage> createState() => _ScanCameraPageState();
}

class _ScanCameraPageState extends State<ScanCameraPage> {
  // Controller utama kamera
  CameraController? _controller;

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

  // Panggil saat widget pertama kali dibuat
  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  // Inisialisasi kamera
  Future<void> _initializeCamera() async {
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

  // Ambil gambar dari galeri
  Future<void> _pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    // Jika pengguna memilih gambar
    if (image != null) {
      debugPrint("Gambar dipilih: ${image.path}");
    }
  }

  // Potret objek dan crop gambar
  Future<void> _takePictureAndValidate() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      setState(() {
        _isProcessing = true;
        _errorMessage = null;
        _loadingMessage = "Mengambil gambar";
      });

      // Ambil gambar asli dari kamera
      final XFile rawImage = await _controller!.takePicture();
      final String imagePath = rawImage.path;

      debugPrint("Foto asli diambil: $imagePath");

      // Jeda agar file siap diakses
      setState(() => _loadingMessage = "Memproses gambar");
      await Future.delayed(const Duration(milliseconds: 100));

      // Validasi kualitas gambar
      await _validateImageQuality(imagePath);
    } catch (e) {
      debugPrint("Error saat mengambil foto: $e");
      setState(() {
        _isProcessing = false;
        _errorMessage = "Gagal mengambil gambar";
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

      // Jika lebar di bawah 768 px atau tinggi di bawah 1024 px
      debugPrint("Resolusi: ${mat.cols}x${mat.rows}");
      if (mat.width < 768 || mat.height < 1024) {
        throw "Resolusi gambar terlalu kecil\nMinimal 768x1024px";
      }

      // CEK PENCAHAYAAN (LUMINANCE)
      setState(() => _loadingMessage = "Menganalisis pencahayaan");
      await Future.delayed(const Duration(milliseconds: 500));

      // Konversi ke grayscale
      gray = cv.cvtColor(mat, cv.COLOR_BGR2GRAY);

      // Hitung pencahayaan (luminance)
      final meanValue = cv.mean(gray);
      double avgLuminance = meanValue.val[0];

      // Jika threshold di bawah 40 (gelap)
      if (avgLuminance < 40) throw "Gambar terlalu gelap";
      // Jika threshold di atas 230 (silau)
      if (avgLuminance > 230) throw "Gambar terlalu terang";

      // CEK BLUR (LAPLACIAN VARIANCE)
      setState(() => _loadingMessage = "Menganalisis fokus gambar");
      await Future.delayed(const Duration(milliseconds: 500));

      // Pengecekan blur (laplacian variance)
      laplacian = await cv.laplacianAsync(gray, cv.MatType.CV_64F);
      final (_, stddev) = cv.meanStdDev(laplacian);
      double blurScore = stddev.val[0] * stddev.val[0];

      // Jika threshold di bawah 100 (blur)
      if (blurScore < 100) throw "Gambar terlalu blur";

      // Jika berhasil lolos ketiga validasi tersebut
      setState(() => _loadingMessage = "Lolos cek kualitas");
      await Future.delayed(const Duration(milliseconds: 500));

      debugPrint("Siap kirim ke YOLO");
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isProcessing = false;
      });

      // Sembunyikan error otomatis setelah 3 detik
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _errorMessage = null);
      });
    } finally {
      // Hapus mat dari memori C++
      mat?.release();
      gray?.release();
      laplacian?.release();
      // Sementara selesai proses
      setState(() => _isProcessing = false);
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
        canPop: !_isProcessing,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;

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
                                    : _pickImageFromGallery,
                              ),

                              // Tombol capture (ambil gambar)
                              GestureDetector(
                                onTap: _isProcessing
                                    ? null
                                    : () async {
                                        await _takePictureAndValidate();
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
