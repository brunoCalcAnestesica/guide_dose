# 🚀 Guia Completo: Preparação para App Store e Google Play

## 📱 Informações do App

| Campo | Valor |
|-------|-------|
| **Nome** | Guide Dose |
| **Versão** | 2.0.0 |
| **Build Number** | 1 |
| **iOS Bundle ID** | com.companyname.medcalc |
| **Android Package** | com.companyname.medcalc |
| **Categoria** | Medical / Saúde |
| **Desenvolvedor** | Bruno Daroz |

---

## 📋 Status Geral

### ✅ iOS - App Store
- ✅ Configurações completas
- ✅ Bundle ID configurado
- ✅ Info.plist configurado
- ✅ Ícones configurados
- ✅ Privacidade configurada
- ✅ Scripts de build prontos

**Status**: ✅ **PRONTO PARA BUILD E UPLOAD**

### ⚠️ Android - Google Play Store
- ✅ Configurações completas
- ✅ Package name configurado
- ✅ AndroidManifest.xml configurado
- ✅ Ícones configurados
- ✅ Build configurado
- ❌ **FALTA: Criar keystore**

**Status**: ⚠️ **AGUARDANDO CRIAÇÃO DO KEYSTORE**

---

## 🎯 Roadmap de Publicação

### Passo 1: Preparação do Android (PRIMEIRO)

#### 1.1. Criar Keystore

```bash
keytool -genkey -v -keystore android/upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

**Informações para preencher**:
- Senha do keystore: `[escolha uma senha forte]`
- Nome e sobrenome: `Bruno Daroz`
- Unidade organizacional: `Desenvolvimento`
- Organização: `Guide Dose`
- Cidade: `[sua cidade]`
- Estado: `[seu estado]`
- Código do país: `BR`

⚠️ **IMPORTANTE**: Faça backup do keystore e guarde as senhas com segurança!

#### 1.2. Criar key.properties

Crie o arquivo `android/key.properties`:

```properties
storePassword=SUA_SENHA_DO_KEYSTORE
keyPassword=SUA_SENHA_DA_KEY
keyAlias=upload
storeFile=../upload-keystore.jks
```

#### 1.3. Build do Android

```bash
./build_android.sh
```

Arquivo gerado: `build/app/outputs/bundle/release/app-release.aab`

### Passo 2: Preparação do iOS

#### 2.1. Limpar e preparar

```bash
flutter clean
flutter pub get
cd ios
pod install
cd ..
```

#### 2.2. Build para App Store

**Opção 1: Via script (recomendado)**
```bash
./build_app_store_final.sh
```

**Opção 2: Via Xcode**
```bash
open ios/Runner.xcworkspace
```

No Xcode:
1. Selecione "Any iOS Device (arm64)"
2. Product > Archive
3. Aguarde o build
4. Window > Organizer > Distribute App
5. Selecione "App Store Connect"
6. Upload

### Passo 3: Assets Necessários

#### Para Ambas as Plataformas

**Ícone do App**:
- ✅ iOS: Configurado em `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
- ✅ Android: Configurado em `android/app/src/main/res/mipmap-*/`

**Capturas de Tela** (mínimo 2, máximo 8 por dispositivo):

**iOS**:
- iPhone 6.7" (1290 x 2796) - iPhone 14 Pro Max
- iPhone 6.5" (1242 x 2688) - iPhone 11 Pro Max
- iPhone 5.5" (1242 x 2208) - iPhone 8 Plus
- iPad Pro 12.9" (2048 x 2732)

**Android**:
- Smartphone (1080 x 1920)
- Tablet 7" (1200 x 1920) - opcional
- Tablet 10" (1800 x 2560) - opcional

**Sugestões de telas para capturar**:
1. Tela inicial (Home)
2. Cálculo de dosagem de medicamento
3. Farmacoteca
4. Conversor de infusão
5. Módulo de indução anestésica
6. Módulo PCR

#### Somente para Google Play

**Feature Graphic** (obrigatório):
- Tamanho: 1024 x 500 px
- Formato: PNG ou JPEG (sem transparência)

**Ícone de Alta Resolução**:
- Tamanho: 512 x 512 px
- Formato: PNG (32-bit com alpha)

---

## 📝 Textos para as Lojas

### Nome do App
```
Guide Dose
```

### Subtítulo / Título Curto
```
Cálculos Médicos e Farmacológicos
```

### Descrição Curta (80 caracteres)
```
Cálculos médicos precisos para profissionais da saúde
```

### Descrição Longa

**Português**:
```
Guide Dose - Seu Assistente Médico de Bolso

Guide Dose é a ferramenta essencial para profissionais da saúde que precisam de cálculos médicos precisos e confiáveis. Desenvolvido especificamente para médicos, enfermeiros, farmacêuticos e outros profissionais da área, o aplicativo oferece recursos especializados para o dia a dia clínico.

🏥 RECURSOS PRINCIPAIS:

✓ Cálculos de Dosagem de Medicamentos
  - Cálculos precisos baseados em peso, idade e condição clínica
  - Suporte a diferentes vias de administração
  - Ajustes automáticos para pacientes pediátricos

✓ Farmacoteca Completa
  - Informações detalhadas sobre medicamentos
  - Doses recomendadas
  - Contraindicações e interações
  - Preparação e diluição

✓ Conversões de Unidades
  - Conversão entre diferentes unidades médicas
  - Cálculos de infusão (ml/h, gotas/min)
  - Conversões de concentração

✓ Cálculos Anestésicos
  - Doses para indução anestésica
  - Cálculos específicos para anestesia
  - Suporte a múltiplos protocolos

✓ Módulo PCR (Parada Cardiorrespiratória)
  - Cronômetro de PCR
  - Guias de medicação
  - Protocolos de atendimento

✓ Suporte Multilíngue
  - Português
  - Inglês
  - Espanhol
  - Chinês

🎯 DESENVOLVIDO PARA PROFISSIONAIS

Guide Dose foi criado pensando na rotina agitada dos profissionais da saúde. Interface intuitiva, cálculos rápidos e informações precisas ao alcance de um toque.

🔒 SEGURANÇA E PRIVACIDADE

- Não coleta dados pessoais
- Funciona offline
- Sem anúncios
- Sem rastreamento

⚕️ PARA QUEM É ESTE APP?

- Médicos
- Enfermeiros
- Farmacêuticos
- Estudantes de medicina
- Residentes
- Profissionais de UTI e emergência

📱 CARACTERÍSTICAS TÉCNICAS

- Interface moderna e limpa
- Funciona offline (não requer internet)
- Leve e rápido
- Compatível com tablets

⚠️ AVISO IMPORTANTE

Este aplicativo é uma ferramenta de apoio para profissionais da saúde. Sempre consulte as diretrizes clínicas locais e use seu julgamento profissional ao tomar decisões clínicas.

Desenvolvido por profissionais da saúde, para profissionais da saúde.
```

**Inglês** (para App Store internacional):
```
Guide Dose - Your Pocket Medical Assistant

Guide Dose is the essential tool for healthcare professionals who need accurate and reliable medical calculations. Developed specifically for doctors, nurses, pharmacists and other healthcare professionals, the app offers specialized features for daily clinical practice.

🏥 MAIN FEATURES:

✓ Drug Dosage Calculations
  - Precise calculations based on weight, age and clinical condition
  - Support for different routes of administration
  - Automatic adjustments for pediatric patients

✓ Complete Pharmacopoeia
  - Detailed drug information
  - Recommended doses
  - Contraindications and interactions
  - Preparation and dilution

✓ Unit Conversions
  - Conversion between different medical units
  - Infusion calculations (ml/h, drops/min)
  - Concentration conversions

✓ Anesthetic Calculations
  - Doses for anesthetic induction
  - Specific calculations for anesthesia
  - Support for multiple protocols

✓ CPR Module (Cardiopulmonary Resuscitation)
  - CPR timer
  - Medication guides
  - Treatment protocols

✓ Multilingual Support
  - Portuguese
  - English
  - Spanish
  - Chinese

🎯 DEVELOPED FOR PROFESSIONALS

Guide Dose was created with the busy routine of healthcare professionals in mind. Intuitive interface, quick calculations and accurate information at your fingertips.

🔒 SECURITY AND PRIVACY

- Does not collect personal data
- Works offline
- No ads
- No tracking

⚕️ WHO IS THIS APP FOR?

- Doctors
- Nurses
- Pharmacists
- Medical students
- Residents
- ICU and emergency professionals

📱 TECHNICAL FEATURES

- Modern and clean interface
- Works offline (no internet required)
- Lightweight and fast
- Tablet compatible

⚠️ IMPORTANT NOTICE

This application is a support tool for healthcare professionals. Always consult local clinical guidelines and use your professional judgment when making clinical decisions.

Developed by healthcare professionals, for healthcare professionals.
```

### Palavras-chave (Keywords)

**iOS** (até 100 caracteres, separados por vírgula):
```
medicina,farmacologia,cálculos,dosagem,anestesia,hospital,médico,enfermeiro,saúde
```

**Android** (tags separadas):
```
medicina
farmacologia
cálculos médicos
dosagem
anestesia
hospital
médico
enfermeiro
saúde
```

### Novidades da Versão (Release Notes)

**Versão 2.0.0**:
```
🎉 Lançamento oficial do Guide Dose!

• Cálculos precisos de dosagem de medicamentos
• Farmacoteca completa com informações detalhadas
• Conversões de unidades médicas
• Cálculos anestésicos especializados
• Módulo PCR para atendimento de emergência
• Suporte a múltiplos idiomas (PT, EN, ES, ZH)
• Interface intuitiva e moderna
• Funciona 100% offline

Desenvolvido para profissionais da saúde.
```

---

## 🔐 Informações de Privacidade

### Para App Store

**Coleta de Dados**: Não

**Rastreamento**: Não

**NSAppTransportSecurity**: Configurado (sem carregamento arbitrário)

**ITSAppUsesNonExemptEncryption**: false

### Para Google Play

**Política de Privacidade**: Necessário hospedar uma página web

**Conteúdo Sugerido**:
```
Política de Privacidade - Guide Dose

1. Coleta de Dados
   O Guide Dose NÃO coleta, armazena ou compartilha dados pessoais dos usuários.

2. Armazenamento de Dados
   Todos os dados são armazenados localmente no dispositivo.
   Não sincronizamos dados com servidores externos.

3. Permissões
   O aplicativo solicita apenas permissões essenciais para funcionar.
   Não acessamos contatos, localização ou outras informações sensíveis.

4. Compartilhamento de Dados
   Não compartilhamos dados com terceiros.
   Não vendemos informações de usuários.

5. Contato
   Email: [seu-email]
   Desenvolvedor: Bruno Daroz

Última atualização: 30 de Outubro de 2025
```

---

## 📊 Classificação de Conteúdo

### App Store
- **Classificação**: 4+ (para todos)
- **Categoria Principal**: Medical
- **Categoria Secundária**: Health & Fitness

### Google Play
- **Classificação**: Livre (Everyone)
- **Categoria**: Medical
- **Tipos de Conteúdo**: Informação médica educacional

---

## 💰 Preços e Disponibilidade

### Modelo de Negócio
- **Tipo**: Gratuito
- **Compras In-App**: Não
- **Anúncios**: Não

### Disponibilidade
- **Países**: Iniciar com Brasil, expandir globalmente
- **iOS**: iOS 12.0+
- **Android**: Android 5.0+ (API 21)

---

## ✅ Checklist Final de Publicação

### Antes de Enviar

#### Configuração
- [x] Bundle ID / Package name configurado
- [x] Versão definida (2.0.0)
- [x] Nome do app definido (Guide Dose)
- [x] Ícones configurados
- [x] Permissões configuradas
- [x] Metadados preenchidos

#### Android Específico
- [ ] Keystore criado
- [ ] key.properties criado
- [ ] Backup do keystore feito
- [ ] App Bundle (.aab) gerado
- [ ] Feature graphic criado (1024x500)

#### iOS Específico
- [x] Certificado de distribuição configurado
- [x] Provisioning profile configurado
- [ ] Archive criado no Xcode
- [ ] Upload para App Store Connect feito

#### Assets
- [ ] Capturas de tela (mínimo 2)
- [ ] Ícone 512x512 (Android)
- [ ] Ícone 1024x1024 (iOS)
- [ ] Feature graphic (Android)
- [ ] Descrições traduzidas
- [ ] Política de privacidade hospedada

#### Testes
- [ ] Testado em dispositivos iOS reais
- [ ] Testado em dispositivos Android reais
- [ ] Todas as funcionalidades testadas
- [ ] Sem crashes conhecidos
- [ ] Performance aceitável

### Durante Upload

#### App Store Connect
- [ ] Conta Apple Developer ativa (US$ 99/ano)
- [ ] App criado no App Store Connect
- [ ] Build enviado via Xcode ou Transporter
- [ ] Informações preenchidas
- [ ] Capturas de tela adicionadas
- [ ] Preços configurados
- [ ] Disponibilidade configurada
- [ ] Enviado para revisão

#### Google Play Console
- [ ] Conta Google Play Console ativa (US$ 25 único)
- [ ] Aplicativo criado no console
- [ ] App Bundle enviado
- [ ] Informações da loja preenchidas
- [ ] Capturas de tela adicionadas
- [ ] Classificação de conteúdo completa
- [ ] Preços e distribuição configurados
- [ ] Enviado para revisão

### Após Upload
- [ ] Responder perguntas da Apple/Google
- [ ] Acompanhar status da revisão
- [ ] Preparar marketing/divulgação
- [ ] Configurar analytics (opcional)
- [ ] Planejar atualizações futuras

---

## 🛠️ Scripts Disponíveis

### Android
```bash
./build_android.sh          # Build do App Bundle para Google Play
```

### iOS
```bash
./build_app_store_final.sh  # Build para App Store
./build_appstore.sh         # Build alternativo
./build_testflight.sh       # Build para TestFlight
```

---

## 📚 Documentação de Referência

### Criados no Projeto
- `GUIA_KEYSTORE_ANDROID.md` - Como criar keystore
- `GOOGLE_PLAY_STORE_READY.md` - Checklist Google Play
- `APP_STORE_READY.md` - Checklist App Store
- `APP_STORE_INFO.md` - Informações detalhadas App Store

### Externos
- [Flutter Deployment - Android](https://flutter.dev/docs/deployment/android)
- [Flutter Deployment - iOS](https://flutter.dev/docs/deployment/ios)
- [App Store Connect Help](https://help.apple.com/app-store-connect/)
- [Google Play Console Help](https://support.google.com/googleplay/android-developer)

---

## 📞 Informações de Contato

**Desenvolvedor**: Bruno Daroz  
**Email**: [seu-email@exemplo.com]  
**Website**: [seu-website.com]  
**Suporte**: [email-suporte@exemplo.com]

---

## 🎯 Próximos Passos Recomendados

### Imediato (Hoje)
1. ✅ Ler este documento completamente
2. 🔴 **CRIAR KEYSTORE DO ANDROID** (ver GUIA_KEYSTORE_ANDROID.md)
3. 🔴 Executar `./build_android.sh`
4. 🔴 Criar capturas de tela (mínimo 2)
5. 🔴 Criar feature graphic para Android (1024x500)

### Curto Prazo (Esta Semana)
6. 📱 Registrar conta Google Play Console (US$ 25)
7. 📱 Fazer upload do Android para Google Play
8. 🍎 Executar build do iOS via Xcode
9. 🍎 Fazer upload do iOS para App Store Connect
10. 📝 Criar e hospedar política de privacidade

### Médio Prazo (Próximas 2 Semanas)
11. ⏳ Aguardar aprovação das lojas (1-7 dias cada)
12. ⏳ Responder solicitações de revisão (se houver)
13. 🎉 Publicar apps
14. 📢 Divulgar lançamento
15. 📊 Monitorar feedback inicial

---

## 🎉 Conclusão

O aplicativo **Guide Dose** está **pronto para publicação** em ambas as lojas!

**Falta apenas**:
- 🔴 Criar keystore do Android
- 🔴 Preparar assets gráficos (capturas de tela, feature graphic)
- 🔴 Hospedar política de privacidade

**Tempo estimado para conclusão**: 2-4 horas de trabalho

**Tempo de revisão das lojas**: 
- Google Play: 1-3 dias
- App Store: 1-7 dias

**Data estimada de publicação**: Dentro de 1-2 semanas

---

**Última atualização**: 30 de Outubro de 2025  
**Status**: ✅ Documentação Completa

