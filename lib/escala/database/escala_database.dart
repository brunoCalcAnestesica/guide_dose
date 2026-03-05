import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class EscalaDatabase {
  static EscalaDatabase? _instance;
  static EscalaDatabase get instance => _instance ??= EscalaDatabase._();
  EscalaDatabase._();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'escala.db');
    return openDatabase(
      path,
      version: 7,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE shifts (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        hospital_name TEXT NOT NULL,
        date TEXT NOT NULL,
        start_time TEXT NOT NULL,
        end_time TEXT NOT NULL,
        duration_hours REAL NOT NULL,
        value REAL NOT NULL,
        type TEXT NOT NULL,
        informations TEXT,
        is_all_day INTEGER NOT NULL DEFAULT 0,
        is_completed INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        sync_status TEXT NOT NULL DEFAULT 'pending'
      )
    ''');

    await db.execute('''
      CREATE TABLE sync_meta (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE recurrence_rules (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        hospital_name TEXT NOT NULL,
        start_date TEXT NOT NULL,
        start_time TEXT NOT NULL,
        end_time TEXT NOT NULL,
        duration_hours REAL NOT NULL,
        value REAL NOT NULL,
        type TEXT NOT NULL,
        informations TEXT,
        is_all_day INTEGER NOT NULL DEFAULT 0,
        recurrence_type TEXT NOT NULL,
        recurrence_interval INTEGER NOT NULL DEFAULT 1,
        recurrence_days_of_week TEXT,
        recurrence_end_type TEXT NOT NULL DEFAULT 'never',
        recurrence_end_date TEXT,
        recurrence_end_count INTEGER,
        recurrence_week_of_month INTEGER,
        end_date TEXT,
        excluded_dates TEXT,
        paid_dates TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        sync_status TEXT NOT NULL DEFAULT 'pending'
      )
    ''');

    await db.execute('''
      CREATE TABLE shift_reports (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        year INTEGER NOT NULL,
        month INTEGER NOT NULL,
        total_hours REAL NOT NULL DEFAULT 0,
        total_value REAL NOT NULL DEFAULT 0,
        shifts_count INTEGER NOT NULL DEFAULT 0,
        paid_count INTEGER NOT NULL DEFAULT 0,
        paid_value REAL NOT NULL DEFAULT 0,
        pending_count INTEGER NOT NULL DEFAULT 0,
        pending_value REAL NOT NULL DEFAULT 0,
        by_hospital TEXT,
        by_type TEXT,
        details TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        sync_status TEXT NOT NULL DEFAULT 'pending'
      )
    ''');

    await db.execute('''
      CREATE TABLE blocked_days (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        date TEXT NOT NULL,
        label TEXT NOT NULL DEFAULT 'Feriado',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        sync_status TEXT NOT NULL DEFAULT 'pending'
      )
    ''');

    await db.execute('''
      CREATE TABLE notes (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        title TEXT NOT NULL DEFAULT 'Sem título',
        content TEXT NOT NULL DEFAULT '',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        sync_status TEXT NOT NULL DEFAULT 'pending'
      )
    ''');

    await db.execute('''
      CREATE TABLE patients (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        initials TEXT NOT NULL DEFAULT '',
        age REAL,
        age_unit TEXT NOT NULL DEFAULT 'anos',
        admission_date TEXT,
        bed TEXT NOT NULL DEFAULT '',
        history TEXT NOT NULL DEFAULT '',
        devices TEXT NOT NULL DEFAULT '',
        diagnosis TEXT NOT NULL DEFAULT '',
        antibiotics TEXT NOT NULL DEFAULT '',
        vasoactive_drugs TEXT NOT NULL DEFAULT '',
        exams TEXT NOT NULL DEFAULT '',
        pending TEXT NOT NULL DEFAULT '',
        observations TEXT NOT NULL DEFAULT '',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        sync_status TEXT NOT NULL DEFAULT 'pending'
      )
    ''');

    await db.execute('''
      CREATE TABLE med_lists (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        nome TEXT NOT NULL,
        medicamento_ids TEXT NOT NULL DEFAULT '[]',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        sync_status TEXT NOT NULL DEFAULT 'pending'
      )
    ''');

    await db.execute(
        'CREATE INDEX idx_shifts_date ON shifts(date)');
    await db.execute(
        'CREATE INDEX idx_shifts_user ON shifts(user_id)');
    await db.execute(
        'CREATE INDEX idx_recurrence_rules_user ON recurrence_rules(user_id)');
    await db.execute(
        'CREATE INDEX idx_shift_reports_user_year_month ON shift_reports(user_id, year, month)');
    await db.execute(
        'CREATE INDEX idx_blocked_days_user_date ON blocked_days(user_id, date)');
    await db.execute(
        'CREATE INDEX idx_notes_user ON notes(user_id)');
    await db.execute(
        'CREATE INDEX idx_patients_user ON patients(user_id)');
    await db.execute(
        'CREATE INDEX idx_med_lists_user ON med_lists(user_id)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
          'ALTER TABLE recurrence_rules ADD COLUMN excluded_dates TEXT');
    }
    if (oldVersion < 3) {
      await db.execute(
          'ALTER TABLE shifts ADD COLUMN updated_at TEXT');
      await db.execute(
          "UPDATE shifts SET updated_at = created_at WHERE updated_at IS NULL");
      await db.execute('''
        CREATE TABLE IF NOT EXISTS sync_meta (
          key TEXT PRIMARY KEY,
          value TEXT NOT NULL
        )
      ''');
    }
    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS blocked_days (
          id TEXT PRIMARY KEY,
          user_id TEXT NOT NULL,
          date TEXT NOT NULL,
          label TEXT NOT NULL DEFAULT 'Feriado',
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          sync_status TEXT NOT NULL DEFAULT 'pending'
        )
      ''');
      await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_blocked_days_user_date ON blocked_days(user_id, date)');
    }
    if (oldVersion < 5) {
      await db.execute(
          'ALTER TABLE recurrence_rules ADD COLUMN paid_dates TEXT');
    }
    if (oldVersion < 6) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS notes (
          id TEXT PRIMARY KEY,
          user_id TEXT NOT NULL,
          title TEXT NOT NULL DEFAULT 'Sem título',
          content TEXT NOT NULL DEFAULT '',
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          sync_status TEXT NOT NULL DEFAULT 'pending'
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS patients (
          id TEXT PRIMARY KEY,
          user_id TEXT NOT NULL,
          initials TEXT NOT NULL DEFAULT '',
          age REAL,
          age_unit TEXT NOT NULL DEFAULT 'anos',
          admission_date TEXT,
          bed TEXT NOT NULL DEFAULT '',
          history TEXT NOT NULL DEFAULT '',
          devices TEXT NOT NULL DEFAULT '',
          diagnosis TEXT NOT NULL DEFAULT '',
          antibiotics TEXT NOT NULL DEFAULT '',
          vasoactive_drugs TEXT NOT NULL DEFAULT '',
          exams TEXT NOT NULL DEFAULT '',
          pending TEXT NOT NULL DEFAULT '',
          observations TEXT NOT NULL DEFAULT '',
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          sync_status TEXT NOT NULL DEFAULT 'pending'
        )
      ''');
      await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_notes_user ON notes(user_id)');
      await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_patients_user ON patients(user_id)');
    }
    if (oldVersion < 7) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS med_lists (
          id TEXT PRIMARY KEY,
          user_id TEXT NOT NULL,
          nome TEXT NOT NULL,
          medicamento_ids TEXT NOT NULL DEFAULT '[]',
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          sync_status TEXT NOT NULL DEFAULT 'pending'
        )
      ''');
      await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_med_lists_user ON med_lists(user_id)');
    }
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
