# Passo a Passo Completo de Integração

Este guia detalha cada etapa para integrar a IA Médica no seu app Flutter.

## Pré-requisitos

- Flutter 3.0 ou superior
- Conta no Supabase (gratuito)
- Conta na OpenAI com créditos

## 1. Adicionar Dependências

Adicione ao seu `pubspec.yaml`:

```yaml
dependencies:
  # Core
  http: ^1.6.0
  supabase_flutter: ^2.5.0
  flutter_dotenv: ^6.0.0
  shared_preferences: ^2.2.2
  path_provider: ^2.1.5
  
  # UI
  flutter_markdown_plus: ^1.0.7
  
  # PDF (opcional - remova se não precisar)
  file_picker: ^10.3.8
  syncfusion_flutter_pdf: ^32.1.23
  pdfx: ^2.9.2
  google_mlkit_barcode_scanning: ^0.14.1
  pdf: ^3.11.3
  share_plus: ^12.0.1
```

Execute:
```bash
flutter pub get
```

## 2. Configurar Variáveis de Ambiente

### 2.1. Criar arquivo .env

Na raiz do projeto, crie `.env`:

```env
OPENAI_API_URL=https://SEU-PROJETO.supabase.co/functions/v1/openai-proxy
SUPABASE_ANON_KEY=sua_chave_anon
OPENAI_MODEL=gpt-4.1
```

### 2.2. Adicionar .env ao .gitignore

```gitignore
.env
*.env
```

### 2.3. Declarar asset no pubspec.yaml

```yaml
flutter:
  assets:
    - .env
```

### 2.4. Carregar .env no main()

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // .env não encontrado - usar variáveis de ambiente do sistema
  }
  
  runApp(MyApp());
}
```

## 3. Copiar Arquivos Flutter

### 3.1. Criar estrutura de pastas

```bash
mkdir -p lib/medical_ai/config
mkdir -p lib/medical_ai/services
mkdir -p lib/medical_ai/theme
```

### 3.2. Copiar arquivos

Copie de `flutter/` para `lib/medical_ai/`:
- `medical_ai_page.dart`
- `medical_ai_screen.dart`
- `shared_data.dart`
- `config/openai_config.dart`
- `services/openai_service.dart`
- `services/pdf_document_service.dart` (opcional)
- `services/chat_pdf_service.dart` (opcional)
- `theme/app_colors.dart`

### 3.3. Ajustar imports

Atualize os imports conforme a estrutura do seu projeto:

```dart
// De:
import 'config/openai_config.dart';

// Para:
import 'package:seu_app/medical_ai/config/openai_config.dart';
```

## 4. Configurar Supabase

### 4.1. Criar projeto no Supabase

1. Acesse https://supabase.com
2. Crie um novo projeto
3. Anote o `Project URL` e `anon public` key

### 4.2. Executar scripts SQL

No SQL Editor do Supabase, execute:

1. `supabase/sql/sofia_knowledge_base.sql`
2. `supabase/sql/ai_knowledge_base.sql`

### 4.3. Criar bucket de Storage (opcional)

Se for usar upload de PDFs para a base de conhecimento:

1. Vá em Storage > New Bucket
2. Nome: `sofia_knowledge`
3. Público: Não
4. Configure as políticas de acesso

### 4.4. Deploy da Edge Function

```bash
# Instalar Supabase CLI
npm install -g supabase

# Login
supabase login

# Link projeto
supabase link --project-ref SEU_PROJECT_REF

# Criar pasta da função
mkdir -p supabase/functions/openai-proxy

# Copiar código
cp supabase/functions/openai-proxy/index.ts supabase/functions/openai-proxy/

# Configurar secret
supabase secrets set OPENAI_API_KEY=sk-sua-chave-openai

# Deploy
supabase functions deploy openai-proxy
```

## 5. Adicionar a Tela no App

### 5.1. Import

```dart
import 'package:seu_app/medical_ai/medical_ai_screen.dart';
```

### 5.2. Navegação

```dart
// Com Navigator
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const MedicalAIScreen()),
);

// Com GoRouter
GoRoute(
  path: '/ia-medica',
  builder: (context, state) => const MedicalAIScreen(),
),
```

### 5.3. Adicionar no menu/drawer

```dart
ListTile(
  leading: Icon(Icons.medical_services),
  title: Text('IA Médica'),
  onTap: () => Navigator.pushNamed(context, '/ia-medica'),
),
```

## 6. Personalizar

### 6.1. Cores

Em `theme/app_colors.dart`:

```dart
class AppColors {
  static const Color primary = Color(0xFF[SUA_COR]);
}
```

### 6.2. Nome da IA

Em `services/openai_service.dart`:

```dart
static const String _baseSystemPrompt = '''
Você é o Dr. [NOME], assistente médico do [SEU APP].
...
''';
```

### 6.3. Logo no PDF

Em `services/chat_pdf_service.dart`:

```dart
static const String _logoAssetPath = 'assets/sua_logo.png';
```

## 7. Testar

1. Execute o app
2. Navegue até a tela de IA
3. Faça uma pergunta: "Qual a dose de dipirona em adultos?"
4. Verifique se a resposta aparece

## Solução de Problemas

### Erro: "Defina SUPABASE_ANON_KEY..."

- Verifique se `.env` existe e está correto
- Verifique se `await dotenv.load()` está no `main()`

### Erro 401 na Edge Function

- Verifique se `OPENAI_API_KEY` está configurado nos secrets
- Verifique se a chave está ativa no OpenAI

### Erro de CORS

- Verifique se os headers CORS estão na Edge Function
- Verifique a URL do proxy no `.env`

### PDF não processa

- Verifique se as dependências de PDF estão instaladas
- No iOS, adicione permissões no Info.plist
- No Android, verifique minSdk >= 21

## Próximos Passos

- Consulte `ARQUITETURA.md` para entender o fluxo
- Consulte `PROMPT_E_COMANDOS.md` para personalizar o comportamento
- Consulte `SUPABASE.md` para configurações avançadas
