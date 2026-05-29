import 'package:flutter/material.dart';
import 'package:pepperlens_ai/core/constants/colors.dart';
import 'package:pepperlens_ai/core/constants/text_style.dart';

// Snackbar untuk menampilkan pesan sukses atau gagal penghapusan riwayat deteksi
class CustomSnackbar {
  // Fungsi untuk menampilkan snackbar
  static void showSnackbar(
    BuildContext context, {
    required String message,
    bool isSuccess = true,
  }) {
    // Menghapus snackbar sebelumnya jika ada
    ScaffoldMessenger.of(context).clearSnackBars();

    // Menampilkan snackbar baru dengan pesan yang diberikan
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isSuccess ? AppColors.frostedMint : Colors.redAccent,
        content: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSuccess ? Icons.check_circle_outline : Icons.error_outline,
                color: AppColors.honeydew,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: AppTextStyles.manropeTwelve,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 200,
          left: 20,
          right: 20,
        ),
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
