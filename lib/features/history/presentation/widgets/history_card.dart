import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:pepperlens_ai/core/constants/colors.dart';
import 'package:pepperlens_ai/core/constants/text_style.dart';
import 'package:pepperlens_ai/core/widgets/image_preview_dialog.dart';

// Widget kartu riwayat deteksi untuk halaman riwayat
class HistoryCard extends StatelessWidget {
  // Atribut untuk tanggal, waktu, alamat gambar hasil deteksi, dan daftar penyakit yang terdeteksi, dan aksi saat kartu dihapus
  final String date;
  final String time;
  final String imagePath;
  final String timeProcess;
  final String assetId;
  final List<Map<String, dynamic>> diseasesData;
  final VoidCallback? onDelete;

  // Instance dari HistoryCard dengan parameter wajib diisi
  const HistoryCard({
    super.key,
    required this.date,
    required this.time,
    required this.imagePath,
    required this.timeProcess,
    required this.assetId,
    required this.diseasesData,
    this.onDelete,
  });

  // Memuat gambar hasil deteksi dari dua kondisi
  Future<File?> _loadImageHistory() async {
    // Jika gambar di storage aplikasi ada
    if (imagePath.isNotEmpty) {
      final internalFile = File(imagePath);
      if (await internalFile.exists()) {
        debugPrint("Gambar dimuat dari penyimpanan internal");
        return internalFile;
      }
    }

    // Jika gambar di storage aplikasi tidak ada, coba memuat dari galeri
    if (assetId.isNotEmpty) {
      debugPrint("File internal hilang! Mencoba memulihkan dari galeri");
      try {
        // Meminta izin untuk mengakses galeri
        final PermissionState permission =
            await PhotoManager.requestPermissionExtend();
        if (permission.isAuth) {
          final AssetEntity? asset = await AssetEntity.fromId(assetId);
          if (asset != null) {
            return await asset.file;
          }
        }
      } catch (e) {
        debugPrint("Gagal memuat gambar dari galeri: $e");
      }
    }

    return null;
  }

  // Bangun tampilan kartu riwayat deteksi
  @override
  Widget build(BuildContext context) {
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
              // Tanggal, waktu, dan lama proses
              Text(
                "$date   |   $time   |   $timeProcess Detik",
                style: AppTextStyles.manropeTwelve,
              ),
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

          // Jarak antar komponen
          const SizedBox(height: 15),

          // Gambar hasil deteksi dan detail penyakit
          IntrinsicHeight(
            child: Row(
              children: [
                // Gambar pratinjau hasil deteksi
                FutureBuilder<File?>(
                  future: _loadImageHistory(),
                  builder: (context, snapshot) {
                    return _buildImagePreview(context, snapshot);
                  },
                ),

                // Jarak antar komponen
                const SizedBox(width: 15),

                // Deskripsi detail penyakit
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: diseasesData.asMap().entries.map((entry) {
                      // Penampung indeks
                      int index = entry.key;

                      // Penampung nama penyakit dan jumlah deteksi
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

                      // Ambil status apakah data terakhir atau tidak
                      bool isLastItem = index == diseasesData.length - 1;

                      // Bangun widget item penyakit
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
  Widget _buildImagePreview(
    BuildContext context,
    AsyncSnapshot<File?> snapshot,
  ) {
    final File? imageFile = snapshot.data;
    final bool hasImage = snapshot.hasData && imageFile != null;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.honeydew, width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: GestureDetector(
          onTap: () {
            // Tampilkan gambar jika ada
            if (hasImage) {
              ImagePreviewDialog.show(context, imageFile.path, isAsset: false);
            }
          },
          child: Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                color: AppColors.frostedMint,
                child: snapshot.connectionState == ConnectionState.waiting
                    // Jika gambar sedang dimuat
                    ? const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.honeydew,
                        ),
                      )
                    // Jika gambar ada
                    : hasImage
                    ? Image.file(
                        imageFile,
                        fit: BoxFit.cover,
                        // Jika gambar gagal dimuat
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.broken_image,
                          color: AppColors.honeydew,
                        ),
                      )
                    // Jika gambar tidak ada
                    : const Icon(Icons.image, color: AppColors.honeydew),
              ),

              // Indikator zoom-in jika gambar ada di penyimpanan lokal
              if (hasImage)
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
                      Icons.zoom_out_map_rounded,
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
          const SizedBox(width: 6),
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
}
