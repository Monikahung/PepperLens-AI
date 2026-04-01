import 'package:flutter/material.dart';
import 'package:pepperlens_ai/core/constants/colors.dart';
import 'package:pepperlens_ai/core/constants/text_style.dart';

// Widget banner untuk halaman beranda dan halaman panduan
class CustomBanner extends StatelessWidget {
  // Atribut untuk teks dan lokasi aset gambar banner
  final String title;
  final String imagePath;

  // Instance dari CustomBanner dengan parameter wajib diisi
  const CustomBanner({super.key, required this.title, required this.imagePath});

  // Bangun tampilan banner
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: AppColors.mysticJade,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // Expanded flex untuk menampilkan teks banner
          Expanded(
            flex: 2,
            child: Text(title, style: AppTextStyles.poppinsFour),
          ),
          // Expanded flex untuk menampilkan gambar banner
          Expanded(flex: 2, child: Image.asset(imagePath, fit: BoxFit.contain)),
        ],
      ),
    );
  }
}
