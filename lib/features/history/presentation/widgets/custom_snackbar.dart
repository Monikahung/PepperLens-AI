import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pepperlens_ai/core/constants/colors.dart';
import 'package:pepperlens_ai/core/constants/text_style.dart';

// Snackbar untuk menampilkan pesan sukses atau gagal dari suatu proses di fitur riwayat deteksi
class CustomSnackbar {
  // Fungsi untuk menampilkan snackbar standar
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
        // Warna hijau standar untuk snackbar sukses, warna merah standar untuk snackbar gagal
        backgroundColor: isSuccess ? Colors.green : Colors.red,
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

  // Fungsi untuk menampilkan snackbar untuk mengunduh dokumen data
  static void showDownloadSnackbar(
    BuildContext context, {
    required String category,
    bool isSuccess = true,
    VoidCallback? onOpenTap,
  }) {
    // Menghapus snackbar sebelumnya jika ada
    ScaffoldMessenger.of(context).clearSnackBars();

    // Menampilkan snackbar baru dengan pesan yang diberikan
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        // Warna hijau standar untuk snackbar sukses, warna merah standar untuk snackbar gagal
        backgroundColor: isSuccess ? Colors.green : Colors.red,
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
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      // Teks pesan biasa
                      TextSpan(
                        text: isSuccess
                            ? 'Laporan ${category.toLowerCase()} sukses disimpan. '
                            : 'Gagal menyimpan dokumen data "$category". Silakan coba lagi!',
                        style: AppTextStyles.manropeTwelve,
                      ),
                      // Teks pesan yang bisa diklik
                      if (isSuccess && onOpenTap != null)
                        TextSpan(
                          text: 'BUKA!',
                          style: AppTextStyles.manropeEighteen,
                          recognizer: TapGestureRecognizer()..onTap = onOpenTap,
                        ),
                    ],
                  ),
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
        duration: Duration(seconds: isSuccess ? 6 : 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
