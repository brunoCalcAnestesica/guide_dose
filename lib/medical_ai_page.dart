import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/openai_config.dart';
import 'config/supabase_config.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'escala/models/patient.dart';
import 'escala/providers/note_provider.dart';
import 'escala/providers/patient_provider.dart';
import 'escala/services/supabase_sync_service.dart';
import 'services/openai_service.dart';
import 'services/pdf_document_service.dart';
import 'services/chat_pdf_service.dart';
import 'services/image_service.dart';
import 'theme/app_colors.dart';
import 'utils/error_messages.dart';

class _ProfessionalContext {
  const _ProfessionalContext({
    required this.context,
    required this.hasCrm,
  });

  final String context;
  final bool hasCrm;
}

class _SendMessageIntent extends Intent {
  const _SendMessageIntent();
}

class _NewLineIntent extends Intent {
  const _NewLineIntent();
}

class MedicalAIPage extends StatefulWidget {
  const MedicalAIPage({super.key});

  @override
  State<MedicalAIPage> createState() => _MedicalAIPageState();
}

class _MedicalAIPageState extends State<MedicalAIPage> {
  static const _messagesKey = 'medical_ai_messages';
  static const _patientContextKey = 'medical_ai_patient_context';
  static const _responseModeKey = 'medical_ai_response_mode';
  static final _pdfTitleRegex = RegExp(r'^\[PDF:(.+?)\]');

  static const _suggestionPhrases = [
    'Me encaminhe o exame para eu dar uma olhada.',
    'Qual dose adequada para este paciente?',
    'Interações medicamentosas deste esquema?',
    'Resumo para alta hospitalar.',
  ];

  late final OpenAIService _service;
  late final PdfDocumentService _pdfService;
  late final ChatPdfService _chatPdfService;
  late final ImageService _imageService;
  final _messages = <ChatMessage>[];
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  final _inputFocusNode = FocusNode();
  bool _isLoading = true;
  bool _isSending = false;
  bool _isProcessingDocument = false;
  bool _isGeneratingPdf = false;
  ResponseMode _responseMode = ResponseMode.precise;
  SharedPreferences? _prefs;
  double _lastBottomInset = 0;
  
  // Estado de edição
  bool _isEditing = false;
  List<ChatMessage> _editBackup = [];
  String _originalInputText = '';

  // Imagem pendente para envio
  ImagePickResult? _pendingImage;

  @override
  void initState() {
    super.initState();
    _service = OpenAIService();
    _pdfService = PdfDocumentService();
    _chatPdfService = ChatPdfService();
    _imageService = ImageService();
    
    // Listener para scroll quando o campo de texto recebe foco
    _inputFocusNode.addListener(_onFocusChange);
    
    // Carrega dados após o primeiro frame para não travar a transição
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  void _onFocusChange() {
    if (_inputFocusNode.hasFocus && _messages.isNotEmpty) {
      // Pequeno delay para esperar o teclado abrir
      Future.delayed(const Duration(milliseconds: 300), () {
        _scrollToBottom();
      });
    } else if (!_inputFocusNode.hasFocus && _isEditing) {
      // Usuário tocou fora enquanto editava - cancelar edição
      _cancelEdit();
    }
  }

  Future<void> _initializeData() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadResponseMode();
    await _loadMessages();
    if (mounted) {
      setState(() => _isLoading = false);
      // Scroll para o final após o estado atualizar e renderizar
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_messages.isNotEmpty) {
          _scrollToBottom(animated: false);
        }
      });
    }
  }

  Future<void> _loadResponseMode() async {
    final modeIndex = _prefs?.getInt(_responseModeKey) ?? 0;
    _responseMode = ResponseMode.values[modeIndex];
  }

  Future<void> _saveResponseMode(ResponseMode mode) async {
    _prefs?.setInt(_responseModeKey, mode.index);
  }

  @override
  void dispose() {
    _inputFocusNode.removeListener(_onFocusChange);
    _inputController.dispose();
    _scrollController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Detecta mudanças no teclado via MediaQuery
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    if (bottomInset > _lastBottomInset && _messages.isNotEmpty) {
      // Teclado abriu - scroll para o final
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
    _lastBottomInset = bottomInset;
  }

  void _insertNewLine() {
    final text = _inputController.text;
    final selection = _inputController.selection;
    final newText = text.replaceRange(
      selection.start,
      selection.end,
      '\n',
    );
    _inputController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: selection.start + 1),
    );
  }

  String _buildPatientContextKey() {
    return 'static_context';
  }

  String _formatDate(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final year = value.year.toString();
    return '$day/$month/$year';
  }

  String? _extractString(dynamic value) {
    if (value is String) return value;
    return null;
  }

  bool _extractBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true';
    }
    if (value is num) {
      return value != 0;
    }
    return false;
  }

  /// Consome o stream de resposta da IA, atualizando a última mensagem
  /// incrementalmente. Retorna o texto completo ao final.
  Future<String> _consumeStream(Stream<String> stream) async {
    final buffer = StringBuffer();
    await for (final chunk in stream) {
      buffer.write(chunk);
      if (!mounted) return buffer.toString();
      setState(() {
        if (_messages.isNotEmpty && _messages.last.role == 'assistant') {
          _messages[_messages.length - 1] =
              ChatMessage(role: 'assistant', content: buffer.toString());
        }
      });
      _scrollToBottom();
    }
    return buffer.toString();
  }

  /// Contexto do profissional sem leitura de banco de dados.
  /// Usa apenas dados já disponíveis no app (ex.: metadados do auth em memória).
  Future<_ProfessionalContext> _buildProfessionalContext() async {
    final today = _formatDate(DateTime.now());
    if (!SupabaseConfig.isConfigured) {
      return _ProfessionalContext(
        context:
            'Dados do profissional do app: Nome: Nao informado; CRM: Nao informado. '
            'Data atual: $today.',
        hasCrm: false,
      );
    }
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      return _ProfessionalContext(
        context:
            'Dados do profissional do app: Nome: Nao informado; CRM: Nao informado. '
            'Data atual: $today.',
        hasCrm: false,
      );
    }

    final metadata = user.userMetadata ?? {};
    final nome =
        _extractString(metadata['full_name']) ?? _extractString(metadata['name']);
    final crm = _extractString(metadata['crm']);
    final crmNaoFormado = _extractBool(metadata['crm_nao_formado']);
    final especialidade = _extractString(metadata['specialty']);

    final nomeFinal =
        (nome != null && nome.trim().isNotEmpty) ? nome.trim() : 'Nao informado';
    final hasCrm = !crmNaoFormado && (crm != null && crm.trim().isNotEmpty);
    final crmFinal = crmNaoFormado
        ? 'Nao informado (nao formado)'
        : ((crm == null || crm.trim().isEmpty) ? 'Nao informado' : crm.trim());
    final especialidadeFinal = (especialidade != null && especialidade.trim().isNotEmpty)
        ? especialidade.trim()
        : null;

    final contextParts = <String>[
      'Dados do profissional do app: Nome: $nomeFinal; CRM: $crmFinal.',
      if (especialidadeFinal != null) ' Especialidade: $especialidadeFinal.',
      ' Data atual: $today.',
    ];

    return _ProfessionalContext(
      context: contextParts.join(),
      hasCrm: hasCrm,
    );
  }

  static const int _maxNotesInContext = 20;
  static const int _maxPatientsInContext = 30;
  static const int _maxFieldChars = 400;

  String _truncate(String text, int maxLen) {
    if (text.length <= maxLen) return text;
    return '${text.substring(0, maxLen)}…';
  }

  String _buildAnnotationsContext() {
    final noteProvider = context.read<NoteProvider>();
    final patientProvider = context.read<PatientProvider>();
    final notes = noteProvider.items;
    final patients = patientProvider.items;

    if (notes.isEmpty && patients.isEmpty) {
      return 'Anotações do médico: Nenhuma nota ou paciente ativo no momento.';
    }

    final buf = StringBuffer();
    buf.writeln('ANOTAÇÕES DO MÉDICO (apenas itens ativos, banco local):');

    if (notes.isNotEmpty) {
      buf.writeln('\n--- NOTAS ---');
      final subset = notes.take(_maxNotesInContext);
      for (final n in subset) {
        buf.writeln('[${n.id}] ${n.title}: ${_truncate(n.content, _maxFieldChars)}');
      }
      if (notes.length > _maxNotesInContext) {
        buf.writeln('(... e mais ${notes.length - _maxNotesInContext} notas)');
      }
    }

    if (patients.isNotEmpty) {
      buf.writeln('\n--- PACIENTES ---');
      final subset = patients.take(_maxPatientsInContext);
      for (final p in subset) {
        buf.write('[${p.id}] ${p.initials}');
        if (p.bed.isNotEmpty) buf.write(' | Leito: ${p.bed}');
        if (p.age != null) buf.write(' | ${p.ageDisplay}');
        if (p.admissionDate != null) {
          buf.write(' | DIH: ${p.admissionDate!.toIso8601String().substring(0, 10)} (${p.admissionDays ?? "-"}º dia)');
        }
        if (p.diagnosis.isNotEmpty) buf.write(' | Diag: ${_truncate(p.diagnosis, 200)}');
        if (p.history.isNotEmpty) buf.write(' | Antec: ${_truncate(p.history, 200)}');
        if (p.devices.isNotEmpty) buf.write(' | Disp: ${_truncate(p.devices, 200)}');
        if (p.antibiotics.isNotEmpty) buf.write(' | ATB: ${_truncate(p.antibiotics, 200)}');
        if (p.vasoactiveDrugs.isNotEmpty) buf.write(' | DVA: ${_truncate(p.vasoactiveDrugs, 200)}');
        if (p.exams.isNotEmpty) buf.write(' | Exames: ${_truncate(p.exams, 200)}');
        if (p.pending.isNotEmpty) buf.write(' | Pend: ${_truncate(p.pending, 200)}');
        if (p.observations.isNotEmpty) buf.write(' | Obs: ${_truncate(p.observations, 200)}');
        buf.writeln();
      }
      if (patients.length > _maxPatientsInContext) {
        buf.writeln('(... e mais ${patients.length - _maxPatientsInContext} pacientes)');
      }
    }

    return buf.toString().trim();
  }

  static final _appActionRegex = RegExp(
    r'\[APP_ACTION\](.*?)\[/APP_ACTION\]',
    dotAll: true,
  );

  String _stripAppAction(String reply) {
    return reply.replaceAll(_appActionRegex, '').trim();
  }

  Future<String?> _executeAppAction(String reply) async {
    final match = _appActionRegex.firstMatch(reply);
    if (match == null) return null;

    final jsonStr = match.group(1)?.trim();
    if (jsonStr == null || jsonStr.isEmpty) return null;

    try {
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      final action = data['action'] as String? ?? '';

      switch (action) {
        case 'create_note':
          final title = data['title'] as String? ?? 'Sem título';
          final content = data['content'] as String? ?? '';
          await context.read<NoteProvider>().add(title, content);
          return 'Nota "$title" criada.';

        case 'update_note':
          final id = data['id'] as String?;
          if (id == null) return 'Erro: ID da nota não informado.';
          final noteProvider = context.read<NoteProvider>();
          final existing = noteProvider.items.where((n) => n.id == id).toList();
          if (existing.isEmpty) return 'Erro: nota "$id" não encontrada.';
          final note = existing.first;
          if (data.containsKey('title')) note.title = data['title'] as String;
          if (data.containsKey('content')) note.content = data['content'] as String;
          await noteProvider.update(note);
          return 'Nota "${note.title}" atualizada.';

        case 'delete_note':
          final id = data['id'] as String?;
          if (id == null) return 'Erro: ID da nota não informado.';
          await context.read<NoteProvider>().delete(id);
          return 'Nota removida.';

        case 'add_patient':
          final now = DateTime.now();
          final patient = Patient(
            id: 'patient_${now.millisecondsSinceEpoch}',
            initials: data['initials'] as String? ?? '',
            age: (data['age'] as num?)?.toDouble(),
            ageUnit: data['age_unit'] as String? ?? 'anos',
            admissionDate: data['admission_date'] != null
                ? DateTime.tryParse(data['admission_date'] as String)
                : null,
            bed: data['bed'] as String? ?? '',
            history: data['history'] as String? ?? '',
            devices: data['devices'] as String? ?? '',
            diagnosis: data['diagnosis'] as String? ?? '',
            antibiotics: data['antibiotics'] as String? ?? '',
            vasoactiveDrugs: data['vasoactive_drugs'] as String? ?? '',
            exams: data['exams'] as String? ?? '',
            pending: data['pending'] as String? ?? '',
            observations: data['observations'] as String? ?? '',
            createdAt: now,
            updatedAt: now,
          );
          await context.read<PatientProvider>().add(patient);
          return 'Paciente "${patient.initials}" adicionado.';

        case 'update_patient':
          final id = data['id'] as String?;
          if (id == null) return 'Erro: ID do paciente não informado.';
          final patientProvider = context.read<PatientProvider>();
          final existing = patientProvider.items.where((p) => p.id == id).toList();
          if (existing.isEmpty) return 'Erro: paciente "$id" não encontrado.';
          final p = existing.first;
          if (data.containsKey('initials')) p.initials = data['initials'] as String;
          if (data.containsKey('age')) p.age = (data['age'] as num?)?.toDouble();
          if (data.containsKey('age_unit')) p.ageUnit = data['age_unit'] as String;
          if (data.containsKey('admission_date')) {
            p.admissionDate = DateTime.tryParse(data['admission_date'] as String? ?? '');
          }
          if (data.containsKey('bed')) p.bed = data['bed'] as String;
          if (data.containsKey('history')) p.history = data['history'] as String;
          if (data.containsKey('devices')) p.devices = data['devices'] as String;
          if (data.containsKey('diagnosis')) p.diagnosis = data['diagnosis'] as String;
          if (data.containsKey('antibiotics')) p.antibiotics = data['antibiotics'] as String;
          if (data.containsKey('vasoactive_drugs')) p.vasoactiveDrugs = data['vasoactive_drugs'] as String;
          if (data.containsKey('exams')) p.exams = data['exams'] as String;
          if (data.containsKey('pending')) p.pending = data['pending'] as String;
          if (data.containsKey('observations')) p.observations = data['observations'] as String;
          await patientProvider.update(p);
          return 'Paciente "${p.initials}" atualizado.';

        case 'delete_patient':
          final id = data['id'] as String?;
          if (id == null) return 'Erro: ID do paciente não informado.';
          await context.read<PatientProvider>().delete(id);
          return 'Paciente removido.';

        default:
          debugPrint('APP_ACTION desconhecida: $action');
          return null;
      }
    } catch (e) {
      debugPrint('Erro ao processar APP_ACTION: $e');
      return 'Erro ao executar ação: ${mensagemErroAmigavel(e)}';
    }
  }

  Future<String> _processReply(String reply) async {
    if (!_appActionRegex.hasMatch(reply)) return reply;
    if (!mounted) return _stripAppAction(reply);

    final feedback = await _executeAppAction(reply);
    final cleanReply = _stripAppAction(reply);

    if (feedback != null && feedback.isNotEmpty) {
      _showSnack(feedback);
      _syncAfterAiAction();
    }

    return cleanReply;
  }

  Future<void> _syncAfterAiAction() async {
    try {
      final syncService = SupabaseSyncService();
      if (!syncService.isAvailable) return;
      await syncService.pushPendingChanges();
    } catch (e) {
      debugPrint('Sync após ação da IA falhou: $e');
    }
  }

  Future<void> _loadMessages() async {
    final prefs = _prefs;
    if (prefs == null) return;
    
    final savedContext = prefs.getString(_patientContextKey) ?? '';
    final currentContext = _buildPatientContextKey();

    // Se os dados do paciente mudaram, limpa a conversa
    if (savedContext != currentContext) {
      await _clearSavedMessages();
      prefs.setString(_patientContextKey, currentContext);
      return;
    }

    final savedMessages = prefs.getStringList(_messagesKey) ?? [];
    if (savedMessages.isNotEmpty) {
      _messages.clear();
      for (final json in savedMessages) {
        try {
          final map = jsonDecode(json) as Map<String, dynamic>;
          _messages.add(ChatMessage.fromJson(map));
        } catch (_) {}
      }
    }
  }

  Future<void> _saveMessages() async {
    final prefs = _prefs;
    if (prefs == null) return;
    
    final jsonList = _messages
        .map((m) => jsonEncode(m.toJson()))
        .toList();
    prefs.setStringList(_messagesKey, jsonList);
    prefs.setString(_patientContextKey, _buildPatientContextKey());
  }

  Future<void> _clearSavedMessages() async {
    _prefs?.remove(_messagesKey);
  }

  Future<void> _resetConversation() async {
    HapticFeedback.lightImpact();
    final confirm = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Fechar',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 250),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Reiniciar conversa'),
        content: const Text('Deseja apagar todo o histórico da conversa?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _clearSavedMessages();
      setState(() => _messages.clear());
      _showSnack('Conversa reiniciada.');
    }
  }

  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    final hasImage = _pendingImage != null;
    if (text.isEmpty && !hasImage) return;
    if (_isProcessingDocument) return;
    if (_isSending) {
      _showSnack('Aguarde a resposta atual.');
      return;
    }
    if (OpenAIConfig.usesProxy && !OpenAIConfig.hasProxyKey) {
      _showSnack(
        'Defina SUPABASE_ANON_KEY no .env para usar o proxy.',
      );
      return;
    }
    if (!OpenAIConfig.usesProxy && !OpenAIConfig.hasApiKey) {
      _showSnack(
        'Defina OPENAI_API_KEY via --dart-define ou configure o proxy.',
      );
      return;
    }
    if (OpenAIConfig.apiUrl.trim().isEmpty) {
      _showSnack(
        'Defina OPENAI_API_URL no .env (ex.: https://api.openai.com/v1/chat/completions ou URL do proxy).',
      );
      return;
    }

    // Captura e limpa a imagem pendente antes de qualquer await
    final imageData = _pendingImage;
    final imageBase64 = imageData?.base64DataUrl;

    // Fecha o teclado e feedback tátil
    FocusScope.of(context).unfocus();
    HapticFeedback.lightImpact();

    // Se estava editando, confirma a edição
    if (_isEditing) {
      _confirmEdit();
    }

    final displayText = hasImage && text.isEmpty
        ? '📷 Imagem enviada para análise'
        : text;

    // Histórico sem a mensagem atual (o serviço adiciona a mensagem do usuário ao final)
    final history = _messages.take(12).toList();
    setState(() {
      _messages.add(ChatMessage(
        role: 'user',
        content: displayText,
        hasImage: hasImage,
        imageBase64: imageBase64,
      ));
      _inputController.clear();
      _pendingImage = null;
      _isSending = true;
    });
    _scrollToBottom();

    final messageText = hasImage && text.isEmpty
        ? 'Analise esta imagem de exame médico. Identifique o tipo de exame, destaque valores alterados e forneça uma análise clínica.'
        : text;

    try {
      final professionalContext = await _buildProfessionalContext();
      final annotationsCtx = _buildAnnotationsContext();
      final fullExtraContext =
          '${professionalContext.context}\n\n$annotationsCtx';

      String reply;
      if (OpenAIConfig.usesProxy) {
        reply = await _service.sendMessageWithExtraContext(
          message: messageText,
          history: history,
          extraContext: fullExtraContext,
          mode: _responseMode,
          imageBase64: imageBase64,
        );
        if (!mounted) return;
        setState(() {
          _messages.add(ChatMessage(role: 'assistant', content: reply));
        });
      } else {
        setState(() {
          _messages.add(ChatMessage(role: 'assistant', content: ''));
        });
        _scrollToBottom();
        try {
          reply = await _consumeStream(
            _service.sendMessageWithExtraContextStream(
              message: messageText,
              history: history,
              extraContext: fullExtraContext,
              mode: _responseMode,
              imageBase64: imageBase64,
            ),
          );
        } catch (_) {
          setState(() => _messages.removeLast());
          if (!mounted) return;
          reply = await _service.sendMessageWithExtraContext(
            message: messageText,
            history: history,
            extraContext: fullExtraContext,
            mode: _responseMode,
            imageBase64: imageBase64,
          );
          if (!mounted) return;
          setState(() {
            _messages.add(ChatMessage(role: 'assistant', content: reply));
          });
        }
      }

      if (!mounted) return;
      HapticFeedback.mediumImpact();

      reply = await _processReply(reply);

      final pdfMatch = _pdfTitleRegex.firstMatch(reply);
      if (pdfMatch != null) {
        final pdfTitle = pdfMatch.group(1)?.trim() ?? 'Documento';
        final pdfContent = reply.substring(pdfMatch.end).trim();
        final displayContent = '📄 **$pdfTitle**\n\n$pdfContent';
        setState(() {
          _messages[_messages.length - 1] = ChatMessage(
            role: 'assistant',
            content: displayContent,
            isPdf: true,
            pdfTitle: pdfTitle,
            pdfContent: pdfContent,
          );
        });
        _scrollToBottom();
        await _saveMessages();
        _showPdfGenerationDialog(pdfTitle, pdfContent);
      } else {
        setState(() {
          _messages[_messages.length - 1] = ChatMessage(role: 'assistant', content: reply);
        });
        _scrollToBottom();
        await _saveMessages();
      }
    } catch (error) {
      if (!mounted) return;
      final userMsg = mensagemErroAmigavel(error);
      _showSnack(userMsg);
      setState(() {
        _messages.add(ChatMessage(
          role: 'assistant',
          content: '⚠️ $userMsg',
        ));
      });
      _scrollToBottom();
      await _saveMessages();
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  void _showPdfGenerationDialog(String title, String content) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Fechar',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 250),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.picture_as_pdf, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text('Documento gerado'),
          ],
        ),
        content: Text('Deseja exportar "$title" como PDF?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Não'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _generateAndSharePdf(title, content);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Gerar PDF'),
          ),
        ],
      ),
    );
  }

  Future<void> _generateAndSharePdf(String title, String content) async {
    if (_isGeneratingPdf) return;
    setState(() => _isGeneratingPdf = true);
    _showSnack('Gerando PDF...');

    try {
      final filePath = await _chatPdfService.generatePdf(
        title: title,
        content: content,
      );

      if (!mounted) return;
      await _chatPdfService.sharePdf(filePath);
      _showSnack('PDF gerado com sucesso!');
    } catch (error) {
      if (!mounted) return;
      _showSnack('Erro ao gerar PDF: ${mensagemErroAmigavel(error)}');
    } finally {
      if (mounted) {
        setState(() => _isGeneratingPdf = false);
      }
    }
  }

  Future<void> _attachPdf() async {
    if (_isProcessingDocument) return;
    if (OpenAIConfig.usesProxy && !OpenAIConfig.hasProxyKey) {
      _showSnack(
        'Defina SUPABASE_ANON_KEY no .env para usar o proxy.',
      );
      return;
    }
    if (!OpenAIConfig.usesProxy && !OpenAIConfig.hasApiKey) {
      _showSnack(
        'Defina OPENAI_API_KEY via --dart-define ou configure o proxy.',
      );
      return;
    }

    setState(() => _isProcessingDocument = true);

    try {
      final result = await _pdfService.pickAndProcessPdf();
      if (!mounted) return;
      if (result == null) {
        setState(() => _isProcessingDocument = false);
        return;
      }

      if (!result.textFound) {
        _showSnack(
          'Nao foi possivel extrair texto do PDF. Resumo sera limitado.',
        );
      }

      final documentContext = _buildCurrentPatientContext();
      final summary = await _service.summarizeDocument(
        documentText: result.documentText,
        documentCode: result.documentCode,
        documentContext: documentContext,
        sourceFileName: result.fileName,
        textFound: result.textFound,
        textTruncated: result.textTruncated,
      );

      if (!mounted) return;
      setState(() {
        _messages.add(
          ChatMessage(
              role: 'user', content: 'Documento anexado: ${result.fileName}'),
        );
        _messages.add(ChatMessage(role: 'assistant', content: summary));
      });
      _scrollToBottom();
      await _saveMessages();
      _showSnack('Documento processado com sucesso.');
    } catch (error) {
      if (!mounted) return;
      _showSnack(mensagemErroAmigavel(error));
    } finally {
      if (mounted) {
        setState(() => _isProcessingDocument = false);
      }
    }
  }

  String _buildCurrentPatientContext() {
    return '';
  }

  void _scrollToBottom({bool animated = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      final targetPosition = _scrollController.position.maxScrollExtent;
      
      if (animated) {
        final currentPosition = _scrollController.position.pixels;
        final distance = (targetPosition - currentPosition).abs();
        final duration = Duration(milliseconds: (200 + (distance * 0.2).clamp(0, 300)).toInt());
        
        _scrollController.animateTo(
          targetPosition,
          duration: duration,
          curve: Curves.easeOutQuart,
        );
      } else {
        // Sem animação - pula direto para o final
        _scrollController.jumpTo(targetPosition);
      }
    });
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 2),
        animation: CurvedAnimation(
          parent: const AlwaysStoppedAnimation(1),
          curve: Curves.easeOutCubic,
        ),
      ),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.lightImpact();
    _showSnack('Resposta copiada para a área de transferência');
  }

  void _setFeedback(int index, String feedback) {
    HapticFeedback.lightImpact();
    setState(() {
      _messages[index].feedback = feedback.isEmpty ? null : feedback;
    });
    _saveMessages();
  }

  Future<void> _regenerateResponse(int index) async {
    if (_isSending) return;
    
    HapticFeedback.lightImpact();
    
    // Encontra a mensagem do usuário anterior a esta resposta
    String? userMessage;
    for (int i = index - 1; i >= 0; i--) {
      if (_messages[i].role == 'user') {
        userMessage = _messages[i].content;
        break;
      }
    }
    
    if (userMessage == null) {
      _showSnack('Não foi possível encontrar a pergunta original.');
      return;
    }
    
    // Remove apenas a resposta atual (mantém a pergunta do usuário)
    setState(() {
      _messages.removeAt(index);
      _isSending = true;
    });
    _scrollToBottom();

    try {
      // Histórico sem a última mensagem (usuário), pois o serviço adiciona a mensagem ao final
      final withoutLastUser = _messages.length > 1
          ? _messages.sublist(0, _messages.length - 1)
          : <ChatMessage>[];
      final history = withoutLastUser.length > 12
          ? withoutLastUser.sublist(withoutLastUser.length - 12)
          : withoutLastUser;
      final professionalContext = await _buildProfessionalContext();
      final annotationsCtx = _buildAnnotationsContext();
      final fullExtraContext =
          '${professionalContext.context}\n\n$annotationsCtx';

      String reply;
      if (OpenAIConfig.usesProxy) {
        reply = await _service.sendMessageWithExtraContext(
          message: userMessage,
          history: history,
          extraContext: fullExtraContext,
          mode: _responseMode,
        );
        if (!mounted) return;
        setState(() {
          _messages.add(ChatMessage(role: 'assistant', content: reply));
        });
      } else {
        setState(() {
          _messages.add(ChatMessage(role: 'assistant', content: ''));
        });
        _scrollToBottom();
        try {
          reply = await _consumeStream(
            _service.sendMessageWithExtraContextStream(
              message: userMessage,
              history: history,
              extraContext: fullExtraContext,
              mode: _responseMode,
            ),
          );
        } catch (_) {
          setState(() => _messages.removeLast());
          if (!mounted) return;
          reply = await _service.sendMessageWithExtraContext(
            message: userMessage,
            history: history,
            extraContext: fullExtraContext,
            mode: _responseMode,
          );
          if (!mounted) return;
          setState(() {
            _messages.add(ChatMessage(role: 'assistant', content: reply));
          });
        }
      }

      if (!mounted) return;
      HapticFeedback.mediumImpact();

      reply = await _processReply(reply);

      final pdfMatch = _pdfTitleRegex.firstMatch(reply);
      if (pdfMatch != null) {
        final pdfTitle = pdfMatch.group(1)?.trim() ?? 'Documento';
        final pdfContent = reply.substring(pdfMatch.end).trim();
        final displayContent = '📄 **$pdfTitle**\n\n$pdfContent';
        setState(() {
          _messages[_messages.length - 1] = ChatMessage(
            role: 'assistant',
            content: displayContent,
            isPdf: true,
            pdfTitle: pdfTitle,
            pdfContent: pdfContent,
          );
        });
        _scrollToBottom();
        await _saveMessages();
        _showPdfGenerationDialog(pdfTitle, pdfContent);
      } else {
        setState(() {
          _messages[_messages.length - 1] = ChatMessage(role: 'assistant', content: reply);
        });
        _scrollToBottom();
        await _saveMessages();
      }
    } catch (error) {
      if (!mounted) return;
      final userMsg = mensagemErroAmigavel(error);
      _showSnack(userMsg);
      setState(() {
        _messages.add(ChatMessage(role: 'assistant', content: '⚠️ $userMsg'));
      });
      _scrollToBottom();
      await _saveMessages();
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  void _editMessage(int index, String content) {
    HapticFeedback.lightImpact();
    
    // Salva o backup das mensagens que serão removidas
    _editBackup = _messages.sublist(index).toList();
    _originalInputText = _inputController.text;
    _isEditing = true;
    
    // Remove todas as mensagens a partir deste índice
    setState(() {
      _messages.removeRange(index, _messages.length);
    });

    // Coloca o texto no campo de input
    _inputController.text = content;
    _inputController.selection = TextSelection.fromPosition(
      TextPosition(offset: content.length),
    );
    // Foca no campo de input e rola para exibir a barra de digitação
    _inputFocusNode.requestFocus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _scrollToBottom();
    });
  }

  void _cancelEdit() {
    if (!_isEditing) return;
    
    HapticFeedback.lightImpact();
    
    // Restaura as mensagens do backup
    setState(() {
      _messages.addAll(_editBackup);
    });
    
    // Restaura o texto original do input
    _inputController.text = _originalInputText;
    
    // Limpa o estado de edição
    _isEditing = false;
    _editBackup = [];
    _originalInputText = '';
    
    _scrollToBottom();
  }

  void _confirmEdit() {
    // Confirma a edição e limpa o estado
    _isEditing = false;
    _editBackup = [];
    _originalInputText = '';
    _saveMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildInfoBanner(),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildChatList(),
        ),
        _buildInputBar(),
      ],
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      width: double.infinity,
      color: AppColors.primary.withValues(alpha: 0.08),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const Text(
            'IA Médica',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const Spacer(),
          _buildModeSelector(),
          const Spacer(),
          SizedBox(
            width: 32,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: _messages.isNotEmpty
                  ? IconButton(
                      key: const ValueKey('refresh'),
                      onPressed: _resetConversation,
                      icon: const Icon(Icons.refresh, size: 20),
                      tooltip: 'Reiniciar conversa',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      splashRadius: 20,
                    )
                  : const SizedBox.shrink(key: ValueKey('empty')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelector() {
    return Container(
      height: 34,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildModeOption(
            mode: ResponseMode.precise,
            label: 'Precisa',
            icon: Icons.bolt,
          ),
          _buildModeOption(
            mode: ResponseMode.complete,
            label: 'Completa',
            icon: Icons.auto_stories,
          ),
        ],
      ),
    );
  }

  Widget _buildModeOption({
    required ResponseMode mode,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _responseMode == mode;
    return GestureDetector(
      onTap: () {
        if (_responseMode != mode) {
          HapticFeedback.selectionClick();
          setState(() => _responseMode = mode);
          _saveResponseMode(mode);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(17),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? Colors.white : Colors.grey.shade600,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? Colors.white : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onTapOutside() {
    if (_isEditing) {
      _cancelEdit();
    }
  }

  void _onSuggestionTap(String text) {
    if (_isSending || _isProcessingDocument) return;
    _inputController.text = text;
    _sendMessage();
  }

  Widget _buildChatList() {
    if (_messages.isEmpty && !_isSending) {
      return GestureDetector(
        onTap: _onTapOutside,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.medical_services_outlined,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Faça uma pergunta clínica para iniciar a conversa.',
                    style: TextStyle(color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: _suggestionPhrases.map((phrase) {
                      return ActionChip(
                        label: Text(
                          phrase,
                          style: const TextStyle(fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                        onPressed: () => _onSuggestionTap(phrase),
                        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final itemCount = _messages.length + (_isSending ? 1 : 0);

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        // Cancela edição quando usuário começa a rolar
        if (notification is ScrollStartNotification && _isEditing) {
          _cancelEdit();
        }
        return false;
      },
      child: GestureDetector(
        onTap: _onTapOutside,
        onPanDown: (_) => _onTapOutside(),
        behavior: HitTestBehavior.opaque,
        child: ListView.builder(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          itemCount: itemCount,
          itemBuilder: (context, index) {
            // Indicador de digitação
            if (_isSending && index == itemCount - 1) {
              return _buildTypingIndicator();
            }

            final item = _messages[index];
            final isUser = item.role == 'user';

          return _MessageBubble(
            key: ValueKey('msg_$index'),
            item: item,
            isUser: isUser,
            isGeneratingPdf: _isGeneratingPdf,
            onGeneratePdf: _generateAndSharePdf,
            onCopy: _copyToClipboard,
            onEdit: isUser ? (content) => _editMessage(index, content) : null,
            onFeedback: !isUser ? (feedback) => _setFeedback(index, feedback) : null,
            onRegenerate: !isUser ? () => _regenerateResponse(index) : null,
          );
          },
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 4, bottom: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TypingDot(delay: 0),
          const SizedBox(width: 3),
          _TypingDot(delay: 150),
          const SizedBox(width: 3),
          _TypingDot(delay: 300),
          const SizedBox(width: 6),
          Text(
            'pensando...',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSendButton() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: _isSending ? 0.95 : 1.0),
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOutCubic,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: SizedBox(
            height: 48,
            width: 48,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: _isSending
                    ? []
                    : [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: ElevatedButton(
                onPressed: _isSending ? null : _sendMessage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.zero,
                  elevation: 0,
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: _isSending
                      ? const SizedBox(
                          key: ValueKey('loading'),
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send, key: ValueKey('send')),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAttachMenu() {
    final disabled = _isProcessingDocument || _isSending;
    if (disabled) return;

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: Icon(Icons.picture_as_pdf, color: AppColors.primary),
                title: const Text('Anexar PDF'),
                subtitle: const Text('Selecione um documento PDF'),
                onTap: () {
                  Navigator.pop(ctx);
                  _attachPdf();
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt, color: AppColors.primary),
                title: const Text('Tirar foto'),
                subtitle: const Text('Fotografar exame com a câmera'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSourceType.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: AppColors.primary),
                title: const Text('Galeria'),
                subtitle: const Text('Selecionar imagem de exame'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSourceType.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSourceType source) async {
    try {
      final result = await _imageService.pickImage(source);
      if (result == null || !mounted) return;
      setState(() => _pendingImage = result);
    } catch (e) {
      if (!mounted) return;
      _showSnack(mensagemErroAmigavel(e));
    }
  }

  void _removePendingImage() {
    setState(() => _pendingImage = null);
  }

  Widget _buildPendingImagePreview() {
    if (_pendingImage == null) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(
              _pendingImage!.bytes,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Imagem anexada',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                Text(
                  '${_pendingImage!.width} x ${_pendingImage!.height} px',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: _removePendingImage,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPendingImagePreview(),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Row(
              children: [
                SizedBox(
                  height: 48,
                  width: 48,
                  child: OutlinedButton(
                    onPressed:
                        _isProcessingDocument || _isSending ? null : _showAttachMenu,
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: Colors.grey.shade300),
                      padding: EdgeInsets.zero,
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(scale: animation, child: child);
                      },
                      child: _isProcessingDocument
                          ? const SizedBox(
                              key: ValueKey('loading'),
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.add, key: ValueKey('attach')),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Shortcuts(
                    shortcuts: <ShortcutActivator, Intent>{
                      const SingleActivator(LogicalKeyboardKey.enter): const _SendMessageIntent(),
                      const SingleActivator(LogicalKeyboardKey.numpadEnter): const _SendMessageIntent(),
                      const SingleActivator(LogicalKeyboardKey.enter, shift: true): const _NewLineIntent(),
                      const SingleActivator(LogicalKeyboardKey.numpadEnter, shift: true): const _NewLineIntent(),
                    },
                    child: Actions(
                      actions: <Type, Action<Intent>>{
                        _SendMessageIntent: CallbackAction<_SendMessageIntent>(onInvoke: (_) {
                          if ((_inputController.text.trim().isNotEmpty || _pendingImage != null) && !_isSending) {
                            _sendMessage();
                          }
                          return null;
                        }),
                        _NewLineIntent: CallbackAction<_NewLineIntent>(onInvoke: (_) {
                          _insertNewLine();
                          return null;
                        }),
                      },
                      child: TextField(
                        focusNode: _inputFocusNode,
                        controller: _inputController,
                        minLines: 1,
                        maxLines: 5,
                        textInputAction: TextInputAction.newline,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          hintText: _pendingImage != null
                              ? 'Descreva o exame (opcional)...'
                              : 'Digite sua pergunta...',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                _buildSendButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingDot extends StatefulWidget {
  const _TypingDot({required this.delay});

  final int delay;

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -3 * _animation.value),
          child: Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.4 + (_animation.value * 0.6)),
                width: 1.2,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MessageBubble extends StatefulWidget {
  const _MessageBubble({
    super.key,
    required this.item,
    required this.isUser,
    required this.isGeneratingPdf,
    required this.onGeneratePdf,
    required this.onCopy,
    this.onEdit,
    this.onFeedback,
    this.onRegenerate,
  });

  final ChatMessage item;
  final bool isUser;
  final bool isGeneratingPdf;
  final Future<void> Function(String, String) onGeneratePdf;
  final void Function(String) onCopy;
  final void Function(String)? onEdit;
  final void Function(String)? onFeedback;
  final void Function()? onRegenerate;

  @override
  State<_MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<_MessageBubble> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width * 0.78;
    
    // Para mensagens do usuário, usar estrutura simples que se adapta ao conteúdo
    if (widget.isUser) {
      return FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Align(
            alignment: Alignment.centerRight,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              constraints: BoxConstraints(maxWidth: maxWidth),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.item.imageBase64 != null &&
                            widget.item.imageBase64!.isNotEmpty)
                          _ImageBubblePreview(
                            base64DataUrl: widget.item.imageBase64!,
                          )
                        else if (widget.item.hasImage)
                          Container(
                            padding: const EdgeInsets.all(8),
                            margin: const EdgeInsets.only(bottom: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.image, size: 16, color: Colors.white70),
                                SizedBox(width: 6),
                                Text(
                                  'Imagem enviada',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Text(
                          widget.item.content,
                          style: const TextStyle(
                            color: Colors.white,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.onEdit != null)
                    Positioned(
                      right: 4,
                      bottom: 4,
                      child: GestureDetector(
                        onTap: () => widget.onEdit!(widget.item.content),
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Icon(
                            Icons.edit_outlined,
                            size: 14,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    
    // Para mensagens do assistente, layout livre sem balão
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
                  child: MarkdownBody(
                    data: widget.item.content,
                    selectable: true,
                    styleSheet: MarkdownStyleSheet(
                      textAlign: WrapAlignment.spaceBetween,
                      p: const TextStyle(
                        color: Colors.black87,
                        height: 1.3,
                      ),
                      h1: const TextStyle(
                        color: Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      h2: const TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      h3: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      strong: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Botões de ação para mensagens do assistente (feedback + regenerar + copiar)
                if (!(widget.item.isPdf && widget.item.pdfTitle != null))
                  Padding(
                    padding: const EdgeInsets.only(left: 4, right: 4, bottom: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Botões de feedback
                        if (widget.onFeedback != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () => widget.onFeedback!(
                                  widget.item.feedback == 'liked' ? '' : 'liked',
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Icon(
                                    widget.item.feedback == 'liked'
                                        ? Icons.thumb_up
                                        : Icons.thumb_up_outlined,
                                    size: 14,
                                    color: widget.item.feedback == 'liked'
                                        ? AppColors.primary
                                        : Colors.grey.shade400,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () => widget.onFeedback!(
                                  widget.item.feedback == 'disliked' ? '' : 'disliked',
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Icon(
                                    widget.item.feedback == 'disliked'
                                        ? Icons.thumb_down
                                        : Icons.thumb_down_outlined,
                                    size: 14,
                                    color: widget.item.feedback == 'disliked'
                                        ? Colors.red.shade400
                                        : Colors.grey.shade400,
                                  ),
                                ),
                              ),
                            ],
                          )
                        else
                          const SizedBox.shrink(),
                        // Botões de regenerar e copiar
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.onRegenerate != null)
                              GestureDetector(
                                onTap: widget.onRegenerate,
                                child: Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Icon(
                                    Icons.refresh,
                                    size: 14,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                              ),
                            GestureDetector(
                              onTap: () => widget.onCopy(widget.item.content),
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Icon(
                                  Icons.copy_outlined,
                                  size: 14,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                if (widget.item.isPdf && widget.item.pdfTitle != null && widget.item.pdfContent != null)
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        TextButton.icon(
                          onPressed: widget.isGeneratingPdf
                              ? null
                              : () => widget.onGeneratePdf(widget.item.pdfTitle!, widget.item.pdfContent!),
                          icon: widget.isGeneratingPdf
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.picture_as_pdf, size: 18),
                          label: Text(widget.isGeneratingPdf ? 'Gerando...' : 'Exportar PDF'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          ),
                        ),
                        const Spacer(),
                        // Botões de feedback
                        if (widget.onFeedback != null) ...[
                          GestureDetector(
                            onTap: () => widget.onFeedback!(
                              widget.item.feedback == 'liked' ? '' : 'liked',
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: Icon(
                                widget.item.feedback == 'liked'
                                    ? Icons.thumb_up
                                    : Icons.thumb_up_outlined,
                                size: 14,
                                color: widget.item.feedback == 'liked'
                                    ? AppColors.primary
                                    : Colors.grey.shade400,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => widget.onFeedback!(
                              widget.item.feedback == 'disliked' ? '' : 'disliked',
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: Icon(
                                widget.item.feedback == 'disliked'
                                    ? Icons.thumb_down
                                    : Icons.thumb_down_outlined,
                                size: 14,
                                color: widget.item.feedback == 'disliked'
                                    ? Colors.red.shade400
                                    : Colors.grey.shade400,
                              ),
                            ),
                          ),
                        ],
                        // Botão de regenerar
                        if (widget.onRegenerate != null)
                          GestureDetector(
                            onTap: widget.onRegenerate,
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: Icon(
                                Icons.refresh,
                                size: 14,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ),
                        GestureDetector(
                          onTap: () => widget.onCopy(widget.item.content),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Icon(
                              Icons.copy_outlined,
                              size: 14,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ImageBubblePreview extends StatelessWidget {
  const _ImageBubblePreview({required this.base64DataUrl});

  final String base64DataUrl;

  Uint8List? _decode() {
    try {
      final commaIdx = base64DataUrl.indexOf(',');
      if (commaIdx < 0) return null;
      return base64Decode(base64DataUrl.substring(commaIdx + 1));
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bytes = _decode();
    if (bytes == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 200),
          child: Image.memory(
            bytes,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}
