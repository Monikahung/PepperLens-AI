import 'package:get/get.dart';

// Controller untuk mengelola state navigasi utama aplikasi menggunakan GetX
class NavigationController extends GetxController {
  // Indeks halaman yang terpilih saat ini
  var selectedIndex = 0.obs;

  // Memperbarui selectedIndex dengan indeks baru yang dipicu dengan mengklik item pada bar navigasi
  void changeIndex(int index) {
    selectedIndex.value = index;
  }
}
