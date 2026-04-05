import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

// Widget untuk membuat kotak fokus dan slider exposure dengan ikon matahari
class CameraExposureController extends StatelessWidget {
  // Atribut untuk nilai exposure, minimal exposure, maksimal exposure, callback, dan controller exposure
  final double exposureValue;
  final double minExposure;
  final double maxExposure;
  final ValueChanged<double> onChanged;
  final CameraController? controller;

  // Instance dari CameraExposureController yang wajib diisi
  const CameraExposureController({
    super.key,
    required this.exposureValue,
    required this.minExposure,
    required this.maxExposure,
    required this.onChanged,
    this.controller,
  });

  // Bangun tampilan kotak fokus dan slider exposure dengan ikon matahari
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Kotak fokus
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.amber, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
        ),

        const SizedBox(width: 10),

        // Slider matahari
        _buildVerticalSlider(),

        // Ikon matahari
        const Icon(Icons.wb_sunny, color: Colors.amber, size: 20),
      ],
    );
  }

  // Widget silder matahari
  Widget _buildVerticalSlider() {
    return SizedBox(
      height: 120,
      child: RotatedBox(
        quarterTurns: 3,
        child: Slider(
          value: exposureValue,
          min: minExposure,
          max: maxExposure,
          activeColor: Colors.amber,
          inactiveColor: Colors.white30,
          onChanged: onChanged,
          onChangeEnd: (val) async {
            if (controller != null && controller!.value.isInitialized) {
              try {
                await controller!.setExposureOffset(val);
              } catch (e) {
                debugPrint("Gagal set exposure: $e");
              }
            }
          },
        ),
      ),
    );
  }
}
