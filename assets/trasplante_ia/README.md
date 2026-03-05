# Transplante da IA Médica (Drª BIA)

Este pacote contém **TUDO** que você precisa para transportar a IA Médica para outro aplicativo Flutter.

## Estrutura da Pasta

```
trasplante_ia/
├── README.md                    # Este arquivo
├── flutter/                     # Código Flutter (frontend)
│   ├── medical_ai_page.dart     # Página principal do chat
│   ├── medical_ai_screen.dart   # Tela wrapper com AppBar
│   ├── shared_data.dart         # Dados do paciente
│   ├── pubspec_dependencies.yaml # Dependências necessárias
│   ├── config/
│   │   └── openai_config.dart   # Configuração da OpenAI
│   ├── services/
│   │   ├── openai_service.dart  # Serviço de comunicação com IA
│   │   ├── pdf_document_service.dart  # Processar PDFs anexados
│   │   └── chat_pdf_service.dart      # Gerar PDFs do chat
│   └── theme/
│       └── app_colors.dart      # Cores do tema
├── supabase/                    # Código Supabase (backend)
│   ├── functions/
│   │   └── openai-proxy/
│   │       └── index.ts         # Edge Function proxy da OpenAI
│   └── sql/
│       ├── sofia_knowledge_base.sql  # Base compartilhada
│       └── ai_knowledge_base.sql     # Base pessoal por usuário
├── env.example                  # Exemplo de variáveis de ambiente
├── ARQUITETURA.md               # Visão geral da arquitetura
├── PASSO_A_PASSO.md             # Guia de integração
├── PROMPT_E_COMANDOS.md         # Prompt do sistema e comandos
└── SUPABASE.md                  # Configuração do Supabase
```

## Início Rápido (5 passos)

### 1. Adicionar Dependências

Copie as dependências de `flutter/pubspec_dependencies.yaml` para o seu `pubspec.yaml`:

```bash
flutter pub add http supabase_flutter flutter_dotenv shared_preferences \
  path_provider flutter_markdown_plus file_picker syncfusion_flutter_pdf \
  pdfx google_mlkit_barcode_scanning pdf share_plus
```

### 2. Copiar Arquivos Flutter

Copie a pasta `flutter/` para `lib/` do seu projeto:

```bash
cp -r flutter/* seu_projeto/lib/medical_ai/
```

### 3. Configurar Variáveis de Ambiente

Crie `.env` na raiz do projeto:

```env
OPENAI_API_URL=https://SEU-PROJETO.supabase.co/functions/v1/openai-proxy
SUPABASE_ANON_KEY=sua_chave_anon_aqui
OPENAI_MODEL=gpt-4.1
```

### 4. Configurar Supabase

Execute os scripts SQL no Supabase:
- `supabase/sql/sofia_knowledge_base.sql`
- `supabase/sql/ai_knowledge_base.sql`

Deploy da Edge Function:
```bash
supabase functions deploy openai-proxy
supabase secrets set OPENAI_API_KEY=sk-sua-chave-aqui
```

### 5. Adicionar a Tela no App

```dart
import 'medical_ai/medical_ai_screen.dart';

// No seu Navigator ou Router:
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const MedicalAIScreen()),
);
```

## Funcionalidades Incluídas

- Chat com IA médica (GPT-4)
- Dois modos de resposta: Precisa e Completa
- Contexto automático do paciente (peso, idade, sexo, altura)
- Anexar e processar PDFs
- Extração de QR Code de prontuários
- Geração e compartilhamento de PDFs
- Histórico de conversas salvo localmente
- UI moderna com animações
- Suporte a Markdown nas respostas

## Personalizações Comuns

### Mudar o Nome da IA

Em `openai_service.dart`, altere o `_baseSystemPrompt`:

```dart
static const String _baseSystemPrompt = '''
Você é o Dr. [NOME], assistente médico do [SEU APP].
...
''';
```

### Mudar as Cores

Em `theme/app_colors.dart`:

```dart
class AppColors {
  static const Color primary = Color(0xFF[SUA_COR]);
  // ...
}
```

### Remover Funcionalidade de PDF

Se não precisar de anexos/geração de PDF:

1. Remova os imports de `pdf_document_service.dart` e `chat_pdf_service.dart`
2. Remova o botão de anexo em `_buildInputBar()`
3. Remova as dependências de PDF do pubspec

### Usar OpenAI Diretamente (não recomendado)

Se preferir não usar o proxy Supabase:

1. Configure `OPENAI_API_URL=https://api.openai.com/v1/chat/completions`
2. Configure `OPENAI_API_KEY=sk-sua-chave`

⚠️ **Atenção**: A chave ficará exposta no app!

## Documentação Adicional

- `ARQUITETURA.md` - Como os componentes se conectam
- `PASSO_A_PASSO.md` - Guia detalhado de integração
- `PROMPT_E_COMANDOS.md` - Prompt do sistema e comandos CRUD
- `SUPABASE.md` - Configuração completa do Supabase

## Suporte

Para dúvidas ou problemas, consulte a documentação adicional ou abra uma issue no repositório.
