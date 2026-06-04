import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_filex/open_filex.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:external_path/external_path.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pepperlens_ai/core/constants/colors.dart';
import 'package:pepperlens_ai/features/history/presentation/widgets/custom_snackbar.dart';

// Logic untuk generate PDF data riwayat deteksi penyakit
class PdfExportHelper {
  // Fungsi untuk kompresi gambar sebelum masuk PDF
  static Future<Uint8List?> _compressImage(String filePath) async {
    final file = File(filePath);
    if (!file.existsSync()) return null;

    // Menghitung target resolusi
    final result = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      minWidth: 900,
      minHeight: 900,
      quality: 75,
      format: CompressFormat.jpeg,
    );

    return result;
  }

  // Fungsi untuk generate PDF dan buka PDF
  static Future<void> generateAndOpenReport({
    required String category,
    required List<Map<String, dynamic>> historyData,
  }) async {
    pw.Document pdf;

    // Inisialisasi font yang digunakan untuk dokumen PDF (Times New Roman)
    try {
      final fontData = await rootBundle.load(
        "assets/fonts/times_new_roman/times.ttf",
      );
      final fontBoldData = await rootBundle.load(
        "assets/fonts/times_new_roman/timesbd.ttf",
      );
      final fontItalicData = await rootBundle.load(
        "assets/fonts/times_new_roman/timesi.ttf",
      );
      final fontBoldItalicData = await rootBundle.load(
        "assets/fonts/times_new_roman/timesbi.ttf",
      );

      // Terapkan tema font global formal untuk dokumen PDF
      pdf = pw.Document(
        theme: pw.ThemeData.withFont(
          base: pw.Font.ttf(fontData),
          bold: pw.Font.ttf(fontBoldData),
          italic: pw.Font.ttf(fontItalicData),
          boldItalic: pw.Font.ttf(fontBoldItalicData),
        ),
      );
    } catch (fontError) {
      // Penanganan jika aset font gagal dimuat
      String snackbarCategory = category.contains('-') ? "Kustom" : category;

      CustomSnackbar.showDownloadSnackbar(
        Get.context!,
        category: snackbarCategory,
        isSuccess: false,
      );
      return;
    }

    // Kompres semua gambar secara asinkron sebelum masuk ke struktur widget PDF
    List<Uint8List?> compressedImages = [];
    for (final item in historyData) {
      if (item['path_deteksi'] != null) {
        final compressedBytes = await _compressImage(item['path_deteksi']);
        compressedImages.add(compressedBytes);
      } else {
        compressedImages.add(null);
      }
    }

    // Membangun struktur halaman PDF
    pdf.addPage(
      pw.MultiPage(
        // Ukuran kertas A4
        pageFormat: PdfPageFormat.a4,

        // Jarak margin 2 cm
        margin: const pw.EdgeInsets.all(57),

        // Header dokumen PDF
        header: (pw.Context context) {
          final now = DateTime.now();
          DateTime startDate = now;
          DateTime endDate = now;
          String periodLabel = category.toUpperCase();

          // Cek jika kategori kostum atau bukan
          if (category.contains('-')) {
            periodLabel = "KUSTOM";
          } else {
            switch (category) {
              case 'Hari ini':
                // Gunakan tanggal hari ini
                startDate = now;
                endDate = now;
                break;
              case 'Minggu ini':
                // Gunakan tanggal mulai dari hari Senin hingga hari Minggu
                int daysToMonday = now.weekday - DateTime.monday;
                startDate = now.subtract(Duration(days: daysToMonday));
                endDate = startDate.add(const Duration(days: 6));
                break;
              case 'Bulan ini':
                // Gunakan tangggal dari tanggal pertama hingga tanggal terakhir dari bulan ini
                startDate = DateTime(now.year, now.month, 1);
                endDate = DateTime(now.year, now.month + 1, 0);
                break;
              case 'Tahun ini':
                // Gunakan tanggal dari tanggal pertama hingga tanggal terakhir dari tahun ini
                startDate = DateTime(now.year, 1, 1);
                endDate = DateTime(now.year, 12, 31);
                break;
              case 'Semua':
              default:
                periodLabel = "SEMUA PERIODE DATA";
                // Ambil rekaman tanggal terlama hingga terbaru dari SQLite
                if (historyData.isNotEmpty) {
                  return pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Teks judul
                      pw.Text(
                        "Pengujian Deteksi Penyakit di Lapangan",
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),

                      // Jarak antar komponen
                      pw.SizedBox(height: 4),

                      // Teks kategori
                      pw.Text(
                        "Kategori Rentang Periode: $periodLabel (${historyData.last['tanggal']} s/d ${historyData.first['tanggal']})",
                        style: const pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.black,
                        ),
                      ),

                      // Garis pemisah dengan tabel
                      pw.Divider(thickness: 1, color: PdfColors.black),
                      pw.SizedBox(height: 10),
                    ],
                  );
                }
                break;
            }
          }

          // Format tanggal lokal
          final dateFormatter = DateFormat('dd MMMM yyyy', 'id_ID');

          // Gabungkan teks rentang tanggal sesuai kategori terpilih
          String dateRangeString;
          if (category.contains('-')) {
            dateRangeString = "($category)";
          } else if (category == 'Semua') {
            dateRangeString = historyData.isNotEmpty
                ? "(${historyData.last['tanggal']} s/d ${historyData.first['tanggal']})"
                : "";
          } else if (category == 'Hari ini') {
            dateRangeString = "(${dateFormatter.format(startDate)})";
          } else {
            dateRangeString =
                "(${dateFormatter.format(startDate)} s/d ${dateFormatter.format(endDate)})";
          }

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Teks judul
              pw.Text(
                "Pengujian Deteksi Penyakit di Lapangan",
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              // Jarak antar komponen
              pw.SizedBox(height: 4),

              // Teks kategori
              pw.Text(
                "Kategori Rentang Periode: ${periodLabel.toUpperCase()} $dateRangeString",
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.black),
              ),

              // Garis pemisah dengan tabel
              pw.Divider(thickness: 1, color: PdfColors.black),
              pw.SizedBox(height: 10),
            ],
          );
        },

        // Footer dokumen PDF
        footer: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 10),
            // Teks halaman
            child: pw.Text(
              "Halaman: ${context.pageNumber} dari ${context.pagesCount}",
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.black),
            ),
          );
        },

        // Isi dokumen PDF
        build: (pw.Context context) {
          return [
            // Tabel data riwayat deteksi penyakit
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.black, width: 1),
              // Lebar kolom tabel
              columnWidths: const {
                0: pw.FixedColumnWidth(25),
                1: pw.FixedColumnWidth(165),
                2: pw.FixedColumnWidth(85),
                3: pw.FixedColumnWidth(50),
                4: pw.FixedColumnWidth(50),
                5: pw.FixedColumnWidth(85),
              },
              defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
              children: [
                // Header tabel
                pw.TableRow(
                  // Diulangi per halaman
                  repeat: true,
                  decoration: const pw.BoxDecoration(color: PdfColors.blue100),
                  // Isi header tabel
                  children: [
                    _buildHeaderCell("No."),
                    _buildHeaderCell("Gambar Hasil Deteksi*"),
                    _buildHeaderCell("Hasil Deteksi"),
                    _buildHeaderCell("Validasi*"),
                    _buildHeaderCell("Akurasi*"),
                    _buildHeaderCell("Perbaikan*"),
                  ],
                ),

                // Isi data riwayat deteksi penyakit
                ...List.generate(historyData.length, (index) {
                  final item = historyData[index];
                  final globalIndex = index + 1;
                  final List<dynamic> diseaseList = item['penyakit_data'] ?? [];
                  final double inferenceTime =
                      (item['waktu_proses'] as num?)?.toDouble() ?? 0.0;

                  // Widget gambar hasil deteksi penyakit
                  final imgBytes = compressedImages[index];
                  pw.Widget imageWidget = (imgBytes != null)
                      ? pw.Image(
                          pw.MemoryImage(imgBytes),
                          fit: pw.BoxFit.contain,
                        )
                      : pw.Text(
                          "[Gambar Tidak Ditemukan]",
                          style: const pw.TextStyle(fontSize: 10),
                        );

                  // Konten data hasil deteksi penyakit
                  return pw.TableRow(
                    children: [
                      // Nomor urut
                      pw.Center(
                        child: pw.Text(
                          "$globalIndex.",
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      ),

                      // Gambar hasil deteksi penyakit beserta lama proses dan total objek aktual
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Column(
                          children: [
                            // Lama proses deteksi penyakit
                            pw.Text(
                              "Durasi Proses: $inferenceTime detik",
                              style: pw.TextStyle(fontSize: 10),
                            ),

                            // Jarak antar komponen
                            pw.SizedBox(height: 4),

                            // Gambar hasil deteksi penyakit
                            pw.Container(
                              height: 165,
                              width: 165,
                              child: imageWidget,
                            ),

                            // Jarak antar komponen
                            pw.SizedBox(height: 4),

                            // Total objek aktual
                            pw.Text(
                              "Total Objek Aktual*: ......",
                              style: pw.TextStyle(
                                fontSize: 10,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Hasil deteksi penyakit
                      pw.Column(
                        children: diseaseList
                            .map(
                              (d) => pw.Container(
                                height: 40,
                                alignment: pw.Alignment.centerLeft,
                                padding: const pw.EdgeInsets.all(4),
                                child: pw.Text(
                                  "- ${d['nama']} (${(d['confidence'] as num).toInt()}%)",
                                  style: const pw.TextStyle(fontSize: 10),
                                ),
                              ),
                            )
                            .toList(),
                      ),

                      // Validasi deteksi penyakit
                      pw.Column(
                        children: diseaseList
                            .map(
                              (_) => pw.Container(
                                height: 40,
                                alignment: pw.Alignment.center,
                                child: pw.Text(
                                  "......",
                                  style: const pw.TextStyle(fontSize: 10),
                                ),
                              ),
                            )
                            .toList(),
                      ),

                      // Akurasi deteksi penyakit
                      pw.Center(
                        child: pw.Text(
                          "......",
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      ),

                      // Perbaikan deteksi penyakit
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(
                          "",
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),

            // Jarak antar komponen
            pw.SizedBox(height: 12),

            // Konten rekap hasil deteksi penyakit
            pw.Inseparable(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Teks judul
                  pw.Text(
                    "Rekap Hasil Deteksi",
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),

                  // Teks kesimpulan hasil deteksi penyakit
                  _buildSummaryRow("Total Keseluruhan Objek Aktual"),
                  _buildSummaryRow("Total Deteksi Benar"),
                  _buildSummaryRow("Total Deteksi Salah"),
                  _buildSummaryRow("Total Tidak Terdeteksi"),
                  _buildSummaryRow("Akurasi Lapangan"),
                ],
              ),
            ),

            // Jarak antar komponen dan garis pemisah
            pw.SizedBox(height: 8),
            pw.Divider(thickness: 1, color: PdfColors.black),
            pw.SizedBox(height: 10),

            // Konten keterangan
            pw.Inseparable(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Teks judul
                  pw.Text(
                    "Keterangan:",
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),

                  // Keterangan total objek aktual
                  pw.Text(
                    "*Total Objek Aktual: Jumlah seluruh objek yang teramati di lapangan",
                    style: const pw.TextStyle(fontSize: 10),
                  ),

                  // Keterangan validasi
                  pw.Text(
                    "*Validasi: Penandaan status deteksi (V untuk benar, X untuk salah)",
                    style: const pw.TextStyle(fontSize: 10),
                  ),

                  // Keterangan akurasi dan perhitungan
                  pw.Text(
                    "*Akurasi: Persentase keberhasilan sistem, dihitung dengan rumus: (Deteksi Benar / Total Objek Aktual) x 100%",
                    style: const pw.TextStyle(fontSize: 10),
                  ),

                  // Keterangan perbaikan
                  pw.Text(
                    "*Perbaikan: Bagian untuk mencatat objek yang salah deteksi atau tidak terdeteksi oleh sistem",
                    style: const pw.TextStyle(fontSize: 10),
                  ),

                  // Keterangan gambar hasil deteksi
                  pw.Text(
                    "*Warna kotak pada Gambar Hasil Deteksi:",
                    style: const pw.TextStyle(fontSize: 10),
                  ),

                  // Jarak antar komponen
                  pw.SizedBox(height: 4),

                  // Tabel warna kotak sesuai penyakit
                  pw.Wrap(
                    spacing: 12,
                    runSpacing: 6,
                    children: [
                      _buildColorLegend(
                        PdfColor.fromInt(
                          AppColors.diseaseMapColors[1]!.toARGB32(),
                        ),
                        "Kuning",
                        hasBorder: true,
                      ),
                      _buildColorLegend(
                        PdfColor.fromInt(
                          AppColors.diseaseMapColors[2]!.toARGB32(),
                        ),
                        "Busuk Pangkal Batang",
                        hasBorder: true,
                      ),
                      _buildColorLegend(
                        PdfColor.fromInt(
                          AppColors.diseaseMapColors[3]!.toARGB32(),
                        ),
                        "Keriting/Kerdil",
                        hasBorder: true,
                      ),
                      _buildColorLegend(
                        PdfColor.fromInt(
                          AppColors.diseaseMapColors[4]!.toARGB32(),
                        ),
                        "Hawar Daun",
                        hasBorder: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Konten penanggung jawab
            pw.Inseparable(
              child: pw.Container(
                margin: const pw.EdgeInsets.only(top: 24),
                alignment: pw.Alignment.centerRight,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    // Tempat dan tanggal
                    pw.Text(
                      "..........................., ${DateFormat('dd MMMM yyyy', 'id_ID').format(DateTime.now())}",
                      style: const pw.TextStyle(fontSize: 10),
                    ),

                    // Teks penanggung jawab
                    pw.Text(
                      "Penanggung Jawab",
                      style: const pw.TextStyle(fontSize: 10),
                    ),

                    // Jarak untuk tanda tangan
                    pw.SizedBox(height: 45),

                    // Tempat untuk menuliskan nama penanggung jawab
                    pw.Text(
                      "(..............................)",
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
      ),
    );

    // Menyimpan file ke storage perangkat
    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;

      // Pengecekan izin storage versi lama
      if (androidInfo.version.sdkInt < 29) {
        if (!(await Permission.storage.request()).isGranted) {
          throw "Izin ditolak";
        }
      }

      // Ambil folder Download dari storage
      final downloadPath = await ExternalPath.getExternalStoragePublicDirectory(
        "Download",
      );
      // Arahkan atau buat folder PepperLens AI di dalam folder Download
      final customFolderPath = "$downloadPath/PepperLens AI";
      if (!Directory(customFolderPath).existsSync()) {
        Directory(customFolderPath).createSync(recursive: true);
      }

      // Nama file PDF yang akan disimpan
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final filePath =
          "$customFolderPath/data_riwayat_${category.replaceAll(' ', '_').toLowerCase()}_$timestamp.pdf";

      // Simpan file PDF ke storage perangkat
      await File(filePath).writeAsBytes(await pdf.save());

      // Jika kategori mengandung tanda pisah, artinya periode kustom
      String snackbarCategory = category;
      if (category.contains('-')) {
        snackbarCategory = "Kustom";
      }

      // Jika berhasil disimpan, tampilkan snackbar dan buka file PDF
      CustomSnackbar.showDownloadSnackbar(
        Get.context!,
        category: snackbarCategory,
        isSuccess: true,
        onOpenTap: () async {
          await OpenFilex.open(filePath);
        },
      );
    } catch (e) {
      // Jika gagal disimpan, potong label kategori
      String snackbarCategory = category.contains('-') ? "Kustom" : category;

      // Jika gagal simpan file PDF
      CustomSnackbar.showDownloadSnackbar(
        Get.context!,
        category: snackbarCategory,
        isSuccess: false,
      );
    }
  }

  // Fungsi untuk membangun header tabel PDF
  static pw.Widget _buildHeaderCell(String text) => pw.Padding(
    padding: const pw.EdgeInsets.all(2),
    child: pw.Text(
      text,
      textAlign: pw.TextAlign.center,
      style: pw.TextStyle(
        fontSize: 10,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.black,
      ),
    ),
  );

  // Fungsi untuk membangun baris summary tabel PDF
  static pw.Widget _buildSummaryRow(String title) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 2),
    child: pw.Row(
      children: [
        pw.SizedBox(
          width: 200,
          child: pw.Text(title, style: const pw.TextStyle(fontSize: 10)),
        ),
        pw.Text(": ......", style: const pw.TextStyle(fontSize: 10)),
      ],
    ),
  );

  // Fungsi untuk membangun warna kotak pada tabel PDF
  static pw.Widget _buildColorLegend(
    PdfColor color,
    String diseaseName, {
    bool hasBorder = false,
  }) {
    return pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Container(
          width: 12,
          height: 12,
          decoration: pw.BoxDecoration(
            color: color,
            border: hasBorder
                ? pw.Border.all(color: PdfColors.black, width: 0.5)
                : null,
          ),
        ),
        pw.SizedBox(width: 4),
        pw.Text(diseaseName, style: const pw.TextStyle(fontSize: 10)),
      ],
    );
  }
}
