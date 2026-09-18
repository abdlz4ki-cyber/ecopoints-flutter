import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' hide Path;

import '../config/app_colors.dart';
import '../models/drop_point_model.dart';
import '../services/waste_service.dart';

class DropPointMapScreen extends StatefulWidget {
  const DropPointMapScreen({super.key});

  @override
  State<DropPointMapScreen> createState() => _DropPointMapScreenState();
}

class _DropPointMapScreenState extends State<DropPointMapScreen>
    with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  late final PageController _pageController;

  List<DropPointModel> _points = [];
  List<DropPointModel> _filteredPoints = [];
  bool _loading = true;
  bool _loadFailed = false;
  int _selectedIndex = 0;
  String _searchQuery = '';
  int _mapStyleIndex = 0;
  bool _sortByNearest = false;

  // Location state
  Position? _userPosition;
  bool _locationLoading = false;
  String? _locationError;
  StreamSubscription<Position>? _positionStream;

  // Pulse animation for user location marker
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final List<Map<String, String>> _mapStyles = [
    {
      'name': 'Voyager (Eco)',
      'url':
          'https://a.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}@2x.png',
    },
    {
      'name': 'Terang (Clean)',
      'url': 'https://a.basemaps.cartocdn.com/light_all/{z}/{x}/{y}@2x.png',
    },
    {
      'name': 'OpenStreetMap',
      'url': 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.88);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _loadPoints();
    _initLocation();
  }

  Future<void> _initLocation() async {
    setState(() => _locationLoading = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationLoading = false;
          _locationError = 'Layanan lokasi tidak aktif';
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationLoading = false;
            _locationError = 'Izin lokasi ditolak';
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationLoading = false;
          _locationError = 'Izin lokasi ditolak permanen';
        });
        return;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      );

      if (mounted) {
        setState(() {
          _userPosition = position;
          _locationLoading = false;
          _locationError = null;
        });
        _sortAndRefreshPoints();
      }

      // Listen for position updates
      _positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 20,
        ),
      ).listen((Position pos) {
        if (mounted) {
          setState(() => _userPosition = pos);
          if (_sortByNearest) {
            _sortAndRefreshPoints();
          }
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _locationLoading = false;
          _locationError = 'Gagal mendapatkan lokasi';
        });
      }
    }
  }

  Future<void> _loadPoints() async {
    try {
      final drops = await WasteService.getDropPoints();
      final points = drops
          .where(
              (dp) => dp.isActive && dp.latitude != null && dp.longitude != null)
          .toList();
      if (mounted) {
        setState(() {
          _points = points;
          _filteredPoints = points;
          _loading = false;
        });
        _sortAndRefreshPoints();
        if (_points.isNotEmpty) {
          _fitCameraToBounds();
        }
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

  /// Calculate distance in km between user and a drop point
  double? _distanceTo(DropPointModel point) {
    if (_userPosition == null ||
        point.latitude == null ||
        point.longitude == null) {
      return null;
    }
    final distanceM = Geolocator.distanceBetween(
      _userPosition!.latitude,
      _userPosition!.longitude,
      point.latitude!,
      point.longitude!,
    );
    return distanceM / 1000.0;
  }

  /// Format distance nicely
  String _formatDistance(double? distKm) {
    if (distKm == null) return '-';
    if (distKm < 1.0) {
      return '${(distKm * 1000).round()} m';
    }
    return '${distKm.toStringAsFixed(1)} km';
  }

  void _sortAndRefreshPoints() {
    if (_userPosition == null) return;
    if (_sortByNearest) {
      _filteredPoints.sort((a, b) {
        final da = _distanceTo(a) ?? double.infinity;
        final db = _distanceTo(b) ?? double.infinity;
        return da.compareTo(db);
      });
      setState(() {});
    }
  }

  void _applySearch(String query) {
    setState(() {
      _searchQuery = query.trim().toLowerCase();
      if (_searchQuery.isEmpty) {
        _filteredPoints = List.from(_points);
      } else {
        _filteredPoints = _points.where((p) {
          return p.name.toLowerCase().contains(_searchQuery) ||
              p.address.toLowerCase().contains(_searchQuery);
        }).toList();
      }
      _selectedIndex = 0;
    });

    if (_sortByNearest) _sortAndRefreshPoints();

    if (_filteredPoints.isNotEmpty) {
      _animateToPoint(0);
    }
  }

  void _fitCameraToBounds() {
    if (_filteredPoints.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      double minLat = _filteredPoints.first.latitude!;
      double maxLat = _filteredPoints.first.latitude!;
      double minLng = _filteredPoints.first.longitude!;
      double maxLng = _filteredPoints.first.longitude!;

      for (final p in _filteredPoints) {
        minLat = p.latitude! < minLat ? p.latitude! : minLat;
        maxLat = p.latitude! > maxLat ? p.latitude! : maxLat;
        minLng = p.longitude! < minLng ? p.longitude! : minLng;
        maxLng = p.longitude! > maxLng ? p.longitude! : maxLng;
      }

      // Include user position in bounds if available
      if (_userPosition != null) {
        minLat = _userPosition!.latitude < minLat
            ? _userPosition!.latitude
            : minLat;
        maxLat = _userPosition!.latitude > maxLat
            ? _userPosition!.latitude
            : maxLat;
        minLng = _userPosition!.longitude < minLng
            ? _userPosition!.longitude
            : minLng;
        maxLng = _userPosition!.longitude > maxLng
            ? _userPosition!.longitude
            : maxLng;
      }

      if (minLat == maxLat && minLng == maxLng) {
        _mapController.move(LatLng(minLat, minLng), 14.5);
        return;
      }

      _mapController.fitCamera(CameraFit.bounds(
        bounds: LatLngBounds(
          LatLng(minLat, minLng),
          LatLng(maxLat, maxLng),
        ),
        padding: const EdgeInsets.only(
            top: 120, bottom: 220, left: 40, right: 40),
      ));
    });
  }

  void _animateToPoint(int index) {
    if (index < 0 || index >= _filteredPoints.length) return;
    final point = _filteredPoints[index];
    setState(() => _selectedIndex = index);
    _mapController.move(
      LatLng(point.latitude!, point.longitude!),
      15.5,
    );
    if (_pageController.hasClients &&
        _pageController.page?.round() != index) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _moveToUserLocation() {
    if (_userPosition == null) return;
    HapticFeedback.mediumImpact();
    _mapController.move(
      LatLng(_userPosition!.latitude, _userPosition!.longitude),
      16.0,
    );
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _pulseController.dispose();
    _mapController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color textDark = AppColors.text;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          // MAP CANVAS
          _buildMapCanvas(),

          // TOP FLOATING HEADER WITH SEARCH & BACK BUTTON
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      // Back Button
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_rounded,
                              color: textDark, size: 20),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Search Bar & Counter
                      Expanded(
                        child: Container(
                          height: 48,
                          padding:
                              const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    Colors.black.withValues(alpha: 0.12),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.search_rounded,
                                  color: AppColors.primary, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  onChanged: _applySearch,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: textDark),
                                  decoration: const InputDecoration(
                                    hintText:
                                        'Cari nama lokasi / drop point...',
                                    hintStyle: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textHint),
                                    border: InputBorder.none,
                                    isDense: true,
                                  ),
                                ),
                              ),
                              if (_searchQuery.isNotEmpty)
                                GestureDetector(
                                  onTap: () => _applySearch(''),
                                  child: const Icon(Icons.close_rounded,
                                      size: 18,
                                      color: AppColors.textMuted),
                                ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${_filteredPoints.length} Lokasi',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Sort by nearest chip
                  if (_userPosition != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() {
                              _sortByNearest = !_sortByNearest;
                            });
                            if (_sortByNearest) {
                              _sortAndRefreshPoints();
                              if (_filteredPoints.isNotEmpty) {
                                _animateToPoint(0);
                              }
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: _sortByNearest
                                  ? AppColors.primary
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: _sortByNearest
                                      ? AppColors.primary
                                          .withValues(alpha: 0.3)
                                      : Colors.black
                                          .withValues(alpha: 0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                              border: Border.all(
                                color: _sortByNearest
                                    ? AppColors.primary
                                    : AppColors.surfaceBorder,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _sortByNearest
                                      ? Icons.near_me_rounded
                                      : Icons.near_me_outlined,
                                  size: 14,
                                  color: _sortByNearest
                                      ? Colors.white
                                      : AppColors.primary,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'Urutkan Terdekat',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: _sortByNearest
                                        ? Colors.white
                                        : AppColors.text,
                                  ),
                                ),
                                if (_sortByNearest) ...[
                                  const SizedBox(width: 4),
                                  const Icon(Icons.check_rounded,
                                      size: 14, color: Colors.white),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // RIGHT SIDE FLOATING MAP CONTROLS
          Positioned(
            right: 16,
            top: _userPosition != null ? 170 : 130,
            child: Column(
              children: [
                _buildFloatingButton(
                  icon: Icons.layers_rounded,
                  tooltip: 'Ganti Tampilan Peta',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _mapStyleIndex =
                          (_mapStyleIndex + 1) % _mapStyles.length;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Tampilan Peta: ${_mapStyles[_mapStyleIndex]['name']}'),
                        duration: const Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                _buildFloatingButton(
                  icon: Icons.add_rounded,
                  tooltip: 'Zoom In',
                  onTap: () {
                    HapticFeedback.selectionClick();
                    _mapController.move(
                      _mapController.camera.center,
                      _mapController.camera.zoom + 1,
                    );
                  },
                ),
                const SizedBox(height: 10),
                _buildFloatingButton(
                  icon: Icons.remove_rounded,
                  tooltip: 'Zoom Out',
                  onTap: () {
                    HapticFeedback.selectionClick();
                    _mapController.move(
                      _mapController.camera.center,
                      _mapController.camera.zoom - 1,
                    );
                  },
                ),
                const SizedBox(height: 10),
                _buildFloatingButton(
                  icon: Icons.center_focus_strong_rounded,
                  tooltip: 'Fokus Semua Titik',
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    _fitCameraToBounds();
                  },
                ),
                const SizedBox(height: 10),
                // My Location Button
                _buildFloatingButton(
                  icon: _userPosition != null
                      ? Icons.my_location_rounded
                      : _locationLoading
                          ? Icons.location_searching_rounded
                          : Icons.location_disabled_rounded,
                  tooltip: 'Lokasi Saya',
                  onTap: () {
                    if (_userPosition != null) {
                      _moveToUserLocation();
                    } else if (_locationError != null) {
                      _initLocation();
                    }
                  },
                  isActive: _userPosition != null,
                ),
              ],
            ),
          ),

          // LOCATION STATUS BANNER (when error)
          if (_locationError != null && _userPosition == null)
            Positioned(
              left: 16,
              right: 70,
              top: _userPosition != null ? 170 : 130,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_off_rounded,
                        size: 16, color: Colors.orange.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _locationError!,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange.shade800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: _initLocation,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Coba Lagi',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.orange.shade900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // BOTTOM FLOATING DROP POINT CAROUSEL
          if (_filteredPoints.isNotEmpty)
            Positioned(
              left: 0,
              right: 0,
              bottom: 24,
              child: SizedBox(
                height: 175,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _filteredPoints.length,
                  onPageChanged: (index) {
                    HapticFeedback.selectionClick();
                    _animateToPoint(index);
                  },
                  itemBuilder: (context, index) {
                    final point = _filteredPoints[index];
                    final isSelected = _selectedIndex == index;
                    final dist = _distanceTo(point);

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: isSelected ? 0 : 6,
                      ),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.surfaceBorder,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected
                                ? AppColors.primary
                                    .withValues(alpha: 0.25)
                                : Colors.black.withValues(alpha: 0.1),
                            blurRadius: isSelected ? 16 : 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.primary
                                          .withValues(alpha: 0.12),
                                  borderRadius:
                                      BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.storefront_rounded,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.primary,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      point.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.text,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration:
                                              const BoxDecoration(
                                            color: Colors.green,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Text(
                                          'Drop Point Aktif',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.green,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'ID: #${point.id}',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color:
                                                AppColors.textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Distance badge
                              if (dist != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: dist < 1.0
                                          ? [
                                              const Color(0xFF10B981),
                                              const Color(0xFF059669),
                                            ]
                                          : dist < 5.0
                                              ? [
                                                  const Color(
                                                      0xFFF59E0B),
                                                  const Color(
                                                      0xFFD97706),
                                                ]
                                              : [
                                                  const Color(
                                                      0xFFEF4444),
                                                  const Color(
                                                      0xFFDC2626),
                                                ],
                                    ),
                                    borderRadius:
                                        BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: (dist < 1.0
                                                ? const Color(
                                                    0xFF10B981)
                                                : dist < 5.0
                                                    ? const Color(
                                                        0xFFF59E0B)
                                                    : const Color(
                                                        0xFFEF4444))
                                            .withValues(alpha: 0.3),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.directions_walk_rounded,
                                        size: 11,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        _formatDistance(dist),
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: Text(
                              point.address,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textMuted,
                                height: 1.3,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              // Distance info or coordinates
                              if (dist != null)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.near_me_rounded,
                                        size: 11,
                                        color: AppColors.primary
                                            .withValues(alpha: 0.7)),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Jarak: ${_formatDistance(dist)} dari posisi Anda',
                                      style: const TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textHint,
                                      ),
                                    ),
                                  ],
                                )
                              else
                                Text(
                                  'Koordinat: ${point.latitude!.toStringAsFixed(4)}, ${point.longitude!.toStringAsFixed(4)}',
                                  style: const TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textHint,
                                  ),
                                ),
                              InkWell(
                                onTap: () {
                                  Clipboard.setData(ClipboardData(
                                      text:
                                          '${point.name}, ${point.address} (${point.latitude}, ${point.longitude})'));
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Alamat "${point.name}" disalin ke clipboard!'),
                                      duration:
                                          const Duration(seconds: 2),
                                      backgroundColor:
                                          AppColors.primary,
                                      behavior:
                                          SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                                borderRadius:
                                    BorderRadius.circular(6),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.copy_rounded,
                                          size: 12,
                                          color: AppColors.primary),
                                      SizedBox(width: 4),
                                      Text(
                                        'Salin Info',
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMapCanvas() {
    if (_loading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 12),
            Text(
              'Menyiapkan peta drop point...',
              style:
                  TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }

    if (_loadFailed) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_rounded,
                  size: 48, color: AppColors.textMuted),
              const SizedBox(height: 12),
              const Text('Gagal memuat data drop point.',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text)),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _loading = true;
                    _loadFailed = false;
                  });
                  _loadPoints();
                },
                icon: const Icon(Icons.refresh_rounded,
                    size: 16, color: Colors.white),
                label: const Text('Coba Lagi',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final currentStyle = _mapStyles[_mapStyleIndex];

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: const LatLng(-6.9175, 107.6191),
        initialZoom: 13,
        minZoom: 3,
        maxZoom: 19,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: currentStyle['url']!,
          userAgentPackageName: 'com.ecopoints.app',
        ),

        // User accuracy circle (large semi-transparent)
        if (_userPosition != null)
          CircleLayer(
            circles: [
              CircleMarker(
                point: LatLng(
                    _userPosition!.latitude, _userPosition!.longitude),
                radius: math.max(_userPosition!.accuracy, 30),
                useRadiusInMeter: true,
                color: const Color(0xFF3B82F6).withValues(alpha: 0.08),
                borderColor:
                    const Color(0xFF3B82F6).withValues(alpha: 0.2),
                borderStrokeWidth: 1.5,
              ),
            ],
          ),

        // Drop point markers
        MarkerLayer(
          markers: [
            for (int i = 0; i < _filteredPoints.length; i++)
              _buildMarker(_filteredPoints[i], i),
          ],
        ),

        // User location marker (on top)
        if (_userPosition != null)
          MarkerLayer(
            markers: [
              _buildUserLocationMarker(),
            ],
          ),
      ],
    );
  }

  Marker _buildUserLocationMarker() {
    return Marker(
      point:
          LatLng(_userPosition!.latitude, _userPosition!.longitude),
      width: 80,
      height: 80,
      alignment: Alignment.center,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Outer pulse ring
              Container(
                width: 60 * _pulseAnimation.value,
                height: 60 * _pulseAnimation.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF3B82F6).withValues(
                      alpha: 0.15 * (1.0 - _pulseAnimation.value)),
                ),
              ),

              // Middle ring
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color:
                          const Color(0xFF3B82F6).withValues(alpha: 0.4),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),

              // Inner blue dot with gradient
              Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF60A5FA), Color(0xFF2563EB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x553B82F6),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),

              // Direction arrow (heading indicator)
              if (_userPosition!.heading != 0)
                Transform.rotate(
                  angle: _userPosition!.heading * (math.pi / 180),
                  child: Align(
                    alignment: const Alignment(0, -1.2),
                    child: CustomPaint(
                      size: const Size(10, 10),
                      painter: _DirectionArrowPainter(),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Marker _buildMarker(DropPointModel point, int index) {
    final isSelected = _selectedIndex == index;

    return Marker(
      point: LatLng(point.latitude!, point.longitude!),
      width: isSelected ? 60 : 44,
      height: isSelected ? 60 : 44,
      alignment: Alignment.topCenter,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          _animateToPoint(index);
        },
        child: AnimatedScale(
          scale: isSelected ? 1.15 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Pulse Glow Ring for Selected
              if (isSelected)
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        AppColors.primary.withValues(alpha: 0.25),
                  ),
                ),

              // Pin Icon Badge
              Container(
                width: isSelected ? 42 : 34,
                height: isSelected ? 42 : 34,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isSelected
                        ? [AppColors.gold, AppColors.goldDark]
                        : [
                            AppColors.primary,
                            AppColors.primaryDark
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: Colors.white, width: 2.5),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.recycling_rounded,
                    size: isSelected ? 22 : 18,
                    color: Colors.white,
                  ),
                ),
              ),

              // Bottom arrow tip
              Positioned(
                bottom: isSelected ? -5 : -3,
                child: Transform.rotate(
                  angle: 0.785398, // 45 degrees
                  child: Container(
                    width: 8,
                    height: 8,
                    color: isSelected
                        ? AppColors.goldDark
                        : AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFEFF6FF) : Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: isActive
                ? const Color(0xFF3B82F6).withValues(alpha: 0.2)
                : Colors.black12,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: isActive
            ? Border.all(
                color:
                    const Color(0xFF3B82F6).withValues(alpha: 0.3),
                width: 1.5)
            : null,
      ),
      child: IconButton(
        icon: Icon(icon,
            color: isActive
                ? const Color(0xFF3B82F6)
                : AppColors.text,
            size: 20),
        tooltip: tooltip,
        onPressed: onTap,
      ),
    );
  }
}

/// Custom painter for the direction arrow on the user location marker
class _DirectionArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2563EB)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width / 2, size.height * 0.7)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
