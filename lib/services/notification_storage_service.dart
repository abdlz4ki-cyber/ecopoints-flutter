import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_notification_model.dart';

class NotificationStorageService {
  static const String _storageKey = 'app_notifications_list_v1';
  static final ValueNotifier<int> unreadCountNotifier = ValueNotifier<int>(0);
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    await updateUnreadCount();
    _initialized = true;
  }

  static Future<List<AppNotificationModel>> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_storageKey);

    if (rawList == null || rawList.isEmpty) {
      final initialData = _getInitialSampleNotifications();
      await _saveList(initialData);
      return initialData;
    }

    try {
      final list = rawList
          .map((item) => AppNotificationModel.fromJson(item))
          .toList();
      list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return list;
    } catch (_) {
      return [];
    }
  }

  static Future<void> addNotification({
    required String title,
    required String body,
    NotificationType type = NotificationType.general,
    String? referenceId,
  }) async {
    final list = await getNotifications();
    final newNotification = AppNotificationModel(
      id: '${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      body: body,
      type: type,
      timestamp: DateTime.now(),
      isRead: false,
      referenceId: referenceId,
    );

    list.insert(0, newNotification);
    if (list.length > 50) {
      list.removeLast();
    }

    await _saveList(list);
    await updateUnreadCount();
  }

  static Future<void> markAsRead(String id) async {
    final list = await getNotifications();
    bool changed = false;
    final updated = list.map((n) {
      if (n.id == id && !n.isRead) {
        changed = true;
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();

    if (changed) {
      await _saveList(updated);
      await updateUnreadCount();
    }
  }

  static Future<void> markAllAsRead() async {
    final list = await getNotifications();
    final updated = list.map((n) => n.copyWith(isRead: true)).toList();
    await _saveList(updated);
    unreadCountNotifier.value = 0;
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    unreadCountNotifier.value = 0;
  }

  static Future<void> updateUnreadCount() async {
    final list = await getNotifications();
    final unread = list.where((n) => !n.isRead).length;
    unreadCountNotifier.value = unread;
  }

  static Future<void> _saveList(List<AppNotificationModel> list) async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = list.map((n) => n.toJson()).toList();
    await prefs.setStringList(_storageKey, rawList);
  }

  static List<AppNotificationModel> _getInitialSampleNotifications() {
    final now = DateTime.now();
    return [
      AppNotificationModel(
        id: 'init-1',
        title: 'Selamat Datang di EcoPoints! 🌱',
        body: 'Kumpulkan sampah daur ulangmu, setor ke drop point terdekat, dan kumpulkan poin rewards!',
        type: NotificationType.general,
        timestamp: now.subtract(const Duration(minutes: 10)),
        isRead: false,
      ),
      AppNotificationModel(
        id: 'init-2',
        title: 'Tips EcoPoints 💡',
        body: 'Pastikan sampah plastik & kertas dalam keadaan bersih dan kering saat disetorkan agar mendapatkan poin maksimal.',
        type: NotificationType.deposit,
        timestamp: now.subtract(const Duration(hours: 2)),
        isRead: true,
      ),
    ];
  }
}
