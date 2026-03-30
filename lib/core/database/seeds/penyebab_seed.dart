import 'package:sqflite/sqflite.dart';

class PenyebabSeed {
  static Future<void> addDataPenyebab(
    Transaction txn,
    Map<int, int> penyakitIds,
  ) async {
    // 1. Penyakit Kuning
    final int idKuning = penyakitIds[1]!;

    // Penyebab Penyakit Kuning
    await txn.insert('Penyebab', {
      'id_penyakit': idKuning,
      'desc_penyebab': 'Nematoda atau cacing Radopholus similis.',
    });
    await txn.insert('Penyebab', {
      'id_penyakit': idKuning,
      'desc_penyebab': 'Nematoda atau cacing Meloidogyne incognita.',
    });
    await txn.insert('Penyebab', {
      'id_penyakit': idKuning,
      'desc_penyebab': 'Jamur Fusarium oxysporum.',
    });
    await txn.insert('Penyebab', {
      'id_penyakit': idKuning,
      'desc_penyebab': 'Tanah kurang subur karena kekurangan bahan organik.',
    });

    // 2. Penyakit Busuk Pangkal Batang
    final int idBPB = penyakitIds[2]!;

    // Penyebab Penyakit Busuk Pangkal Batang
    await txn.insert('Penyebab', {
      'id_penyakit': idBPB,
      'desc_penyebab': 'Infeksi patogen tanah seperti Phytophthora capsici.',
    });
    await txn.insert('Penyebab', {
      'id_penyakit': idBPB,
      'desc_penyebab': 'Kondisi tanah terlalu lembap atau tergenang air.',
    });
    await txn.insert('Penyebab', {
      'id_penyakit': idBPB,
      'desc_penyebab': 'Sistem drainase kebun kurang baik.',
    });
    await txn.insert('Penyebab', {
      'id_penyakit': idBPB,
      'desc_penyebab':
          'Lingkungan kebun terlalu teduh dan sirkulasi udara kurang baik.',
    });

    // 3. Penyakit Keriting/Kerdil
    final int idKeriting = penyakitIds[3]!;

    // Penyebab Penyakit Keriting/Kerdil
    await txn.insert('Penyebab', {
      'id_penyakit': idKeriting,
      'desc_penyebab': 'Virus CMV (Cucumber Mosaic Virus).',
    });
    await txn.insert('Penyebab', {
      'id_penyakit': idKeriting,
      'desc_penyebab': 'Virus PYMoV (Pepper Yellow Mottle Virus).',
    });

    // 4. Penyakit Hawar Daun
    final int idHawar = penyakitIds[4]!;

    // Penyebab Penyakit Hawar Daun
    await txn.insert('Penyebab', {
      'id_penyakit': idHawar,
      'desc_penyebab':
          'Infeksi jamur, umumnya dari kelompok Cercospora, Colletotrichum, atau jamur sejenis.',
    });
    await txn.insert('Penyebab', {
      'id_penyakit': idHawar,
      'desc_penyebab': 'Kondisi lingkungan lembap dan curah hujan tinggi.',
    });
    await txn.insert('Penyebab', {
      'id_penyakit': idHawar,
      'desc_penyebab': 'Sirkulasi udara yang buruk dan tanaman terlalu rapat.',
    });
    await txn.insert('Penyebab', {
      'id_penyakit': idHawar,
      'desc_penyebab': 'Daun sering basah.',
    });
  }
}
