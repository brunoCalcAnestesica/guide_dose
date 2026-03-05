import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../calculos_info_page.dart';
import '../escala/database/daos/med_list_dao.dart';
import 'lista_medicamentos_model.dart';
import 'criar_editar_lista_page.dart';
import 'medicamento_card.dart';
import 'medicamento_data.dart';

const String _kIdioma = 'PT';


/// Aba Medicamentos: barra com título, botão + (criar lista) e botão que abre a lista completa.
class MedicamentoUnificadoPage extends StatefulWidget {
  const MedicamentoUnificadoPage({super.key});

  @override
  State<MedicamentoUnificadoPage> createState() => _MedicamentoUnificadoPageState();
}

class _MedicamentoUnificadoPageState extends State<MedicamentoUnificadoPage> {
  final MedListDao _medListDao = MedListDao();

  List<ListaMedicamentosCustom> _listas = [];
  bool _carregando = true;

  String? get _userId {
    try {
      return Supabase.instance.client.auth.currentUser?.id;
    } catch (_) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _recarregarListas();
  }

  Future<void> _recarregarListas() async {
    setState(() => _carregando = true);
    final uid = _userId;
    if (uid == null) {
      if (mounted) setState(() => _carregando = false);
      return;
    }
    try {
      final rows = await _medListDao.getByUser(uid);
      final listas = rows.map((r) => ListaMedicamentosCustom.fromDbRow(r)).toList();
      if (mounted) {
        setState(() {
          _listas = listas;
          _carregando = false;
        });
      }
    } catch (e) {
      debugPrint('Erro ao carregar listas: $e');
      if (mounted) setState(() => _carregando = false);
    }
  }

  void _abrirCriarLista() async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const CriarEditarListaPage(idioma: _kIdioma),
      ),
    );
    if (mounted) _recarregarListas();
  }

  void _abrirEditarLista(ListaMedicamentosCustom lista) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CriarEditarListaPage(
          listaExistente: lista,
          idioma: _kIdioma,
        ),
      ),
    );
    if (mounted) _recarregarListas();
  }

  Future<void> _excluirLista(ListaMedicamentosCustom lista) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir lista'),
        content: Text(
          'Excluir a lista "${lista.nome}"? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await _medListDao.softDelete(lista.id);
      try {
        await Supabase.instance.client
            .from('med_lists')
            .delete()
            .eq('id', lista.id)
            .eq('user_id', _userId!);
        await _medListDao.hardDelete(lista.id);
      } catch (_) {
        // Offline: stays as 'deleted', sync service will push later
      }
      if (mounted) _recarregarListas();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeaderBar(context),
        Expanded(
          child: _carregando
              ? const Center(child: CircularProgressIndicator())
              : _listas.isEmpty
                  ? _buildHint(context)
                  : _buildListaColapsavel(context),
        ),
      ],
    );
  }

  Widget _buildHint(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Toque no ícone + para criar uma lista de medicamentos e no ícone → para acessar todos os medicamentos.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListaColapsavel(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      itemCount: _listas.length,
      itemBuilder: (context, index) {
        final lista = _listas[index];
        return ExpansionTile(
          key: ValueKey(lista.id),
          title: Text(
            lista.nome,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          controlAffinity: ListTileControlAffinity.trailing,
          trailing: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 24),
            tooltip: 'Opções',
            onSelected: (value) {
              if (value == 'editar') {
                _abrirEditarLista(lista);
              } else if (value == 'excluir') {
                _excluirLista(lista);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'editar',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit_outlined, size: 22),
                    SizedBox(width: 12),
                    Text('Editar lista'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'excluir',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.delete_outline, size: 22),
                    SizedBox(width: 12),
                    Text('Excluir lista'),
                  ],
                ),
              ),
            ],
          ),
          children: [
            _ConteudoExpandidoLista(
              medicamentoIds: lista.medicamentoIds,
              idioma: _kIdioma,
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeaderBar(BuildContext context) {
    return Container(
      width: double.infinity,
      height: AppBarStyle.toolbarHeight,
      decoration: BoxDecoration(
        color: AppColors.primary,
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white, size: 26),
            tooltip: 'Criar lista de medicamentos',
            onPressed: _abrirCriarLista,
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Medicamentos',
                style: AppBarStyle.titleStyle,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.open_in_new, color: Colors.white, size: 22),
            tooltip: 'Abrir lista de medicamentos',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const CalculosInfoPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Conteúdo expandido de uma lista: carrega MedicamentoData e exibe MedicamentoCards.
class _ConteudoExpandidoLista extends StatefulWidget {
  const _ConteudoExpandidoLista({
    required this.medicamentoIds,
    required this.idioma,
  });

  final List<String> medicamentoIds;
  final String idioma;

  @override
  State<_ConteudoExpandidoLista> createState() =>
      _ConteudoExpandidoListaState();
}

class _ConteudoExpandidoListaState extends State<_ConteudoExpandidoLista> {
  late Future<List<MedicamentoData>> _medicamentosFuture;

  @override
  void initState() {
    super.initState();
    _medicamentosFuture = _carregarMedicamentos();
  }

  Future<List<MedicamentoData>> _carregarMedicamentos() async {
    final List<MedicamentoData> resultado = [];
    for (final id in widget.medicamentoIds) {
      final path = 'assets/medicamentos_dose/$id.json';
      try {
        final med = await MedicamentoData.fromAsset(path, widget.idioma);
        resultado.add(med);
      } catch (e) {
        debugPrint('Erro ao carregar $path: $e');
      }
    }
    return resultado;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MedicamentoData>>(
      future: _medicamentosFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(24.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final medicamentos = snapshot.data ?? <MedicamentoData>[];
        if (medicamentos.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              snapshot.hasError
                  ? 'Erro ao carregar medicamentos.'
                  : 'Nenhum medicamento nesta lista.',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(left: 8, right: 8, bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: medicamentos
                .map(
                  (med) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: MedicamentoCard(
                      key: ValueKey(med.id),
                      medicamento: med,
                      idioma: widget.idioma,
                      indicacaoDestacada: null,
                      termoPesquisa: null,
                    ),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }
}
