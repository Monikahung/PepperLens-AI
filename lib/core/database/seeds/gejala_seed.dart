import 'package:sqflite/sqflite.dart';

class GejalaSeed {
  static Future<void> addDataGejala(
    Transaction txn,
    Map<int, int> penyakitIds,
  ) async {
    // 1. Penyakit Kuning
    final int idKuning = penyakitIds[1]!;

    // Gejala Penyakit Kuning
    await txn.insert('Gejala', {
      'id_penyakit': idKuning,
      'desc_gejala':
          'Daun dan ruas buku sulur berubah menjadi kuning secara bertahap.',
    });
    await txn.insert('Gejala', {
      'id_penyakit': idKuning,
      'desc_gejala':
          'Warna kuning biasanya dimulai dari daun bawah lalu menyebar ke atas.',
    });
    await txn.insert('Gejala', {
      'id_penyakit': idKuning,
      'desc_gejala': 'Daun tampak pucat, lemas, dan tidak segar.',
    });
    await txn.insert('Gejala', {
      'id_penyakit': idKuning,
      'desc_gejala': 'Pertumbuhan tanaman menjadi lambat.',
    });
    await txn.insert('Gejala', {
      'id_penyakit': idKuning,
      'desc_gejala': 'Daun dapat rontok jika kondisi semakin parah.',
    });

    // Gambar Gejala Penyakit Kuning
    await txn.insert('Gambar_Gejala', {
      'id_penyakit': idKuning,
      'path_gambar': 'assets/images/disease_images/yellow_leaf.png',
      'keterangan': 'Kondisi Daun Penyakit Kuning',
    });
    await txn.insert('Gambar_Gejala', {
      'id_penyakit': idKuning,
      'path_gambar': 'assets/images/disease_images/yellow_plant.png',
      'keterangan': 'Kondisi Lada Penyakit Kuning',
    });


    // 2. Penyakit Busuk Pangkal Batang
    final int idBPB = penyakitIds[2]!;

    // Gejala Penyakit Busuk Pangkal Batang
    await txn.insert('Gejala', {
      'id_penyakit': idBPB,
      'desc_gejala': 'Tanaman tiba-tiba layu dan dapat mati dengan cepat.',
    });
    await txn.insert('Gejala', {
      'id_penyakit': idBPB,
      'desc_gejala': 'Daun berubah menjadi kuning lalu rontok.',
    });
    await txn.insert('Gejala', {
      'id_penyakit': idBPB,
      'desc_gejala':
          'Pada daun terdapat bercak hitam berbentuk serabut di tengahnya.',
    });
    await txn.insert('Gejala', {
      'id_penyakit': idBPB,
      'desc_gejala': 'Pangkal batang atau akar menghitam, busuk, dan lembek.',
    });

    // Gambar Gejala Penyakit Busuk Pangkal Batang
    await txn.insert('Gambar_Gejala', {
      'id_penyakit': idBPB,
      'path_gambar': 'assets/images/disease_images/foot_rot_leaf.png',
      'keterangan': 'Kondisi Daun Penyakit BPB',
    });
    await txn.insert('Gambar_Gejala', {
      'id_penyakit': idBPB,
      'path_gambar': 'assets/images/disease_images/foot_rot_plant.png',
      'keterangan': 'Kondisi Lada Penyakit BPB',
    });


    // 3. Penyakit Keriting/Kerdil
    final int idKeriting = penyakitIds[3]!;

    // Gejala Penyakit Keriting/Kerdil
    await txn.insert('Gejala', {
      'id_penyakit': idKeriting,
      'desc_gejala':
          'Tanaman kerdil/stunting dan daun tampak bercak-bercak hitam dan kuning',
    });
    await txn.insert('Gejala', {
      'id_penyakit': idKeriting,
      'desc_gejala':
          'Daun berukuran kecil, tapi tanaman masih bisa berbuah walaupun kecil-kecil.',
    });
    await txn.insert('Gejala', {
      'id_penyakit': idKeriting,
      'desc_gejala': 'Daun sering melengkung atau keriting.',
    });
    await txn.insert('Gejala', {
      'id_penyakit': idKeriting,
      'desc_gejala':
          'Jika mengalami beberapa gejala sekaligus, tanaman bisa mati.',
    });

    // Gambar Gejala Penyakit Keriting/Kerdil
    await txn.insert('Gambar_Gejala', {
      'id_penyakit': idKeriting,
      'path_gambar': 'assets/images/disease_images/curl_leaf.png',
      'keterangan': 'Kondisi Daun Penyakit Keriting',
    });
    await txn.insert('Gambar_Gejala', {
      'id_penyakit': idKeriting,
      'path_gambar': 'assets/images/disease_images/curl_plant.png',
      'keterangan': 'Kondisi Lada Penyakit Keriting',
    });


    // 4. Penyakit Hawar Daun
    final int idHawar = penyakitIds[4]!;

    // Gejala Penyakit Hawar Daun
    await txn.insert('Gejala', {
      'id_penyakit': idHawar,
      'desc_gejala':
          'Daun terdapat bercak berwarna pucat atau putih keabuan dengan tepi cokelat kehitaman.',
    });
    await txn.insert('Gejala', {
      'id_penyakit': idHawar,
      'desc_gejala':
          'Bercak dapat bertambah banyak, membesar, dan menyatu sehingga daun tampak rusak atau berlubang.',
    });
    await txn.insert('Gejala', {
      'id_penyakit': idHawar,
      'desc_gejala': 'Bagian sekitar bercak dapat menguning.',
    });
    await txn.insert('Gejala', {
      'id_penyakit': idHawar,
      'desc_gejala': 'Pada kondisi parah, daun mengering lalu rontok.',
    });

    // Gambar Gejala Penyakit Hawar Daun
    await txn.insert('Gambar_Gejala', {
      'id_penyakit': idHawar,
      'path_gambar': 'assets/images/disease_images/blight_leaf.png',
      'keterangan': 'Kondisi Daun Penyakit Hawar',
    });
  }
}
