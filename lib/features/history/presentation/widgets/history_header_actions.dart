import 'package:flutter/material.dart';
import 'package:pepperlens_ai/core/constants/colors.dart';
import 'package:pepperlens_ai/core/constants/text_style.dart';

class HistoryHeaderActions extends StatelessWidget {
  final String selectedCategory;
  final List<String> categories;
  final ValueChanged<String?> onCategoryChanged;
  final VoidCallback onVisualisasiTap;

  const HistoryHeaderActions({
    super.key,
    required this.selectedCategory,
    required this.categories,
    required this.onCategoryChanged,
    required this.onVisualisasiTap,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
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

          const SizedBox(width: 10),

          // Tombol navigasi ke halaman visualisasi
          Expanded(
            child: InkWell(
              onTap: () {},
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
    );
  }
}
