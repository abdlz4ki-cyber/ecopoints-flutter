import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../models/waste_deposit_model.dart';
import '../models/redemption_model.dart';
import '../services/waste_service.dart';
import '../utils/redemption_status_ui.dart';
import 'setoran_detail_screen.dart';

enum ActivityType { deposit, redemption }

class UnifiedActivityItem {
  final ActivityType type;
  final DateTime date;
  final int points;
  final String status;
  final WasteDepositModel? deposit;
  final RedemptionModel? redemption;

  UnifiedActivityItem({
    required this.type,
    required this.date,
    required this.points,
    required this.status,
    this.deposit,
    this.redemption,
  });
}

class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({super.key});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  String _selectedTab = 'Semua';
  final List<String> _tabs = ['Semua', 'Setor Sampah', 'Tukar Hadiah'];

  String _statusFilter = 'Semua';
  final List<String> _statusOptions = [
    'Semua',
    'Menunggu',
    'Disetujui',
    'Ditolak'
  ];

  String _sortBy = 'Terbaru';
  final List<String> _sortOptions = [
    'Terbaru',
    'Terlama',
    'Poin Terbanyak',
    'Poin Terendah'
  ];

  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  List<WasteDepositModel> _deposits = [];
  List<RedemptionModel> _redemptions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllHistory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAllHistory() async {
    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        WasteService.getDeposits(),
        WasteService.getMyRedemptions(),
      ]);

      if (mounted) {
        setState(() {
          _deposits = results[0] as List<WasteDepositModel>;
          _redemptions = results[1] as List<RedemptionModel>;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  DateTime _parseDate(String? raw) {
    if (raw == null || raw.isEmpty) return DateTime.fromMillisecondsSinceEpoch(0);
    try {
      return DateTime.parse(raw);
    } catch (_) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
  }

  void _showSortDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceAlt,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text(
                    'Urutkan Riwayat',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ..._sortOptions.map((option) {
                  final isSelected = _sortBy == option;
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    leading: Icon(
                      isSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: isSelected ? AppColors.primary : AppColors.textMuted,
                      size: 20,
                    ),
                    title: Text(
                      option,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? AppColors.primary : AppColors.text,
                      ),
                    ),
                    onTap: () {
                      setState(() => _sortBy = option);
                      Navigator.pop(ctx);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  List<UnifiedActivityItem> _getFilteredItems() {
    final List<UnifiedActivityItem> list = [];

    // Filter deposits
    if (_selectedTab == 'Semua' || _selectedTab == 'Setor Sampah') {
      for (final d in _deposits) {
        final statusNorm = d.status.toLowerCase();
        final points = d.earnedPoints ?? d.estimatedPoints;

        // Search query filter
        if (_searchQuery.isNotEmpty) {
          final query = _searchQuery.toLowerCase();
          final matchWaste = d.wasteTypeName.toLowerCase().contains(query);
          final matchCode = d.code.toLowerCase().contains(query);
          final matchDrop = (d.dropPointName ?? '').toLowerCase().contains(query);
          if (!matchWaste && !matchCode && !matchDrop) continue;
        }

        // Status filter
        if (_statusFilter == 'Menunggu' && statusNorm != 'pending') continue;
        if (_statusFilter == 'Disetujui' && statusNorm != 'verified') continue;
        if (_statusFilter == 'Ditolak' &&
            statusNorm != 'rejected' &&
            statusNorm != 'cancelled' &&
            statusNorm != 'canceled') {
          continue;
        }

        list.add(
          UnifiedActivityItem(
            type: ActivityType.deposit,
            date: _parseDate(d.createdAt),
            points: points,
            status: d.status,
            deposit: d,
          ),
        );
      }
    }

    // Filter redemptions
    if (_selectedTab == 'Semua' || _selectedTab == 'Tukar Hadiah') {
      for (final r in _redemptions) {
        final statusNorm = r.status.toLowerCase();

        // Search query filter
        if (_searchQuery.isNotEmpty) {
          final query = _searchQuery.toLowerCase();
          final matchReward = r.rewardName.toLowerCase().contains(query);
          final matchNotes = (r.notes ?? '').toLowerCase().contains(query);
          if (!matchReward && !matchNotes) continue;
        }

        // Status filter
        if (_statusFilter == 'Menunggu' && statusNorm != 'pending') continue;
        if (_statusFilter == 'Disetujui' &&
            statusNorm != 'completed' &&
            statusNorm != 'verified') {
          continue;
        }
        if (_statusFilter == 'Ditolak' &&
            statusNorm != 'rejected' &&
            statusNorm != 'cancelled' &&
            statusNorm != 'canceled' &&
            statusNorm != 'expired') {
          continue;
        }

        list.add(
          UnifiedActivityItem(
            type: ActivityType.redemption,
            date: _parseDate(r.createdAt),
            points: r.pointsUsed,
            status: r.status,
            redemption: r,
          ),
        );
      }
    }

    // Sorting
    switch (_sortBy) {
      case 'Terlama':
        list.sort((a, b) => a.date.compareTo(b.date));
        break;
      case 'Poin Terbanyak':
        list.sort((a, b) => b.points.compareTo(a.points));
        break;
      case 'Poin Terendah':
        list.sort((a, b) => a.points.compareTo(b.points));
        break;
      case 'Terbaru':
      default:
        list.sort((a, b) => b.date.compareTo(a.date));
        break;
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _getFilteredItems();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          'Semua Riwayat Aktivitas',
          style: TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.primary),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort_rounded, color: AppColors.primary),
            tooltip: 'Urutkan Riwayat',
            onPressed: _showSortDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(fontSize: 13, color: AppColors.text),
                decoration: InputDecoration(
                  hintText: 'Cari sampah, hadiah, kode resi...',
                  hintStyle: const TextStyle(
                      fontSize: 12.5, color: AppColors.textMuted),
                  prefixIcon: const Icon(Icons.search,
                      size: 20, color: AppColors.textMuted),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear,
                              size: 16, color: AppColors.textMuted),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onChanged: (val) {
                  setState(() => _searchQuery = val.trim());
                },
              ),
            ),
          ),

          // Kategori Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: SizedBox(
              height: 36,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _tabs.length,
                itemBuilder: (context, index) {
                  final tab = _tabs[index];
                  final isSelected = _selectedTab == tab;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = tab),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.surfaceAlt,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.surfaceBorder,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            tab,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : AppColors.text,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Status Filter Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              children: [
                const Icon(Icons.filter_list_rounded,
                    size: 15, color: AppColors.textMuted),
                const SizedBox(width: 6),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _statusOptions.map((status) {
                        final isSelected = _statusFilter == status;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ChoiceChip(
                            selected: isSelected,
                            label: Text(status),
                            labelStyle: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textMuted,
                            ),
                            selectedColor:
                                AppColors.primary.withValues(alpha: 0.14),
                            backgroundColor: AppColors.surfaceAlt,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            side: BorderSide(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.surfaceBorder,
                              width: isSelected ? 1.2 : 1,
                            ),
                            onSelected: (_) {
                              setState(() => _statusFilter = status);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 8, color: AppColors.surfaceBorder),

          // Active Sort & Results Info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${filteredItems.length} transaksi ditemukan',
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textMuted),
                ),
                GestureDetector(
                  onTap: _showSortDialog,
                  child: Row(
                    children: [
                      Text(
                        'Urut: $_sortBy',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(Icons.arrow_drop_down,
                          size: 16, color: AppColors.primary),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // List Items
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _loadAllHistory,
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.primary))
                  : filteredItems.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.15),
                            Center(
                              child: Column(
                                children: [
                                  const Icon(Icons.manage_search_rounded,
                                      size: 52, color: AppColors.textMuted),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Tidak ada riwayat yang sesuai',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.text,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Coba ubah kata kunci pencarian atau filter status',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          itemCount: filteredItems.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final item = filteredItems[index];
                            if (item.type == ActivityType.deposit &&
                                item.deposit != null) {
                              return _buildDepositCard(item.deposit!);
                            } else if (item.type == ActivityType.redemption &&
                                item.redemption != null) {
                              return _buildRedemptionCard(item.redemption!);
                            }
                            return const SizedBox.shrink();
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDepositCard(WasteDepositModel d) {
    final isVerified = d.status.toLowerCase() == 'verified';
    final isRejected = d.status.toLowerCase() == 'rejected';
    final isCancelled = d.status.toLowerCase() == 'cancelled' ||
        d.status.toLowerCase() == 'canceled';

    final statusText = isVerified
        ? 'Selesai'
        : (isRejected ? 'Ditolak' : (isCancelled ? 'Dibatalkan' : 'Menunggu'));
    final statusBgColor = isVerified
        ? AppColors.successBg
        : (isRejected || isCancelled ? AppColors.dangerBg : AppColors.warningBg);
    final statusTextColor = isVerified
        ? AppColors.success
        : (isRejected || isCancelled ? AppColors.danger : AppColors.warning);

    String dateDisplay = 'Baru saja';
    if (d.createdAt != null && d.createdAt!.length >= 10) {
      dateDisplay = d.createdAt!.substring(0, 10);
    }

    final points = d.earnedPoints ?? d.estimatedPoints;

    return InkWell(
      onTap: () async {
        final cancelled = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => SetoranDetailScreen(deposit: d),
          ),
        );
        if (cancelled == true && mounted) {
          await _loadAllHistory();
        }
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: const Icon(Icons.recycling_rounded,
                  size: 22, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Setor ${d.wasteTypeName}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Resi: ${d.code} • ${d.weightKg.toStringAsFixed(1)} kg\n${d.dropPointName ?? 'Drop Point'} • $dateDisplay',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '+$points Poin',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.gold,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: statusTextColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: statusTextColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRedemptionCard(RedemptionModel r) {
    String dateDisplay = 'Baru saja';
    if (r.createdAt != null && r.createdAt!.length >= 10) {
      dateDisplay = r.createdAt!.substring(0, 10);
    }

    final statusUi = redemptionStatusUi(r);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: const Icon(Icons.card_giftcard_rounded,
                size: 22, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tukar ${r.rewardName}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${r.notes ?? 'Klaim Hadiah'} • $dateDisplay',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '-${r.pointsUsed} Poin',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Colors.red.shade700,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusUi.bg,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: statusUi.fg.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  statusUi.label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: statusUi.fg,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
