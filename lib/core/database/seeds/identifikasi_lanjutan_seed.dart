import 'package:sqflite/sqflite.dart';

class IdentifikasiLanjutanSeed {
  static Future<void> addDataIdentifikasiLanjutan(
    Transaction txn,
    Map<int, int> penyakitIds,
  ) async {
    // 1. Penyakit Kuning
    final int idKuning = penyakitIds[1]!;

    // Identifikasi Lanjutan Penyakit Kuning
    List<String> langkahIdentifikasiKuning = [
      'Periksa daun dan batang. Jika daun menguning, pucat, atau rontok, dan batang terlihat lemah atau warnanya tidak normal, tanaman perlu diwaspadai.',
      'Gali sedikit di samping batang untuk memeriksa akar tanpa mencabut tanaman.',
      'Jika akar berwarna cokelat tua atau hitam, kemungkinan terserang nematoda atau jamur.',
      'Raba tekstur akar. Akar yang lunak, lembek, dan mudah patah menandakan penyakit.',
      'Amati pertumbuhan tanaman. Tanaman yang melambat, daun terus menguning, dan pucat kemungkinan terserang penyakit.',
    ];

    for (int i = 0; i < langkahIdentifikasiKuning.length; i++) {
      await txn.insert('Identifikasi_Lanjutan', {
        'id_penyakit': idKuning,
        'urutan': i + 1,
        'desc_langkah': langkahIdentifikasiKuning[i],
      });
    }

    // 2. Penyakit Busuk Pangkal Batang
    final int idBPB = penyakitIds[2]!;

    // Identifikasi Lanjutan Penyakit Busuk Pangkal Batang
    List<String> langkahIdentifikasiBPB = [
      'Periksa pangkal batang. Jika berwarna gelap, basah, atau kulitnya mengelupas, tanaman perlu dicurigai.',
      'Gali sedikit di samping batang untuk memeriksa akar tanpa mencabut tanaman.',
      'Apabila akar berwarna cokelat tua atau hitam, tanaman terindikasi terserang penyakit.',
      'Selain itu, tekstur akar terasa lunak, lembek, dan mudah putus.',
      'Jika tercium bau busuk, berarti akar mengalami pembusukan.',
    ];

    for (int i = 0; i < langkahIdentifikasiBPB.length; i++) {
      await txn.insert('Identifikasi_Lanjutan', {
        'id_penyakit': idBPB,
        'urutan': i + 1,
        'desc_langkah': langkahIdentifikasiBPB[i],
      });
    }
  }
}
