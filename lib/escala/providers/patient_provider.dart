import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/daos/patient_dao.dart';
import '../models/patient.dart';

class PatientProvider extends ChangeNotifier {
  final PatientDao _dao = PatientDao();
  List<Patient> _items = [];
  List<Patient> _archivedItems = [];
  bool _loaded = false;
  bool _loadingArchived = false;

  List<Patient> get items => List.unmodifiable(_items);
  List<Patient> get archivedItems => List.unmodifiable(_archivedItems);
  bool get loadingArchived => _loadingArchived;

  String? get _userId {
    try {
      return Supabase.instance.client.auth.currentUser?.id;
    } catch (_) {
      return null;
    }
  }

  SupabaseClient? get _client {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  Future<void> load() async {
    if (_loaded) return;
    final uid = _userId;
    if (uid == null) {
      _loaded = true;
      notifyListeners();
      return;
    }
    try {
      final rows = await _dao.getByUser(uid);
      _items = rows.map((r) => Patient.fromDbRow(r)).toList();
      _sortByUpdated();
    } catch (e) {
      debugPrint('PatientProvider.load error: $e');
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> reload() async {
    _loaded = false;
    _items = [];
    await load();
  }

  Future<void> add(Patient patient) async {
    await load();
    final uid = _userId;
    if (uid == null) return;

    final dbRow = patient.toDbRow(uid);
    await _dao.insert(dbRow);
    _items.add(patient);
    _sortByUpdated();
    notifyListeners();
  }

  Future<void> update(Patient patient) async {
    await load();
    final uid = _userId;
    if (uid == null) return;

    patient.updatedAt = DateTime.now();
    final dbRow = patient.toDbRow(uid);
    await _dao.insert(dbRow);
    final index = _items.indexWhere((p) => p.id == patient.id);
    if (index != -1) {
      _items[index] = patient;
    }
    _sortByUpdated();
    notifyListeners();
  }

  Future<void> delete(String id) async {
    await load();
    await _dao.softDelete(id);
    _items.removeWhere((p) => p.id == id);
    _sortByUpdated();
    notifyListeners();

    try {
      final client = _client;
      if (client != null) {
        await client.from('patients').delete().eq('id', id);
        await _dao.hardDelete(id);
      }
    } catch (_) {
      // Offline: stays as 'deleted', sync service will push later
    }
  }

  /// Move a patient to archive. Works offline: marks locally as 'archive_pending',
  /// then tries to push to Supabase immediately. If offline, the sync service
  /// will process the pending archive on next sync.
  Future<void> archive(String id) async {
    await load();
    final uid = _userId;
    if (uid == null) return;

    final idx = _items.indexWhere((p) => p.id == id);
    if (idx == -1) return;
    final patient = _items[idx];

    await _dao.markArchivePending(id);
    _items.removeAt(idx);
    _sortByUpdated();
    notifyListeners();

    try {
      final client = _client;
      if (client != null) {
        final archiveRow = patient.toSupabaseRow(uid);
        archiveRow['archived_at'] = DateTime.now().toIso8601String();
        await client.from('patients_archive').upsert(archiveRow);
        await client.from('patients').delete().eq('id', id);
        await _dao.hardDelete(id);
      }
    } catch (_) {
      // Offline: stays as 'archive_pending', will be processed by sync service
    }
  }

  /// Fetch archived patients from Supabase (requires internet).
  Future<void> fetchArchivedItems() async {
    final uid = _userId;
    final client = _client;
    if (uid == null || client == null) {
      _archivedItems = [];
      notifyListeners();
      return;
    }
    _loadingArchived = true;
    notifyListeners();

    try {
      final rows = await client
          .from('patients_archive')
          .select()
          .eq('user_id', uid)
          .order('archived_at', ascending: false);
      _archivedItems = rows.map((r) => Patient.fromSupabaseRow(r)).toList();
    } catch (e) {
      debugPrint('PatientProvider.fetchArchivedItems error: $e');
    }

    _loadingArchived = false;
    notifyListeners();
  }

  /// Move a patient from Supabase archive back to active (local + Supabase).
  /// After this, the patient exists ONLY in patients (active) — zero duplicity.
  Future<void> unarchive(String id) async {
    final uid = _userId;
    final client = _client;
    if (uid == null || client == null) return;

    final archivedIndex = _archivedItems.indexWhere((p) => p.id == id);
    if (archivedIndex == -1) return;
    final patient = _archivedItems[archivedIndex];

    patient.updatedAt = DateTime.now();
    patient.archivedAt = null;

    await client.from('patients').upsert(patient.toSupabaseRow(uid));
    await client.from('patients_archive').delete().eq('id', id);

    final dbRow = patient.toDbRow(uid);
    dbRow['sync_status'] = 'synced';
    await _dao.insert(dbRow);

    _archivedItems.removeAt(archivedIndex);
    _items.add(patient);
    _sortByUpdated();
    notifyListeners();
  }

  /// Delete an archived patient permanently from Supabase.
  Future<void> deleteArchived(String id) async {
    final client = _client;
    if (client == null) return;

    await client.from('patients_archive').delete().eq('id', id);
    _archivedItems.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  void _sortByUpdated() {
    _items.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }
}
