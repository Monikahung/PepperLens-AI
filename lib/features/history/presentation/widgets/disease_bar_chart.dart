import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pepperlens_ai/core/constants/colors.dart';
import 'package:pepperlens_ai/core/constants/text_style.dart';
import 'package:pepperlens_ai/features/history/logic/visualization_mapper.dart';

// Widget untuk menampilkan visualisasi data berupa diagram batang
class DiseaseBarChart extends StatelessWidget {
  // Atribut untuk menyimpan data diagram batang
  final Map<int, double> chartData;

  // Instance dari DiseaseBarChart dengan parameter wajib diisi
  const DiseaseBarChart({super.key, required this.chartData});

  // Bangun tampilan visualisasi data berupa diagram batang
  @override
  Widget build(BuildContext context) {
    // Menghitung skala, interval, dan nilai maksimum untuk diagram batang
    final scale = VisualizationMapper.calculateChartScale(chartData);
    final interval = scale['interval']!;
    final dynamicMaxY = scale['maxY']!;

    // Mengembalikan visualisasi data berupa diagram batang
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        // Nilai maksimum untuk sumbu Y
        maxY: dynamicMaxY,
        // Nilai minimum untuk sumbu Y
        minY: 0,
        // Jika bar ditekan, menampilkan tooltip
        barTouchData: BarTouchData(
          enabled: false,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => AppColors.transparent,
            tooltipPadding: EdgeInsets.zero,
            tooltipMargin: 0,
            tooltipBorderRadius: BorderRadius.circular(8),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                rod.toY.toInt().toString(),
                AppTextStyles.manropeThirteen,
              );
            },
          ),
        ),
        // Judul untuk sisi diagram
        titlesData: FlTitlesData(
          show: true,
          // Nonaktif judul atas
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          // Nonaktif judul kanan
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          // Judul bawah atau sumbu X berupa nama penyakit
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: _getBottomTitles,
              reservedSize: 35,
            ),
          ),
          // Judul kiri atau sumbu Y berupa angka jumlah penyakit
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 26,
              interval: interval,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  meta: meta,
                  space: 5,
                  child: Text(
                    value.toInt().toString(),
                    style: AppTextStyles.manropeOne,
                  ),
                );
              },
            ),
          ),
        ),
        // Grid data untuk diagram batang
        gridData: const FlGridData(show: false),
        // Border data untuk diagram batang
        borderData: FlBorderData(
          show: true,
          border: const Border(
            left: BorderSide(color: AppColors.darkCyan, width: 0.5),
            bottom: BorderSide(color: AppColors.darkCyan, width: 0.5),
          ),
        ),
        // Data untuk diagram batang
        barGroups: _getBarGroups(chartData, dynamicMaxY),
      ),
    );
  }

  // Data label untuk ditampilkan pada sumbu X diagram batang
  Widget _getBottomTitles(double value, TitleMeta meta) {
    // Style teks untuk label sumbu X
    const style = AppTextStyles.manropeOne;
    switch (value.toInt()) {
      // Untuk penyakit kuning
      case 0:
        return SideTitleWidget(
          meta: meta,
          child: const Text('Kuning', style: style),
        );
      // Untuk penyakit busuk pangkal batang
      case 1:
        return SideTitleWidget(
          meta: meta,
          child: const Text('BPB', style: style),
        );
      // Untuk penyakit keriting/kerdil
      case 2:
        return SideTitleWidget(
          meta: meta,
          child: const Text('Keriting', style: style),
        );
      // Untuk penyakit hawar daun
      case 3:
        return SideTitleWidget(
          meta: meta,
          child: const Text('Hawar', style: style),
        );
      default:
        return const Text('');
    }
  }

  // Data untuk batang diagram
  List<BarChartGroupData> _getBarGroups(
    Map<int, double> chartData,
    double maxY,
  ) {
    return [
      // Membuat batang tunggal untuk setiap penyakit dengan data dari chartData
      _makeBarData(0, chartData[1] ?? 0, AppColors.getDiseaseColor(1), maxY),
      _makeBarData(1, chartData[2] ?? 0, AppColors.getDiseaseColor(2), maxY),
      _makeBarData(2, chartData[3] ?? 0, AppColors.getDiseaseColor(3), maxY),
      _makeBarData(3, chartData[4] ?? 0, AppColors.getDiseaseColor(4), maxY),
    ];
  }

  // Membuat batang tunggal dengan data yang diberikan
  BarChartGroupData _makeBarData(int x, double y, Color color, double maxY) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 40,
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(
            color: AppColors.darkCyan.withAlpha((0.75 * 255).toInt()),
            width: 1,
          ),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: maxY,
            color: AppColors.darkCyan.withAlpha((0.05 * 255).toInt()),
          ),
        ),
      ],
      // Paksa FlChart menampilkan label data rod secara permanen
      showingTooltipIndicators: [0],
    );
  }
}
