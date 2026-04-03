import 'package:flutter/material.dart';
import 'package:pepperlens_ai/core/constants/colors.dart';
import 'package:pepperlens_ai/core/constants/text_style.dart';

// Widget untuk menampilkan informasi mendalam yang digunakan sebagai elemen child di dalam InfoCard
class DetailInfoCard extends StatelessWidget {
  // Atribut judul dan contentnya
  final String title;
  final Widget content;

  // Instance dari DetailInfoCard dengan parameter wajib diisi
  const DetailInfoCard({super.key, required this.title, required this.content});

  // Bangun tampilan informasi untuk child InforCard
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.mysticJade,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Judul informasi
          Text(title, style: AppTextStyles.manropeSeven),
          const SizedBox(height: 10),
          // Content
          content,
        ],
      ),
    );
  }
}
