import 'package:sqflite/sqflite.dart';

class PengendalianSeed {
  static Future<void> addDataPengendalian(
    Transaction txn,
    Map<int, int> penyakitIds,
  ) async {
    // 1. Penyakit Kuning
    final int idKuning = penyakitIds[1]!;

    // Pengendalian Penyakit Kuning
    await txn.insert('Pengendalian', {
      'id_penyakit': idKuning,
      'desc_pengendalian':
          'Amati tanaman secara rutin, perhatikan daun yang menguning atau pucat.',
    });
    await txn.insert('Pengendalian', {
      'id_penyakit': idKuning,
      'desc_pengendalian': 'Gunakan bibit sehat dan bebas penyakit.',
    });
    await txn.insert('Pengendalian', {
      'id_penyakit': idKuning,
      'desc_pengendalian':
          'Hindari menanam di lokasi yang sebelumnya terserang penyakit kuning.',
    });
    await txn.insert('Pengendalian', {
      'id_penyakit': idKuning,
      'desc_pengendalian':
          'Jaga kesuburan dan keseimbangan nutrisi tanah, serta hindari genangan air.',
    });
    await txn.insert('Pengendalian', {
      'id_penyakit': idKuning,
      'desc_pengendalian':
          'Cabut dan buang tanaman yang menunjukkan gejala kuning parah untuk mencegah penyebaran.',
    });

    // 2. Penyakit Busuk Pangkal Batang
    final int idBPB = penyakitIds[2]!;

    // Pengendalian Penyakit Busuk Pangkal Batang
    await txn.insert('Pengendalian', {
      'id_penyakit': idBPB,
      'desc_pengendalian':
          'Amati kondisi tanaman secara rutin, terutama saat musim hujan.',
    });
    await txn.insert('Pengendalian', {
      'id_penyakit': idBPB,
      'desc_pengendalian': 'Gunakan bibit sehat dan bebas penyakit.',
    });
    await txn.insert('Pengendalian', {
      'id_penyakit': idBPB,
      'desc_pengendalian':
          'Hindari penggunaan bibit dari kebun yang terserang penyakit.',
    });
    await txn.insert('Pengendalian', {
      'id_penyakit': idBPB,
      'desc_pengendalian':
          'Pastikan drainase kebun baik agar tidak terjadi genangan air.',
    });
    await txn.insert('Pengendalian', {
      'id_penyakit': idBPB,
      'desc_pengendalian':
          'Segera cabut tanaman yang pangkal batang atau akarnya sudah busuk.',
    });

    // 3. Penyakit Keriting/Kerdil
    final int idKeriting = penyakitIds[3]!;

    // Pengendalian Penyakit Keriting/Kerdil
    await txn.insert('Pengendalian', {
      'id_penyakit': idKeriting,
      'desc_pengendalian':
          'Gunakan bahan tanam atau bibit yang sehat dan bebas virus.',
    });
    await txn.insert('Pengendalian', {
      'id_penyakit': idKeriting,
      'desc_pengendalian': 'Cabut dan musnahkan tanaman yang terinfeksi.',
    });
    await txn.insert('Pengendalian', {
      'id_penyakit': idKeriting,
      'desc_pengendalian':
          'Bersihkan atau sterilkan alat yang digunakan agar tidak menularkan penyakit.',
    });
    await txn.insert('Pengendalian', {
      'id_penyakit': idKeriting,
      'desc_pengendalian':
          'Kendalikan serangga pembawa virus, seperti kutu daun.',
    });

    // 4. Penyakit Hawar Daun
    final int idHawar = penyakitIds[4]!;

    // Pengendalian Penyakit Hawar Daun
    await txn.insert('Pengendalian', {
      'id_penyakit': idHawar,
      'desc_pengendalian': 'Gunakan bibit sehat dan bebas penyakit.',
    });
    await txn.insert('Pengendalian', {
      'id_penyakit': idHawar,
      'desc_pengendalian':
          'Jaga kebersihan kebun dan buang daun yang terinfeksi.',
    });
    await txn.insert('Pengendalian', {
      'id_penyakit': idHawar,
      'desc_pengendalian':
          'Atur jarak tanam dan sirkulasi udara agar tidak lembap.',
    });
    await txn.insert('Pengendalian', {
      'id_penyakit': idHawar,
      'desc_pengendalian':
          'Perbaiki kondisi tanah dengan drainase yang baik serta pengaplikasian kapur dolomit untuk pH tanah.',
    });
    await txn.insert('Pengendalian', {
      'id_penyakit': idHawar,
      'desc_pengendalian':
          'Gunakan agen hayati atau fungisida bila diperlukan.',
    });
  }
}
