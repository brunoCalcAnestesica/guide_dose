import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/daos/note_dao.dart';
import '../models/note.dart';

class NoteProvider extends ChangeNotifier {
  final NoteDao _dao = NoteDao();
  List<Note> _items = [];
  List<Note> _archivedItems = [];
  bool _loaded = false;
  bool _loadingArchived = false;

  List<Note> get items => List.unmodifiable(_items);
  List<Note> get archivedItems => List.unmodifiable(_archivedItems);
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
      _items = rows.map((r) => Note.fromDbRow(r)).toList();
      _sortByUpdated();
    } catch (e) {
      debugPrint('NoteProvider.load error: $e');
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> reload() async {
    _loaded = false;
    _items = [];
    await load();
  }

  Future<void> add(String title, String content) async {
    await load();
    final uid = _userId;
    if (uid == null) return;

    final now = DateTime.now();
    final note = Note(
      id: 'note_${now.millisecondsSinceEpoch}',
      title: title.isEmpty ? 'Sem título' : title,
      content: content,
      createdAt: now,
      updatedAt: now,
    );
    final dbRow = note.toDbRow(uid);
    await _dao.insert(dbRow);
    _items.add(note);
    _sortByUpdated();
    notifyListeners();
  }

  Future<void> update(Note note) async {
    await load();
    final uid = _userId;
    if (uid == null) return;

    note.updatedAt = DateTime.now();
    final dbRow = note.toDbRow(uid);
    await _dao.insert(dbRow);
    final index = _items.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      _items[index] = note;
    }
    _sortByUpdated();
    notifyListeners();
  }

  Future<void> delete(String id) async {
    await load();
    await _dao.softDelete(id);
    _items.removeWhere((n) => n.id == id);
    _sortByUpdated();
    notifyListeners();

    try {
      final client = _client;
      if (client != null) {
        await client.from('notes').delete().eq('id', id);
        await _dao.hardDelete(id);
      }
    } catch (_) {
      // Offline: stays as 'deleted', sync service will push later
    }
  }

  /// Move a note to archive. Works offline: marks locally as 'archive_pending',
  /// then tries to push to Supabase immediately. If offline, the sync service
  /// will process the pending archive on next sync.
  Future<void> archive(String id) async {
    await load();
    final uid = _userId;
    if (uid == null) return;

    final noteIndex = _items.indexWhere((n) => n.id == id);
    if (noteIndex == -1) return;
    final note = _items[noteIndex];

    await _dao.markArchivePending(id);
    _items.removeAt(noteIndex);
    _sortByUpdated();
    notifyListeners();

    try {
      final client = _client;
      if (client != null) {
        final archiveRow = note.toSupabaseRow(uid);
        archiveRow['archived_at'] = DateTime.now().toIso8601String();
        await client.from('notes_archive').upsert(archiveRow);
        await client.from('notes').delete().eq('id', id);
        await _dao.hardDelete(id);
      }
    } catch (_) {
      // Offline: stays as 'archive_pending', will be processed by sync service
    }
  }

  /// Fetch archived notes from Supabase (requires internet).
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
          .from('notes_archive')
          .select()
          .eq('user_id', uid)
          .order('archived_at', ascending: false);
      _archivedItems = rows.map((r) => Note.fromSupabaseRow(r)).toList();
    } catch (e) {
      debugPrint('NoteProvider.fetchArchivedItems error: $e');
    }

    _loadingArchived = false;
    notifyListeners();
  }

  /// Move a note from Supabase archive back to active (local + Supabase).
  /// After this, the note exists ONLY in notes (active) — zero duplicity.
  Future<void> unarchive(String id) async {
    final uid = _userId;
    final client = _client;
    if (uid == null || client == null) return;

    final archivedIndex = _archivedItems.indexWhere((n) => n.id == id);
    if (archivedIndex == -1) return;
    final note = _archivedItems[archivedIndex];

    note.updatedAt = DateTime.now();
    note.archivedAt = null;

    await client.from('notes').upsert(note.toSupabaseRow(uid));
    await client.from('notes_archive').delete().eq('id', id);

    final dbRow = note.toDbRow(uid);
    dbRow['sync_status'] = 'synced';
    await _dao.insert(dbRow);

    _archivedItems.removeAt(archivedIndex);
    _items.add(note);
    _sortByUpdated();
    notifyListeners();
  }

  /// Delete an archived note permanently from Supabase.
  Future<void> deleteArchived(String id) async {
    final client = _client;
    if (client == null) return;

    await client.from('notes_archive').delete().eq('id', id);
    _archivedItems.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  void _sortByUpdated() {
    _items.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }
}
