// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

Future<void> requestWebNotificationPermission() async {
  if (html.Notification.supported) {
    await html.Notification.requestPermission();
  }
}

void showWebNotification(String title, String body) {
  if (html.Notification.supported &&
      html.Notification.permission == 'granted') {
    html.Notification(title, body: body);
  }
}
