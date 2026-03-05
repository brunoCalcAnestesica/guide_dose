import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/procedure_type.dart';

class ProcedureTypeProvider extends ChangeNotifier {
  final Uuid _uuid = const Uuid();

  List<ProcedureType> _types = [];
  bool _isLoading = false;

  List<ProcedureType> get types => _types;
  bool get isLoading => _isLoading;

  Future<void> loadTypes() async {
    _isLoading = true;
    notifyListeners();

    _types.sort((a, b) => a.name.compareTo(b.name));

    _isLoading = false;
    notifyListeners();
  }

  ProcedureType? getById(String id) {
    return _types.where((t) => t.id == id).firstOrNull;
  }

  ProcedureType? getByName(String name) {
    return _types.where((t) => t.name == name).firstOrNull;
  }

  Future<void> addType({
    required String name,
    required double defaultValue,
  }) async {
    final type = ProcedureType(
      id: _uuid.v4(),
      name: name,
      defaultValue: defaultValue,
      createdAt: DateTime.now(),
    );

    _types.add(type);
    _types.sort((a, b) => a.name.compareTo(b.name));
    notifyListeners();
  }

  Future<void> updateType(ProcedureType type) async {
    final index = _types.indexWhere((t) => t.id == type.id);
    if (index != -1) {
      _types[index] = type;
      _types.sort((a, b) => a.name.compareTo(b.name));
    }
    notifyListeners();
  }

  Future<void> deleteType(String id) async {
    _types.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  Future<void> seedDefaults() async {
    if (_types.isNotEmpty) return;

    const defaults = [
      'Cirurgia',
      'Consulta',
      'Parto',
      'Endoscopia',
      'Colonoscopia',
      'Biópsia',
      'Sutura',
      'Drenagem',
    ];

    final toAdd = <ProcedureType>[];
    for (final name in defaults) {
      toAdd.add(ProcedureType(
        id: _uuid.v4(),
        name: name,
        defaultValue: 0.0,
        createdAt: DateTime.now(),
      ));
    }
    _types.addAll(toAdd);
    _types.sort((a, b) => a.name.compareTo(b.name));
    notifyListeners();
  }
}
