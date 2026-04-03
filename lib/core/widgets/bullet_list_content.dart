import 'package:flutter/material.dart';
import 'package:pepperlens_ai/core/constants/text_style.dart';

// Widget untuk menampilkan teks dalam bentuk bullet
class BulletListContent extends StatelessWidget {
  // Atribut berupa sumber data dari database dan nama key yang berisi teks informasi
  final List data;
  final String column;

  // Instance dari BulletListContent dengan parameter wajib diisi
  const BulletListContent({
    super.key,
    required this.data,
    required this.column,
  });

  // Bangun tampilan teks dalam bentuk bullet
  @override
  Widget build(BuildContext context) {
    // Jika data kosong
    if (data.isEmpty) {
      return Text("Data tidak tersedia", style: AppTextStyles.manropeTwo);
    }

    // Data tersedia
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(data.length, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bullet berbentuk angka (1 2 3 dst)
              Text("${index + 1}. ", style: AppTextStyles.manropeTen),
              // Jarak bullet dengan teks informasi
              const SizedBox(width: 4),
              // Teks informasi
              Expanded(
                child: Text(
                  data[index][column],
                  style: AppTextStyles.manropeTen,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
