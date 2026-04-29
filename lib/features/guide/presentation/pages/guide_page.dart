import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pepperlens_ai/core/widgets/banner.dart';
import 'package:pepperlens_ai/core/widgets/bullet_list_content.dart';
import 'package:pepperlens_ai/core/widgets/info_card.dart';
import 'package:pepperlens_ai/core/constants/assets.dart';
import 'package:pepperlens_ai/core/constants/colors.dart';
import 'package:pepperlens_ai/core/constants/text_style.dart';
import 'package:pepperlens_ai/features/guide/data/guide_data.dart';

// Halaman utama untuk menampilkan panduan penggunaan aplikasi
class GuidePage extends StatefulWidget {
  const GuidePage({super.key});

  @override
  State<GuidePage> createState() => _GuidePageState();
}

class _GuidePageState extends State<GuidePage> {
  // Widget helper untuk membuat lingkaran nomor urut
  Widget _buildStepNumber(String number) {
    return Container(
      width: 28,
      height: 28,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.honeydew,
      ),
      alignment: Alignment.center,
      child: Text(number, style: AppTextStyles.poppinsFive),
    );
  }

  // Bangun tampilan halaman panduan penggunaan aplikasi
  @override
  Widget build(BuildContext context) {
    // Ambil data list panduan penggunaan aplikasi
    final List<Map<String, dynamic>> guides = GuideData.pepperlensGuide;

    return Scaffold(
      backgroundColor: AppColors.honeydew,

      // Teks 'Panduan' di bagian atas halaman
      appBar: AppBar(
        title: const Text("Panduan", style: AppTextStyles.manropeFive),
        backgroundColor: AppColors.honeydew,
        surfaceTintColor: AppColors.transparent,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: AppColors.honeydew,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: AppColors.mysticJade,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      ),

      body: SafeArea(
        bottom: true,
        top: false,
        child: SingleChildScrollView(
          // Padding untuk menampilkan content di bawah appBar
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            top: 10,
            bottom: 30,
          ),
          child: Column(
            children: [
              // Banner panduan penggunaan aplikasi
              const CustomBanner(
                title: "Pelajari Panduan Penggunaan Aplikasi PepperLens AI",
                imagePath: AppAssets.guideBanner,
              ),

              // Jarak antar komponen
              const SizedBox(height: 16),

              // Content panduan penggunaan aplikasi
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.frostedMint,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  // Tampilkan list panduan penggunaan aplikasi secara vertikal
                  children: guides.asMap().entries.map((entry) {
                    int index = entry.key;
                    Map<String, dynamic> item = entry.value;
                    bool isLast = index == guides.length - 1;
                    return InfoCard(
                      // Kosongkan title
                      title: "",

                      // Gunakan titleWidget untuk menampilkan nomor urut dan judul
                      titleWidget: Row(
                        children: [
                          // Tampilkan nomor urut panduan
                          _buildStepNumber(item['id']),

                          // Jarak antar komponen
                          const SizedBox(width: 15),

                          // Tampilkan judul panduan
                          Expanded(
                            child: Text(
                              item['title'],
                              style: AppTextStyles.poppinsFour,
                            ),
                          ),
                        ],
                      ),

                      // Latar belakang saat accordion terbuka dan tertutup
                      backgroundColor: AppColors.mysticJade,
                      collapsedBackgroundColor: AppColors.mysticJade,

                      // Penggunaan isLast untuk menetapkan panduan terakhir
                      isLast: isLast,

                      // Tampilkan gambar ilustrasi beserta list panduan
                      children: [
                        // Gambar ilustrasi
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.honeydew,
                              width: 1,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: AspectRatio(
                              aspectRatio: 3 / 2,
                              child: Image.asset(
                                item['imagePath'],
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),

                        // Jarak antar komponen
                        const SizedBox(height: 15),

                        // List panduan
                        BulletListContent(data: item['steps'], column: ''),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
