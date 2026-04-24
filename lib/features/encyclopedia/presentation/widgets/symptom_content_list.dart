import 'package:flutter/material.dart';
import 'package:pepperlens_ai/core/constants/colors.dart';
import 'package:pepperlens_ai/core/widgets/detail_info_card.dart';
import 'package:pepperlens_ai/core/widgets/bullet_list_content.dart';

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

  // Bangun tampilan widget konten gejala di dalam widget accordion
  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];

    // Tampilkan widget untuk gambar daun lada sehat
    children.add(
      DetailInfoCard(
        title: "Kondisi Daun Sehat",
        content: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.honeydew, width: 1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: AspectRatio(
              aspectRatio: 1 / 1,
              child: Image.asset(
                "assets/images/healthy_leaf.png",
                fit: BoxFit.cover,
              ),
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
            content: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.honeydew, width: 1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: AspectRatio(
                  aspectRatio: 1 / 1,
                  child: Image.asset(
                    item['path_gambar'],
                    fit: BoxFit.cover,
                    errorBuilder: (context, e, s) => const Icon(
                      Icons.broken_image,
                      color: AppColors.honeydew,
                    ),
                  ),
                ),
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
