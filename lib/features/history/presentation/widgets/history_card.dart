import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pepperlens_ai/core/constants/colors.dart';
import 'package:pepperlens_ai/core/constants/text_style.dart';

// Widget kartu riwayat deteksi untuk halaman riwayat
class HistoryCard extends StatelessWidget {
  // Atribut untuk tanggal, waktu, alamat gambar hasil deteksi, dan daftar penyakit yang terdeteksi, dan aksi saat kartu dihapus
  final String date;
  final String time;
  final String imagePath;
  final List<Map<String, dynamic>> diseasesData;
  final VoidCallback? onDelete;

  // Instance dari HistoryCard dengan parameter wajib diisi
  const HistoryCard({
    super.key,
    required this.date,
    required this.time,
    required this.imagePath,
    required this.diseasesData,
    this.onDelete,
  });

  // Bangun tampilan kartu riwayat deteksi
  @override
  Widget build(BuildContext context) {
    // Validasi apakah file gambar ada di penyimpanan lokal
    final bool fileExists =
        imagePath.isNotEmpty && File(imagePath).existsSync();

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.mysticJade,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Tanggal dan waktu
              Text("$date  $time", style: AppTextStyles.manropeTwelve),
              // Tombol hapus
              GestureDetector(
                onTap: onDelete,
                child: Transform.translate(
                  offset: const Offset(4, 0),
                  child: const Icon(
                    Icons.delete,
                    color: AppColors.honeydew,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          // Gambar hasil deteksi dan detail penyakit
          IntrinsicHeight(
            child: Row(
              children: [
                // Gambar pratinjau hasil deteksi
                _buildImagePreview(context, fileExists),

                const SizedBox(width: 15),

                // Deskripsi detail penyakit
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: diseasesData.asMap().entries.map((entry) {
                      int index = entry.key;

                      String originalName = entry.value['nama'];
                      String count = entry.value['jumlah'].toString();

                      // Logika penamaan penyakit berdasarkan gambar deteksi
                      String displayName;
                      if (originalName.contains('Busuk Pangkal Batang')) {
                        displayName = "Daun Penyakit BPB";
                      } else if (originalName.contains('Hawar Daun')) {
                        displayName = "Daun Penyakit Hawar";
                      } else if (originalName.contains('Keriting')) {
                        displayName = "Daun Penyakit Keriting";
                      } else if (originalName.contains('Kuning')) {
                        displayName = "Daun Penyakit Kuning";
                      } else {
                        displayName = "Daun Penyakit $originalName";
                      }

                      bool isLastItem = index == diseasesData.length - 1;
                      return _buildDiseaseItem(displayName, count, isLastItem);
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk menampilkan pratinjau gambar hasil deteksi dengan fitur tap-to-zoom
  Widget _buildImagePreview(BuildContext context, bool fileExists) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.honeydew, width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: GestureDetector(
          onTap: () => _showImageDialog(context, fileExists),
          child: Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                color: AppColors.frostedMint,
                child: fileExists
                    ? Image.file(
                        File(imagePath),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.broken_image,
                          color: AppColors.honeydew,
                        ),
                      )
                    : const Icon(Icons.image, color: AppColors.honeydew),
              ),

              // Indikator zoom-in jika gambar ada di penyimpanan lokal
              if (fileExists)
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: AppColors.darkCyan.withAlpha((0.75 * 255).toInt()),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(
                      Icons.zoom_in,
                      color: AppColors.honeydew,
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget untuk menampilkan item penyakit yang terdeteksi
  Widget _buildDiseaseItem(String label, String count, bool isLastItem) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLastItem ? 0 : 6),
      child: Row(
        children: [
          Container(
            constraints: const BoxConstraints(minWidth: 25, minHeight: 25),
            padding: const EdgeInsets.all(4),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.honeydew,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(count, style: AppTextStyles.manropeThirteen),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.manropeTwelve,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Dialog untuk menampilkan gambar hasil deteksi
  void _showImageDialog(BuildContext context, bool fileExists) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.honeydew, width: 2),
                    color: AppColors.honeydew,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: !fileExists
                        ? Container(
                            height: 200,
                            width: double.infinity,
                            color: AppColors.frostedMint,
                            child: const Icon(Icons.broken_image, size: 40),
                          )
                        : InteractiveViewer(
                            panEnabled: true,
                            minScale: 0.5,
                            maxScale: 4.0,
                            child: Image.file(
                              File(imagePath),
                              fit: BoxFit.contain,
                            ),
                          ),
                  ),
                ),

                // Tombol untuk menutup dialog
                Positioned(
                  right: 10,
                  top: 10,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        color: AppColors.honeydew,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: AppColors.darkCyan,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
