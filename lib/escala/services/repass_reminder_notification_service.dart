import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;

import '../providers/blocked_day_provider.dart';
import '../providers/shift_provider.dart';
import '../screens/escala_page.dart';
import '../utils/constants.dart';

/// Serviço que agenda uma notificação diária às 7h quando existem plantões ou
/// procedimentos em dias bloqueados na agenda, lembrando o usuário de repassar.
class RepassReminderNotificationService {
  static const int notificationId = 777;
  static const String _channelId = 'repass_reminder';
  static const String _channelName = 'Lembretes da agenda';

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;
  static GlobalKey<NavigatorState>? _navigatorKey;

  /// Inicializa o plugin e o timezone. Chamar uma vez no startup (ex.: main)
  /// com [navigatorKey] para que o toque na notificação abra a Escala.
  static Future<void> initialize([GlobalKey<NavigatorState>? navigatorKey]) async {
    if (_initialized) {
      _navigatorKey = navigatorKey ?? _navigatorKey;
      return;
    }
    _navigatorKey = navigatorKey;
    tz_data.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('America/Sao_Paulo'));
    } catch (_) {
      // fallback: use local if São Paulo not found
    }
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
    );
    const initSettings = InitializationSettings(
      android: android,
      iOS: ios,
    );
    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
    if (Platform.isAndroid) {
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(
            const AndroidNotificationChannel(
              _channelId,
              _channelName,
              description: 'Lembretes de plantões e procedimentos para repassar',
              importance: Importance.defaultImportance,
            ),
          );
    }
    _initialized = true;
  }

  static void _onNotificationTap(NotificationResponse response) {
    if (response.id != null && response.id == notificationId) {
      _navigateToEscala();
    }
  }

  /// Navega para a página da Escala (aba Calendário). Chamado ao tocar na notificação.
  static void _navigateToEscala() {
    final state = _navigatorKey?.currentState;
    if (state == null || !state.mounted) return;
    state.push(
      MaterialPageRoute<void>(
        builder: (_) => const EscalaPage(),
      ),
    );
  }

  /// Retorna true se o app foi aberto ao tocar na notificação de repasse.
  /// Chamar ao exibir a Home e, se true, abrir a Escala.
  static Future<bool> wasLaunchedByRepassNotification() async {
    if (!_initialized) return false;
    final details = await _plugin.getNotificationAppLaunchDetails();
    final id = details?.notificationResponse?.id;
    return id != null && id == notificationId;
  }

  /// Conta quantos plantões estão em dias bloqueados.
  static int countOnBlockedDays(
    ShiftProvider shiftProvider,
    BlockedDayProvider blockedDayProvider,
  ) {
    int total = 0;
    for (final blocked in blockedDayProvider.items) {
      final day = DateTime(blocked.date.year, blocked.date.month, blocked.date.day);
      total += shiftProvider.getByDate(day).length;
    }
    return total;
  }

  /// Atualiza o agendamento: se houver itens em dias bloqueados, agenda notificação
  /// diária às 7h; caso contrário, cancela.
  static Future<void> updateSchedule(
    ShiftProvider shiftProvider,
    BlockedDayProvider blockedDayProvider,
  ) async {
    if (!_initialized) await initialize();
    final count = countOnBlockedDays(shiftProvider, blockedDayProvider);
    if (count <= 0) {
      await _plugin.cancel(notificationId);
      return;
    }
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, 7, 0);
    if (scheduled.isBefore(now) || scheduled.isAtSameMomentAs(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Lembretes de plantões e procedimentos para repassar',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    await _plugin.zonedSchedule(
      notificationId,
      AppStrings.repassNotificationTitle,
      AppStrings.repassNotificationBody,
      scheduled,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Solicita permissão de notificação (Android 13+ e iOS). Chamar antes de agendar.
  static Future<bool> requestPermission(BuildContext context) async {
    if (Platform.isAndroid) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final granted = await android?.requestNotificationsPermission();
      return granted == true;
    }
    if (Platform.isIOS) {
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      final granted = await ios?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted == true;
    }
    return true;
  }
}
