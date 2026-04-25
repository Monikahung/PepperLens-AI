import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pepperlens_ai/core/constants/colors.dart';
import 'package:pepperlens_ai/core/constants/text_style.dart';
import 'package:pepperlens_ai/core/widgets/bullet_list_content.dart';
import 'package:pepperlens_ai/core/widgets/info_card.dart';
import 'package:pepperlens_ai/core/widgets/detail_info_card.dart';
import 'package:pepperlens_ai/features/encyclopedia/data/repositories/encyclopedia_repository.dart';
import 'package:pepperlens_ai/features/encyclopedia/presentation/widgets/disease_detail_header.dart';
import 'package:pepperlens_ai/features/encyclopedia/presentation/widgets/symptom_content_list.dart';

// Halaman utama untuk menampilkan informasi detail mengenai penyakit yang telah dipilih dari halaman sebelumnya
class EncyclopediaDetailPage extends StatefulWidget {
  // Id penyakit sebagai kunci pencarian database
  final int diseaseId;

  final String? originalImagePath;
  final List<Map<String, dynamic>>? detectionResults;

  const EncyclopediaDetailPage({
    super.key,
    required this.diseaseId,
    this.originalImagePath,
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
                "Data tidak ditemukan",
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
                onPressed: () => Get.back(),
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

            body: SingleChildScrollView(
              // Padding untuk menampilkan content di bawah appBar
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
                  widget.originalImagePath != null &&
                          widget.detectionResults != null
                      ?
                        // Jika ada gambar hasil deteksi, tampilkan gambar hasil deteksi beserta kotak bounding box (menu deteksi)
                        DiseaseDetailHeader(
                          originalImagePath: widget.originalImagePath,
                          detectionResults: widget.detectionResults,
                          diseaseId: widget.diseaseId,
                          mainImagePath: mainImagePath,
                          hasNoImage: hasNoImage,
                          getShortLabel: _getShortLabel,
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
                    children: [
                      SymptomContentList(
                        imageList: gambarList,
                        symptomText: data['gejala'],
                      ),
                    ],
                  ),

                  // Tampilkan accordion penyebab beserta content di dalamnya apabila tidak ditampilkan gambar hasil deteksi setiap penyakit (menu ensiklopedia)
                  if (widget.originalImagePath == null &&
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
}
