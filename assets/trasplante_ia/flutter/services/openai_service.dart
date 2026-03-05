import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/openai_config.dart';
import '../shared_data.dart';

enum ResponseMode {
  precise,
  complete,
}

/// Serviço principal para comunicação com a OpenAI.
/// 
/// Funcionalidades:
/// - Envio de mensagens com contexto do paciente
/// - Modos de resposta (precisa/completa)
/// - Resumo de documentos
/// - Planejamento de ações no banco de dados
class OpenAIService {
  static const String _baseSystemPrompt = '''
Você é a Drª BIA, assistente médica técnica do Guide Dose.
Responda em português, de forma clínica e baseada em evidências.
Priorize: base compartilhada (SofIA) > base pessoal > conhecimento geral.
Se não houver informação suficiente, informe limitações e sugira próxima ação.

IMPORTANTE - Geração de PDF:
Quando o usuário solicitar explicitamente um PDF, documento, receita, relatório, prescrição ou laudo:
1. Inicie a resposta EXATAMENTE com: [PDF:Título do Documento]
2. Em seguida, escreva o conteúdo completo e bem formatado do documento.
3. Use markdown para estruturar: # para títulos, ## para subtítulos, - para listas.
4. O conteúdo deve ser profissional e adequado para impressão.
''';

  static const String _precisePrompt = '''
MODO DE RESPOSTA: PRECISO
- Seja extremamente objetivo e direto
- Respostas curtas e práticas (máximo 3-4 parágrafos)
- Vá direto ao ponto principal
- Use bullet points para informações essenciais
- Evite explicações extensas ou contextualizações desnecessárias
''';

  static const String _completePrompt = '''
MODO DE RESPOSTA: COMPLETO
- Forneça explicações detalhadas e didáticas
- Inclua contexto, mecanismos de ação e fundamentação
- Explore diferentes aspectos do tema
- Adicione considerações clínicas relevantes
- Use exemplos quando apropriado para facilitar o entendimento
''';

  String _buildSystemPrompt(ResponseMode mode) {
    final modePrompt = mode == ResponseMode.precise ? _precisePrompt : _completePrompt;
    return '$_baseSystemPrompt\n$modePrompt';
  }

  /// Envia uma mensagem para a IA e retorna a resposta.
  Future<String> sendMessage({
    required String message,
    required List<ChatMessage> history,
    ResponseMode mode = ResponseMode.precise,
  }) async {
    final patientContext = _buildPatientContext();
    final systemPrompt = _buildSystemPrompt(mode);
    final messages = <Map<String, String>>[
      {'role': 'system', 'content': systemPrompt},
      if (patientContext.isNotEmpty)
        {'role': 'system', 'content': patientContext},
      ..._mapHistory(history),
      {'role': 'user', 'content': message},
    ];
    return _callChat(messages);
  }

  /// Envia mensagem com contexto extra (ex: dados de prontuário).
  Future<String> sendMessageWithExtraContext({
    required String message,
    required List<ChatMessage> history,
    required String extraContext,
    ResponseMode mode = ResponseMode.precise,
  }) async {
    final patientContext = _buildPatientContext();
    final systemPrompt = _buildSystemPrompt(mode);
    final messages = <Map<String, String>>[
      {'role': 'system', 'content': systemPrompt},
      if (patientContext.isNotEmpty)
        {'role': 'system', 'content': patientContext},
      if (extraContext.trim().isNotEmpty)
        {'role': 'system', 'content': extraContext.trim()},
      ..._mapHistory(history),
      {'role': 'user', 'content': message},
    ];
    return _callChat(messages);
  }

  /// Planeja ações no banco de dados baseado na mensagem.
  Future<List<DbAction>> planDbActions({
    required String message,
    required List<ChatMessage> history,
  }) async {
    final instructions = '''
Você decide se deve interagir com o banco de dados.
Responda SOMENTE em JSON valido (sem markdown).
Formato:
{
  "actions": [
    {
      "action": "none|query_prontuarios|query_notas|create_prontuario|update_prontuario|create_nota|update_nota",
      "parameters": { ... }
    }
  ]
}
Regras:
- Se nenhuma acao for necessaria, use action "none".
- Use "codigo" para buscar prontuario por codigo (campo name).
- Para criar prontuario, forneca "codigo" e opcionalmente "sexo", "idade_tipo", "idade", "peso", "altura".
- Para criar prontuario, opcionalmente forneca "patient_name".
- Para atualizar prontuario, forneca "id" ou "codigo" e os campos a atualizar, incluindo "patient_name" quando houver.
- Para criar nota, forneca "prontuario_id" ou "codigo" e "summary".
- Para atualizar nota, forneca "id" e "summary".
- Para buscar notas, forneca "codigo" ou "prontuario_id" e opcionalmente "query".
''';

    final messages = <Map<String, String>>[
      {'role': 'system', 'content': _baseSystemPrompt},
      {'role': 'system', 'content': instructions.trim()},
      ..._mapHistory(history),
      {'role': 'user', 'content': message},
    ];

    final content = await _callChat(messages);
    return _parseDbActions(content);
  }

  /// Gera um resumo de documento anexado.
  Future<String> summarizeDocument({
    required String documentText,
    required String prontuarioCode,
    required String prontuarioContext,
    required String sourceFileName,
    required bool textFound,
    required bool textTruncated,
  }) async {
    final contextBuffer = StringBuffer()
      ..writeln('Prontuario: $prontuarioCode');
    if (prontuarioContext.trim().isNotEmpty) {
      contextBuffer.writeln(prontuarioContext.trim());
    }

    final userPrompt = StringBuffer()
      ..writeln('Arquivo: $sourceFileName')
      ..writeln('Texto extraido:');
    if (!textFound) {
      userPrompt.writeln('[Texto nao encontrado no PDF]');
    } else {
      userPrompt.writeln(documentText);
    }
    if (textTruncated) {
      userPrompt.writeln('\n[Texto truncado para caber no limite]');
    }

    final messages = <Map<String, String>>[
      {'role': 'system', 'content': _baseSystemPrompt},
      {'role': 'system', 'content': contextBuffer.toString().trim()},
      {
        'role': 'system',
        'content':
            'Gere um resumo clinico objetivo do documento. Relacione com o prontuario. '
                'Responda em topicos curtos: Achados, Hipoteses, Condutas, Alertas, Observacoes. '
                'Se houver pouca informacao, explicite as limitacoes.',
      },
      {'role': 'user', 'content': userPrompt.toString().trim()},
    ];

    return _callChat(messages);
  }

  List<Map<String, String>> _mapHistory(List<ChatMessage> history) {
    return history
        .map((item) => {'role': item.role, 'content': item.content})
        .toList();
  }

  String _buildPatientContext() {
    final idade = SharedData.idade;
    final peso = SharedData.peso;
    final altura = SharedData.altura;
    if (idade == null && peso == null && altura == null) {
      return '';
    }
    final buffer = StringBuffer('Contexto do paciente atual:\n');
    if (idade != null) {
      buffer.writeln('Idade: ${idade.toStringAsFixed(1)} anos');
    }
    if (peso != null) {
      buffer.writeln('Peso: ${peso.toStringAsFixed(1)} kg');
    }
    if (altura != null) {
      buffer.writeln('Altura: ${altura.toStringAsFixed(1)} cm');
    }
    buffer.writeln('Sexo: ${SharedData.sexo}');
    buffer.writeln('Faixa etária: ${SharedData.faixaEtaria}');
    return buffer.toString().trim();
  }

  String _tryExtractError(String body) {
    try {
      final data = jsonDecode(body) as Map<String, dynamic>;
      final error = data['error'] as Map<String, dynamic>? ?? {};
      final message = error['message'] as String? ?? '';
      return message.trim();
    } catch (_) {
      return '';
    }
  }

  Future<String> _callChat(List<Map<String, String>> messages) async {
    final body = jsonEncode({
      'model': OpenAIConfig.model,
      'messages': messages,
      'temperature': 0.2,
    });

    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (!OpenAIConfig.usesProxy && OpenAIConfig.hasApiKey)
        'Authorization': 'Bearer ${OpenAIConfig.apiKey}',
      if (OpenAIConfig.usesProxy && OpenAIConfig.hasProxyKey) ...{
        'Authorization': 'Bearer ${OpenAIConfig.supabaseAnonKey}',
        'apikey': OpenAIConfig.supabaseAnonKey,
      },
    };

    final response = await http.post(
      Uri.parse(OpenAIConfig.apiUrl),
      headers: headers,
      body: body,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final details = _tryExtractError(response.body);
      throw Exception(
        'Erro ${response.statusCode} ao chamar IA${details.isNotEmpty ? ': $details' : ''}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = data['choices'] as List<dynamic>? ?? [];
    if (choices.isEmpty) {
      throw Exception('Resposta da IA vazia.');
    }
    final first = choices.first as Map<String, dynamic>;
    final messageNode = first['message'] as Map<String, dynamic>? ?? {};
    final content = messageNode['content'] as String? ?? '';
    if (content.trim().isEmpty) {
      throw Exception('Resposta da IA vazia.');
    }
    return content.trim();
  }

  List<DbAction> _parseDbActions(String content) {
    try {
      final data = jsonDecode(content) as Map<String, dynamic>;
      final actions = data['actions'] as List<dynamic>? ?? [];
      return actions
          .map((item) => DbAction.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [DbAction(action: 'none', parameters: const {})];
    }
  }
}

/// Representa uma mensagem no chat.
class ChatMessage {
  ChatMessage({
    required this.role,
    required this.content,
    this.isPdf = false,
    this.pdfTitle,
    this.pdfContent,
  });

  final String role;
  final String content;
  final bool isPdf;
  final String? pdfTitle;
  final String? pdfContent;

  Map<String, dynamic> toJson() => {
    'role': role,
    'content': content,
    'isPdf': isPdf,
    'pdfTitle': pdfTitle,
    'pdfContent': pdfContent,
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    role: json['role'] as String,
    content: json['content'] as String,
    isPdf: json['isPdf'] as bool? ?? false,
    pdfTitle: json['pdfTitle'] as String?,
    pdfContent: json['pdfContent'] as String?,
  );
}

/// Representa uma ação no banco de dados.
class DbAction {
  DbAction({
    required this.action,
    required this.parameters,
  });

  final String action;
  final Map<String, dynamic> parameters;

  factory DbAction.fromMap(Map<String, dynamic> map) {
    return DbAction(
      action: (map['action'] as String? ?? 'none').trim(),
      parameters: (map['parameters'] as Map<String, dynamic>? ?? {}),
    );
  }
}
