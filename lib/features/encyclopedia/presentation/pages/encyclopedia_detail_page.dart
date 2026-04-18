import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pepperlens_ai/core/constants/colors.dart';
import 'package:pepperlens_ai/core/constants/text_style.dart';
import 'package:pepperlens_ai/core/widgets/bullet_list_content.dart';
import 'package:pepperlens_ai/core/widgets/info_card.dart';
import 'package:pepperlens_ai/core/widgets/detail_info_card.dart';
import 'package:pepperlens_ai/features/encyclopedia/data/repositories/encyclopedia_repository.dart';

// Halaman utama untuk menampilkan informasi detail mengenai penyakit yang telah dipilih dari halaman sebelumnya
class EncyclopediaDetailPage extends StatefulWidget {
  // Id penyakit sebagai kunci pencarian database
  final int diseaseId;

  final String? detectionImagePath;
  final List<Map<String, dynamic>>? detectionResults;

  const EncyclopediaDetailPage({
    super.key,
    required this.diseaseId,
    this.detectionImagePath,
    this.detectionResults,
  });

  @override
  State<EncyclopediaDetailPage> createState() => _EncyclopediaDetailPageState();
}

class _EncyclopediaDetailPageState extends State<EncyclopediaDetailPage> {
  // Inisialisasi repository untuk akses data penyakit
  final EncyclopediaRepository _repository = EncyclopediaRepository();

  // Konversi nama penyakit menjadi label penyakit
  String _getShortLabel(String? fullName) {
    if (fullName == null) return "Unknown";

    switch (fullName) {
      case 'Kuning':
        return 'Kuning';
      case 'Busuk Pangkal Batang':
        return 'BPB';
      case 'Keriting/Kerdil':
        return 'Keriting';
      case 'Hawar Daun':
        return 'Hawar';
      default:
        return fullName;
    }
  }

  // Dapatkan ukuran gambar berdasarkan path gambar
  Future<Size> _getImageSize(String imagePath) async {
    final File file = File(imagePath);
    final data = await file.readAsBytes();
    final decodedImage = await decodeImageFromList(data);
    return Size(decodedImage.width.toDouble(), decodedImage.height.toDouble());
  }

  // Bangun tampilan halaman detail penyakit di ensiklopedia
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _repository.getDiseaseDetail(widget.diseaseId),
      builder: (context, snapshot) {
        // Jika sedang menunggu data dari database, tampilkan loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.honeydew,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.mysticJade),
            ),
          );
        }

        // Jika terjadi error atau data tidak ditemukan, tampilkan teks 'Data tidak ditemukan'
        if (snapshot.hasError || snapshot.data == null) {
          return const Scaffold(
            backgroundColor: AppColors.honeydew,
            body: Center(
              child: Text(
                "Data tidak ditemukan.",
                style: AppTextStyles.manropeOne,
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        // Destrukturisasi data hasil query
        final data = snapshot.data!;
        final info = data['info'];
        final List gambarList = data['gambar'];

        // Logika untuk mengecek ada tidaknya gambar utama
        final bool hasNoImage = gambarList.isEmpty;
        final String mainImagePath = !hasNoImage
            ? gambarList[0]['path_gambar']
            : '';

        // Logika untuk menentukan accordion identifikasi lanjutan perlu ditampilkan atau tidak
        final bool showIdentification =
            data['identifikasi_lanjutan'] != null &&
            data['identifikasi_lanjutan'].isNotEmpty;

        // AnnotatedRegion untuk mengontrol tampilan status bar dan navigasi sistem
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: AppColors.honeydew,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
            systemNavigationBarColor: AppColors.mysticJade,
            systemNavigationBarIconBrightness: Brightness.light,
          ),
          child: Scaffold(
            backgroundColor: AppColors.honeydew,
            appBar: AppBar(
              backgroundColor: AppColors.honeydew,
              surfaceTintColor: AppColors.transparent,
              elevation: 0,
              centerTitle: true,
              // Icon panah kembali ke halaman sebelumnya
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: AppColors.darkCyan,
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              // Teks paling atas pada halaman
              title: const Text(
                "Detail Penyakit",
                style: AppTextStyles.manropeFive,
              ),
              // AnnotatedRegion untuk mengontrol tampilan status bar dan navigasi sistem
              systemOverlayStyle: const SystemUiOverlayStyle(
                statusBarColor: AppColors.honeydew,
                statusBarIconBrightness: Brightness.dark,
                statusBarBrightness: Brightness.light,
                systemNavigationBarColor: AppColors.mysticJade,
                systemNavigationBarIconBrightness: Brightness.light,
              ),
            ),
            // Padding untuk menampilkan content di bawah appBar
            body: SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 10,
                bottom: 30,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tampilkan gambar utama berupa gambar tanaman lada atau gambar daun lada yang terserang penyakit serta gambar hasil deteksi pada kondisi tertentu
                  widget.detectionImagePath != null &&
                          widget.detectionResults != null
                      ?
                        // Jika ada gambar hasil deteksi, tampilkan gambar hasil deteksi beserta kotak bounding box (menu deteksi)
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.mysticJade,
                              width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: _buildDetectionHeader(
                              widget.detectionImagePath!,
                              widget.detectionResults!,
                              widget.diseaseId,
                            ),
                          ),
                        )
                      :
                        // Jika tidak ada gambar hasil deteksi, tampilkan gambar tanaman lada atau daun lada yang terserang penyakit (menu ensiklopedia)
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.mysticJade,
                              width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: AspectRatio(
                              aspectRatio: 1 / 1,
                              child: hasNoImage || mainImagePath.isEmpty
                                  ? Container(
                                      color: AppColors.frostedMint,
                                      child: const Icon(
                                        Icons.broken_image,
                                        color: AppColors.honeydew,
                                        size: 40,
                                      ),
                                    )
                                  : Image.asset(
                                      mainImagePath,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, e, s) =>
                                          Container(
                                            color: AppColors.frostedMint,
                                            child: const Icon(
                                              Icons.broken_image,
                                              color: AppColors.honeydew,
                                            ),
                                          ),
                                    ),
                            ),
                          ),
                        ),

                  // Jarak antar komponen
                  const SizedBox(height: 20),

                  // Tampilkan nama penyakit
                  Text(
                    info['nama_penyakit'],
                    style: AppTextStyles.manropeEight,
                  ),

                  // Jarak antar komponen
                  const SizedBox(height: 4),

                  // Tampilkan nama penyakit menggunakan bahasa inggris
                  Text(
                    info['nama_inggris'] ?? "",
                    style: AppTextStyles.poppinsTwo,
                  ),

                  // Jarak antar komponen
                  const SizedBox(height: 10),

                  // Tampilkan deskripsi penyakit
                  Text(
                    info['desc_penyakit'] ?? "",
                    style: AppTextStyles.manropeNine,
                  ),

                  // Jarak antar komponen
                  const SizedBox(height: 25),

                  // Tampilkan accordion gejala beserta content di dalamnya
                  InfoCard(
                    title: "Gejala",
                    backgroundColor: AppColors.frostedMint,
                    collapsedBackgroundColor: AppColors.frostedMint,
                    children: _buildGejalaChildren(gambarList, data['gejala']),
                  ),

                  // Tampilkan accordion penyebab beserta content di dalamnya apabila tidak ditampilkan gambar hasil deteksi setiap penyakit (menu ensiklopedia)
                  if (widget.detectionImagePath == null &&
                      widget.detectionResults == null)
                    InfoCard(
                      title: "Penyebab",
                      backgroundColor: AppColors.frostedMint,
                      collapsedBackgroundColor: AppColors.frostedMint,
                      children: [
                        DetailInfoCard(
                          title: "Kemungkinan Penyebab",
                          content: BulletListContent(
                            data: data['penyebab'],
                            column: 'desc_penyebab',
                          ),
                        ),
                      ],
                    ),

                  // Tampilkan accordion pengendalian beserta content di dalamnya
                  InfoCard(
                    title: "Pengendalian",
                    isLast: !showIdentification,
                    backgroundColor: AppColors.frostedMint,
                    collapsedBackgroundColor: AppColors.frostedMint,
                    children: [
                      DetailInfoCard(
                        title: "Pengendalian Terpadu",
                        content: BulletListContent(
                          data: data['pengendalian'],
                          column: 'desc_pengendalian',
                        ),
                      ),
                    ],
                  ),

                  // Tampilkan accordion identifikasi lanjutan beserta content di dalamnya
                  InfoCard(
                    title: "Identifikasi Lanjutan",
                    isLast: true,
                    isVisible:
                        data['identifikasi_lanjutan'] != null &&
                        data['identifikasi_lanjutan'].isNotEmpty,
                    backgroundColor: AppColors.frostedMint,
                    collapsedBackgroundColor: AppColors.frostedMint,
                    children: [
                      DetailInfoCard(
                        title: "Tahapan Identifikasi",
                        content: BulletListContent(
                          data: data['identifikasi_lanjutan'],
                          column: 'desc_langkah',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Function untuk menyusun daftar widget yang ditampilkan di dalam accordion gejala
  List<Widget> _buildGejalaChildren(List gambarData, List gejalaTeks) {
    List<Widget> children = [];

    // Tampilkan widget untuk gambar daun lada sehat
    children.add(
      DetailInfoCard(
        title: "Kondisi Daun Sehat",
        content: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.honeydew, width: 1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: AspectRatio(
              aspectRatio: 1 / 1,
              child: Image.asset(
                "assets/images/healthy_leaf.png",
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );

    // Urutkan gambar berdasarkan namanya. Dari database diutamakan untuk mengambil gambar 'kondisi lada penyakit%' sebagai prioritas sehingga disini perlu diurutkan kembali prioritasnya karena yang pertama ditampilkan yaitu gambar 'kondisi daun penyakit%'
    List sortedGambar = List.from(gambarData);
    sortedGambar.sort((a, b) {
      String ketA = (a['keterangan'] ?? "").toLowerCase();
      String ketB = (b['keterangan'] ?? "").toLowerCase();

      // Jika keterangan a ada kata 'daun', sedangkan keterangan b tidak, a digeser ke depan
      if (ketA.contains('daun') && !ketB.contains('daun')) {
        return -1;
      }
      // Jika keterangan a tidak ada kata 'daun', sedangkan keterangan b ada, a digeser ke belakang
      else if (!ketA.contains('daun') && ketB.contains('daun')) {
        return 1;
      }
      return 0;
    });

    // Tampilkan widget untuk gambar penyakit
    for (var item in sortedGambar) {
      children.add(
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: DetailInfoCard(
            title: item['keterangan'] ?? "Kondisi Penyakit",
            content: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.honeydew, width: 1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: AspectRatio(
                  aspectRatio: 1 / 1,
                  child: Image.asset(
                    item['path_gambar'],
                    fit: BoxFit.cover,
                    errorBuilder: (context, e, s) => const Icon(
                      Icons.broken_image,
                      color: AppColors.honeydew,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Tampilkan widget untuk teks gejala penyakit dalam bentuk bullet list
    children.add(
      Padding(
        padding: const EdgeInsets.only(top: 12),
        child: DetailInfoCard(
          title: "Gejala Umum",
          content: BulletListContent(data: gejalaTeks, column: 'desc_gejala'),
        ),
      ),
    );

    return children;
  }

  // Widget khusus untuk menampilkan gambar hasil deteksi untuk setiap penyakit di halaman detail penyakit pada menu ensiklopedia
  Widget _buildDetectionHeader(
    String path,
    List<Map<String, dynamic>> results,
    int currentDiseaseId,
  ) {
    return FutureBuilder<Size>(
      future: _getImageSize(path),
      builder: (context, sizeSnapshot) {
        if (!sizeSnapshot.hasData) return const SizedBox();

        double originalWidth = sizeSnapshot.data!.width;

        return LayoutBuilder(
          builder: (context, constraints) {
            double scale = constraints.maxWidth / originalWidth;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    // Gambar mentah asli
                    Image.file(
                      File(path),
                      width: constraints.maxWidth,
                      fit: BoxFit.fitWidth,
                    ),

                    // Loop bounding box dan label
                    ...results
                        .where((res) => res['id_penyakit'] == currentDiseaseId)
                        .expand((res) {
                          // Konversi data koordinat dari database ke double
                          double x = (res['x'] as num).toDouble() * scale;
                          double y = (res['y'] as num).toDouble() * scale;
                          double w = (res['width'] as num).toDouble() * scale;
                          double h = (res['height'] as num).toDouble() * scale;

                          // Ambil warna sesuai id penyakit
                          Color diseaseColor = AppColors.getDiseaseColor(
                            currentDiseaseId,
                          );

                          return [
                            // Gambar kotak bounding box
                            Positioned(
                              left: x,
                              top: y,
                              child: Container(
                                width: w,
                                height: h,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: diseaseColor,
                                    width: 4,
                                  ),
                                ),
                              ),
                            ),

                            // Label penyakit
                            Positioned(
                              left: x,
                              top: y,
                              child: FractionalTranslation(
                                translation: Offset(0.0, -1.0),
                                child: Text(
                                  "${_getShortLabel(res['nama_penyakit'])} ${(res['confidence'] as num).round()}%",
                                  style: AppTextStyles.poppinsFour.copyWith(
                                    color: diseaseColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ];
                        }),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }
}
