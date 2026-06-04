import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:intl/intl.dart';
import 'package:pepperlens_ai/core/constants/colors.dart';
import 'package:pepperlens_ai/core/constants/text_style.dart';

// Widget dialog kustom untuk memilih rentang tanggal awal dan akhir berupa kalender yang dipakai di filter visualisasi dan unduh data
class DateRangeDialog extends StatefulWidget {
  // Callback fungsi untuk meneruskan data objek DateTimeRange yang berhasil dipilih kembali ke widget pengirim
  final Function(DateTimeRange) onApply;

  const DateRangeDialog({super.key, required this.onApply});

  // Fungsi statis untuk memicu pemanggilan eksekusi penampilan showDialog
  static void show(BuildContext context, Function(DateTimeRange) onApply) {
    showDialog(
      context: context,
      builder: (context) => DateRangeDialog(onApply: onApply),
    );
  }

  @override
  State<DateRangeDialog> createState() => _DateRangeDialogState();
}

class _DateRangeDialogState extends State<DateRangeDialog> {
  // State untuk menampung objek rentang tanggal yang dipilih serta format standar penampilan teks tanggal menggunakan penamaan bulan bahasa Indonesia
  PickerDateRange? _selectedRange;
  final DateFormat formatter = DateFormat('dd MMM yyyy', 'id_ID');

  // Bangun tampilan kalender
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.transparent,
      insetPadding: const EdgeInsets.all(20),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.frostedMint,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.honeydew, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
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

            // Teks judul
            Center(
              child: Text(
                "Pilih Rentang Waktu",
                style: AppTextStyles.manropeSeventeen,
                textAlign: TextAlign.center,
              ),
            ),

            // Jarak antar komponen
            const SizedBox(height: 4),

            // Teks tanggal awal dan akhir
            SizedBox(
              width: double.infinity,
              child: Text(
                _selectedRange?.startDate == null
                    // Jika belum dipilih tanggal awal atau akhir
                    ? "Tekan tanggal awal dan akhir"
                    // Jika sudah dipilih tanggal awal atau akhir
                    : "${formatter.format(_selectedRange!.startDate!)} - ${_selectedRange!.endDate != null ? formatter.format(_selectedRange!.endDate!) : '...'}",
                textAlign: TextAlign.center,
                style: AppTextStyles.manropeTwo,
              ),
            ),

            // Jarak antar komponen
            const SizedBox(height: 12),

            // Widget kalender
            Theme(
              // Atur warna tema
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: AppColors.honeydew,
                ),
              ),
              child: SizedBox(
                height: 300,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: SfDateRangePicker(
                    // Kustom mode range
                    selectionMode: DateRangePickerSelectionMode.range,

                    // Kustom warna background beserta warna range tanggal
                    backgroundColor: AppColors.honeydew,
                    selectionColor: AppColors.mysticJade,
                    rangeSelectionColor: AppColors.mysticJade.withAlpha(
                      (0.25 * 255).toInt(),
                    ),
                    startRangeSelectionColor: AppColors.mysticJade,
                    endRangeSelectionColor: AppColors.mysticJade,
                    todayHighlightColor: AppColors.mysticJade,

                    // Kustom header
                    headerStyle: const DateRangePickerHeaderStyle(
                      backgroundColor: Colors.transparent,
                      textStyle: AppTextStyles.manropeSixteen,
                    ),

                    // Kustom style
                    monthCellStyle: const DateRangePickerMonthCellStyle(
                      textStyle: AppTextStyles.manropeSixteen,
                      todayTextStyle: AppTextStyles.manropeSixteen,
                      leadingDatesTextStyle: AppTextStyles.manropeSixteen,
                      trailingDatesTextStyle: AppTextStyles.manropeSixteen,
                    ),

                    // Callback otomatis setiap kali pengguna menekan elemen tanggal pada kalender
                    onSelectionChanged: (args) {
                      setState(() {
                        if (args.value is PickerDateRange) {
                          // Perbarui objek state rentang tanggal aktif
                          _selectedRange = args.value;
                        }
                      });
                    },
                  ),
                ),
              ),
            ),

            // Jarak antar komponen
            const SizedBox(height: 12),

            // Tombol terapkan
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mysticJade,
                  side: const BorderSide(color: AppColors.honeydew, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  // Warna background waktu tidak aktif
                  disabledBackgroundColor: AppColors.honeydew.withAlpha(
                    (0.25 * 255).toInt(),
                  ),
                ),
                onPressed:
                    (_selectedRange?.startDate != null &&
                        _selectedRange?.endDate != null)
                    ? () {
                        widget.onApply(
                          DateTimeRange(
                            start: _selectedRange!.startDate!,
                            end: _selectedRange!.endDate!,
                          ),
                        );
                        Navigator.pop(context);
                      }
                    : null,
                // Teks tombol terapkan
                child: Text("Terapkan", style: AppTextStyles.manropeSeven),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
