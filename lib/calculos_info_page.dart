import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'medicamento_unificado/medicamento_card.dart';
import 'medicamento_unificado/medicamento_data.dart';
import 'medicamento_unificado/medicamentos_dose_fallback.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';
import 'shared_data.dart';

/// Página de Cálculos com lista de medicamentos e campo de busca.
class CalculosInfoPage extends StatefulWidget {
  const CalculosInfoPage({super.key});

  @override
  State<CalculosInfoPage> createState() => _CalculosInfoPageState();
}

class _CalculosInfoPageState extends State<CalculosInfoPage> {
  List<MedicamentoData> _todosMedicamentos = [];
  List<ItemPesquisa> _itensFiltrados = [];
  bool _isLoading = true;
  final String _idioma = 'PT';
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _termoPesquisa = '';
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _carregarMedicamentos();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _abrirSuporteWhatsappMedicamento(String termoPesquisa) async {
    const numeroSuporte = '5511960176851';
    final mensagem = Uri.encodeComponent(
      'Olá! Gostaria de solicitar a adição do medicamento "$termoPesquisa" no app Guide Dose.',
    );
    final uri = Uri.parse('https://wa.me/$numeroSuporte?text=$mensagem');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível abrir o WhatsApp.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _carregarMedicamentos() async {
    setState(() => _isLoading = true);

    try {
      final medicamentosJson = await _listarMedicamentosDisponiveis();
      if (medicamentosJson.isEmpty) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        return;
      }
      final results = await Future.wait(
        medicamentosJson.map((path) => MedicamentoData.fromAsset(path, _idioma)
            .then<MedicamentoData?>((med) => med)
            .catchError((e) {
          debugPrint('Erro ao carregar $path: $e');
          return null;
        })),
      );
      final medicamentos = results.whereType<MedicamentoData>().toList();

      medicamentos
          .sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));

      if (!mounted) return;
      setState(() {
        _todosMedicamentos = medicamentos;
        _itensFiltrados =
            medicamentos.map((m) => ItemPesquisa(medicamento: m)).toList();
        _reordenarLista();
        _isLoading = false;
      });
    } catch (e, stack) {
      debugPrint('Erro ao carregar medicamentos: $e');
      debugPrint('$stack');
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<List<String>> _listarMedicamentosDisponiveis() async {
    List<String> medicamentos = [];

    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle)
          .timeout(const Duration(seconds: 5));
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
            await rootBundle.loadString('AssetManifest.json')
                .timeout(const Duration(seconds: 2));
        final Map<String, dynamic> manifestMap = json.decode(manifestContent);
        medicamentos = manifestMap.keys
            .where((key) =>
                key.startsWith('assets/medicamentos_dose/') &&
                key.endsWith('.json'))
            .toList();
      } catch (_) {}
    }

    final Set<String> set = medicamentos.isNotEmpty
        ? Set.from(medicamentos)
        : <String>{};
    for (final path in kMedicamentosDoseFallback) {
      set.add(path);
    }
    medicamentos = set.toList()..sort();
    return medicamentos;
  }

  void _reordenarLista() {
    _itensFiltrados.sort((a, b) {
      return a.medicamento.nome
          .toLowerCase()
          .compareTo(b.medicamento.nome.toLowerCase());
    });
  }

  void _filtrarMedicamentos(String termo) {
    setState(() {
      _termoPesquisa = termo;

      if (termo.isEmpty) {
        _itensFiltrados = _todosMedicamentos
            .map((m) => ItemPesquisa(medicamento: m))
            .toList();
        _reordenarLista();
        return;
      }

      final termoLower = _removerAcentos(termo.toLowerCase());
      final List<ItemPesquisa> resultados = [];
      final Map<String, ItemPesquisa> porMedicamento = {};

      for (final med in _todosMedicamentos) {
        final nomeLower = _removerAcentos(med.nome.toLowerCase());
        final classeLower = _removerAcentos(med.classe.toLowerCase());

        String? indicacaoDestacada;
        for (final indicacao in med.indicacoes) {
          final tituloLower = _removerAcentos(indicacao.titulo.toLowerCase());
          final descLower =
              _removerAcentos(indicacao.descricaoDose.toLowerCase());

          if (tituloLower.contains(termoLower) ||
              descLower.contains(termoLower)) {
            indicacaoDestacada = indicacao.titulo;
            break;
          }
        }

        final nomeOuClasseMatch = nomeLower.contains(termoLower) ||
            classeLower.contains(termoLower);

        if (nomeOuClasseMatch || indicacaoDestacada != null) {
          if (!porMedicamento.containsKey(med.id)) {
            porMedicamento[med.id] = ItemPesquisa(
              medicamento: med,
              indicacaoDestacada: indicacaoDestacada,
            );
          } else if (indicacaoDestacada != null &&
              porMedicamento[med.id]!.indicacaoDestacada == null) {
            porMedicamento[med.id] = ItemPesquisa(
              medicamento: med,
              indicacaoDestacada: indicacaoDestacada,
            );
          }
        }
      }
      resultados.addAll(porMedicamento.values);

      resultados.sort((a, b) {
        final nomeA = a.medicamento.nome.toLowerCase();
        final nomeB = b.medicamento.nome.toLowerCase();
        final cmpNome = nomeA.compareTo(nomeB);
        if (cmpNome != 0) return cmpNome;
        if (a.indicacaoDestacada == null) return -1;
        if (b.indicacaoDestacada == null) return 1;
        return a.indicacaoDestacada!.compareTo(b.indicacaoDestacada!);
      });

      _itensFiltrados = resultados;
    });
  }

  List<ItemPesquisa> get _itensExibiveis {
    final faixa = SharedData.faixaEtaria;
    // Quando faixa etária não está definida ('-'), mostrar todos os medicamentos
    if (faixa == '-') {
      return _itensFiltrados;
    }
    final isAdulto = faixa == 'Adulto' || faixa == 'Idoso';
    return _itensFiltrados
        .where((item) =>
            item.medicamento.temConteudoParaFaixaEtaria(isAdulto))
        .toList();
  }

  String _removerAcentos(String texto) {
    const comAcento = 'àáâãäåèéêëìíîïòóôõöùúûüýÿñçÀÁÂÃÄÅÈÉÊËÌÍÎÏÒÓÔÕÖÙÚÛÜÝŸÑÇ';
    const semAcento = 'aaaaaaeeeeiiiioooooouuuuyyncAAAAAAEEEEIIIIOOOOOUUUUYYNC';
    for (int i = 0; i < comAcento.length; i++) {
      texto = texto.replaceAll(comAcento[i], semAcento[i]);
    }
    return texto;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todos os Medicamentos'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
          hintText: 'Pesquisar medicamento ou indicação...',
          hintStyle: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade500,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.grey.shade600,
            size: 22,
          ),
          suffixIcon: _termoPesquisa.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: Colors.grey.shade600,
                    size: 20,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    _filtrarMedicamentos('');
                    _searchFocusNode.unfocus();
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.grey.shade100,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
        style: TextStyle(fontSize: 15, color: Colors.black87),
        onChanged: (termo) {
          _searchDebounce?.cancel();
          _searchDebounce = Timer(const Duration(milliseconds: 300), () {
            if (mounted) _filtrarMedicamentos(termo);
          });
        },
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_todosMedicamentos.isEmpty) {
      return const Center(
        child: Text('Nenhum medicamento disponível'),
      );
    }

    if (_itensExibiveis.isEmpty && _termoPesquisa.isEmpty) {
      return const Center(
        child: Text('Nenhum medicamento para a faixa etária selecionada'),
      );
    }

    if (_itensExibiveis.isEmpty && _termoPesquisa.isNotEmpty) {
      final theme = Theme.of(context);
      final textTheme = theme.textTheme;
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: AppRadius.card,
                ),
                child: Icon(
                  Icons.search_off,
                  size: 48,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.sectionSpacing),
              Text(
                'Nenhum resultado para "$_termoPesquisa"',
                textAlign: TextAlign.center,
                style: textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Tente outro termo ou solicite a adição do medicamento pelo suporte.',
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: AppSpacing.sectionSpacing),
              ElevatedButton.icon(
                onPressed: () => _abrirSuporteWhatsappMedicamento(_termoPesquisa),
                icon: const Icon(Icons.chat_outlined, size: 20),
                label: const Text('Abrir suporte no WhatsApp'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _itensExibiveis.length,
      itemBuilder: (context, index) {
        final item = _itensExibiveis[index];
        return RepaintBoundary(
          child: MedicamentoCard(
            key: ValueKey(
                '${item.medicamento.id}_${item.indicacaoDestacada ?? "all"}'),
            medicamento: item.medicamento,
            idioma: _idioma,
            indicacaoDestacada: item.indicacaoDestacada,
            termoPesquisa: _termoPesquisa,
          ),
        );
      },
    );
  }
}
