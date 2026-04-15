import 'package:flutter/material.dart';
import 'colors.dart';

class AppTextStyles {
  // -- MANROPE FONT FAMILY --

  // Teks untuk sub judul menu, teks error
  static const TextStyle manropeOne = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.darkCyan,
  );

  // Teks untuk deskripsi penyakit ensiklopedia, teks error
  static const TextStyle manropeTwo = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.honeydew,
  );

  // Teks untuk judul menu
  static const TextStyle manropeThree = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.darkCyan,
  );

  // Teks untuk judul penyakit ensiklopedia
  static const TextStyle manropeFour = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.honeydew,
  );

  // Teks untuk 'Halo, Sobat Lada'
  static const TextStyle manropeFive = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.darkCyan,
  );

  // Teks untuk nama aplikasi di halaman splash screen
  static const TextStyle manropeSix = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 27,
    fontWeight: FontWeight.w800,
    color: AppColors.mysticJade,
  );

  // Teks untuk judul content di accordion
  static const TextStyle manropeSeven = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 14,
    fontWeight: FontWeight.w800,
    color: AppColors.honeydew,
  );

  // Teks untuk nama penyakit di halaman detail penyakit
  static const TextStyle manropeEight = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.darkCyan,
  );

  // Teks untuk deskripsi penyakit di halaman detail penyakit
  static const TextStyle manropeNine = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.darkCyan,
  );

  // Teks untuk deskripsi widget di detail penyakit
  static const TextStyle manropeTen = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.honeydew,
  );

  // Teks untuk keterangan di halaman ambil gambar
  static const TextStyle manropeEleven = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.honeydew,
  );

  // Teks untuk keterangan tanggal, jam, dan waktu proses
  static const TextStyle manropeTwelve = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.honeydew,
  );

  // -- POPPINS FONT FAMILY --

  // Teks untuk label navbar
  static const TextStyle poppinsOne = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.honeydew,
  );

  // Teks untuk nama inggris dari penyakit
  static const TextStyle poppinsTwo = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic,
    color: AppColors.darkCyan,
  );

  // Teks untuk 'Selamat Datang!'
  static const TextStyle poppinsThree = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.darkCyan,
  );

  // Teks untuk banner dan 'Menu Utama', judul informasi di dalam accordion, judul nama penyakit di hasil deteksi, teks di kotak hitam sebagai tanda jumlah cropping
  static const TextStyle poppinsFour = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.honeydew,
  );
}
