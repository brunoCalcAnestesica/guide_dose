import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../escala/database/daos/med_list_dao.dart';
import 'lista_medicamentos_model.dart';
import 'selecionar_medicamentos_page.dart';

/// Página para criar ou editar uma lista personalizada de medicamentos.
class CriarEditarListaPage extends StatefulWidget {
  const CriarEditarListaPage({
    super.key,
    this.listaExistente,
    this.idioma = 'PT',
  });

  /// Se null, modo criar; caso contrário, modo editar.
  final ListaMedicamentosCustom? listaExistente;

  final String idioma;

  @override
  State<CriarEditarListaPage> createState() => _CriarEditarListaPageState();
}

class _CriarEditarListaPageState extends State<CriarEditarListaPage> {
  final MedListDao _medListDao = MedListDao();
  late final TextEditingController _nomeController;
  List<String> _medicamentoIds = [];
  bool _salvando = false;

  bool get _isEdicao => widget.listaExistente != null;

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
    _nomeController = TextEditingController(
      text: widget.listaExistente?.nome ?? '',
    );
    _medicamentoIds = List.from(widget.listaExistente?.medicamentoIds ?? []);
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  Future<void> _abrirSelecao() async {
    final result = await Navigator.of(context).push<List<String>>(
      MaterialPageRoute(
        builder: (_) => SelecionarMedicamentosPage(
          selecionadosAtuais: _medicamentoIds.toSet(),
          idioma: widget.idioma,
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() => _medicamentoIds = result);
    }
  }

  void _removerMedicamento(String id) {
    setState(() => _medicamentoIds.remove(id));
  }

  Future<void> _salvar() async {
    final nome = _nomeController.text.trim();
    if (nome.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe um nome para a lista')),
      );
      return;
    }

    final uid = _userId;
    if (uid == null) return;

    setState(() => _salvando = true);
    try {
      if (_isEdicao) {
        final atualizada = widget.listaExistente!.copyWith(
          nome: nome,
          medicamentoIds: _medicamentoIds,
          updatedAt: DateTime.now(),
        );
        await _medListDao.insert(atualizada.toDbRow(uid));
        _pushToSupabase(atualizada, uid);
        if (!mounted) return;
        Navigator.of(context).pop(atualizada);
      } else {
        final now = DateTime.now();
        final nova = ListaMedicamentosCustom(
          id: 'lista_${now.millisecondsSinceEpoch}',
          nome: nome,
          medicamentoIds: List.from(_medicamentoIds),
          createdAt: now,
          updatedAt: now,
        );
        await _medListDao.insert(nova.toDbRow(uid));
        _pushToSupabase(nova, uid);
        if (!mounted) return;
        Navigator.of(context).pop(true);
      }
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  void _pushToSupabase(ListaMedicamentosCustom lista, String uid) async {
    try {
      await Supabase.instance.client
          .from('med_lists')
          .upsert(lista.toSupabaseRow(uid), onConflict: 'id,user_id');
      await _medListDao.markSynced(lista.id);
    } catch (_) {
      // Offline: stays as 'pending', sync service will push on next startup
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdicao ? 'Editar lista' : 'Nova lista'),
        actions: [
          if (_salvando)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _salvar,
              child: const Text('Salvar'),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                TextField(
                  controller: _nomeController,
                  decoration: const InputDecoration(
                    labelText: 'Nome da lista',
                    hintText: 'Ex: Emergência, UTI',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Text(
                      'Medicamentos (${_medicamentoIds.length})',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton.icon(
                          onPressed: _abrirSelecao,
                          icon: const Icon(Icons.add, size: 20),
                          label: const Text(
                            'Selecionar',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_medicamentoIds.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      'Nenhum medicamento selecionado. Toque em "Selecionar medicamentos" para adicionar.',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _medicamentoIds.map((id) {
                      final label = id
                          .split('_')
                          .map((s) => s.isEmpty
                              ? s
                              : s[0].toUpperCase() + s.substring(1).toLowerCase())
                          .join(' ');
                      return Chip(
                        label: Text(label),
                        onDeleted: () => _removerMedicamento(id),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _salvando ? null : _salvar,
                  child: _salvando
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_isEdicao ? 'Salvar alterações' : 'Criar lista'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
