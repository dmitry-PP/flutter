import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'web_notification_stub.dart'
    if (dart.library.html) 'web_notification_impl.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    if (kIsWeb) {
      await requestWebNotificationPermission();
      _initialized = true;
      return;
    }

    const DarwinInitializationSettings darwinSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      macOS: darwinSettings,
    );

    await _plugin.initialize(initSettings);
    _initialized = true;
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    if (kIsWeb) {
      showWebNotification(title, body);
      return;
    }

    const DarwinNotificationDetails darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      macOS: darwinDetails,
    );

    await _plugin.show(id, title, body, details);
  }

  Future<void> showOrderNotification(String orderTotal) async {
    await showNotification(
      id: 1,
      title: 'Заказ оформлен',
      body:
          'Ваш заказ на $orderTotal успешно принят. Спасибо за покупку!',
    );
  }

  Future<void> showWelcomeNotification(String userName) async {
    await showNotification(
      id: 2,
      title: 'Добро пожаловать, $userName!',
      body:
          'Рады видеть вас в BookNest. Подберите следующую книгу для чтения!',
    );
  }

  Future<void> showCartNotification(String gameName) async {
    await showNotification(
      id: 3,
      title: 'Добавлено в корзину',
      body: '"$gameName" добавлена в вашу корзину.',
    );
  }

  Future<void> showNewGamesNotification() async {
    await showNotification(
      id: 4,
      title: 'Новинки недели',
      body: 'Проверьте каталог — добавили новые книги.',
    );
  }
}
