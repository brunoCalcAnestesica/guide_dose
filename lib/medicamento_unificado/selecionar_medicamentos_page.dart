import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'medicamento_data.dart';
import 'medicamentos_dose_fallback.dart';

/// Página para selecionar medicamentos (checkboxes). Retorna [List<String>] de IDs ao concluir.
class SelecionarMedicamentosPage extends StatefulWidget {
  const SelecionarMedicamentosPage({
    super.key,
    required this.selecionadosAtuais,
    this.idioma = 'PT',
  });

  /// IDs já selecionados (serão pré-marcados).
  final Set<String> selecionadosAtuais;

  final String idioma;

  @override
  State<SelecionarMedicamentosPage> createState() =>
      _SelecionarMedicamentosPageState();
}

class _SelecionarMedicamentosPageState extends State<SelecionarMedicamentosPage> {
  List<MedicamentoData> _medicamentos = [];
  List<MedicamentoData> _filtrados = [];
  bool _isLoading = true;
  final Set<String> _selecionados = {};
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selecionados.addAll(widget.selecionadosAtuais);
    _carregarMedicamentos();
    _searchController.addListener(_aplicarFiltro);
  }

  @override
  void dispose() {
    _searchController.removeListener(_aplicarFiltro);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _carregarMedicamentos() async {
    setState(() => _isLoading = true);
    try {
      final paths = await _listarMedicamentosDisponiveis();
      final List<MedicamentoData> lista = [];
      for (final path in paths) {
        try {
          final med = await MedicamentoData.fromAsset(path, widget.idioma);
          lista.add(med);
        } catch (e) {
          debugPrint('Erro ao carregar $path: $e');
        }
      }
      lista.sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
      setState(() {
        _medicamentos = lista;
        _aplicarFiltro();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Erro ao carregar medicamentos: $e');
    }
  }

  Future<List<String>> _listarMedicamentosDisponiveis() async {
    List<String> medicamentos = [];
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final allAssets = manifest.listAssets();
      medicamentos = allAssets
          .where((key) =>
              key.startsWith('assets/medicamentos_dose/') &&
              key.endsWith('.json'))
          .toList();
    } catch (_) {}

    if (medicamentos.isEmpty) {
      try {
        final manifestContent =
            await rootBundle.loadString('AssetManifest.json');
        final Map<String, dynamic> manifestMap = json.decode(manifestContent);
        medicamentos = manifestMap.keys
            .where((key) =>
                key.startsWith('assets/medicamentos_dose/') &&
                key.endsWith('.json'))
            .toList();
      } catch (_) {}
    }

    final Set<String> set =
        medicamentos.isNotEmpty ? Set.from(medicamentos) : <String>{};
    for (final path in kMedicamentosDoseFallback) {
      set.add(path);
    }
    medicamentos = set.toList()..sort();
    return medicamentos;
  }

  void _aplicarFiltro() {
    final termo = _searchController.text.trim().toLowerCase();
    if (termo.isEmpty) {
      setState(() => _filtrados = List.from(_medicamentos));
      return;
    }
    setState(() {
      _filtrados = _medicamentos
          .where((m) =>
              m.nome.toLowerCase().contains(termo) ||
              m.classe.toLowerCase().contains(termo))
          .toList();
    });
  }

  void _toggle(String id) {
    setState(() {
      if (_selecionados.contains(id)) {
        _selecionados.remove(id);
      } else {
        _selecionados.add(id);
      }
    });
  }

  void _concluir() {
    final lista = _medicamentos
        .where((m) => _selecionados.contains(m.id))
        .map((m) => m.id)
        .toList();
    Navigator.of(context).pop(lista);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecionar medicamentos'),
        actions: [
          TextButton(
            onPressed: _selecionados.isEmpty ? null : _concluir,
            child: const Text('Concluir'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              autocorrect: false,
              enableSuggestions: false,
              decoration: const InputDecoration(
                hintText: 'Buscar por nome ou classe...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filtrados.isEmpty
                    ? Center(
                        child: Text(
                          _searchController.text.trim().isEmpty
                              ? 'Nenhum medicamento disponível'
                              : 'Nenhum resultado para a busca',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filtrados.length,
                        itemBuilder: (context, index) {
                          final med = _filtrados[index];
                          final selected = _selecionados.contains(med.id);
                          return CheckboxListTile(
                            value: selected,
                            onChanged: (_) => _toggle(med.id),
                            title: Text(med.nome),
                            subtitle: med.classe.isNotEmpty
                                ? Text(
                                    med.classe,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  )
                                : null,
                          );
                        },
                      ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _selecionados.isEmpty ? null : _concluir,
                  child: Text(
                    _selecionados.isEmpty
                        ? 'Selecione ao menos um medicamento'
                        : 'Concluir (${_selecionados.length} selecionado${_selecionados.length == 1 ? '' : 's'})',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
