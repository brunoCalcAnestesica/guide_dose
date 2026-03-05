# Checklist Unico - Publicacao nas Lojas

**App**: Guide Dose  
**Versao**: 3.7.0+1  
**Bundle ID / Package**: com.companyname.medcalc  
**Data**: Fevereiro 2026

---

## Itens Comuns (iOS e Android)

### Versao e Build
- [ ] Conferir `version` no [pubspec.yaml](pubspec.yaml) (atual: 3.7.0+1)
- [ ] Se necessario, incrementar o build number antes de novo upload

### Metadados das Lojas
- [ ] Nome do app: **Guide Dose**
- [ ] Descricao curta (ate 80 caracteres)
- [ ] Descricao completa (ate 4000 caracteres)
- [ ] Palavras-chave (ate 100 caracteres, somente App Store)
- [ ] Categoria primaria: **Medical**
- [ ] Classificacao etaria: **17+** (conteudo medico)

### Screenshots
- [ ] Screenshots de iPhone (6.7", 6.5", 5.5")
- [ ] Screenshots de iPad (12.9", 11")
- [ ] Screenshots de Android (telefone e tablet, se aplicavel)
- [ ] Imagens reais do app, sem molduras enganosas

### URLs Obrigatorias
- [ ] URL da Politica de Privacidade publicada em pagina web publica
- [ ] URL de Suporte (pode ser email ou pagina web)
- [ ] URL de Marketing (opcional)

### Politica de Privacidade
- [ ] Texto base em [POLITICA_PRIVACIDADE.md](POLITICA_PRIVACIDADE.md)
- [ ] Publicar o conteudo em URL publica acessivel (ex.: GitHub Pages, site proprio)
- [ ] Inserir a URL nas duas lojas

---

## iOS - App Store

### Pre-Build
- [ ] Conta Apple Developer ativa ($99/ano)
- [ ] Certificados de distribuicao validos (Xcode > Preferences > Accounts)
- [ ] Provisioning Profile de distribuicao atualizado
- [ ] App registrado no App Store Connect com Bundle ID `com.companyname.medcalc`

### Build e Upload
```bash
# Opcao 1: Script automatizado
./build_app_store.sh

# Opcao 2: Manual
flutter clean
flutter pub get
cd ios && pod install --repo-update && cd ..
flutter build ios --release --no-codesign
open ios/Runner.xcworkspace
```
- [ ] No Xcode: selecionar **Any iOS Device (arm64)**
- [ ] Conferir Team e Signing em Runner > Signing & Capabilities
- [ ] **Product > Archive**
- [ ] No Organizer: **Distribute App > App Store Connect > Upload**
- [ ] Aguardar processamento (pode levar 15-30 min)

### No App Store Connect
- [ ] Build processado e visivel em "Meus Apps"
- [ ] Selecionar o build na versao
- [ ] Preencher metadados (descricao, palavras-chave, categoria)
- [ ] Inserir URL de politica de privacidade e URL de suporte
- [ ] Adicionar screenshots nos tamanhos exigidos
- [ ] Preencher classificacao etaria (questionario)
- [ ] Notas para revisao (opcional, mas recomendado para apps medicos)
- [ ] Enviar para revisao

### Configuracoes ja prontas (verificadas)
- [x] Info.plist com ITSAppUsesNonExemptEncryption: false
- [x] PrivacyInfo.xcprivacy incluido
- [x] Permissoes declaradas (calendario, camera, galeria)
- [x] Copyright 2026
- [x] Deep links configurados (guidedose://)
- [x] Icones em todas as resolucoes

---

## Android - Google Play

### Pre-Build
- [ ] Conta Google Play Console ativa (US$ 25 unico)
- [ ] Keystore criado (ver [GUIA_KEYSTORE_ANDROID.md](GUIA_KEYSTORE_ANDROID.md))
- [ ] Arquivo `key.properties` na raiz do projeto com:
  - `storeFile` (caminho do keystore)
  - `storePassword`
  - `keyAlias`
  - `keyPassword`

### Build
```bash
flutter clean
flutter pub get
flutter build appbundle --release
```
- [ ] AAB gerado em `build/app/outputs/bundle/release/app-release.aab`

### Na Play Console
- [ ] Criar app com package `com.companyname.medcalc`
- [ ] Preencher ficha da loja (descricao, screenshots, feature graphic 1024x500)
- [ ] Inserir URL de politica de privacidade
- [ ] Preencher classificacao de conteudo (questionario)
- [ ] Definir publico-alvo e conteudo
- [ ] Fazer upload do `.aab`
- [ ] Preencher notas de versao
- [ ] Enviar para revisao

### Configuracoes ja prontas (verificadas)
- [x] build.gradle.kts com signing config de release
- [x] ProGuard/R8 habilitado (isMinifyEnabled + isShrinkResources)
- [x] compileSdk 36
- [x] Permissoes declaradas no AndroidManifest
- [x] Widgets Android configurados
- [x] Icone adaptativo (foreground + background)

---

## Pos-Upload (ambas as lojas)

- [ ] Aguardar processamento do build
- [ ] Verificar se nao ha alertas ou erros no build
- [ ] Confirmar que o build esta selecionado na versao
- [ ] Submeter para revisao
- [ ] Monitorar status da revisao
- [ ] Responder rapidamente ao Resolution Center (iOS) ou alertas (Android)

---

## Tempos Estimados

| Etapa | Tempo |
|-------|-------|
| Build e upload iOS | 30-60 min |
| Build e upload Android | 15-30 min |
| Preenchimento metadados (por loja) | 1-2 horas |
| Revisao App Store | 24-48 horas |
| Revisao Google Play | 1-3 dias |

---

## Documentacao Relacionada

| Arquivo | Conteudo |
|---------|----------|
| [APP_STORE_GUIDE.md](APP_STORE_GUIDE.md) | Guia detalhado App Store |
| [GOOGLE_PLAY_STORE_READY.md](GOOGLE_PLAY_STORE_READY.md) | Checklist Google Play |
| [GUIA_KEYSTORE_ANDROID.md](GUIA_KEYSTORE_ANDROID.md) | Como criar keystore Android |
| [POLITICA_PRIVACIDADE.md](POLITICA_PRIVACIDADE.md) | Texto da politica de privacidade |
| [VERIFICACAO_FINAL_APP_STORE.md](VERIFICACAO_FINAL_APP_STORE.md) | Verificacao tecnica completa |

---

*Ultima atualizacao: Fevereiro 2026*
