import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as developer;

final fcmProvider = Provider<FirebaseMessaging>((ref) {
  return FirebaseMessaging.instance;
});

final pushNotificationServiceProvider = Provider<PushNotificationService>((ref) {
  return PushNotificationService(ref.watch(fcmProvider));
});

class PushNotificationService {
  final FirebaseMessaging _fcm;

  PushNotificationService(this._fcm);

  Future<void> init() async {
    // Request permission (mostly for iOS)
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    developer.log('User granted permission: ${settings.authorizationStatus}');

    // Get FCM Token
    String? token = await _fcm.getToken();
    if (token != null) {
      developer.log('FCM Token: $token');
      // Here you would save the token to the user's Firestore document
    }

    // Listen to token refresh
    _fcm.onTokenRefresh.listen((newToken) {
      developer.log('FCM Token Refreshed: $newToken');
      // Save new token to Firestore
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      developer.log('Got a message whilst in the foreground!');
      developer.log('Message data: ${message.data}');

      if (message.notification != null) {
        developer.log('Message also contained a notification: ${message.notification}');
      }
    });
  }
}
