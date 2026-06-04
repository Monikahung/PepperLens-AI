import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pepperlens_ai/core/constants/colors.dart';
import 'package:pepperlens_ai/core/constants/text_style.dart';
import 'package:pepperlens_ai/features/history/presentation/widgets/custom_snackbar.dart';
import 'package:pepperlens_ai/features/history/presentation/widgets/date_range_dialog.dart';

// Widget untuk menampilkan dialog filter kategori riwayat yang ingin diunduh ke bentuk dokumen PDF
class HistoryDownloadDialog extends StatefulWidget {
  // Atribut yang diperlukan untuk membangun dialog filter kategori riwayat yang ingin diunduh
  final String currentCategory;
  final List<String> categories;
  final Function(String filterParam, String pdfTitle) onDownloadConfirm;
  final String? firstDataDate;
  final String? lastDataDate;

  // Instance dari HistoryDownloadDialog dengan parameter wajib diisi
  const HistoryDownloadDialog({
    super.key,
    required this.currentCategory,
    required this.categories,
    required this.onDownloadConfirm,
    this.firstDataDate,
    this.lastDataDate,
  });

  // Function statis untuk memicu pemanggilan eksekusi showDialog
  static void show(
    BuildContext context, {
    required String currentCategory,
    required List<String> categories,
    required Function(String filterParam, String pdfTitle) onDownloadConfirm,
    String? firstDataDate,
    String? lastDataDate,
  }) {
    showDialog(
      context: context,
      builder: (context) => HistoryDownloadDialog(
        currentCategory: currentCategory,
        categories: categories,
        onDownloadConfirm: onDownloadConfirm,
        firstDataDate: firstDataDate,
        lastDataDate: lastDataDate,
      ),
    );
  }

  @override
  State<HistoryDownloadDialog> createState() => _HistoryDownloadDialogState();
}

class _HistoryDownloadDialogState extends State<HistoryDownloadDialog> {
  // State untuk menyimpan kategori unduhan pilihan pengguna
  late String _downloadSelectedCategory;

  // State untuk menyimpan objek rentang tanggal yang dipilih oleh pengguna jika memilih opsi kustom
  DateTimeRange? _downloadSelectedDateRange;

  // State untuk menyembunyikan dialog sementara ketika sub dialog kalender sedang terbuka
  bool _isCalendarOpen = false;

  // Inisialisasi awal variabel state saat objek state dialog pertama kali dibuat
  @override
  void initState() {
    super.initState();
    // Sinkron otomatis nilai radio awal berdasarkan filter yang sedang aktif di layar riwayat
    _downloadSelectedCategory = widget.currentCategory;
  }

  // Fungsi untuk mendapatkan string rentang periode tanggal berdasarkan pilihan pengguna
  String _getPeriodText() {
    // Tanggal hari ini
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Format tanggal menggunakan lokalisasi Indonesia
    final formatter = DateFormat('dd MMM yyyy', 'id_ID');

    // Switch untuk konversi kategori menjadi rentang waktu
    switch (_downloadSelectedCategory) {
      // Jika memilih hari ini
      case 'Hari Ini':
      case 'Hari ini':
        return "Periode:\n${formatter.format(today)}";

      // Jika memilih minggu ini
      case 'Minggu Ini':
      case 'Minggu ini':
        final int daysToSubtract = today.weekday - DateTime.monday;
        final startOfWeek = today.subtract(Duration(days: daysToSubtract));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        return "Periode:\n${formatter.format(startOfWeek)} s/d ${formatter.format(endOfWeek)}";

      // Jika memilih bulan ini
      case 'Bulan Ini':
      case 'Bulan ini':
        final startOfMonth = DateTime(today.year, today.month, 1);
        final endOfMonth = DateTime(today.year, today.month + 1, 0);
        return "Periode:\n${formatter.format(startOfMonth)} s/d ${formatter.format(endOfMonth)}";

      // Jika memilih tahun ini
      case 'Tahun Ini':
      case 'Tahun ini':
        final startOfYear = DateTime(today.year, 1, 1);
        final endOfYear = DateTime(today.year, 12, 31);
        return "Periode:\n${formatter.format(startOfYear)} s/d ${formatter.format(endOfYear)}";

      // Jika memilih semua
      case 'Semua':
        if (widget.firstDataDate != null && widget.lastDataDate != null) {
          return "Periode:\n${widget.firstDataDate} s/d ${widget.lastDataDate}";
        }
        return "Periode:\nMenampilkan seluruh riwayat data terdata";

      // Jika memilih kustom
      case 'Kustom':
        if (_downloadSelectedDateRange != null) {
          return "Periode:\n${formatter.format(_downloadSelectedDateRange!.start)} s/d ${formatter.format(_downloadSelectedDateRange!.end)}";
        }
        return "Periode:\nRentang waktu belum ditentukan";

      // Jika memilih kategori lain
      default:
        return "Periode:\nMenampilkan semua cakupan data kategori $_downloadSelectedCategory";
    }
  }

  @override
  Widget build(BuildContext context) {
    // Jika dialog kalender diaktifkan, kembalikan widget kosong agar tampilan dialog utama tidak tumpang tindih
    if (_isCalendarOpen) {
      return const SizedBox.shrink();
    }

    return AlertDialog(
      backgroundColor: AppColors.honeydew,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      title: const Text(
        "Pilih Periode Riwayat",
        style: AppTextStyles.manropeEight,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tampilkan informasi berupa periode tanggal awal dan akhir apabila dipilih filter kustom
            Padding(
              padding: EdgeInsets.zero,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: AppColors.honeydew,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: AppColors.mysticJade, width: 1.5),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _getPeriodText(),
                    style: AppTextStyles.manropeFourteen,
                  ),
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.only(top: 12),
              // Kontainer pengelola pilihan kelompok tombol radio tunggal
              child: RadioGroup<String>(
                groupValue: _downloadSelectedCategory,
                onChanged: (value) async {
                  if (value == null) return;

                  // Jika nilainya kustom
                  if (value == 'Kustom') {
                    setState(() => _isCalendarOpen = true);

                    // Tampilkan dialog kalender untuk memilih rentang tanggal
                    await showDialog(
                      context: context,
                      builder: (context) => DateRangeDialog(
                        onApply: (DateTimeRange range) {
                          // Perbarui variabel penampung data tanggal pasca aksi konfirmasi kalender
                          _downloadSelectedCategory = value;
                          _downloadSelectedDateRange = range;
                        },
                      ),
                    );

                    setState(() => _isCalendarOpen = false);
                  } else {
                    // Jika memilih filter selain kustom, reset data rentang tanggal menjadi null
                    setState(() {
                      _downloadSelectedCategory = value;
                      _downloadSelectedDateRange = null;
                    });
                  }
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  // Petakan list kategori menjadi baris komponen RadioListTile
                  children: widget.categories.map((category) {
                    return RadioListTile<String>(
                      title: Text(category, style: AppTextStyles.manropeNine),
                      value: category,
                      activeColor: AppColors.mysticJade,
                      contentPadding: EdgeInsets.symmetric(vertical: 4),
                      visualDensity: const VisualDensity(
                        horizontal: VisualDensity.minimumDensity,
                        vertical: VisualDensity.minimumDensity,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        // Tombol batal
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Batal", style: AppTextStyles.manropeFifteen),
        ),

        // Tombol unduh
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.mysticJade,
          ),
          onPressed: () {
            // Cegah jika pilih kustom, tapi tidak menentukan tanggal di kalender
            if (_downloadSelectedCategory == 'Kustom' &&
                _downloadSelectedDateRange == null) {
              CustomSnackbar.showSnackbar(
                context,
                message: 'Pilih rentang waktu terlebih dahulu',
                isSuccess: false,
              );
              return;
            }

            // Inisialisasi variabel string default untuk parameter filter database dan judul dokumen PDF
            String filterParam = _downloadSelectedCategory;
            String pdfTitle = _downloadSelectedCategory;

            // Pemformatan ulang string jika data parameter bernilai kustom
            if (_downloadSelectedCategory == 'Kustom' &&
                _downloadSelectedDateRange != null) {
              // Memotong string tanggal ISO (YYYY-MM-DD HH:mm:ss) menjadi format tanggal database (YYYY-MM-DD)
              final startDateStr = _downloadSelectedDateRange!.start
                  .toString()
                  .split(' ')[0];
              final endDateStr = _downloadSelectedDateRange!.end
                  .toString()
                  .split(' ')[0];

              // Parameter digabungkan menggunakan garis bawah
              filterParam = "${startDateStr}_$endDateStr";

              // Memformat penulisan judul teks tanggal dalam dokumen PDF menggunakan lokalisasi Indonesia
              final startFormatted = DateFormat(
                'dd MMM yyyy',
                'id_ID',
              ).format(_downloadSelectedDateRange!.start);
              final endFormatted = DateFormat(
                'dd MMM yyyy',
                'id_ID',
              ).format(_downloadSelectedDateRange!.end);

              // Format teks judul gabungan
              pdfTitle = "$startFormatted - $endFormatted";
            }

            // Menutup tampilan dialog
            Navigator.pop(context);

            // Picu fungsi callback konfirmasi untuk mengekspor data ke dokumen PDF
            widget.onDownloadConfirm(filterParam, pdfTitle);
          },

          // Teks tombol unduh
          child: const Text("Unduh", style: AppTextStyles.manropeEleven),
        ),
      ],
    );
  }
}
