import 'package:get/get.dart';

// Controller untuk mengelola state navigasi utama aplikasi menggunakan GetX
class NavigationController extends GetxController {
  // Indeks halaman yang saat ini sedang ditampilkan
  var selectedIndex = 0.obs;

  // Simpan indeks halaman sebelumnya
  var previousIndex = 0.obs;

  // Memperbarui selectedIndex dengan indeks baru yang dipicu dengan mengklik item pada bar navigasi
  void changeIndex(int index) {
    // Jika indeks 0, reset previousIndex jadi 0
    if (index == 0) {
      previousIndex.value = 0;
    }
    // Jika indeks halaman saat ini bukan indeks 2, simpan sebagai halaman terakhir
    else if (selectedIndex.value != 2) {
      previousIndex.value = selectedIndex.value;
    }

    // Perbarui indeks utama
    selectedIndex.value = index;
  }
}
