import 'package:flutter/material.dart';
import 'package:pepperlens_ai/core/constants/colors.dart';
import 'package:pepperlens_ai/core/constants/text_style.dart';

// Widget untuk menampilkan filter kategori riwayat untuk visualisasi data
class VisualizationFilter extends StatelessWidget {
  // Atribut untuk menyimpan filter yang dipilih dan fungsi untuk menangani perubahan filter yang dipilih
  final String selectedFilter;
  final Function(String) onFilterSelected;

  // Daftar filter yang tersedia untuk visualisasi data
  final List<String> filters = const [
    'Semua',
    'Hari ini',
    'Minggu ini',
    'Bulan ini',
    'Tahun ini',
    'Kustom',
  ];

  // Instance dari VisualizationFilter dengan parameter yang wajib diisi
  const VisualizationFilter({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  // Bangun tampilan filter riwayat untuk visualisasi data
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // Scroll horizontal (kiri kanan)
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Row(
        children: filters.map((filter) {
          // Logika evaluasi untuk menentukan apakah chip ini sedang dalam kondisi aktif
          final isSelected =
              selectedFilter == filter ||
              (selectedFilter.contains('_') && filter == 'Kustom');
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(filter),
              labelStyle: AppTextStyles.manropeSeven,
              selected: isSelected,
              onSelected: (_) => onFilterSelected(filter),
              selectedColor: AppColors.mysticJade,
              backgroundColor: AppColors.frostedMint,
              shape: const StadiumBorder(
                side: BorderSide(color: Colors.transparent),
              ),
              showCheckmark: true,
              checkmarkColor: AppColors.honeydew,
            ),
          );
        }).toList(),
      ),
    );
  }
}
