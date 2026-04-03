import 'package:flutter/material.dart';
import 'package:pepperlens_ai/core/constants/colors.dart';
import 'package:pepperlens_ai/core/constants/text_style.dart';

// Widget untuk menampilkan informasi dalam bentuk accordion
class InfoCard extends StatelessWidget {
  // Atribut judul utama, daftar widget yang ada di dalamnya, kontrol visible kartu, warna background saat terbuka dan tertutup, serta menentukan apakah kartu termasuk urutan terakhir
  final String title;
  final List<Widget> children;
  final bool isVisible;
  final Color backgroundColor;
  final Color collapsedBackgroundColor;
  final bool isLast;

  // Instance dari InfoCard dengan parameter wajib diisi
  const InfoCard({
    super.key,
    required this.title,
    required this.children,
    this.isVisible = true,
    required this.backgroundColor,
    required this.collapsedBackgroundColor,
    this.isLast = false,
  });

  // Bangun tampilan accordion
  @override
  Widget build(BuildContext context) {
    // Menghindari rendering jika isVisible diset false
    if (!isVisible) return const SizedBox.shrink();

    return Container(
      // Jarak antar kartu kecuali untuk item terakhir
      margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Theme(
        // Hapus garis pembatas (divider) default
        data: Theme.of(context).copyWith(dividerColor: AppColors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 15),
          backgroundColor: backgroundColor,
          collapsedBackgroundColor: collapsedBackgroundColor,

          // Atur sudut kartu saat terbuka maupun tertutup
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),

          // Warna icon panah
          iconColor: AppColors.honeydew,
          collapsedIconColor: AppColors.honeydew,

          // Judul accordion
          title: Text(title, style: AppTextStyles.poppinsFour),

          // Padding untuk konten di dalam kartu setelah dibuka
          childrenPadding: const EdgeInsets.only(
            left: 15,
            right: 15,
            top: 0,
            bottom: 15,
          ),
          children: children,
        ),
      ),
    );
  }
}
