// Logic untuk menangani perhitungan dan konversi untuk tampilan visualisasi
class VisualizationMapper {
  // Memproses data dari repository menjadi total per id penyakit
  static Map<int, double> processChartData(
    List<Map<String, dynamic>> historyData,
  ) {
    // Variabel totals penampung total deteksi per id penyakit
    Map<int, double> totals = {1: 0.0, 2: 0.0, 3: 0.0, 4: 0.0};

    // Iterasi berdasarkan data detail hasil deteksi
    for (var record in historyData) {
      // List data penyakit yang terdeteksi
      var penyakitList = record['penyakit_data'] as List?;
      if (penyakitList == null) continue;

      // Iterasi berdasarkan data penyakit yang terdeteksi
      for (var p in penyakitList) {
        // Jika id tidak ada, lanjutkan iterasi
        if (p['id'] == null) continue;

        // Ambil id dan jumlah deteksi penyakit
        int id = int.tryParse(p['id'].toString()) ?? 0;
        double jumlah = double.tryParse(p['jumlah']?.toString() ?? '0') ?? 0.0;

        // Perhitungan total deteksi per id penyakit
        if (totals.containsKey(id)) {
          totals[id] = totals[id]! + jumlah;
        }
      }
    }
    return totals;
  }

  // Konversi teks filter menjadi judul halaman yang sesuai
  static String getTitleByFilter(String filter) {
    switch (filter.trim()) {
      case 'Hari ini':
        return "Hasil Deteksi Hari Ini";
      case 'Bulan ini':
        return "Hasil Deteksi Bulan Ini";
      case 'Tahun ini':
        return "Hasil Deteksi Tahun Ini";
      case 'Semua':
        return "Hasil Deteksi Sepanjang Waktu";
      default:
        return "Hasil Deteksi";
    }
  }

  // Menghitung interval dan maxY secara dinamis berdasarkan data tertinggi
  static Map<String, double> calculateChartScale(Map<int, double> chartData) {
    // Deklarasi variabel untuk interval dan maxY
    double maxData = chartData.values.isEmpty
        ? 0
        : chartData.values.reduce((a, b) => a > b ? a : b);

    double interval;
    double dynamicMaxY;

    // Penentuan interval dan maxY berdasarkan data tertinggi
    if (maxData <= 5) {
      interval = 1;
      dynamicMaxY = 5;
    } else if (maxData <= 10) {
      interval = 2;
      dynamicMaxY = 10;
    } else if (maxData <= 30) {
      interval = 5;
      dynamicMaxY = (maxData / 5).ceil() * 5;
    } else if (maxData <= 100) {
      interval = 20;
      dynamicMaxY = (maxData / 20).ceil() * 20;
    } else if (maxData <= 500) {
      interval = 100;
      dynamicMaxY = (maxData / 100).ceil() * 100;
    } else {
      interval = 500;
      dynamicMaxY = (maxData / 500).ceil() * 500;
    }

    // Tambahkan ekstra ruang satu langkah interval di atas nilai maksimal
    dynamicMaxY += interval;

    // Mengembalikan interval dan maxY
    return {'interval': interval, 'maxY': dynamicMaxY};
  }
}
