import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';

/// Top-level handler for background messages (required by firebase_messaging).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('FCM background message: ${message.messageId}');
}

/// Manages FCM token registration and push notification handling.
/// Call [initialize] after Firebase.initializeApp() and Supabase login.
/// On web, all calls are no-ops.
class FcmService {
  FcmService._();
  static final FcmService instance = FcmService._();

  bool _initialized = false;
  String? _currentToken;
  void Function(RemoteMessage)? onMessageOpenedApp;

  /// Initialize FCM: request permissions, get token, set up listeners.
  Future<void> initialize({
    void Function(RemoteMessage)? onMessageOpened,
  }) async {
    if (_initialized || kIsWeb) return;

    try {
      onMessageOpenedApp = onMessageOpened;
      final messaging = FirebaseMessaging.instance;

      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus != AuthorizationStatus.authorized &&
          settings.authorizationStatus != AuthorizationStatus.provisional) {
        debugPrint('FCM: permission not granted');
        return;
      }

      // Android notification channel
      if (Platform.isAndroid) {
        await messaging.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
      }

      // iOS foreground presentation
      if (Platform.isIOS) {
        await messaging.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
      }

      // Background handler
      FirebaseMessaging.onBackgroundMessage(
          firebaseMessagingBackgroundHandler);

      // Get token and register
      _currentToken = await messaging.getToken();
      if (_currentToken != null) {
        await _registerToken(_currentToken!);
      }

      // Token refresh
      messaging.onTokenRefresh.listen((newToken) async {
        _currentToken = newToken;
        await _registerToken(newToken);
      });

      // Foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Notification tap (app in background)
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      // Check if app was opened from a notification (terminated state)
      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleMessageOpenedApp(initialMessage);
      }

      _initialized = true;
      debugPrint(
          'FCM initialized, token: ${_currentToken?.substring(0, 20)}…');
    } catch (e) {
      debugPrint('FCM initialization skipped: $e');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('FCM foreground: ${message.notification?.title}');
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('FCM opened: ${message.data}');
    if (onMessageOpenedApp != null) {
      onMessageOpenedApp!(message);
    }
  }

  /// Register (upsert) FCM token in Supabase.
  Future<void> _registerToken(String token) async {
    if (!SupabaseConfig.isConfigured) return;
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final platform = _getPlatformName();
      await Supabase.instance.client.from('fcm_tokens').upsert(
        {
          'user_id': user.id,
          'token': token,
          'platform': platform,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        },
        onConflict: 'user_id,token',
      );
      debugPrint('FCM token registered for $platform');
    } catch (e) {
      debugPrint('FCM token registration error: $e');
    }
  }

  /// Re-register the current token (e.g. after login).
  Future<void> reRegisterToken() async {
    if (_currentToken != null) {
      await _registerToken(_currentToken!);
    }
  }

  /// Remove current token from Supabase (e.g. on logout).
  Future<void> unregisterToken() async {
    if (_currentToken == null || !SupabaseConfig.isConfigured) return;
    try {
      await Supabase.instance.client
          .from('fcm_tokens')
          .delete()
          .eq('token', _currentToken!);
      debugPrint('FCM token unregistered');
    } catch (e) {
      debugPrint('FCM token unregister error: $e');
    }
  }

  String _getPlatformName() {
    if (kIsWeb) return 'web';
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    return 'unknown';
  }
}
