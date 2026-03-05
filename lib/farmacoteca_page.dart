import 'dart:async';
import 'package:flutter/material.dart';

import 'shared_data.dart';
import 'farmacoteca/medicamento_generico.dart';
import 'utils/error_messages.dart';

class FarmacotecaPage extends StatefulWidget {
  const FarmacotecaPage({super.key});

  @override
  State<FarmacotecaPage> createState() => _FarmacotecaPageState();
}

class _FarmacotecaPageState extends State<FarmacotecaPage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  List<Map<String, dynamic>> medicamentos = [];
  List<Map<String, dynamic>> _medicamentosFiltrados = [];
  bool _carregando = true;
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _carregarMedicamentos();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() {
        _query = _searchController.text.toLowerCase();
        _recalcularFiltro();
      });
    });
  }

  void _recalcularFiltro() {
    final filtrados = _query.isEmpty
        ? List<Map<String, dynamic>>.from(medicamentos)
        : medicamentos
            .where((med) => (med['nome'] ?? '').toString().toLowerCase().contains(_query))
            .toList();

    filtrados.sort((a, b) {
      final nomeA = a['nome'] as String;
      final nomeB = b['nome'] as String;
      return nomeA.compareTo(nomeB);
    });

    _medicamentosFiltrados = filtrados;
  }

  Future<void> _carregarMedicamentos() async {
    try {
      final medicamentosCarregados =
          await FarmacotecaManager.getMedicamentosParaUI();
      if (!mounted) return;
      setState(() {
        medicamentos = medicamentosCarregados;
        _carregando = false;
        _recalcularFiltro();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _carregando = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar medicamentos: ${mensagemErroAmigavel(e)}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (SharedData.peso == null ||
        SharedData.altura == null ||
        SharedData.idade == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Farmacoteca'),
        ),
        body: const Center(
          child: Text(
            'Por favor, preencha os dados do paciente na aba Paciente para acessar a farmacoteca.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Farmacoteca'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Campo de busca
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                style: TextStyle(fontSize: 15, color: Colors.black87),
                decoration: InputDecoration(
                  labelText: 'Buscar medicamentos...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            FocusScope.of(context).unfocus();
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
            ),

            // Lista de medicamentos
            Expanded(
              child: _carregando
                  ? const Center(child: CircularProgressIndicator())
                  : _medicamentosFiltrados.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _medicamentosFiltrados.length,
                          itemBuilder: (context, index) {
                            final med = _medicamentosFiltrados[index];
                            try {
                              return RepaintBoundary(
                                child: med['builder'](context),
                              );
                            } catch (e) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Card(
                                  color: Colors.red.shade50,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Erro ao carregar ${med['nome']}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red.shade700,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          mensagemErroAmigavel(e),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.red.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              _query.isEmpty
                  ? 'Nenhum medicamento disponível na farmacoteca.'
                  : 'Nenhum medicamento encontrado para "$_query".',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            if (_query.isNotEmpty) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  _searchController.clear();
                  FocusScope.of(context).unfocus();
                },
                child: const Text('Limpar busca'),
              ),
            ],
            const SizedBox(height: 24),
            const Text(
              'Quer sugerir um medicamento?',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                // Funcionalidade de email removida
                if (context.mounted) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Contato'),
                      content: const Text(
                          'Para sugestões e feedback, entre em contato através do email: brunodaroz@exemplo.com'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
              },
              child: const Text(
                'bhdaroz@gmail.com',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
