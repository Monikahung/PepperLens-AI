// Data panduan penggunaan aplikasi PepperLens AI
class GuideData {
  // List pepperlensGuide berisi data panduan
  static const List<Map<String, dynamic>> pepperlensGuide = [
    // Data panduan pertama (ambil gambar)
    {
      "id": "1",
      "title": "Ambil Gambar",
      "imagePath": "assets/images/guide_images/take_picture.jpg",
      "steps": [
        "Pastikan pencahayaan cukup.",
        "Pastikan kamera fokus pada daun lada.",
        "Pastikan gambar terlihat jelas.",
        "Ambil gambar daun lada menggunakan kamera.",
      ],
    },
    // Data panduan kedua (upload gambar)
    {
      "id": "2",
      "title": "Upload Gambar",
      "imagePath": "assets/images/guide_images/upload_picture.jpg",
      "steps": [
        "Pilih gambar daun lada dari galeri.",
        "Pastikan gambar terlihat jelas.",
        "Gunakan gambar dengan ukuran minimal 640 x 640 piksel.",
      ],
    },
    // Data panduan ketiga (hasil deteksi)
    {
      "id": "3",
      "title": "Hasil Deteksi",
      "imagePath": "assets/images/guide_images/detection_result.jpg",
      "steps": [
        "Sistem menampilkan gambar dengan bounding box pada bagian daun yang terdeteksi.",
        "Ditampilkan jenis penyakit yang teridentifikasi pada daun lada.",
        "Pilih penyakit untuk melihat informasi lebih lanjut, seperti deskripsi singkat, gejala, pengendalian, dan identifikasi lanjutan.",
      ],
    },
    // Data panduan keempat (ensiklopedia)
    {
      "id": "4",
      "title": "Ensiklopedia",
      "imagePath": "assets/images/guide_images/encyclopedia.jpg",
      "steps": [
        "Menyediakan informasi mengenai empat penyakit pada tanaman lada.",
        "Pilih penyakit untuk melihat informasi lebih lanjut, seperti gambar, deskripsi singkat, gejala, penyebab, pengendalian, dan identifikasi lanjutan.",
      ],
    },
    // Data panduan kelima (riwayat)
    {
      "id": "5",
      "title": "Riwayat",
      "imagePath": "assets/images/guide_images/history.jpg",
      "steps": [
        "Menampilkan riwayat hasil deteksi yang pernah dilakukan.",
        "Riwayat dapat dikategorikan berdasarkan hari, bulan, tahun, atau semua data.",
        "Tersedia visualisasi diagram batang untuk menampilkan jumlah hasil deteksi sesuai kategori yang dipilih.",
      ],
    },
    // Data panduan keenam (tentang sistem)
    {
      "id": "6",
      "title": "Tentang Sistem",
      "imagePath": "assets/images/guide_images/about_the_system.jpg",
      "steps": [
        "Aplikasi ini dirancang untuk membantu mengidentifikasi penyakit tanaman lada berdasarkan gejala visual pada daun.",
        "Hasil deteksi dihasilkan oleh model kecerdasan buatan (AI) dan tetap memerlukan verifikasi lebih lanjut untuk memastikan keakuratan diagnosis.",
      ],
    },
  ];
}
