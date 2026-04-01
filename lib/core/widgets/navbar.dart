import 'package:flutter/material.dart';
import 'package:pepperlens_ai/core/constants/colors.dart';
import 'package:pepperlens_ai/core/constants/text_style.dart';

// Widget navbar untuk navigasi utama di bagian bawah layar
class CustomNavbar extends StatelessWidget {
  // Atribut untuk indeks yang dipilih dan fungsi callback saat item navbar ditekan
  final int selectedIndex;
  final Function(int) onItemTapped;

  // Instance dari CustomNavbar dengan parameter wajib diisi
  const CustomNavbar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  // Bangun tampilan navbar
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(color: AppColors.mysticJade),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        // Expanded untuk menampilkan setiap item navbar secara merata
        children: [
          Expanded(child: _navItem(Icons.home_outlined, "Beranda", 0)),
          Expanded(
            child: _navItem(Icons.menu_book_outlined, "Ensiklopedia", 1),
          ),
          Expanded(child: _navItem(Icons.camera_alt_outlined, "Deteksi", 2)),
          Expanded(child: _navItem(Icons.history, "Riwayat", 3)),
          Expanded(child: _navItem(Icons.bookmark_outline, "Panduan", 4)),
        ],
      ),
    );
  }

  // Metode untuk membuat item navbar dengan ikon, label, dan status aktif
  Widget _navItem(IconData icon, String label, int index) {
    bool isActive = selectedIndex == index;
    return GestureDetector(
      // Panggil fungsi callback dengan indeks saat item navbar ditekan
      onTap: () => onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Ikon pada item navbar
          Icon(icon, color: AppColors.honeydew, size: 26),
          // Jarak antara ikon dan label
          const SizedBox(height: 4),
          // Label pada item navbar
          Text(
            label,
            style: AppTextStyles.poppinsOne.copyWith(
              fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
