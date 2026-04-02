import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pepperlens_ai/core/constants/colors.dart';
import 'package:pepperlens_ai/core/constants/text_style.dart';
import 'package:pepperlens_ai/features/encyclopedia/presentation/widgets/encyclopedia_card.dart';
import 'package:pepperlens_ai/features/encyclopedia/data/repositories/encyclopedia_repository.dart';
import 'package:pepperlens_ai/features/encyclopedia/presentation/pages/encyclopedia_detail_page.dart';

// Halaman ensiklopedia yang menampilkan daftar penyakit
class EncyclopediaPage extends StatefulWidget {
  const EncyclopediaPage({super.key});

  @override
  State<EncyclopediaPage> createState() => _EncyclopediaPageState();
}

class _EncyclopediaPageState extends State<EncyclopediaPage> {
  // Instance repository untuk menangani logika pengambilan data penyakit
  final EncyclopediaRepository _repository = EncyclopediaRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.honeydew,

      // Teks 'Ensiklopedia' di bagian atas halaman
      appBar: AppBar(
        title: const Text("Ensiklopedia", style: AppTextStyles.manropeFive),
        backgroundColor: Colors.transparent,
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

      // Content dari halaman ensiklopedia
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _repository.getDiseasesWithImages(),
        builder: (context, snapshot) {
          // Tampilkan indikator loading saat data sedang dimuat
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.mysticJade),
            );
          }

          // Tampilkan pesan kesalahan jika terjadi error pada query
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Terjadi kesalahan: ${snapshot.error}",
                style: AppTextStyles.manropeOne,
                textAlign: TextAlign.center,
              ),
            );
          }

          final data = snapshot.data ?? [];

          // Tampilkan pesan jika tidak ada data penyakit ditemukan di database
          if (data.isEmpty) {
            return Center(
              child: Text(
                "Belum ada data penyakit.",
                style: AppTextStyles.manropeOne,
                textAlign: TextAlign.center,
              ),
            );
          }

          // Tampilkan daftar penyakit
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemCount: data.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = data[index];
              return EncyclopediaCard(
                // Ambil nama penyakit
                name: item['nama_penyakit'],
                // Ambil preview penyakit
                previewText: item['preview_penyakit'],
                // Ambil path gambar penyakit
                imagePath: item['path_gambar'] ?? '',
                // Jika diklik, dialihkan ke halaman ini
                onTap: () {
                  // Masuk ke halaman encyclopedia detail page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EncyclopediaDetailPage(
                        diseaseId: item['id_penyakit'],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
