import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config/openai_config.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'services/openai_service.dart';
import 'services/pdf_document_service.dart';
import 'services/chat_pdf_service.dart';
import 'shared_data.dart';
import 'theme/app_colors.dart';

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

  late final OpenAIService _service;
  late final PdfDocumentService _pdfService;
  late final ChatPdfService _chatPdfService;
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

  @override
  void initState() {
    super.initState();
    _service = OpenAIService();
    _pdfService = PdfDocumentService();
    _chatPdfService = ChatPdfService();
    
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

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    // Só processa no key down
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    
    // Verifica se é Enter
    if (event.logicalKey == LogicalKeyboardKey.enter || 
        event.logicalKey == LogicalKeyboardKey.numpadEnter) {
      
      // Verifica se Shift está pressionado
      final isShiftPressed = HardwareKeyboard.instance.isShiftPressed;
      
      if (isShiftPressed) {
        // Shift+Enter: insere nova linha
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
        return KeyEventResult.handled;
      } else {
        // Enter: envia mensagem
        if (_inputController.text.trim().isNotEmpty && !_isSending) {
          _sendMessage();
          return KeyEventResult.handled;
        }
      }
    }
    
    return KeyEventResult.ignored;
  }

  String _buildPatientContextKey() {
    return '${SharedData.peso}_${SharedData.altura}_${SharedData.idade}_${SharedData.sexo}';
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
    if (text.isEmpty || _isProcessingDocument) return;
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

    // Fecha o teclado e feedback tátil
    FocusScope.of(context).unfocus();
    HapticFeedback.lightImpact();

    setState(() {
      _messages.add(ChatMessage(role: 'user', content: text));
      _inputController.clear();
      _isSending = true;
    });
    _scrollToBottom();

    try {
      final history = _messages.take(12).toList();

      final reply = await _service.sendMessage(
        message: text,
        history: history,
        mode: _responseMode,
      );

      if (!mounted) return;
      
      // Feedback tátil quando resposta chega
      HapticFeedback.mediumImpact();

      // Verifica se a resposta contém marcador de PDF
      final pdfMatch = _pdfTitleRegex.firstMatch(reply);
      if (pdfMatch != null) {
        final pdfTitle = pdfMatch.group(1)?.trim() ?? 'Documento';
        final pdfContent = reply.substring(pdfMatch.end).trim();
        
        // Mostra mensagem sem o marcador
        final displayContent = '📄 **$pdfTitle**\n\n$pdfContent';
        setState(() {
          _messages.add(ChatMessage(role: 'assistant', content: displayContent, isPdf: true, pdfTitle: pdfTitle, pdfContent: pdfContent));
        });
        _scrollToBottom();
        await _saveMessages();
        
        // Pergunta se quer gerar o PDF
        _showPdfGenerationDialog(pdfTitle, pdfContent);
      } else {
        setState(() {
          _messages.add(ChatMessage(role: 'assistant', content: reply));
        });
        _scrollToBottom();
        await _saveMessages();
      }
    } catch (error) {
      if (!mounted) return;
      _showSnack(error.toString().replaceAll('Exception: ', ''));
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
      final patientContext = _buildCurrentPatientContext();
      final filePath = await _chatPdfService.generatePdf(
        title: title,
        content: content,
        patientContext: patientContext.isNotEmpty ? patientContext : null,
      );

      if (!mounted) return;
      await _chatPdfService.sharePdf(filePath);
      _showSnack('PDF gerado com sucesso!');
    } catch (error) {
      if (!mounted) return;
      _showSnack('Erro ao gerar PDF: ${error.toString().replaceAll('Exception: ', '')}');
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

      final prontuarioContext = _buildCurrentPatientContext();
      final summary = await _service.summarizeDocument(
        documentText: result.documentText,
        prontuarioCode: result.prontuarioCode,
        prontuarioContext: prontuarioContext,
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
      _showSnack(error.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _isProcessingDocument = false);
      }
    }
  }

  String _buildCurrentPatientContext() {
    final buffer = StringBuffer();
    if (SharedData.sexo.trim().isNotEmpty) {
      buffer.writeln('Sexo: ${SharedData.sexo}');
    }
    if (SharedData.idade != null) {
      buffer.writeln('Idade: ${SharedData.idade!.toStringAsFixed(1)} ${SharedData.idadeTipo}');
    }
    if (SharedData.peso != null) {
      buffer.writeln('Peso: ${SharedData.peso!.toStringAsFixed(1)} kg');
    }
    if (SharedData.altura != null) {
      buffer.writeln('Altura: ${SharedData.altura!.toStringAsFixed(1)} cm');
    }
    return buffer.toString().trim();
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
            'Drª Giul IA',
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

  Widget _buildChatList() {
    if (_messages.isEmpty && !_isSending) {
      return Center(
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
            ],
          ),
        ),
      );
    }

    final itemCount = _messages.length + (_isSending ? 1 : 0);

    return ListView.builder(
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
        );
      },
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _TypingDot(delay: 0),
            const SizedBox(width: 4),
            _TypingDot(delay: 150),
            const SizedBox(width: 4),
            _TypingDot(delay: 300),
            const SizedBox(width: 8),
            Text(
              'Drª Giul está pensando...',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
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

  Widget _buildInputBar() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Row(
          children: [
            SizedBox(
              height: 48,
              width: 48,
              child: OutlinedButton(
                onPressed:
                    _isProcessingDocument || _isSending ? null : _attachPdf,
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
                      : const Icon(Icons.attach_file, key: ValueKey('attach')),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Focus(
                focusNode: _inputFocusNode,
                onKeyEvent: _handleKeyEvent,
                child: TextField(
                  controller: _inputController,
                  minLines: 1,
                  maxLines: 5,
                  textInputAction: TextInputAction.newline,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    hintText: 'Digite sua pergunta...',
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
            const SizedBox(width: 10),
            _buildSendButton(),
          ],
        ),
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
          offset: Offset(0, -4 * _animation.value),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.4 + (_animation.value * 0.6)),
              shape: BoxShape.circle,
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
  });

  final ChatMessage item;
  final bool isUser;
  final bool isGeneratingPdf;
  final Future<void> Function(String, String) onGeneratePdf;

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
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Align(
          alignment: widget.isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.78,
            ),
            decoration: BoxDecoration(
              color: widget.isUser ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: MarkdownBody(
                    data: widget.item.content,
                    selectable: true,
                    styleSheet: MarkdownStyleSheet(
                      p: TextStyle(
                        color: widget.isUser ? Colors.white : Colors.black87,
                        height: 1.3,
                      ),
                      h1: TextStyle(
                        color: widget.isUser ? Colors.white : Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      h2: TextStyle(
                        color: widget.isUser ? Colors.white : Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      h3: TextStyle(
                        color: widget.isUser ? Colors.white : Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      strong: TextStyle(
                        color: widget.isUser ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
                    child: TextButton.icon(
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
                        padding: const EdgeInsets.symmetric(vertical: 8),
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
}
