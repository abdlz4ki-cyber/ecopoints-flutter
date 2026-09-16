import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../models/app_notification_model.dart';
import '../services/notification_storage_service.dart';
import 'riwayat_screen.dart';
import 'hadiah_saya_screen.dart';

class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  State<NotificationCenterScreen> createState() =>
      _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen> {
  List<AppNotificationModel> _notifications = [];
  bool _isLoading = true;
  String _selectedFilter = 'Semua';
  final List<String> _filters = ['Semua', 'Setoran', 'Hadiah'];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    final list = await NotificationStorageService.getNotifications();
    if (mounted) {
      setState(() {
        _notifications = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _markAllAsRead() async {
    await NotificationStorageService.markAllAsRead();
    await _loadNotifications();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semua notifikasi telah ditandai dibaca'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _clearAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceAlt,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Semua Notifikasi?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: const Text(
          'Semua riwayat notifikasi yang tersimpan akan dihapus secara permanen.',
          style: TextStyle(fontSize: 13, color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal',
                style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await NotificationStorageService.clearAll();
      await _loadNotifications();
    }
  }

  Future<void> _handleNotificationTap(AppNotificationModel item) async {
    await NotificationStorageService.markAsRead(item.id);
    await _loadNotifications();

    if (!mounted) return;

    if (item.type == NotificationType.deposit) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const RiwayatScreen()),
      );
    } else if (item.type == NotificationType.reward) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const HadiahSayaScreen()),
      );
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) {
      return 'Baru saja';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} mnt lalu';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} jam lalu';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} hari lalu';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _notifications.where((n) {
      if (_selectedFilter == 'Setoran') {
        return n.type == NotificationType.deposit;
      } else if (_selectedFilter == 'Hadiah') {
        return n.type == NotificationType.reward;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Pemberitahuan',
          style: TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        actions: [
          if (_notifications.isNotEmpty) ...[
            IconButton(
              icon: const Icon(Icons.done_all, color: AppColors.primary, size: 22),
              tooltip: 'Tandai Semua Dibaca',
              onPressed: _markAllAsRead,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  color: AppColors.textMuted, size: 22),
              tooltip: 'Hapus Semua',
              onPressed: _clearAll,
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          // Filter tabs
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: _filters.map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(filter),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.text,
                    ),
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.surfaceAlt,
                    checkmarkColor: Colors.white,
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.surfaceBorder,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    onSelected: (_) {
                      setState(() => _selectedFilter = filter);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1, color: AppColors.surfaceBorder),

          // List content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary))
                : filteredList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceAlt,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: AppColors.surfaceBorder),
                              ),
                              child: const Icon(
                                Icons.notifications_none_rounded,
                                size: 48,
                                color: AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Belum ada pemberitahuan',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.text,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Pemberitahuan aktivitas setoran dan hadiah akan muncul di sini.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: _loadNotifications,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredList.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final item = filteredList[index];
                            return _buildNotificationCard(item);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(AppNotificationModel item) {
    IconData icon;
    Color iconBg;
    Color iconColor;

    switch (item.type) {
      case NotificationType.deposit:
        icon = Icons.recycling_rounded;
        iconBg = AppColors.successBg;
        iconColor = AppColors.success;
        break;
      case NotificationType.reward:
        icon = Icons.card_giftcard_rounded;
        iconBg = AppColors.warningBg;
        iconColor = AppColors.warning;
        break;
      case NotificationType.general:
        icon = Icons.notifications_active_rounded;
        iconBg = AppColors.primary.withValues(alpha: 0.12);
        iconColor = AppColors.primary;
        break;
    }

    return InkWell(
      onTap: () => _handleNotificationTap(item),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: item.isRead
              ? AppColors.surfaceAlt
              : AppColors.surfaceAlt.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: item.isRead
                ? AppColors.surfaceBorder
                : AppColors.primary.withValues(alpha: 0.4),
            width: item.isRead ? 1 : 1.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Leading icon avatar
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: item.isRead
                                ? FontWeight.w600
                                : FontWeight.w800,
                            color: AppColors.text,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatTime(item.timestamp),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.body,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.35,
                      color: item.isRead
                          ? AppColors.textMuted
                          : AppColors.text.withValues(alpha: 0.9),
                    ),
                  ),
                  if (item.type == NotificationType.deposit ||
                      item.type == NotificationType.reward) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          item.type == NotificationType.deposit
                              ? 'Ketuk untuk lihat Riwayat Setoran →'
                              : 'Ketuk untuk lihat Hadiah Saya →',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Unread dot indicator
            if (!item.isRead) ...[
              const SizedBox(width: 8),
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 4),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
