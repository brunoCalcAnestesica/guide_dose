import 'package:flutter/material.dart';
import 'storage_manager.dart';
import 'shared_data.dart';
import 'farmacoteca/medicamento_generico.dart';

class FarmacotecaPage extends StatefulWidget {
  const FarmacotecaPage({super.key});

  @override
  State<FarmacotecaPage> createState() => _FarmacotecaPageState();
}

class _FarmacotecaPageState extends State<FarmacotecaPage> {
  Set<String> favoritos = {};
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  List<Map<String, dynamic>> medicamentos = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarFavoritos();
    _carregarMedicamentos();
    _searchController.addListener(() {
      setState(() {
        _query = _searchController.text.toLowerCase();
      });
    });
  }

  Future<void> _carregarFavoritos() async {
    try {
      await StorageManager.instance.initialize();
      final favoritosList =
          StorageManager.instance.getStringList('farmacoteca_favoritos');
      setState(() {
        favoritos = favoritosList.toSet();
      });
    } catch (e) {
      setState(() {
        favoritos = {};
      });
    }
  }

  Future<void> _carregarMedicamentos() async {
    try {
      final medicamentosCarregados =
          await FarmacotecaManager.getMedicamentosParaUI();
      setState(() {
        medicamentos = medicamentosCarregados;
        _carregando = false;
      });
    } catch (e) {
      setState(() {
        _carregando = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar medicamentos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _alternarFavorito(String nomeMedicamento) async {
    try {
      await StorageManager.instance.initialize();
      final novoEstado = !favoritos.contains(nomeMedicamento);

      setState(() {
        if (novoEstado) {
          favoritos.add(nomeMedicamento);
        } else {
          favoritos.remove(nomeMedicamento);
        }
      });

      await StorageManager.instance
          .setStringList('farmacoteca_favoritos', favoritos.toList());
    } catch (e) {
      // Se houver erro, reverte a mudança
      setState(() {
        if (favoritos.contains(nomeMedicamento)) {
          favoritos.remove(nomeMedicamento);
        } else {
          favoritos.add(nomeMedicamento);
        }
      });
    }
  }

  @override
  void dispose() {
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

    // Medicamentos já carregados no initState

    // Filtrar medicamentos baseado na busca
    final medicamentosFiltrados = medicamentos
        .where((med) => med['nome'].toLowerCase().contains(_query))
        .toList();

    // Ordenar: favoritos primeiro, depois alfabético
    medicamentosFiltrados.sort((a, b) {
      final nomeA = a['nome'] as String;
      final nomeB = b['nome'] as String;
      final aFav = favoritos.contains(nomeA);
      final bFav = favoritos.contains(nomeB);

      if (aFav && !bFav) return -1;
      if (!aFav && bFav) return 1;
      return nomeA.compareTo(nomeB);
    });

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
                  : medicamentosFiltrados.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: medicamentosFiltrados.length,
                          itemBuilder: (context, index) {
                            final med = medicamentosFiltrados[index];
                            try {
                              return med['builder'](
                                  context, favoritos, _alternarFavorito);
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
                                          e.toString(),
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
