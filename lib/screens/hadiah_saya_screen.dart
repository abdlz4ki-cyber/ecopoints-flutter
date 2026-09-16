import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/app_colors.dart';
import '../models/redemption_model.dart';
import '../services/waste_service.dart';
import '../utils/redemption_status_ui.dart';

class HadiahSayaScreen extends StatefulWidget {
  const HadiahSayaScreen({super.key});

  @override
  State<HadiahSayaScreen> createState() => _HadiahSayaScreenState();
}

class _HadiahSayaScreenState extends State<HadiahSayaScreen> {
  String _selectedTab = 'Voucher Aktif';
  String _statusFilter = 'Semua';
  final List<String> _statusFilters = [
    'Semua',
    'Menunggu',
    'Selesai',
    'Ditolak'
  ];
  List<RedemptionModel> _redemptions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRedemptions();
  }

  Future<void> _loadRedemptions() async {
    setState(() => _isLoading = true);
    try {
      final list = await WasteService.getMyRedemptions();
      if (mounted) {
        setState(() {
          _redemptions = list;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = AppColors.surface;
    final Color primaryDarkColor = AppColors.primary;
    final Color textDark = AppColors.text;
    final Color textGray = AppColors.textMuted;
    final Color cardBackgroundColor = AppColors.surfaceAlt;
    final Color cardBorderColor = AppColors.surfaceBorder;

    final activeList = _redemptions
        .where((r) =>
            r.status.toLowerCase() != 'rejected' &&
            r.status.toLowerCase() != 'expired')
        .toList();

    bool matchesStatus(RedemptionModel r) {
      final s = r.status.toLowerCase();
      if (_statusFilter == 'Menunggu') return s == 'pending';
      if (_statusFilter == 'Selesai') {
        return s == 'completed' || s == 'verified';
      }
      if (_statusFilter == 'Ditolak') {
        return s == 'rejected' ||
            s == 'cancelled' ||
            s == 'canceled' ||
            s == 'expired';
      }
      return true;
    }

    final filteredActiveList = activeList.where(matchesStatus).toList();
    final filteredAllList = _redemptions.where(matchesStatus).toList();

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          color: primaryDarkColor,
          onRefresh: _loadRedemptions,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: cardBackgroundColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: cardBorderColor),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back, size: 18),
                              color: textDark,
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hadiah Saya',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: textDark,
                                ),
                              ),
                              Text(
                                'Voucher & Riwayat Penukaran',
                                style: TextStyle(fontSize: 10, color: textGray),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: cardBackgroundColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: cardBorderColor),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle)),
                            const SizedBox(width: 6),
                            Text('${activeList.length} Hadiah\nAktif',
                                style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: textDark,
                                    height: 1.1)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: cardBackgroundColor,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: cardBorderColor),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _selectedTab = 'Voucher Aktif'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: _selectedTab == 'Voucher Aktif'
                                    ? primaryDarkColor
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Voucher Aktif (${activeList.length})',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: _selectedTab == 'Voucher Aktif'
                                      ? Colors.white
                                      : textDark,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(
                                () => _selectedTab = 'Riwayat Selesai'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: _selectedTab == 'Riwayat Selesai'
                                    ? primaryDarkColor
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Semua Riwayat (${_redemptions.length})',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: _selectedTab == 'Riwayat Selesai'
                                      ? Colors.white
                                      : textDark,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Status Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _statusFilters.map((st) {
                        final isSel = _statusFilter == st;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ChoiceChip(
                            selected: isSel,
                            label: Text(st),
                            labelStyle: TextStyle(
                              fontSize: 11,
                              fontWeight:
                                  isSel ? FontWeight.w700 : FontWeight.w500,
                              color: isSel
                                  ? AppColors.primary
                                  : AppColors.textMuted,
                            ),
                            selectedColor:
                                AppColors.primary.withValues(alpha: 0.14),
                            backgroundColor: cardBackgroundColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            side: BorderSide(
                              color:
                                  isSel ? AppColors.primary : cardBorderColor,
                              width: isSel ? 1.2 : 1,
                            ),
                            onSelected: (_) =>
                                setState(() => _statusFilter = st),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40.0),
                      child: Center(
                        child:
                            CircularProgressIndicator(color: AppColors.primary),
                      ),
                    )
                  else if (_selectedTab == 'Voucher Aktif') ...[
                    if (filteredActiveList.isEmpty)
                      _buildEmptyState(
                        icon: Icons.card_giftcard,
                        title: 'Belum Ada Voucher Aktif',
                        subtitle:
                            'Tukarkan poin EcoPoints kamu dengan berbagai reward menarik di Katalog Hadiah!',
                        cardBg: cardBackgroundColor,
                        borderColor: cardBorderColor,
                        textDark: textDark,
                        textGray: textGray,
                      )
                    else
                      ...filteredActiveList.map((r) => _renderRedemptionCard(
                          r,
                          cardBackgroundColor,
                          cardBorderColor,
                          textDark,
                          textGray,
                          backgroundColor)),
                  ] else ...[
                    if (filteredAllList.isEmpty)
                      _buildEmptyState(
                        icon: Icons.history,
                        title: 'Belum Ada Riwayat Penukaran',
                        subtitle:
                            'Aktivitas penukaran hadiah yang kamu lakukan akan tercatat di sini.',
                        cardBg: cardBackgroundColor,
                        borderColor: cardBorderColor,
                        textDark: textDark,
                        textGray: textGray,
                      )
                    else
                      ..._redemptions.map((r) => _renderRedemptionCard(
                          r,
                          cardBackgroundColor,
                          cardBorderColor,
                          textDark,
                          textGray,
                          backgroundColor)),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color cardBg,
    required Color borderColor,
    required Color textDark,
    required Color textGray,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: textGray),
          const SizedBox(height: 12),
          Text(title,
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w800, color: textDark)),
          const SizedBox(height: 6),
          Text(subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: textGray, height: 1.3)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back, size: 14, color: Colors.white),
            label: const Text('Buka Katalog Hadiah',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _renderRedemptionCard(
    RedemptionModel r,
    Color cardBg,
    Color borderColor,
    Color textDark,
    Color textGray,
    Color bgColor,
  ) {
    final isEwallet = r.rewardName.toLowerCase().contains('gopay') ||
        r.rewardName.toLowerCase().contains('ovo') ||
        r.rewardName.toLowerCase().contains('dana') ||
        r.rewardName.toLowerCase().contains('shopee');

    final category = isEwallet ? 'Saldo E-Wallet' : 'Kupon / Voucher Digital';
    final couponCode = r.voucherCode ??
        'ECO-RDM-${r.rewardId.toString().padLeft(3, "0")}-${r.id.toString().padLeft(4, "0")}';

    String dateDisplay = 'Baru saja';
    if (r.createdAt != null && r.createdAt!.length >= 10) {
      dateDisplay = r.createdAt!.substring(0, 10);
    }

    final statusUi = redemptionStatusUi(r);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: _buildVoucherCard(
        category: category,
        title: r.rewardName,
        subtitle:
            '$dateDisplay • ${r.pointsUsed.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")} Poin',
        badgeText: statusUi.label,
        badgeColor: statusUi.bg,
        badgeTextColor: statusUi.fg,
        cardBg: cardBg,
        borderColor: borderColor,
        textDark: textDark,
        contentWidget: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isEwallet && r.notes != null && r.notes!.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Tujuan:',
                      style: TextStyle(fontSize: 10, color: textGray)),
                  Text(r.notes!,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: textDark)),
                ],
              ),
              const SizedBox(height: 6),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Kode Kupon / Transaksi:',
                    style: TextStyle(fontSize: 10, color: textGray)),
                Text('Status: ${statusUi.label}',
                    style: TextStyle(fontSize: 9, color: textGray)),
              ],
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SelectableText(
                    couponCode,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: textDark),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: couponCode));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppColors.primary,
                          content: Text('Kode "$couponCode" berhasil disalin!'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy,
                        size: 12, color: AppColors.primary),
                    label: const Text('Salin',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: borderColor),
                      backgroundColor: cardBg,
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoucherCard({
    required String category,
    required String title,
    required String subtitle,
    required String badgeText,
    required Color badgeColor,
    required Color badgeTextColor,
    required Widget contentWidget,
    required Color cardBg,
    required Color borderColor,
    required Color textDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: borderColor),
                      ),
                      child: const Icon(Icons.card_giftcard,
                          size: 18, color: AppColors.primary),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(category.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textMuted)),
                          const SizedBox(height: 2),
                          Text(title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: textDark)),
                          const SizedBox(height: 2),
                          Text(subtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 10, color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 88),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(badgeText,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: badgeTextColor)),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Divider(color: AppColors.surfaceBorder, height: 1),
          ),
          contentWidget,
        ],
      ),
    );
  }
}
