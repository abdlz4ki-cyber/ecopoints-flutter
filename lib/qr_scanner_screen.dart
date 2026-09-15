import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'config/app_colors.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  static const Color primaryDarkColor = AppColors.primary;
  static const Color backgroundColor = AppColors.surface;
  static const Color cardBg = AppColors.surfaceAlt;
  static const Color cardBorder = AppColors.surfaceBorder;
  static const Color textDark = AppColors.text;
  static const Color textGray = AppColors.textMuted;

  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );

  bool _hasScanned = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? code = barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;

    setState(() => _hasScanned = true);
    Navigator.pop(context, code);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          MobileScanner(
            controller: _scannerController,
            onDetect: _onDetect,
            errorBuilder: (context, error, child) => _buildScannerError(error),
          ),

          // Dark overlay with scanner cutout
          _buildScannerOverlay(),

          // Top Bar
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  // Flash toggle
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: ValueListenableBuilder(
                        valueListenable: _scannerController,
                        builder: (context, state, child) {
                          return Icon(
                            state.torchState == TorchState.on
                                ? Icons.flash_on
                                : Icons.flash_off,
                            color: state.torchState == TorchState.on
                                ? AppColors.goldBright
                                : Colors.white,
                            size: 20,
                          );
                        },
                      ),
                      onPressed: () => _scannerController.toggleTorch(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom info card
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                MediaQuery.of(context).padding.bottom + 20,
              ),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: cardBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: primaryDarkColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.qr_code_scanner,
                            color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pindai QR Code Tiket',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: textDark,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Arahkan kamera ke QR code tiket nasabah',
                              style: TextStyle(fontSize: 11, color: textGray),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: cardBorder),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, size: 14, color: textGray),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Pastikan QR Code terlihat jelas di dalam bingkai pemindai',
                            style: TextStyle(fontSize: 10, color: textGray),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerError(MobileScannerException? error) {
    final bool isPermissionDenied =
        error?.errorCode == MobileScannerErrorCode.permissionDenied;
    return Container(
      color: Colors.black,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isPermissionDenied
                      ? Icons.no_photography_outlined
                      : Icons.videocam_off_outlined,
                  color: Colors.white70,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  isPermissionDenied
                      ? 'Izin Kamera Ditolak'
                      : 'Kamera Tidak Dapat Dibuka',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  isPermissionDenied
                      ? 'Aktifkan akses kamera di pengaturan perangkat untuk memindai QR code tiket nasabah.'
                      : 'Terjadi kendala saat mengakses kamera. Silakan coba lagi.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 20),
                if (isPermissionDenied)
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, size: 18),
                    label: const Text('Kembali'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: primaryDarkColor),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: () => _scannerController.start(),
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Coba Lagi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScannerOverlay() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scanAreaSize = constraints.maxWidth * 0.65;
        final scanAreaTop = constraints.maxHeight * 0.2;
        final scanAreaLeft = (constraints.maxWidth - scanAreaSize) / 2;

        return Stack(
          children: [
            // Semi-transparent overlay
            ColorFiltered(
              colorFilter: const ColorFilter.mode(
                Colors.black54,
                BlendMode.srcOut,
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      backgroundBlendMode: BlendMode.dstOut,
                    ),
                  ),
                  Positioned(
                    left: scanAreaLeft,
                    top: scanAreaTop,
                    child: Container(
                      width: scanAreaSize,
                      height: scanAreaSize,
                      decoration: BoxDecoration(
                        color: Colors.red, // any color, will be cut out
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Scan area border corners
            Positioned(
              left: scanAreaLeft,
              top: scanAreaTop,
              child: _buildCornerBorder(scanAreaSize),
            ),
            // Animated scan line
            Positioned(
              left: scanAreaLeft + 16,
              top: scanAreaTop + scanAreaSize / 2 - 1,
              child: Container(
                width: scanAreaSize - 32,
                height: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      AppColors.green.withValues(alpha: 0.8),
                      Colors.transparent,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCornerBorder(double size) {
    const double cornerLength = 24;
    const double cornerWidth = 3;
    const Color cornerColor = AppColors.green;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Top-left
          Positioned(
            top: 0,
            left: 0,
            child: Container(
                width: cornerLength,
                height: cornerWidth,
                decoration: BoxDecoration(
                    color: cornerColor,
                    borderRadius: BorderRadius.circular(cornerWidth))),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: Container(
                width: cornerWidth,
                height: cornerLength,
                decoration: BoxDecoration(
                    color: cornerColor,
                    borderRadius: BorderRadius.circular(cornerWidth))),
          ),
          // Top-right
          Positioned(
            top: 0,
            right: 0,
            child: Container(
                width: cornerLength,
                height: cornerWidth,
                decoration: BoxDecoration(
                    color: cornerColor,
                    borderRadius: BorderRadius.circular(cornerWidth))),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Container(
                width: cornerWidth,
                height: cornerLength,
                decoration: BoxDecoration(
                    color: cornerColor,
                    borderRadius: BorderRadius.circular(cornerWidth))),
          ),
          // Bottom-left
          Positioned(
            bottom: 0,
            left: 0,
            child: Container(
                width: cornerLength,
                height: cornerWidth,
                decoration: BoxDecoration(
                    color: cornerColor,
                    borderRadius: BorderRadius.circular(cornerWidth))),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: Container(
                width: cornerWidth,
                height: cornerLength,
                decoration: BoxDecoration(
                    color: cornerColor,
                    borderRadius: BorderRadius.circular(cornerWidth))),
          ),
          // Bottom-right
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
                width: cornerLength,
                height: cornerWidth,
                decoration: BoxDecoration(
                    color: cornerColor,
                    borderRadius: BorderRadius.circular(cornerWidth))),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
                width: cornerWidth,
                height: cornerLength,
                decoration: BoxDecoration(
                    color: cornerColor,
                    borderRadius: BorderRadius.circular(cornerWidth))),
          ),
        ],
      ),
    );
  }
}
