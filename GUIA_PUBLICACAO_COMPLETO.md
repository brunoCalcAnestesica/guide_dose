# 🚀 GUIA COMPLETO DE PUBLICAÇÃO - GUIDE DOSE

**Data**: Outubro 2025  
**Versão**: 2.0.0 (Build 1)  
**Status**: ✅ PRONTO PARA PUBLICAÇÃO

---

## 📋 ÍNDICE

1. [Preparação Android (Google Play)](#android-google-play)
2. [Preparação iOS (App Store)](#ios-app-store)
3. [Checklist de Pré-Publicação](#checklist)
4. [Materiais de Marketing](#marketing)
5. [Política de Privacidade](#privacidade)

---

## 🤖 ANDROID (GOOGLE PLAY)

### Passo 1: Criar Keystore de Assinatura

O Android exige que você assine seu APK/AAB com uma chave privada. **ATENÇÃO**: Guarde essa chave com segurança - se perdê-la, não poderá mais atualizar o app!

```bash
cd /Users/brunodaroz/StudioProjects/guide_dose/android

# Criar keystore (execute apenas UMA vez)
keytool -genkey -v -keystore upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload \
  -storepass 'SuaSenhaSegura123!' \
  -keypass 'SuaSenhaSegura123!' \
  -dname "CN=Bruno Daroz, OU=Medical Apps, O=Guide Dose, L=São Paulo, ST=SP, C=BR"
```

**⚠️ IMPORTANTE**: 
- Substitua `SuaSenhaSegura123!` por uma senha forte
- Anote a senha em local seguro
- Faça backup do arquivo `upload-keystore.jks`
- NUNCA commite o keystore no Git

### Passo 2: Configurar Arquivo de Propriedades

Crie o arquivo `android/key.properties`:

```properties
storePassword=SuaSenhaSegura123!
keyPassword=SuaSenhaSegura123!
keyAlias=upload
storeFile=upload-keystore.jks
```

**⚠️ IMPORTANTE**: Este arquivo já está no `.gitignore` - não commite!

### Passo 3: Build de Produção (Android)

```bash
cd /Users/brunodaroz/StudioProjects/guide_dose

# Limpar builds anteriores
flutter clean
flutter pub get

# Build AAB (recomendado para Google Play)
flutter build appbundle --release

# OU Build APK (para distribuição manual)
flutter build apk --release
```

**Arquivos gerados**:
- AAB: `build/app/outputs/bundle/release/app-release.aab` (~30-40 MB)
- APK: `build/app/outputs/apk/release/app-release.apk` (~50-60 MB)

### Passo 4: Google Play Console

1. **Acesse**: [Google Play Console](https://play.google.com/console)
2. **Criar App**: 
   - Nome: "Guide Dose"
   - Idioma padrão: Português (Brasil)
   - App ou jogo: App
   - Gratuito ou pago: Gratuito
3. **Configurar**:
   - Categoria: Medicina
   - Classificação de conteúdo: PEGI 3 / Livre
   - Público-alvo: Profissionais de saúde
4. **Upload**: 
   - Vá em "Versões de produção"
   - Criar nova versão
   - Upload do AAB
   - Preencher "Notas da versão"
5. **Informações da loja**:
   - Título: Guide Dose
   - Descrição curta (80 caracteres)
   - Descrição completa (4000 caracteres)
   - Ícone: 512x512 PNG
   - Screenshots: Mínimo 2, máximo 8
   - Banner: 1024x500 PNG

---

## 🍎 iOS (APP STORE)

### Passo 1: Verificar Configurações

✅ Já configurado:
- Bundle ID: `com.companyname.medcalc`
- Team ID: `Z9CACSUCBA`
- Nome: "Guide Dose"
- Versão: 2.0.0 (1)

### Passo 2: Build de Produção (iOS)

```bash
cd /Users/brunodaroz/StudioProjects/guide_dose

# Limpar builds anteriores
flutter clean
flutter pub get

# Build iOS
flutter build ios --release

# Abrir no Xcode
open ios/Runner.xcworkspace
```

### Passo 3: Archive no Xcode

1. **Selecionar dispositivo**: "Any iOS Device (arm64)"
2. **Product → Archive** (aguarde 5-10 minutos)
3. **Organizer abrirá automaticamente**
4. **Validate App** (opcional mas recomendado)
5. **Distribute App**:
   - Escolha: "App Store Connect"
   - Escolha: "Upload"
   - Opções de distribuição: deixe padrão
   - Re-sign: automático
   - Upload (aguarde 5-15 minutos)

### Passo 4: App Store Connect

1. **Acesse**: [App Store Connect](https://appstoreconnect.apple.com)
2. **Meus Apps → + → Novo App**:
   - Plataforma: iOS
   - Nome: Guide Dose
   - Idioma principal: Português (Brasil)
   - Bundle ID: com.companyname.medcalc
   - SKU: GUIDEDOSE001
3. **Informações do App**:
   - Categoria principal: Medicina
   - Categoria secundária: Referência
   - Classificação: 17+ (Informação médica)
4. **Preços e disponibilidade**:
   - Preço: Gratuito
   - Disponibilidade: Todos os países
5. **Preparar para envio**:
   - Aguardar processamento do build (10-30 min)
   - Selecionar o build
   - Preencher informações
   - Adicionar screenshots
   - Adicionar descrição
   - URL da política de privacidade (obrigatório)
6. **Enviar para análise**

---

## ✅ CHECKLIST DE PRÉ-PUBLICAÇÃO

### Android
- [ ] Keystore criado e salvo com segurança
- [ ] key.properties configurado
- [ ] AAB/APK compilado sem erros
- [ ] Testado em dispositivo físico
- [ ] Google Play Console configurado
- [ ] Screenshots preparadas (mínimo 2)
- [ ] Ícone 512x512 pronto
- [ ] Descrição escrita em português
- [ ] Política de privacidade publicada

### iOS
- [ ] Certificados de distribuição válidos
- [ ] Provisioning profiles atualizados
- [ ] Archive criado com sucesso
- [ ] Upload para App Store Connect concluído
- [ ] App registrado no App Store Connect
- [ ] Screenshots preparadas (iPhone + iPad)
- [ ] Ícone 1024x1024 pronto
- [ ] Descrição escrita em português
- [ ] Política de privacidade publicada

### Geral
- [ ] App testado em dispositivos reais
- [ ] Todas as funcionalidades verificadas
- [ ] Módulo PCR testado completamente
- [ ] Sem crashes ou erros críticos
- [ ] Política de privacidade criada
- [ ] Materiais de marketing prontos

---

## 📱 MATERIAIS DE MARKETING

### Screenshots Necessários

**Android** (mínimo 2 por dispositivo):
- Celular: 1080x1920 ou superior
- Tablet 7": 1024x600 ou superior
- Tablet 10": 1920x1200 ou superior

**iOS** (mínimo 3 por tamanho):
- iPhone 6.7": 1290x2796
- iPhone 6.5": 1242x2688
- iPad Pro 12.9": 2048x2732

### Sugestões de Screenshots:
1. **Tela inicial** - Mostrando entrada de dados do paciente
2. **Farmacoteca** - Lista de medicamentos
3. **Cálculo de medicação** - Exemplo de cálculo
4. **Módulo PCR** - Timer de RCP
5. **Fisiologia** - Cálculos de IMC, SC
6. **Indução** - Protocolo de indução
7. **Relatório PCR** - Exemplo de PDF gerado
8. **Configurações** - Preferências do app

### Ícones

✅ **Já configurados**:
- iOS: 1024x1024 em `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
- Android: Vários tamanhos em `android/app/src/main/res/mipmap-*/`

Se precisar criar novos ícones, use: [App Icon Generator](https://www.appicon.co/)

### Descrição do App (Português)

```
TÍTULO (30 caracteres):
Guide Dose - Cálculo Médico

DESCRIÇÃO CURTA (80 caracteres Android):
Calculadora médica para doses, infusões e protocolos de emergência

DESCRIÇÃO COMPLETA:
Guide Dose é um aplicativo médico profissional desenvolvido para auxiliar profissionais de saúde em cálculos clínicos e farmacológicos precisos.

🏥 FUNCIONALIDADES PRINCIPAIS:

📊 FISIOLOGIA
• Cálculo de IMC (Índice de Massa Corporal)
• Superfície Corporal (SC)
• Peso Ideal e Peso Ajustado
• Clearance de Creatinina
• Índice de Massa Corporal Pediátrico

💊 FARMACOTECA COMPLETA
• Mais de 130 medicamentos catalogados
• Cálculos automáticos de doses
• Conversão para ml/h em infusões
• Doses por peso, superfície e idade
• Informações de diluição e preparo

🚨 MÓDULO PCR (Parada Cardiorrespiratória)
• Timer de RCP com beep 115 BPM
• Protocolos ACLS e PALS
• Cálculo automático de medicações
• Registro de eventos em tempo real
• Geração de relatório PDF
• Compartilhamento de dados

💉 INDUÇÃO ANESTÉSICA
• Protocolos personalizados
• Cálculos baseados em peso e comorbidades
• Sugestões de doses seguras

📋 CONDIÇÕES CLÍNICAS
• Mais de 80 protocolos clínicos
• Orientações baseadas em evidências
• Referências bibliográficas

⚡ DIFERENCIAIS:
✓ Interface simples e intuitiva
✓ Funcionamento offline
✓ Sem coleta de dados pessoais
✓ Sem anúncios
✓ Gratuito
✓ Atualizado com literatura médica recente
✓ Desenvolvido por médico anestesiologista

⚠️ IMPORTANTE:
Este aplicativo é uma ferramenta de SUPORTE à decisão clínica. Não substitui o julgamento clínico profissional, a avaliação individual do paciente ou as diretrizes locais da instituição.

👨‍⚕️ PÚBLICO-ALVO:
• Médicos (todas as especialidades)
• Anestesiologistas
• Intensivistas
• Emergencistas
• Pediatras
• Enfermeiros
• Residentes e Estudantes de Medicina

🔒 PRIVACIDADE:
• Sem coleta de dados pessoais
• Sem rastreamento
• Dados armazenados apenas localmente
• Sem login necessário

📚 REFERÊNCIAS:
Baseado em:
• AHA Guidelines (American Heart Association)
• ERC Guidelines (European Resuscitation Council)
• Micromedex
• UpToDate
• Literatura médica revisada por pares

Desenvolvido por Bruno Daroz, médico anestesiologista.
```

### Palavras-chave (App Store)

```
calculadora médica, dose medicamento, infusão, PCR, RCP, emergência, farmacologia, anestesia, pediatria, UTI, medicina, protocolo, ACLS, PALS
```

---

## 🔒 POLÍTICA DE PRIVACIDADE

**OBRIGATÓRIO**: Você precisa criar uma página web com a política de privacidade.

### Opção 1: GitHub Pages (Gratuito)

1. Crie um repositório público no GitHub
2. Crie arquivo `privacy-policy.html`
3. Ative GitHub Pages
4. URL será: `https://seuusuario.github.io/guide-dose/privacy-policy.html`

### Opção 2: Site Simples

Use serviços como:
- GitHub Pages (gratuito)
- Netlify (gratuito)
- Vercel (gratuito)
- Google Sites (gratuito)

### Modelo de Política de Privacidade

```html
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Política de Privacidade - Guide Dose</title>
    <style>
        body { font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px; line-height: 1.6; }
        h1 { color: #2c3e50; }
        h2 { color: #3498db; margin-top: 30px; }
        .update { color: #7f8c8d; font-size: 0.9em; }
    </style>
</head>
<body>
    <h1>Política de Privacidade - Guide Dose</h1>
    <p class="update">Última atualização: Outubro de 2025</p>
    
    <h2>1. Introdução</h2>
    <p>O Guide Dose é um aplicativo médico desenvolvido para auxiliar profissionais de saúde em cálculos clínicos e farmacológicos. Levamos sua privacidade muito a sério.</p>
    
    <h2>2. Coleta de Dados</h2>
    <p><strong>O Guide Dose NÃO coleta, armazena ou transmite nenhum dado pessoal do usuário ou de pacientes.</strong></p>
    
    <h2>3. Armazenamento Local</h2>
    <p>O aplicativo armazena apenas preferências de configuração localmente no dispositivo usando SharedPreferences (Android) e UserDefaults (iOS). Estes dados incluem:</p>
    <ul>
        <li>Dados temporários do paciente para cálculos (peso, altura, idade)</li>
        <li>Preferências de interface do usuário</li>
        <li>Histórico de cálculos (apenas localmente)</li>
    </ul>
    <p><strong>Estes dados nunca saem do seu dispositivo.</strong></p>
    
    <h2>4. Permissões do Aplicativo</h2>
    <ul>
        <li><strong>Microfone (iOS)</strong>: Usado apenas para síntese de voz (TTS) durante emergências PCR</li>
        <li><strong>Galeria de Fotos</strong>: Apenas para salvar relatórios PDF gerados</li>
    </ul>
    
    <h2>5. Conexão com a Internet</h2>
    <p>O aplicativo funciona completamente offline. Nenhuma conexão com servidores externos é necessária ou realizada para funcionalidades principais.</p>
    
    <h2>6. Compartilhamento de Dados</h2>
    <p><strong>O Guide Dose NÃO compartilha nenhum dado com terceiros.</strong> Não usamos:</p>
    <ul>
        <li>Analytics</li>
        <li>Rastreamento de usuários</li>
        <li>Anúncios</li>
        <li>Serviços de terceiros que coletam dados</li>
    </ul>
    
    <h2>7. Dados de Pacientes</h2>
    <p>Quaisquer dados de pacientes inseridos no aplicativo são:</p>
    <ul>
        <li>Armazenados apenas localmente no dispositivo</li>
        <li>Não identificam o paciente (sem nome, CPF, etc)</li>
        <li>Podem ser apagados a qualquer momento pelo usuário</li>
        <li>Nunca são transmitidos pela internet</li>
    </ul>
    
    <h2>8. Segurança</h2>
    <p>Como não coletamos ou transmitimos dados, não há risco de vazamento de informações. Os dados locais são protegidos pelos mecanismos de segurança do sistema operacional (iOS/Android).</p>
    
    <h2>9. Alterações nesta Política</h2>
    <p>Podemos atualizar esta política ocasionalmente. Alterações serão publicadas nesta página com a data de atualização.</p>
    
    <h2>10. Contato</h2>
    <p>Para dúvidas sobre esta política de privacidade, entre em contato:</p>
    <p>Email: <a href="mailto:contato@guidedose.com">contato@guidedose.com</a></p>
    
    <h2>11. Responsabilidade</h2>
    <p><strong>IMPORTANTE</strong>: O Guide Dose é uma ferramenta de suporte à decisão clínica. Não substitui o julgamento clínico profissional ou a avaliação individual do paciente. O desenvolvedor não se responsabiliza por decisões clínicas tomadas com base nas informações fornecidas pelo aplicativo.</p>
    
    <hr>
    <p><small>© 2025 Bruno Daroz. Todos os direitos reservados.</small></p>
</body>
</html>
```

---

## 📞 SUPORTE E CONTATO

Crie um email de suporte para as lojas:
- Email: `contato@guidedose.com` (ou similar)
- Responda dúvidas de usuários
- Colete feedback
- Resolva problemas técnicos

---

## 🎯 PRÓXIMOS PASSOS IMEDIATOS

### 1️⃣ PREPARAR ANDROID (1-2 horas)
```bash
# Criar keystore
cd /Users/brunodaroz/StudioProjects/guide_dose/android
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# Configurar key.properties (ver instruções acima)

# Build
cd ..
flutter build appbundle --release
```

### 2️⃣ PREPARAR iOS (30 minutos)
```bash
cd /Users/brunodaroz/StudioProjects/guide_dose
flutter build ios --release
open ios/Runner.xcworkspace
# Seguir passos do Xcode Archive
```

### 3️⃣ CRIAR MATERIAIS (2-3 horas)
- [ ] Tirar screenshots (8 por plataforma)
- [ ] Escrever descrições
- [ ] Publicar política de privacidade
- [ ] Criar email de suporte

### 4️⃣ UPLOAD (1 hora por loja)
- [ ] Google Play Console
- [ ] App Store Connect

### 5️⃣ AGUARDAR REVISÃO
- Android: 1-3 dias
- iOS: 1-2 dias (primeira vez) ou 24 horas (atualizações)

---

## ⚠️ PROBLEMAS COMUNS

### Android
**Erro de assinatura**: Verifique se o keystore e key.properties estão corretos
**Build falha**: Execute `flutter clean && flutter pub get`
**AAB muito grande**: Normal, o Google Play otimiza por dispositivo

### iOS
**Certificado expirado**: Renovar no Apple Developer
**Archive falha**: Limpar build folder no Xcode
**Upload falha**: Verificar conexão e espaço no iCloud

---

## 📊 APÓS PUBLICAÇÃO

### Monitoramento
- Verifique reviews diariamente
- Responda feedbacks
- Monitore crashes (Google Play Console / App Store Connect)
- Atualize conforme necessário

### Atualizações
- Incremente versionCode (Android) e Build Number (iOS)
- Incremente versionName quando houver mudanças significativas
- Publique notas de versão claras

---

## ✅ STATUS ATUAL

| Item | Android | iOS |
|------|---------|-----|
| **Código** | ✅ | ✅ |
| **Configuração** | ⚠️ Precisa keystore | ✅ |
| **Build testado** | ✅ | ✅ |
| **Ícones** | ✅ | ✅ |
| **Permissões** | ✅ | ✅ |
| **Screenshots** | ⏳ Pendente | ⏳ Pendente |
| **Descrição** | ⏳ Pendente | ⏳ Pendente |
| **Política Privacidade** | ⏳ Pendente | ⏳ Pendente |
| **Console configurado** | ⏳ Pendente | ⏳ Pendente |

---

## 🎉 CONCLUSÃO

Você está a poucos passos de publicar o Guide Dose nas lojas!

**Tempo estimado total**: 6-10 horas de trabalho + 2-5 dias de revisão

**Boa sorte! 🚀**

