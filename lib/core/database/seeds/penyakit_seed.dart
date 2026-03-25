import 'package:sqflite/sqflite.dart';

class PenyakitSeed {
  static Future<Map<int, int>> addDataPenyakit(Transaction txn) async {
    Map<int, int> penyakitIds = {};

    // 1. Penyakit Kuning
    penyakitIds[1] = await txn.insert('Penyakit', {
      'nama_penyakit': 'Kuning',
      'nama_inggris': 'Yellow Disease',
      'preview_penyakit':
          'Penyakit lada yang menyebabkan seluruh tanaman berwarna kuning.',
      'desc_penyakit':
          'Penyakit Kuning adalah gangguan pada tanaman lada yang ditandai dengan perubahan warna daun menjadi kuning secara bertahap pada sebagian atau seluruh bagian tanaman. Kondisi ini mengganggu proses fisiologis tanaman sehingga pertumbuhan menjadi tidak optimal dan produktivitas menurun.',
    });

    // 2. Penyakit Busuk Pangkal Batang
    penyakitIds[2] = await txn.insert('Penyakit', {
      'nama_penyakit': 'Busuk Pangkal Batang',
      'nama_inggris': 'Foot Rot Disease',
      'preview_penyakit':
          'Penyakit lada yang menyebabkan pembusukan akar dan pangkal batang.',
      'desc_penyakit':
          'Busuk Pangkal Batang (BPB) adalah penyakit tanaman lada yang menyerang bagian pangkal batang hingga akar dan menyebabkan kerusakan jaringan tanaman secara bertahap. Serangan penyakit ini mengganggu kondisi fisiologis tanaman sehingga pertumbuhan melemah dan produktivitas menurun.',
    });

    // 3. Penyakit Keriting/Kerdil
    penyakitIds[3] = await txn.insert('Penyakit', {
      'nama_penyakit': 'Keriting/Kerdil',
      'nama_inggris': 'Leaf Curl and Stunting Disease',
      'preview_penyakit':
          'Penyakit lada yang menyebabkan tanaman menjadi kecil atau kerdil.',
      'desc_penyakit':
          'Keriting/Kerdil adalah gangguan pada tanaman lada yang ditandai dengan perubahan bentuk daun menjadi keriting serta pertumbuhan tanaman yang terhambat. Kondisi ini menyebabkan ukuran tanaman lebih kecil dari normal dan perkembangan menjadi tidak optimal sehingga berpengaruh pada produktivitas.',
    });

    // 4. Penyakit Hawar Daun
    penyakitIds[4] = await txn.insert('Penyakit', {
      'nama_penyakit': 'Hawar Daun',
      'nama_inggris': 'Leaf Blight Disease',
      'preview_penyakit':
          'Penyakit lada yang merusak jaringan daun hingga berlubang.',
      'desc_penyakit':
          'Hawar Daun adalah penyakit pada tanaman lada yang menyerang bagian daun dan menyebabkan kerusakan jaringan secara bertahap. Kondisi ini mengakibatkan daun mengering, rusak, hingga berlubang sehingga mengganggu proses fotosintesis dan menurunkan produktivitas tanaman.',
    });

    return penyakitIds;
  }
}
