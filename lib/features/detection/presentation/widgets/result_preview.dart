import 'package:flutter/material.dart';
import 'package:pepperlens_ai/core/constants/colors.dart';
import 'package:pepperlens_ai/core/constants/text_style.dart';
import 'package:pepperlens_ai/features/detection/presentation/widgets/crop_preview.dart';
import 'package:pepperlens_ai/features/detection/presentation/widgets/detail_result_preview.dart';

// Widget untuk menampilkan preview kumpulan crop hasil deteksi
class ResultPreview extends StatefulWidget {
  // Atribut yang diperlukan untuk menampilkan preview kumpulan crop hasil deteksi
  final String title;
  final String originalPath;
  final List<Map<String, dynamic>> diseaseItems;

  // Instance dari ResultPreview dengan parameter wajib diisi
  const ResultPreview({
    super.key,
    required this.title,
    required this.originalPath,
    required this.diseaseItems,
  });

  // Metode statis untuk menampilkan dialog preview kumpulan crop hasil deteksi
  static void show(
    BuildContext context, {
    required String title,
    required String originalPath,
    required List<Map<String, dynamic>> diseaseItems,
  }) {
    showDialog(
      context: context,
      builder: (context) => ResultPreview(
        title: title,
        originalPath: originalPath,
        diseaseItems: diseaseItems,
      ),
    );
  }

  @override
  State<ResultPreview> createState() => _ResultPreviewState();
}

// Class untuk membangun tampilan dialog preview kumpulan crop hasil deteksi
class _ResultPreviewState extends State<ResultPreview> {
  // Halaman aktif dalam sistem grid
  int currentPage = 0;

  // Jumlah maksimum item yang ditampilkan per halaman
  final int itemsPerPage = 9;

  // Bangun tampilan dialog preview kumpulan crop hasil deteksi
  @override
  Widget build(BuildContext context) {
    // Hitung total halaman yang dibutuhkan secara dinamis
    int totalPages = (widget.diseaseItems.length / itemsPerPage).ceil();

    // Logika penentu pagination
    bool showPagination = widget.diseaseItems.length > itemsPerPage;

    // Tentukan batas jangkauan indeks data list yang akan dipotong dan ditampilkan pada halaman aktif
    int startIndex = currentPage * itemsPerPage;
    int endIndex = startIndex + itemsPerPage;
    if (endIndex > widget.diseaseItems.length) {
      endIndex = widget.diseaseItems.length;
    }

    // Potong list utama menjadi sublist parsial khusus untuk halaman yang sedang aktif
    List<Map<String, dynamic>> currentPagedItems = widget.diseaseItems.sublist(
      startIndex,
      endIndex,
    );

    return Dialog(
      backgroundColor: AppColors.transparent,
      insetPadding: const EdgeInsets.all(20),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColors.frostedMint,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.honeydew, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tombol close
                Align(
                  alignment: Alignment.topRight,
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

                // Jarak antar komponen
                const SizedBox(height: 4),

                // Nama penyakit
                Text(
                  widget.title,
                  style: AppTextStyles.manropeSeventeen,
                  textAlign: TextAlign.center,
                ),

                // Jarak antar komponen
                const SizedBox(height: 12),

                // Kumpulan crop preview
                LayoutBuilder(
                  builder: (context, constraints) {
                    double gridWidth = constraints.maxWidth;
                    double spacing = 10.0;
                    double itemSize = (gridWidth - (spacing * 2)) / 3;

                    return SizedBox(
                      width: gridWidth,
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: currentPagedItems.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: spacing,
                          mainAxisSpacing: spacing,
                          childAspectRatio: 1.0,
                        ),
                        itemBuilder: (context, index) {
                          final detectionItem = currentPagedItems[index];

                          int originalIndex = widget.diseaseItems.indexOf(
                            detectionItem,
                          );

                          return GestureDetector(
                            // Arahkan ke dialog cropping hasil deteksi
                            onTap: () {
                              DetailResultPreview.show(
                                context,
                                title: widget.title,
                                originalPath: widget.originalPath,
                                diseaseItems: widget.diseaseItems,
                                initialIndex: originalIndex,
                              );
                            },
                            // Tampilkan kotak crop hasil deteksi
                            child: CropPreview(
                              originalPath: widget.originalPath,
                              detection: detectionItem,
                              size: itemSize,
                              showZoomIcon: true,
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),

                // Jarak antar komponen
                const SizedBox(height: 12),

                // Pagination
                if (showPagination) ...[
                  SizedBox(
                    height: 32,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Prev button
                        Material(
                          color: AppColors.transparent,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(
                              Icons.arrow_back_ios,
                              color: AppColors.honeydew,
                              size: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            onPressed: () {
                              setState(() {
                                currentPage = currentPage > 0
                                    ? currentPage - 1
                                    : totalPages - 1;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 50),
                        // Next button
                        Material(
                          color: AppColors.transparent,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(
                              Icons.arrow_forward_ios,
                              color: AppColors.honeydew,
                              size: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            onPressed: () {
                              setState(() {
                                currentPage = currentPage < totalPages - 1
                                    ? currentPage + 1
                                    : 0;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
