import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // Instance tunggal untuk Singleton agar koneksi database tetap konsisten
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  // Buka database jika diperlukan
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Atur lokasi file .db di penyimpanan device
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'pepperlens_ai.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  // Buat struktur tabel
  Future _onCreate(Database db, int version) async {
    // 1. Tabel Penyakit
    await db.execute('''
      CREATE TABLE Penyakit (
        id_penyakit INTEGER PRIMARY KEY AUTOINCREMENT,
        nama_penyakit TEXT NOT NULL,
        preview_penyakit TEXT NOT NULL,
        desc_penyakit TEXT NOT NULL
      )
    ''');

    // 2. Tabel Gejala
    await db.execute('''
      CREATE TABLE Gejala (
        id_gejala INTEGER PRIMARY KEY AUTOINCREMENT,
        id_penyakit INTEGER,
        desc_gejala TEXT NOT NULL,
        FOREIGN KEY (id_penyakit) REFERENCES Penyakit (id_penyakit) ON DELETE CASCADE
      )
    ''');

    // 3. Tabel Gambar Gejala
    await db.execute('''
      CREATE TABLE Gambar_Gejala (
        id_gambar_gejala INTEGER PRIMARY KEY AUTOINCREMENT,
        id_penyakit INTEGER,
        path_gambar TEXT NOT NULL,
        keterangan TEXT NOT NULL,
        FOREIGN KEY (id_penyakit) REFERENCES Penyakit (id_penyakit) ON DELETE CASCADE
      )
    ''');

    // 4. Tabel Penyebab
    await db.execute('''
      CREATE TABLE Penyebab (
        id_penyebab INTEGER PRIMARY KEY AUTOINCREMENT,
        id_penyakit INTEGER,
        desc_penyebab TEXT NOT NULL,
        FOREIGN KEY (id_penyakit) REFERENCES Penyakit (id_penyakit) ON DELETE CASCADE
      )
    ''');

    // 5. Tabel Pengendalian
    await db.execute('''
      CREATE TABLE Pengendalian (
        id_pengendalian INTEGER PRIMARY KEY AUTOINCREMENT,
        id_penyakit INTEGER,
        desc_pengendalian TEXT NOT NULL,
        FOREIGN KEY (id_penyakit) REFERENCES Penyakit (id_penyakit) ON DELETE CASCADE
      )
    ''');

    // 6. Tabel Identifikasi Lanjutan
    await db.execute('''
      CREATE TABLE Identifikasi_Lanjutan (
        id_identifikasi INTEGER PRIMARY KEY AUTOINCREMENT,
        id_penyakit INTEGER,
        path_gambar TEXT NOT NULL,
        FOREIGN KEY (id_penyakit) REFERENCES Penyakit (id_penyakit) ON DELETE CASCADE
      )
    ''');

    // 7. Tabel Langkah Identifikasi Lanjutan
    await db.execute('''
      CREATE TABLE Langkah_Identifikasi (
        id_langkah INTEGER PRIMARY KEY AUTOINCREMENT,
        id_identifikasi INTEGER,
        urutan INTEGER NOT NULL,
        desc_langkah TEXT NOT NULL,
        FOREIGN KEY (id_identifikasi) REFERENCES Identifikasi_Lanjutan (id_identifikasi) ON DELETE CASCADE
      )
    ''');

    // 8. Tabel Hasil Deteksi
    await db.execute('''
      CREATE TABLE Hasil_Deteksi (
        id_hasil_deteksi INTEGER PRIMARY KEY AUTOINCREMENT,
        waktu_deteksi TEXT NOT NULL,
        waktu_proses REAL NOT NULL,
        path_gambar_potret TEXT NOT NULL,
        path_gambar_deteksi TEXT NOT NULL
      )
    ''');

    // 9. Tabel Detail Deteksi
    await db.execute('''
      CREATE TABLE Detail_Deteksi (
        id_detail_deteksi INTEGER PRIMARY KEY AUTOINCREMENT,
        id_hasil_deteksi INTEGER,
        id_penyakit INTEGER,
        x REAL NOT NULL,
        y REAL NOT NULL,
        width REAL NOT NULL,
        height REAL NOT NULL,
        FOREIGN KEY (id_hasil_deteksi) REFERENCES Hasil_Deteksi (id_hasil_deteksi) ON DELETE CASCADE,
        FOREIGN KEY (id_penyakit) REFERENCES Penyakit (id_penyakit) ON DELETE CASCADE
      )
    ''');
  }
}
