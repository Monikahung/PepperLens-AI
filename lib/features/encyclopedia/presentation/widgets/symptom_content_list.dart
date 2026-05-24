import 'package:flutter/material.dart';
import 'package:pepperlens_ai/core/constants/colors.dart';
import 'package:pepperlens_ai/core/widgets/detail_info_card.dart';
import 'package:pepperlens_ai/core/widgets/bullet_list_content.dart';
import 'package:pepperlens_ai/core/widgets/image_preview.dart';

// Widget yang menampilkan konten gejala di dalam widget accordion
class SymptomContentList extends StatelessWidget {
  // Atribut untuk list gambar gejala penyakit dan teks gejala penyakit
  final List imageList;
  final List symptomText;

  // Instance dari SymptomContentList dengan parameter wajib diisi
  const SymptomContentList({
    super.key,
    required this.imageList,
    required this.symptomText,
  });

  // Widget pembungkus gambar dengan ikon zoom
  Widget _buildImageWithZoom(BuildContext context, String path) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: AspectRatio(
            aspectRatio: 1 / 1,
            child: Image.asset(
              path,
              fit: BoxFit.cover,
              errorBuilder: (context, e, s) =>
                  const Icon(Icons.broken_image, color: AppColors.honeydew),
            ),
          ),
        ),
        Positioned(
          bottom: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.darkCyan.withAlpha((0.75 * 255).toInt()),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(
              Icons.zoom_out_map_rounded,
              color: AppColors.honeydew,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  // Bangun tampilan widget konten gejala di dalam widget accordion
  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];

    // Tampilkan widget untuk gambar daun lada sehat
    children.add(
      DetailInfoCard(
        title: "Kondisi Daun Sehat",
        content: GestureDetector(
          onTap: () => ImagePreviewDialog.show(
            context,
            "assets/images/healthy_leaf.png",
            isAsset: true,
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.honeydew, width: 1),
            ),
            child: _buildImageWithZoom(
              context,
              "assets/images/healthy_leaf.png",
            ),
          ),
        ),
      ),
    );

    // Urutkan gambar berdasarkan namanya. Dari database diutamakan untuk mengambil gambar 'kondisi lada penyakit%' sebagai prioritas sehingga disini perlu diurutkan kembali prioritasnya karena yang pertama ditampilkan yaitu gambar 'kondisi daun penyakit%'
    List sortedGambar = List.from(imageList);
    sortedGambar.sort((a, b) {
      String ketA = (a['keterangan'] ?? "").toLowerCase();
      String ketB = (b['keterangan'] ?? "").toLowerCase();

      // Jika keterangan a ada kata 'daun', sedangkan keterangan b tidak, a digeser ke depan
      if (ketA.contains('daun') && !ketB.contains('daun')) {
        return -1;
      }
      // Jika keterangan a tidak ada kata 'daun', sedangkan keterangan b ada, a digeser ke belakang
      else if (!ketA.contains('daun') && ketB.contains('daun')) {
        return 1;
      }
      return 0;
    });

    // Tampilkan widget untuk gambar penyakit
    for (var item in sortedGambar) {
      children.add(
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: DetailInfoCard(
            title: item['keterangan'] ?? "Kondisi Penyakit",
            content: GestureDetector(
              onTap: () => ImagePreviewDialog.show(
                context,
                item['path_gambar'],
                isAsset: true,
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.honeydew, width: 1),
                ),
                child: _buildImageWithZoom(context, item['path_gambar']),
              ),
            ),
          ),
        ),
      );
    }

    // Tampilkan widget untuk teks gejala penyakit dalam bentuk bullet list
    children.add(
      Padding(
        padding: const EdgeInsets.only(top: 12),
        child: DetailInfoCard(
          title: "Gejala Umum",
          content: BulletListContent(data: symptomText, column: 'desc_gejala'),
        ),
      ),
    );

    return Column(children: children);
  }
}
