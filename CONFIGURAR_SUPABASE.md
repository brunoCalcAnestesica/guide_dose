# 🚀 Como Configurar Supabase no Guide Dose

## 📋 Pré-requisitos

1. Conta no Supabase (https://supabase.com) - **GRATUITO**
2. Projeto criado no Supabase
3. Flutter instalado

## 🔧 Passo 1: Instalar Dependências

Adicione ao `pubspec.yaml`:

```yaml
dependencies:
  supabase_flutter: ^2.5.0  # Cliente Supabase para Flutter
```

Depois execute:
```bash
flutter pub get
```

## 🔑 Passo 2: Obter Credenciais do Supabase

1. Acesse seu projeto no Supabase: https://app.supabase.com
2. Vá em **Settings** > **API**
3. Copie:
   - **Project URL** (ex: `https://xxxxx.supabase.co`)
   - **anon public key** (chave pública)

## ⚙️ Passo 3: Configurar no Flutter

### Criar arquivo de configuração

Crie `lib/config/supabase_config.dart`:

```dart
class SupabaseConfig {
  // ⚠️ Substitua com suas credenciais do Supabase
  static const String supabaseUrl = 'SUA_URL_AQUI';
  static const String supabaseAnonKey = 'SUA_CHAVE_ANON_AQUI';
}
```

### Inicializar no main.dart

Edite `lib/main.dart`:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Supabase
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );
  
  runApp(MyApp());
}
```

## ✉️ Passo 3.1: Confirmacao de e-mail e troca de senha

### Corrigir erro "Database error saving new user" (criar conta)

Se ao **criar conta** aparecer erro de banco de dados:

1. No Supabase: **SQL Editor** → New query.
2. Copie e execute todo o conteúdo do arquivo **`supabase_profiles_table_and_trigger.sql`** (na raiz do projeto).
3. Tente criar a conta novamente.

Esse script cria a tabela `profiles` e o trigger que preenche o perfil ao registrar um novo usuário.

### No Supabase Dashboard
1. Acesse **Authentication** > **Providers** e mantenha **Email** ativo.
2. Em **Authentication** > **URL Configuration**:
   - **Site URL**: use seu dominio web (se houver).
   - **Redirect URLs**: adicione `guidedose://login-callback`.
3. Em **Authentication** > **Settings**:
   - Ative **Confirm email** (recomendado).

### No app (Flutter)
- O app ja esta preparado para abrir o link e mostrar a tela de nova senha.
- Caso queira outro esquema, ajuste:
  - `SUPABASE_AUTH_REDIRECT_URL` no `.env`.
  - Android: `android/app/src/main/AndroidManifest.xml`.
  - iOS: `ios/Runner/Info.plist`.

## 🔒 Passo 4: Adicionar ao .gitignore

Adicione ao `.gitignore`:

```
# Supabase
lib/config/supabase_config.dart
```

**⚠️ NUNCA commite suas chaves no Git!**

## 📝 Passo 5: Usar no Projeto

### Exemplo: Autenticação

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

// Login
final response = await Supabase.instance.client.auth.signInWithPassword(
  email: 'usuario@exemplo.com',
  password: 'senha123',
);

// Verificar usuário logado
final user = Supabase.instance.client.auth.currentUser;

// Logout
await Supabase.instance.client.auth.signOut();
```

### Exemplo: Banco de Dados

```dart
// Ler dados
final response = await Supabase.instance.client
  .from('tabela')
  .select();

// Inserir dados
await Supabase.instance.client
  .from('tabela')
  .insert({'campo': 'valor'});

// Atualizar dados
await Supabase.instance.client
  .from('tabela')
  .update({'campo': 'novo_valor'})
  .eq('id', 1);
```

## 🎯 Casos de Uso para Guide Dose

### 1. Sincronizar Farmacoteca
- Salvar favoritos do usuário
- Histórico de cálculos
- Configurações personalizadas

### 2. Autenticação (se necessário)
- Login de usuários
- Perfis de usuários
- Dados pessoais

### 3. Analytics
- Estatísticas de uso
- Medicamentos mais consultados
- Feedback dos usuários

## 🔐 Segurança

1. **Nunca commite chaves**: Use `.gitignore`
2. **Use variáveis de ambiente** em produção
3. **Configure Row Level Security (RLS)** no Supabase
4. **Valide dados** antes de inserir

## 🚀 Deploy de Edge Functions

Para publicar ou atualizar Edge Functions (ex.: exclusão de conta), use o guia em:

- **[supabase/DEPLOY_FUNCOES.md](supabase/DEPLOY_FUNCOES.md)** — token em `.env.supabase`, comandos e exemplos.

## 📚 Recursos

- [Documentação Supabase Flutter](https://supabase.com/docs/reference/dart/introduction)
- [Supabase Dashboard](https://app.supabase.com)
- [Exemplos Flutter](https://github.com/supabase/supabase-flutter)

