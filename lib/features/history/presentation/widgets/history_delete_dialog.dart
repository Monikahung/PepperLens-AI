import 'package:flutter/material.dart';
import 'package:pepperlens_ai/core/constants/colors.dart';
import 'package:pepperlens_ai/core/constants/text_style.dart';

class HistoryDeleteDialog extends StatelessWidget {
  const HistoryDeleteDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.honeydew,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      title: Text("Hapus Riwayat", style: AppTextStyles.manropeEight),
      content: Text(
        "Apakah Anda yakin ingin menghapus riwayat deteksi ini?",
        style: AppTextStyles.manropeNine,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text("Batal", style: AppTextStyles.manropeFourteen),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text("Hapus", style: AppTextStyles.manropeFifteen),
        ),
      ],
    );
  }

  // Snackbar sukses jika penghapusan riwayat berhasil
  static void showSuccessSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.frostedMint,
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: AppColors.honeydew,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              "Riwayat berhasil dihapus",
              style: AppTextStyles.manropeTwelve,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 150,
          left: 20,
          right: 20,
        ),
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
