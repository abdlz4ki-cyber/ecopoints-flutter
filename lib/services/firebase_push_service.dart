import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../config/api_config.dart';
import 'api_service.dart';
import 'auth_service.dart';

import '../models/app_notification_model.dart';
import 'notification_storage_service.dart';

const AndroidNotificationDetails _androidDetails = AndroidNotificationDetails(
  'ecopoints_channel',
  'Notifikasi EcoPoints',
  channelDescription: 'Informasi setoran, poin, dan hadiah EcoPoints',
  importance: Importance.high,
  priority: Priority.high,
);

const AndroidNotificationChannel _androidChannel = AndroidNotificationChannel(
  'ecopoints_channel',
  'Notifikasi EcoPoints',
  description: 'Informasi setoran, poin, dan hadiah EcoPoints',
  importance: Importance.high,
);

Future<void> _recordNotification(RemoteMessage message) async {
  try {
    final notification = message.notification;
    if (notification == null) return;
    final title = notification.title ?? 'EcoPoints';
    final body = notification.body ?? '';

    NotificationType type = NotificationType.general;
    final lowerTitle = title.toLowerCase();
    final lowerBody = body.toLowerCase();
    if (lowerTitle.contains('setoran') ||
        lowerBody.contains('setoran') ||
        lowerBody.contains('sampah')) {
      type = NotificationType.deposit;
    } else if (lowerTitle.contains('hadiah') ||
        lowerBody.contains('hadiah') ||
        lowerTitle.contains('penukaran') ||
        lowerBody.contains('penukaran')) {
      type = NotificationType.reward;
    }

    await NotificationStorageService.addNotification(
      title: title,
      body: body,
      type: type,
    );
  } catch (_) {}
}

Future<void> _showLocalNotification(
  FlutterLocalNotificationsPlugin plugin,
  RemoteMessage message,
) async {
  final notification = message.notification;
  if (notification == null) return;

  await _recordNotification(message);

  await plugin.show(
    id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    title: notification.title ?? 'EcoPoints',
    body: notification.body ?? '',
    notificationDetails: const NotificationDetails(android: _androidDetails),
  );
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
    await _recordNotification(message);
    final plugin = FlutterLocalNotificationsPlugin();
    await plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
    await _showLocalNotification(plugin, message);
  } catch (_) {}
}

class FirebasePushService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  static Future<void> init() async {
    if (!Platform.isAndroid && !Platform.isIOS) return;
    if (_initialized) return;

    try {
      await NotificationStorageService.init();
      await Firebase.initializeApp();

      await _localNotifications.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        ),
      );

      final androidPlugin =
          _localNotifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(_androidChannel);
      }

      final messaging = FirebaseMessaging.instance;

      await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      FirebaseMessaging.onMessage.listen((message) {
        _showLocalNotification(_localNotifications, message);
      });

      FirebaseMessaging.onMessageOpenedApp.listen((_) {});

      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {}

      messaging.onTokenRefresh.listen((token) {
        registerToken(token);
      });

      final token = await messaging.getToken();
      if (token != null) {
        await registerToken(token);
      }

      _initialized = true;
    } catch (_) {}
  }

  static Future<void> registerCurrentToken() async {
    if (!Platform.isAndroid && !Platform.isIOS) return;
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await registerToken(token);
      }
    } catch (_) {}
  }

  static Future<void> registerToken(String token) async {
    final authToken = await AuthService.getToken();
    if (authToken == null || authToken.isEmpty) return;
    try {
      await ApiService.post(
        ApiConfig.pushTokens,
        body: {
          'token': token,
          'platform': Platform.isAndroid ? 'android' : 'ios',
        },
        token: authToken,
      );
    } catch (_) {}
  }

  static Future<void> unregisterCurrentToken() async {
    if (!Platform.isAndroid && !Platform.isIOS) return;
    final authToken = await AuthService.getToken();
    if (authToken == null || authToken.isEmpty) return;
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        await ApiService.delete(
          ApiConfig.pushTokens,
          body: {'token': token},
          token: authToken,
        );
      }
    } catch (_) {}
  }
}
