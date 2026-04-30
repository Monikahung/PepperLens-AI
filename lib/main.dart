import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pepperlens_ai/core/constants/assets.dart';
import 'package:pepperlens_ai/core/constants/colors.dart';
import 'package:pepperlens_ai/core/constants/text_style.dart';
import 'package:pepperlens_ai/core/database/database_helper.dart';
import 'package:pepperlens_ai/features/home/presentation/pages/home_page.dart';

void main() async {
  // Inisialisasi Flutter sebelum menjalankan operasi asynchronous
  WidgetsFlutterBinding.ensureInitialized();

  // Set mode UI sistem
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Inisialisasi data format tanggal untuk bahasa Indonesia
  await initializeDateFormatting('id_ID', null);

  try {
    // Pesan database sedang diinisialisasi
    debugPrint('Sedang menginisialisasi database saat Splash Screen...');

    // Panggil getter database untuk memicu _onCreate dan Seeding
    await DatabaseHelper().database;

    // Jika berhasil, cetak pesan sukses
    debugPrint('Database berhasil dimuat');
  } catch (e) {
    // Jika terjadi error, cetak pesan error
    debugPrint('Gagal menginisialisasi database: $e');
  }

  // Jalankan aplikasi utama
  runApp(const MyApp());

  // Mengatur warna status bar dan navigasi sistem Android
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: AppColors.honeydew,
      systemNavigationBarColor: AppColors.mysticJade,
      systemNavigationBarContrastEnforced: false,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Widget ini adalah root dari aplikasi
  @override
  Widget build(BuildContext context) {
    // Mengatur warna status bar dan navigasi sistem Android
    return AnnotatedRegion<SystemUiOverlayStyle>(
      // Atur sesuai tema aplikasi
      value: SystemUiOverlayStyle(
        statusBarColor: AppColors.honeydew,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemStatusBarContrastEnforced: false,

        systemNavigationBarColor: AppColors.honeydew,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: AppColors.transparent,
        systemNavigationBarContrastEnforced: false,
      ),
      child: GetMaterialApp(
        title: 'Pepperlens AI',

        // Matikan banner debug di pojok kanan atas
        debugShowCheckedModeBanner: false,

        // Konfigurasi tema global aplikasi
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.mysticJade),
          scaffoldBackgroundColor: AppColors.honeydew,
        ),

        // Tampilkan halaman logo saat aplikasi dimulai
        home: const LogoPage(),
      ),
    );
  }
}

// Halaman menampilkan logo dan nama aplikasi saat dibuka
class LogoPage extends StatefulWidget {
  // Konstruktor untuk LogoPage
  const LogoPage({super.key});

  // Buat state untuk LogoPage
  @override
  State<LogoPage> createState() => _LogoPageState();
}

// State untuk menangani logika tampilan logo dan navigasi
class _LogoPageState extends State<LogoPage> {
  @override
  void initState() {
    super.initState();
    // Simulasi delay untuk menampilkan logo selama 3 detik
    Future.delayed(const Duration(seconds: 3), () {
      // Cek apakah halaman ini masih ada di layar
      if (!mounted) return;

      // Jika masih ada di layar, navigasi ke halaman beranda aplikasi
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    });
  }

  // Bangun tampilan halaman logo
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.honeydew,
      body: SafeArea(
        top: true,
        bottom: true,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // Area logo aplikasi dengan rasio aspek 1:1
              Flexible(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 96.0),
                  child: AspectRatio(
                    aspectRatio: 1 / 1,
                    child: Image.asset(
                      AppAssets.logoPepperLensAI,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        // Jika terjadi error saat memuat gambar, tampilkan pesan error
                        return const Text("Gagal memuat logo");
                      },
                    ),
                  ),
                ),
              ),

              // Jarak vertikal antara logo dan nama aplikasi
              const SizedBox(height: 16),

              // Area nama aplikasi dengan gaya teks khusus
              Flexible(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    "PepperLens AI",
                    textAlign: TextAlign.center,
                    style: AppTextStyles.manropeSix,
                  ),
                ),
              ),

              // Jarak vertikal tambahan di bawah nama aplikasi
              const Flexible(flex: 1, child: SizedBox(height: 64)),
            ],
          ),
        ),
      ),
    );
  }
}
