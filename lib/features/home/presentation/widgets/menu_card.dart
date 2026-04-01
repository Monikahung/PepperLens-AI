import 'package:flutter/material.dart';
import 'package:pepperlens_ai/core/constants/colors.dart';
import 'package:pepperlens_ai/core/constants/text_style.dart';

// Widget kartu menu untuk halaman beranda
class MenuCard extends StatelessWidget {
  // Atribut untuk ikon, judul, subjudul, dan aksi saat kartu ditekan
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  // Instance dari MenuCard dengan parameter wajib diisi
  const MenuCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  // Bangun tampilan kartu menu
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppColors.honeydew,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            // Ikon dengan latar belakang lingkaran
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.mysticJade,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.honeydew, size: 24),
            ),
            // Jarak antara ikon dan teks
            const SizedBox(width: 15),
            // Expanded untuk teks judul dan sub judul
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.manropeThree),
                  Text(subtitle, style: AppTextStyles.manropeOne),
                ],
              ),
            ),
            // Ikon panah
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.darkCyan,
            ),
          ],
        ),
      ),
    );
  }
}
