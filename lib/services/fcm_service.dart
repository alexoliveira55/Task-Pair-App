import 'package:firebase_messaging/firebase_messaging.dart';

class FcmService {
  final FirebaseMessaging _messaging;

  FcmService(this._messaging);

  Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  Future<void> requestPermission() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  Stream<RemoteMessage> get onMessage => FirebaseMessaging.onMessage;

  Stream<RemoteMessage> get onMessageOpenedApp =>
      FirebaseMessaging.onMessageOpenedApp;

  Future<RemoteMessage?> getInitialMessage() =>
      _messaging.getInitialMessage();

  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }
}
