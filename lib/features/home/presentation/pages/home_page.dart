import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pepperlens_ai/core/widgets/banner.dart';
import 'package:pepperlens_ai/core/widgets/navbar.dart';
import 'package:pepperlens_ai/core/constants/assets.dart';
import 'package:pepperlens_ai/core/constants/colors.dart';
import 'package:pepperlens_ai/core/constants/text_style.dart';
import 'package:pepperlens_ai/core/controllers/navigation_controller.dart';
import 'package:pepperlens_ai/features/encyclopedia/presentation/pages/encyclopedia_page.dart';
import 'package:pepperlens_ai/features/home/presentation/widgets/menu_card.dart';

// Halaman beranda utama aplikasi
class HomePage extends StatelessWidget {
  HomePage({super.key});

  final NavigationController navBarController = Get.put(NavigationController());

  @override
  Widget build(BuildContext context) {
    // List untuk isi aplikasi
    final List<Widget> pages = [
      _buildHomeContent(),
      const EncyclopediaPage(),
      const Center(child: Text("Halaman Deteksi")),
      const Center(child: Text("Halaman Riwayat")),
      const Center(child: Text("Halaman Panduan")),
    ];

    // AnnotatedRegion untuk mengontrol tampilan status bar dan navigasi sistem
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: AppColors.honeydew,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.mysticJade,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.honeydew,

        // Obx membuat body otomatis update saat selectedIndex di controller berubah
        body: Obx(() {
          return AnimatedSwitcher(
            // Durasi transisi
            duration: const Duration(milliseconds: 100),

            // Efek transisi FadeTransition
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },

            // Halaman yang ditampilkan berdasarkan index
            child: pages[navBarController.selectedIndex.value],
          );
        }),

        // Navbar menggunakan Obx
        bottomNavigationBar: Obx(
          () => CustomNavbar(
            selectedIndex: navBarController.selectedIndex.value,
            onItemTapped: (index) {
              navBarController.changeIndex(index);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHomeContent() {
    // SafeArea untuk memastikan konten tidak tertutup oleh status bar atau notch
    return SafeArea(
      // Antisipasi supaya jika content melebihi tinggi layar, bisa di-scroll
      child: SingleChildScrollView(
        child: Padding(
          // Jarak sisi kiri dan kanan untuk konten utama
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Jarak antara status bar dan konten utama
              const SizedBox(height: 10),

              // Content sapaan dan logo aplikasi
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      // Teks sapaan
                      Text(
                        "Halo, Sobat Lada",
                        style: AppTextStyles.manropeFive,
                      ),
                      // Teks selamat datang
                      Text(
                        "Selamat Datang!",
                        style: AppTextStyles.poppinsThree,
                      ),
                    ],
                  ),
                  // Logo aplikasi
                  Image.asset(AppAssets.logoPepperLensAI, width: 60),
                ],
              ),

              // Jarak vertikal antara content sapaan dan banner
              const SizedBox(height: 16),

              // Content banner halaman beranda
              const CustomBanner(
                // Teks pada banner
                title:
                    "Lindungi Tanaman Lada Lebih Cerdas Bersama PepperLens AI",
                // Gambar pada banner
                imagePath: AppAssets.homeBanner,
              ),

              // Jarak vertikal antara banner dan menu utama
              const SizedBox(height: 16),

              // Content menu utama aplikasi
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.frostedMint,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // Judul 'Menu Utama' dan garis pembatas
                  children: [
                    Row(
                      children: [
                        const Text(
                          "Menu Utama",
                          style: AppTextStyles.poppinsFour,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Divider(
                            color: AppColors.honeydew,
                            thickness: 2,
                          ),
                        ),
                      ],
                    ),

                    // Jarak vertikal antara judul 'Menu Utama' dan daftar menu
                    const SizedBox(height: 12),

                    // Menu Deteksi
                    MenuCard(
                      icon: Icons.camera_alt,
                      title: "Deteksi",
                      subtitle:
                          "Deteksi penyakit tanaman lada berbasis citra daun",
                      onTap: () => navBarController.changeIndex(2),
                    ),

                    // Jarak vertikal antar menu
                    const SizedBox(height: 12),

                    // Menu Ensiklopedia
                    MenuCard(
                      icon: Icons.menu_book,
                      title: "Ensiklopedia",
                      subtitle: "Informasi mengenai penyakit tanaman lada",
                      onTap: () => navBarController.changeIndex(1),
                    ),

                    // Jarak vertikal antar menu
                    const SizedBox(height: 12),

                    // Menu Riwayat
                    MenuCard(
                      icon: Icons.history,
                      title: "Riwayat",
                      subtitle: "Rekam hasil deteksi dan visualisasi diagram",
                      onTap: () => navBarController.changeIndex(3),
                    ),
                  ],
                ),
              ),

              // Jarak vertikal antara menu utama dan bagian bawah layar
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
