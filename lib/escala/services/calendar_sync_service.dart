import 'dart:convert';

import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../storage_manager.dart';
import '../models/shift.dart';

const String _kEnabledKey = 'calendar_sync_enabled';
const String _kCalendarIdKey = 'calendar_sync_calendar_id';
const String _kEventMapKey = 'calendar_sync_event_map';
const String _kCalendarName = 'Guide Dose';

class CalendarSyncService {
  static final CalendarSyncService _instance = CalendarSyncService._();
  factory CalendarSyncService() => _instance;
  CalendarSyncService._();

  final DeviceCalendarPlugin _plugin = DeviceCalendarPlugin();
  String? _calendarId;

  bool get isEnabled =>
      StorageManager.instance.getBool(_kEnabledKey, defaultValue: false);

  Future<void> setEnabled(bool value) async {
    await StorageManager.instance.setBool(_kEnabledKey, value);
  }

  Future<bool> requestPermission() async {
    try {
      var result = await _plugin.hasPermissions();
      if (result.data == true) return true;
      result = await _plugin.requestPermissions();
      return result.data == true;
    } catch (e) {
      debugPrint('CalendarSyncService.requestPermission error: $e');
      return false;
    }
  }

  Future<String?> _getOrCreateCalendar() async {
    if (_calendarId != null) {
      return _calendarId;
    }

    final savedId = StorageManager.instance.getString(_kCalendarIdKey);
    if (savedId.isNotEmpty) {
      try {
        final calendars = await _plugin.retrieveCalendars();
        final exists = calendars.data
            ?.any((c) => c.id == savedId && c.isReadOnly == false);
        if (exists == true) {
          _calendarId = savedId;
          return savedId;
        }
      } catch (_) {}
    }

    try {
      final calendars = await _plugin.retrieveCalendars();
      final existing = calendars.data?.where(
        (c) => c.name == _kCalendarName && c.isReadOnly == false,
      );
      if (existing != null && existing.isNotEmpty) {
        _calendarId = existing.first.id;
        await StorageManager.instance
            .setString(_kCalendarIdKey, _calendarId!);
        return _calendarId;
      }
    } catch (_) {}

    try {
      final result = await _plugin.createCalendar(
        _kCalendarName,
        calendarColor: const Color(0xFF1A2848),
        localAccountName: _kCalendarName,
      );
      if (result.isSuccess && result.data != null) {
        _calendarId = result.data;
        await StorageManager.instance
            .setString(_kCalendarIdKey, _calendarId!);
        return _calendarId;
      }
    } catch (e) {
      debugPrint('CalendarSyncService._getOrCreateCalendar error: $e');
    }
    return null;
  }

  Map<String, String> _loadEventMap() {
    try {
      final json = StorageManager.instance.getString(_kEventMapKey);
      if (json.isEmpty) return {};
      final decoded = jsonDecode(json) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(k, v as String));
    } catch (_) {
      return {};
    }
  }

  Future<void> _saveEventMap(Map<String, String> map) async {
    await StorageManager.instance.setString(_kEventMapKey, jsonEncode(map));
  }

  TZDateTime _buildTZDateTime(DateTime date, String time) {
    final parts = time.split(':');
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
    return tz.TZDateTime(
      tz.local,
      date.year,
      date.month,
      date.day,
      hour,
      minute,
    );
  }

  Future<void> addEvent(Shift shift, String hospitalName) async {
    if (!isEnabled) return;
    try {
      final calId = await _getOrCreateCalendar();
      if (calId == null) return;

      final start = _buildTZDateTime(shift.date, shift.startTime);
      var end = _buildTZDateTime(shift.date, shift.endTime);
      if (end.isBefore(start) || end.isAtSameMomentAs(start)) {
        end = end.add(const Duration(days: 1));
      }

      final event = Event(calId,
          title: 'Plantão ${shift.type} - $hospitalName',
          start: start,
          end: end,
          description: shift.informations);

      final result = await _plugin.createOrUpdateEvent(event);
      if (result?.isSuccess == true && result?.data != null) {
        final map = _loadEventMap();
        map[shift.id] = result!.data!;
        await _saveEventMap(map);
      }
    } catch (e) {
      debugPrint('CalendarSyncService.addEvent error: $e');
    }
  }

  Future<void> updateEvent(Shift shift, String hospitalName) async {
    if (!isEnabled) return;
    try {
      final calId = await _getOrCreateCalendar();
      if (calId == null) return;

      final map = _loadEventMap();
      final existingEventId = map[shift.id];

      final start = _buildTZDateTime(shift.date, shift.startTime);
      var end = _buildTZDateTime(shift.date, shift.endTime);
      if (end.isBefore(start) || end.isAtSameMomentAs(start)) {
        end = end.add(const Duration(days: 1));
      }

      final event = Event(calId,
          eventId: existingEventId,
          title: 'Plantão ${shift.type} - $hospitalName',
          start: start,
          end: end,
          description: shift.informations);

      final result = await _plugin.createOrUpdateEvent(event);
      if (result?.isSuccess == true && result?.data != null) {
        map[shift.id] = result!.data!;
        await _saveEventMap(map);
      }
    } catch (e) {
      debugPrint('CalendarSyncService.updateEvent error: $e');
    }
  }

  Future<void> deleteEvent(String shiftId) async {
    if (!isEnabled) return;
    try {
      final calId = await _getOrCreateCalendar();
      if (calId == null) return;

      final map = _loadEventMap();
      final eventId = map[shiftId];
      if (eventId == null) return;

      await _plugin.deleteEvent(calId, eventId);
      map.remove(shiftId);
      await _saveEventMap(map);
    } catch (e) {
      debugPrint('CalendarSyncService.deleteEvent error: $e');
    }
  }

  Future<void> deleteEvents(List<String> shiftIds) async {
    if (!isEnabled) return;
    try {
      final calId = await _getOrCreateCalendar();
      if (calId == null) return;

      final map = _loadEventMap();
      for (final shiftId in shiftIds) {
        final eventId = map[shiftId];
        if (eventId != null) {
          await _plugin.deleteEvent(calId, eventId);
          map.remove(shiftId);
        }
      }
      await _saveEventMap(map);
    } catch (e) {
      debugPrint('CalendarSyncService.deleteEvents error: $e');
    }
  }

  Future<void> syncAllShifts(List<Shift> shifts) async {
    if (!isEnabled) return;
    try {
      final calId = await _getOrCreateCalendar();
      if (calId == null) return;

      final map = _loadEventMap();

      final currentShiftIds = shifts.map((s) => s.id).toSet();
      final toRemove = map.keys
          .where((id) => !currentShiftIds.contains(id))
          .toList();
      for (final shiftId in toRemove) {
        final eventId = map[shiftId];
        if (eventId != null) {
          await _plugin.deleteEvent(calId, eventId);
        }
        map.remove(shiftId);
      }

      for (final shift in shifts) {
        final hospitalName = shift.hospitalName;
        final start = _buildTZDateTime(shift.date, shift.startTime);
        var end = _buildTZDateTime(shift.date, shift.endTime);
        if (end.isBefore(start) || end.isAtSameMomentAs(start)) {
          end = end.add(const Duration(days: 1));
        }

        final event = Event(calId,
            eventId: map[shift.id],
            title: 'Plantão ${shift.type} - $hospitalName',
            start: start,
            end: end,
            description: shift.informations);

        final result = await _plugin.createOrUpdateEvent(event);
        if (result?.isSuccess == true && result?.data != null) {
          map[shift.id] = result!.data!;
        }
      }

      await _saveEventMap(map);
    } catch (e) {
      debugPrint('CalendarSyncService.syncAllShifts error: $e');
    }
  }

  Future<void> removeAllEvents() async {
    try {
      final calId = await _getOrCreateCalendar();
      if (calId == null) return;

      final map = _loadEventMap();
      for (final eventId in map.values) {
        await _plugin.deleteEvent(calId, eventId);
      }
      map.clear();
      await _saveEventMap(map);
    } catch (e) {
      debugPrint('CalendarSyncService.removeAllEvents error: $e');
    }
  }
}
