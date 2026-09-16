import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../config/app_colors.dart';
import '../models/drop_point_model.dart';
import '../services/waste_service.dart';

class DropPointMapScreen extends StatefulWidget {
  const DropPointMapScreen({super.key});

  @override
  State<DropPointMapScreen> createState() => _DropPointMapScreenState();
}

class _DropPointMapScreenState extends State<DropPointMapScreen> {
  final MapController _mapController = MapController();
  List<DropPointModel> _points = [];
  bool _loading = true;
  bool _loadFailed = false;
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _loadPoints();
  }

  Future<void> _loadPoints() async {
    try {
      final drops = await WasteService.getDropPoints();
      final points = drops
          .where((dp) =>
              dp.isActive && dp.latitude != null && dp.longitude != null)
          .toList();
      if (mounted) {
        setState(() {
          _points = points;
          _loading = false;
        });
        _fitCameraToBounds();
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _loadFailed = true;
        });
      }
    }
  }

  void _fitCameraToBounds() {
    if (_points.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      double minLat = _points.first.latitude!;
      double maxLat = _points.first.latitude!;
      double minLng = _points.first.longitude!;
      double maxLng = _points.first.longitude!;
      for (final p in _points) {
        minLat = p.latitude! < minLat ? p.latitude! : minLat;
        maxLat = p.latitude! > maxLat ? p.latitude! : maxLat;
        minLng = p.longitude! < minLng ? p.longitude! : minLng;
        maxLng = p.longitude! > maxLng ? p.longitude! : maxLng;
      }
      if (minLat == maxLat && minLng == maxLng) return;
      _mapController.fitCamera(CameraFit.bounds(
        bounds: LatLngBounds(
          LatLng(minLat, minLng),
          LatLng(maxLat, maxLng),
        ),
        padding: const EdgeInsets.all(48),
      ));
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = AppColors.surface;
    final Color textDark = AppColors.text;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: const Text('Peta Drop Point',
            style:
                TextStyle(fontWeight: FontWeight.w700, color: AppColors.text)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          _buildMapBody(),
          Positioned(
            top: 12,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.surfaceBorder),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                _loading ? 'Memuat...' : '${_points.length} Drop Point',
                style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w700, color: textDark),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: _buildBottomInfo(),
          ),
        ],
      ),
    );
  }

  Widget _buildMapBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    if (_loadFailed) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 40, color: AppColors.textMuted),
              const SizedBox(height: 10),
              const Text('Gagal memuat data drop point.',
                  style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _loading = true;
                    _loadFailed = false;
                  });
                  _loadPoints();
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary),
                child: const Text('Coba Lagi',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }
    if (_points.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_off,
                  size: 40, color: AppColors.textMuted),
              const SizedBox(height: 10),
              const Text('Belum ada drop point dengan koordinat.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
            ],
          ),
        ),
      );
    }

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: LatLng(-6.9175, 107.6191),
        initialZoom: 12,
        minZoom: 3,
        maxZoom: 19,
        onTap: (_, __) {
          setState(() => _selectedIndex = null);
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.ecopoints.app',
        ),
        MarkerLayer(
          markers: [
            for (int i = 0; i < _points.length; i++)
              Marker(
                point: LatLng(_points[i].latitude!, _points[i].longitude!),
                width: 44,
                height: 44,
                child: GestureDetector(
                  onTap: () {
                    setState(() => _selectedIndex = i);
                  },
                  child: Icon(
                    Icons.location_pin,
                    size: 44,
                    color: _selectedIndex == i
                        ? AppColors.gold
                        : AppColors.primary,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomInfo() {
    final selected = _selectedIndex != null && _selectedIndex! < _points.length
        ? _points[_selectedIndex!]
        : null;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: selected == null
          ? Row(
              children: [
                const Icon(Icons.touch_app, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Ketuk penanda untuk melihat detail lokasi.',
                      style: TextStyle(fontSize: 11, color: AppColors.text)),
                ),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.surfaceBorder),
                  ),
                  child: const Icon(Icons.storefront_rounded,
                      size: 18, color: AppColors.primary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(selected.name,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.text)),
                      const SizedBox(height: 3),
                      Text(
                        selected.address,
                        style: const TextStyle(
                            fontSize: 10.5,
                            height: 1.3,
                            color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${selected.latitude!.toStringAsFixed(5)}, ${selected.longitude!.toStringAsFixed(5)}',
                        style: const TextStyle(
                            fontSize: 9, color: AppColors.textHint),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _selectedIndex = null),
                  child: const Icon(Icons.close,
                      size: 18, color: AppColors.textMuted),
                ),
              ],
            ),
    );
  }
}
