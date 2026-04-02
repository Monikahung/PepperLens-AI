import 'package:flutter/material.dart';
import 'package:pepperlens_ai/core/constants/colors.dart';
import 'package:pepperlens_ai/core/constants/text_style.dart';

// Widget kartu penyakit untuk halaman ensiklopedia
class EncyclopediaCard extends StatelessWidget {
  // Atribut untuk nama, deskripsi singkat, lokasi aset gambar, dan aksi saat kartu ditekan
  final String name;
  final String previewText;
  final String imagePath;
  final VoidCallback onTap;

  // Instance dari EncyclopediaCard dengan parameter wajib diisi
  const EncyclopediaCard({
    super.key,
    required this.name,
    required this.previewText,
    required this.imagePath,
    required this.onTap,
  });

  // Bangun tampilan kartu penyakit
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppColors.mysticJade,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            // Gambar penyakit
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.honeydew, width: 1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  imagePath,
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 70,
                    height: 70,
                    color: AppColors.frostedMint,
                    child: const Icon(
                      Icons.broken_image,
                      color: AppColors.honeydew,
                    ),
                  ),
                ),
              ),
            ),

            // Jarak antara gambar dengan teks mengenai penyakit
            const SizedBox(width: 15),

            // Nama penyakit dan deskripsi singkatnya
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama penyakit
                  Text(name, style: AppTextStyles.manropeFour),
                  // Jarak antara nama penyakit dengan deskripsi singkatnya
                  const SizedBox(height: 4),
                  // Deskripsi singkat
                  Text(previewText, style: AppTextStyles.manropeTwo),
                ],
              ),
            ),

            // Jarak antara teks penyakit dengan ikon panah
            const SizedBox(width: 5),

            // Ikon panah
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.honeydew,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
