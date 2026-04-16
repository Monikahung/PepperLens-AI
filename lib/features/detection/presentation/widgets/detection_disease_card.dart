import 'package:flutter/material.dart';
import 'package:pepperlens_ai/core/constants/colors.dart';
import 'package:pepperlens_ai/core/constants/text_style.dart';

// Widget untuk menampilkan daftar penyakit yang terdeteksi beserta gambar cropping penyakit tersebut
class DetectionDiseaseCard extends StatelessWidget {
  // Atribut judul nama penyakit, daftar widget berupa gambar cropping, direct ke halaman lain, serta menentukan apakah kartu termasuk urutan terakhir
  final String title;
  final List<Widget> children;
  final VoidCallback? onTap;
  final bool isLast;

  // Instance dari DetectionDiseaseCard dengan parameter wajib diisi
  const DetectionDiseaseCard({
    super.key,
    required this.title,
    required this.children,
    this.onTap,
    this.isLast = false,
  });

  // Bangun tampilan daftar penyakit yang terdeteksi
  @override
  Widget build(BuildContext context) {
    return Container(
      // Jarak antar kartu kecuali item terakhir
      margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
      decoration: BoxDecoration(
        color: AppColors.mysticJade,
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    // Judul nama penyakit yang terdeteksi
                    child: Text(title, style: AppTextStyles.poppinsFour),
                  ),
                  // Icon panah
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.honeydew,
                    size: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // Gambar cropping penyakit yang terdeteksi
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: children,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
