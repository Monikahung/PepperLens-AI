import 'package:intl/intl.dart';

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
      case 'Minggu ini':
        return "Hasil Deteksi Minggu Ini";
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

  // Menghasilkan rentang tanggal tertulis menggunakan lokalisasi bahasa Indonesia untuk ditampilkan di sub judul visualisasi
  static String getDateRangeByFilter(
    String filter,
    List<Map<String, dynamic>> data,
  ) {
    if (data.isEmpty) return "-";

    // Format tanggal dari SQLite dan konversi keluaran akhir
    final DateFormat inputFormat = DateFormat("d MMM yyyy", "id_ID");
    final DateFormat formatter = DateFormat('d MMMM yyyy', 'id_ID');

    DateTime now = DateTime.now();

    // Penanganan kondisi jika memilih tanggal kustom
    if (filter.contains('_')) {
      List<String> parts = filter.split('_');
      return "${formatter.format(DateTime.parse(parts[0]))} - ${formatter.format(DateTime.parse(parts[1]))}";
    }

    switch (filter) {
      case 'Hari ini':
        // Gunakan tanggal hari ini
        return formatter.format(now);

      case 'Minggu ini':
        // Hitung tanggal awal dan akhir minggu ini
        DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));
        return "${formatter.format(startOfWeek)} - ${formatter.format(endOfWeek)}";

      case 'Bulan ini':
        // Hitung tanggal awal dan akhir bulan ini
        DateTime startOfMonth = DateTime(now.year, now.month, 1);
        DateTime endOfMonth = DateTime(now.year, now.month + 1, 0);
        return "${formatter.format(startOfMonth)} - ${formatter.format(endOfMonth)}";

      case 'Tahun ini':
        // Hitung tanggal awal dan akhir tahun ini
        return "1 Januari ${now.year} - 31 Desember ${now.year}";

      case 'Semua':
        // Melakukan parsing string dan mengurutkan seluruh objek tanggal dari terlama hingga terbaru
        List<DateTime> dates = data.map((e) {
          String dateString = e['tanggal'].toString().trim();

          // Bersihkan spasi berlebih di dalam string tanggal
          dateString = dateString.replaceAll(RegExp(r'\s+'), ' ');

          try {
            return inputFormat.parse(dateString);
          } catch (err) {
            return DateTime.now();
          }
        }).toList()..sort();

        // Mengembalikan rentang dari entri indeks pertama (terlama) sampai indeks terakhir (terbaru)
        return "${formatter.format(dates.first)} - ${formatter.format(dates.last)}";

      default:
        return "";
    }
  }

  // Mengubah teks filter bawaan sistem menjadi kalimat penjelas rentang waktu untuk ditampilkan di catatan visualisasi
  static String getFormattedDateRange(String filter) {
    // Parsing rentang jika mendeteksi pemisah rentang kustom
    if (filter.contains('_')) {
      List<String> range = filter.split('_');
      String start = DateFormat(
        'd MMMM yyyy',
        'id_ID',
      ).format(DateTime.parse(range[0]));
      String end = DateFormat(
        'd MMMM yyyy',
        'id_ID',
      ).format(DateTime.parse(range[1]));
      return "$start sampai $end";
    }

    // Penanganan untuk kategori filter
    switch (filter.trim()) {
      case 'Hari ini':
        return "hari ini";
      case 'Minggu ini':
        return "minggu ini";
      case 'Bulan ini':
        return "bulan ini";
      case 'Tahun ini':
        return "tahun ini";
      case 'Semua':
        return "seluruh waktu";
      default:
        return filter.toLowerCase();
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
