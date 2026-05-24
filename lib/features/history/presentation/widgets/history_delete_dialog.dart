import 'package:flutter/material.dart';
import 'package:pepperlens_ai/core/constants/colors.dart';
import 'package:pepperlens_ai/core/constants/text_style.dart';

// Widget untuk menampilkan dialog konfirmasi saat menghapus riwayat deteksi serta menampilkan snackbar sukses jika penghapusan berhasil
class HistoryDeleteDialog extends StatelessWidget {
  const HistoryDeleteDialog({super.key});

  // Menampilkan dialog konfirmasi saat menghapus riwayat deteksi
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.honeydew,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      title: Text("Hapus Riwayat", style: AppTextStyles.manropeEight),
      content: Text(
        "Riwayat deteksi dan foto terkait akan dihapus. Lanjutkan?",
        style: AppTextStyles.manropeNine,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text("Tidak", style: AppTextStyles.manropeFourteen),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text("Ya, Hapus", style: AppTextStyles.manropeFifteen),
        ),
      ],
    );
  }
}
