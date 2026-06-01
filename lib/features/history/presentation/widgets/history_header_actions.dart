import 'package:flutter/material.dart';
import 'package:pepperlens_ai/core/constants/colors.dart';
import 'package:pepperlens_ai/core/constants/text_style.dart';

// Widget untuk menampilkan filter dropdown, tombol visualisasi, dan tombol unduh data riwayat
class HistoryHeaderActions extends StatelessWidget {
  // Atribut yang diperlukan untuk filter dropdown, tombol visualisasi, dan tombol unduh data riwayat
  final String selectedCategory;
  final List<String> categories;
  final ValueChanged<String?> onCategoryChanged;
  final VoidCallback onVisualisasiTap;
  final VoidCallback? onDownloadTap;
  final bool isDownloading;

  // Instance dari HistoryHeaderActions dengan parameter wajib diisi
  const HistoryHeaderActions({
    super.key,
    required this.selectedCategory,
    required this.categories,
    required this.onCategoryChanged,
    required this.onVisualisasiTap,
    required this.onDownloadTap,
    required this.isDownloading,
  });

  // Bangun tampilan filter dropdown, tombol visualisasi, dan tombol unduh data riwayat
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Filter dropdown untuk kategori berdasarkan rentang waktu
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.frostedMint,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedCategory,
                      isExpanded: true,
                      dropdownColor: AppColors.frostedMint,
                      borderRadius: BorderRadius.circular(10),
                      icon: Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: AppColors.honeydew,
                        ),
                      ),
                      selectedItemBuilder: (BuildContext context) {
                        return categories.map<Widget>((String item) {
                          return Row(
                            children: [
                              const SizedBox(width: 10),
                              const Icon(Icons.tune, color: AppColors.honeydew),
                              const SizedBox(width: 10),
                              Text(item, style: AppTextStyles.manropeSeven),
                            ],
                          );
                        }).toList();
                      },
                      items: categories.map((val) {
                        return DropdownMenuItem(
                          value: val,
                          child: Text(val, style: AppTextStyles.manropeSeven),
                        );
                      }).toList(),
                      onChanged: onCategoryChanged,
                    ),
                  ),
                ),
              ),

              // Jarak antar filter dropdown dan tombol visualisasi
              const SizedBox(width: 10),

              // Tombol navigasi ke halaman visualisasi
              Expanded(
                child: InkWell(
                  onTap: onVisualisasiTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: AppColors.frostedMint,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(Icons.bar_chart, color: AppColors.honeydew),
                        const SizedBox(width: 5),
                        Text('Visualisasi', style: AppTextStyles.manropeSeven),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: AppColors.honeydew,
                          size: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Jarak antar filter dropdown dan tombol visualisasi dengan tombol unduh data riwayat
        const SizedBox(height: 12),

        // Tombol unduh data riwayat
        ElevatedButton.icon(
          onPressed: isDownloading ? () {} : onDownloadTap,
          icon: isDownloading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: AppColors.honeydew,
                    strokeWidth: 2,
                  ),
                )
              : const SizedBox(
                  width: 20,
                  height: 20,
                  child: Icon(
                    Icons.picture_as_pdf,
                    color: AppColors.honeydew,
                    size: 20,
                  ),
                ),
          label: Text(
            isDownloading ? "Memproses Dokumen PDF" : "Unduh Data Riwayat",
            style: AppTextStyles.manropeSeven,
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.frostedMint,
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
          ),
        ),
      ],
    );
  }
}
