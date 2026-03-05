# 🔥 Como Configurar Firebase no Guide Dose

## 📋 Pré-requisitos

1. Conta no Firebase (https://firebase.google.com) - **GRATUITO**
2. Projeto criado no Firebase Console
3. Flutter instalado
4. FlutterFire CLI instalado (recomendado)

## 🔧 Passo 1: Instalar FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
```

## 🔑 Passo 2: Configurar Firebase no Projeto

### Opção A: Usando FlutterFire CLI (Recomendado)

```bash
# 1. Login no Firebase
firebase login

# 2. Configurar FlutterFire no projeto
flutterfire configure
```

O comando vai:
- Listar seus projetos Firebase
- Gerar `firebase_options.dart` automaticamente
- Configurar para iOS e Android

### Opção B: Manual

1. **Instalar dependências** no `pubspec.yaml`:

```yaml
dependencies:
  firebase_core: ^3.6.0
  # Adicione os serviços que precisa:
  firebase_auth: ^5.3.1        # Autenticação
  cloud_firestore: ^5.4.4      # Banco de dados
  firebase_storage: ^12.3.5    # Armazenamento
  firebase_analytics: ^11.3.3  # Analytics
```

2. **Configurar Android**:
   - Baixe `google-services.json` do Firebase Console
   - Coloque em `android/app/google-services.json`

3. **Configurar iOS**:
   - Baixe `GoogleService-Info.plist` do Firebase Console
   - Coloque em `ios/Runner/GoogleService-Info.plist`

## ⚙️ Passo 3: Inicializar no Flutter

### Usando FlutterFire CLI (automático)

Edite `lib/main.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(MyApp());
}
```

### Configuração manual

Se não usar FlutterFire CLI, inicialize com credenciais:

```dart
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    // Configure com suas credenciais
  );
  
  runApp(MyApp());
}
```

## 🔒 Passo 4: Adicionar ao .gitignore

Adicione ao `.gitignore`:

```
# Firebase
android/app/google-services.json
ios/Runner/GoogleService-Info.plist
lib/firebase_options.dart  # Se contiver credenciais sensíveis
```

## 📝 Passo 5: Usar no Projeto

### Exemplo: Autenticação

```dart
import 'package:firebase_auth/firebase_auth.dart';

final auth = FirebaseAuth.instance;

// Login
await auth.signInWithEmailAndPassword(
  email: 'usuario@exemplo.com',
  password: 'senha123',
);

// Verificar usuário logado
final user = auth.currentUser;

// Logout
await auth.signOut();
```

### Exemplo: Firestore (Banco de Dados)

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

final firestore = FirebaseFirestore.instance;

// Ler dados
final snapshot = await firestore.collection('tabela').get();
final docs = snapshot.docs;

// Inserir dados
await firestore.collection('tabela').add({
  'campo': 'valor',
  'timestamp': FieldValue.serverTimestamp(),
});

// Atualizar dados
await firestore.collection('tabela').doc('id').update({
  'campo': 'novo_valor',
});
```

### Exemplo: Storage

```dart
import 'package:firebase_storage/firebase_storage.dart';

final storage = FirebaseStorage.instance;

// Upload de arquivo
final ref = storage.ref().child('arquivos/nome.jpg');
await ref.putFile(file);

// Download de arquivo
final url = await ref.getDownloadURL();
```

## 🎯 Casos de Uso para Guide Dose

### 1. Sincronizar Dados
- Favoritos do usuário
- Histórico de cálculos
- Configurações personalizadas

### 2. Autenticação
- Login de usuários
- Perfis personalizados
- Sincronização entre dispositivos

### 3. Analytics
- Uso do app
- Medicamentos mais consultados
- Fluxo de navegação

### 4. Backup e Restore
- Backup automático de configurações
- Restore em novo dispositivo

## 🔐 Segurança

1. **Configure regras de segurança** no Firebase Console
2. **Nunca commite** arquivos de configuração
3. **Use Authentication** para proteger dados
4. **Valide dados** antes de inserir

## 📱 Configurações Adicionais

### Android

No `android/build.gradle.kts`:
```kotlin
dependencies {
    classpath("com.google.gms:google-services:4.4.0")
}
```

No `android/app/build.gradle.kts`:
```kotlin
plugins {
    id("com.google.gms.google-services")
}
```

### iOS

No `ios/Podfile`, adicione:
```ruby
pod 'Firebase/Core'
```

Depois execute:
```bash
cd ios
pod install
```

## 📚 Recursos

- [Documentação Firebase Flutter](https://firebase.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com/)
- [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/)

