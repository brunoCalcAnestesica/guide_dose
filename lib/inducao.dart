import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'theme/app_theme.dart';
import 'storage_manager.dart';

import 'shared_data.dart';
import 'condicao_clinica_page.dart';

class InducaoPage extends StatefulWidget {
  const InducaoPage({super.key});

  @override
  State<InducaoPage> createState() => _InducaoPageState();
}

class _InducaoPageState extends State<InducaoPage> {
  Map<String, dynamic> inducoes = {};
  List<MapEntry<String, dynamic>> filtradas = [];
  Set<String> favoritos = {};
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    carregarDados();
    carregarFavoritos();
    _searchController.addListener(_filtrarSituacoes);
  }

  Future<void> carregarDados() async {
    final String data =
        await rootBundle.loadString('assets/data/inducoes.json');
    final Map<String, dynamic> jsonMap = json.decode(data);
    setState(() {
      inducoes = jsonMap;
      _ordenarFiltradas();
    });
  }

  Future<void> carregarFavoritos() async {
    try {
      await StorageManager.instance.initialize();
      setState(() {
        favoritos =
            StorageManager.instance.getStringList('favoritos_inducao').toSet();
        _ordenarFiltradas();
      });
    } catch (e) {
      setState(() {
        favoritos = {};
        _ordenarFiltradas();
      });
    }
  }

  Future<void> salvarFavoritos() async {
    try {
      await StorageManager.instance.initialize();
      await StorageManager.instance
          .setStringList('favoritos_inducao', favoritos.toList());

    } catch (e) {
      // Se houver erro, continua sem salvar
      debugPrint('Erro ao salvar favoritos: $e');
    }
  }

  void alternarFavorito(String key) async {
    setState(() {
      if (favoritos.contains(key)) {
        favoritos.remove(key);
      } else {
        favoritos.add(key);
      }
      _ordenarFiltradas();
    });
    await salvarFavoritos();
  }

  void _filtrarSituacoes() {
    final query = _searchController.text.toLowerCase();
    final todos = inducoes.entries.toList();

    setState(() {
      filtradas = todos
          .where((entry) => entry.value['titulo'].toLowerCase().contains(query))
          .toList();

      filtradas.sort((a, b) {
        final aFav = favoritos.contains(a.key) ? 0 : 1;
        final bFav = favoritos.contains(b.key) ? 0 : 1;
        if (aFav != bFav) {
          return aFav.compareTo(bFav);
        } else {
          return a.value['titulo']
              .toLowerCase()
              .compareTo(b.value['titulo'].toLowerCase());
        }
      });
    });
  }

  void _ordenarFiltradas() {
    filtradas = inducoes.entries.toList();

    filtradas.sort((a, b) {
      final aFav = favoritos.contains(a.key) ? 0 : 1;
      final bFav = favoritos.contains(b.key) ? 0 : 1;
      if (aFav != bFav) {
        return aFav.compareTo(bFav);
      } else {
        return a.value['titulo']
            .toLowerCase()
            .compareTo(b.value['titulo'].toLowerCase());
      }
    });
  }

  void _abrirDetalhes(String arquivoJson) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CondicaoClinicaPage(arquivoJson: arquivoJson),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final peso = SharedData.peso ?? 70;

    return Scaffold(
      appBar: AppBar(title: const Text('Dose de Indução')),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.only(bottom: 12),
          itemCount: filtradas.isEmpty ? 2 : filtradas.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screenPadding, AppSpacing.md, AppSpacing.screenPadding, AppSpacing.xs),
                    child: SizedBox(
                      width: double.infinity,
                      child: TextField(
                        controller: _searchController,
                        style: TextStyle(
                            fontSize: 15,
                            color: Theme.of(context).colorScheme.onSurface),
                        decoration: InputDecoration(
                          labelText: 'Pesquisa',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.5),
                          border: OutlineInputBorder(
                            borderRadius: AppRadius.card,
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: AppRadius.card,
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: AppRadius.card,
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 1.2,
                            ),
                          ),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: AppSpacing.md),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              );
            }

            if (filtradas.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: _buildEmptyState(),
              );
            }

            final itemIndex = index - 1;
            final key = filtradas[itemIndex].key;
            final dados = filtradas[itemIndex].value;
            final List medicamentos = dados['medicamentos'];

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Card(
                margin: const EdgeInsets.symmetric(vertical: 5),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.cardPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => _abrirDetalhes(key),
                              child: Text(
                                dados['titulo'],
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Cabeçalho da tabela
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 6,
                              child: Text(
                                'Medicamento',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Text(
                                'Dose / Volume',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Linhas dos medicamentos
                      ...medicamentos.map((med) {
                        final nome = med['nome'];
                        final doseMg = med['dose_mg_kg'] * peso;
                        final concentracao = _obterConcentracao(nome);
                        final doseMl =
                            concentracao > 0 ? doseMg / concentracao : 0.0;
                        final nomeComConcentracao = concentracao > 0
                            ? '$nome (${concentracao.toStringAsFixed(1)} mg/mL)'
                            : nome;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 6,
                                child: Text(
                                  nomeComConcentracao,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: Text(
                                  '${doseMg.toStringAsFixed(2)} mg / ${doseMl > 0 ? doseMl.toStringAsFixed(1) : '-'} mL',
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Nenhuma condição encontrada.',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 12),
          const Text('Ajude-nos a melhorar:', style: TextStyle(fontSize: 14)),
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
    );
  }

  double _obterConcentracao(String nomeMedicamento) {
    // Mapeamento de concentrações dos medicamentos (mg/mL)
    final Map<String, double> concentracoes = {
      'Fentanil': 0.05, // 50 mcg/mL = 0.05 mg/mL
      'Etomidato': 2.0, // 2 mg/mL
      'Quetamina': 50.0, // 50 mg/mL
      'Midazolam': 5.0, // 5 mg/mL
      'Rocurônio': 10.0, // 10 mg/mL
      'Succinilcolina': 20.0, // 20 mg/mL
      'Propofol': 10.0, // 10 mg/mL
      'Tiopental': 25.0, // 25 mg/mL
      'Cisatracúrio': 2.0, // 2 mg/mL
      'Vecurônio': 4.0, // 4 mg/mL
      'Atracúrio': 10.0, // 10 mg/mL
      'Mivacúrio': 2.0, // 2 mg/mL
      'Diazepam': 5.0, // 5 mg/mL
      'Lorazepam': 2.0, // 2 mg/mL
      'Flumazenil': 0.1, // 0.1 mg/mL
      'Naloxona': 0.4, // 0.4 mg/mL
      'Sugamadex': 100.0, // 100 mg/mL
      'Protamina': 10.0, // 10 mg/mL
      'Dantroleno': 0.333, // 0.333 mg/mL (20mg/60mL)
      'Hidroxicobalamina': 2.5, // 2.5 mg/mL
      'Neostigmina': 0.5, // 0.5 mg/mL
      'Adrenalina': 1, // 1 mg/mL
    };

    return concentracoes[nomeMedicamento] ?? 0.0;
  }
}
