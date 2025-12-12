# 🚀 INSTRUÇÕES PARA ARCHIVE NO XCODE

## ✅ STATUS ATUAL

- ✅ Pods instalados: 5 dependências
- ✅ DerivedData limpo
- ✅ Build preparado
- ✅ **PRONTO PARA ARCHIVE**

---

## 📋 PASSO A PASSO PARA ARCHIVE

### **1. Abrir o projeto no Xcode**

```bash
cd /Users/brunodaroz/StudioProjects/guide_dose
open ios/Runner.xcworkspace
```

⚠️ **IMPORTANTE:** Abra **Runner.xcworkspace** (NÃO Runner.xcodeproj)

---

### **2. No Xcode - Configurações Iniciais**

1. **Aguarde o Xcode indexar** (barra de progresso no topo)
2. **Selecione o destino**: No menu superior, escolha **"Any iOS Device (arm64)"**
3. **Verifique o esquema**: Certifique-se de que está selecionado **"Runner"**

---

### **3. Limpar Build (IMPORTANTE)**

1. Menu: **Product** → **Clean Build Folder**
   - Ou use o atalho: **⇧⌘K** (Shift + Command + K)
2. Aguarde a limpeza completar

---

### **4. Fazer o Archive**

1. Menu: **Product** → **Archive**
2. **Aguarde a compilação** (~30-60 segundos)
3. O Xcode irá:
   - Compilar o código
   - Linkar os módulos (incluindo path_provider_foundation)
   - Gerar o arquivo IPA
   - Abrir o **Organizer** automaticamente

---

### **5. No Organizer (quando abrir)**

1. Você verá seu arquivo listado
2. Clique em **"Distribute App"**
3. Selecione: **"App Store Connect"**
4. Clique: **"Next"**
5. Selecione as opções:
   - ✅ Upload (padrão)
   - ✅ Include bitcode for iOS content (se disponível)
   - ✅ Upload your app's symbols (recomendado)
6. Clique: **"Next"**
7. Revise e clique: **"Upload"**
8. Aguarde o upload (pode levar 5-15 minutos)

---

## ⚠️ SE DER ERRO NO ARCHIVE

### **Erro: "Module 'path_provider_foundation' not found"**

Execute no terminal:

```bash
cd /Users/brunodaroz/StudioProjects/guide_dose/ios
rm -rf Pods Podfile.lock
pod install --repo-update
```

Depois, no Xcode:
1. **Product → Clean Build Folder**
2. Feche e reabra o Xcode
3. Tente **Product → Archive** novamente

---

### **Erro: "Signing for 'Runner' requires a development team"**

1. No Xcode, clique no projeto **"Runner"** (azul, no lado esquerdo)
2. Selecione o target **"Runner"**
3. Aba **"Signing & Capabilities"**
4. Em **"Team"**, selecione sua equipe Apple Developer
5. Certifique-se de que **"Automatically manage signing"** está marcado

---

### **Erro de Provisioning Profile**

1. Na aba **"Signing & Capabilities"**
2. Clique em **"Download Manual Profiles"**
3. Ou desmarque e marque novamente **"Automatically manage signing"**

---

## 📱 APÓS O UPLOAD

### **No App Store Connect**

1. Acesse: https://appstoreconnect.apple.com
2. Entre com sua conta Apple Developer
3. Vá em **"My Apps"**
4. Clique em seu app (ou **"+ App"** se for novo)
5. Na seção **"Build"**:
   - O build pode levar 10-30 minutos para aparecer
   - Quando aparecer, selecione-o
6. Preencha todas as informações necessárias:
   - Screenshots (5-8 imagens)
   - Descrição
   - Palavras-chave
   - Categoria: **Medical**
   - Classificação etária: **17+** (conteúdo médico)
   - Política de privacidade (URL)
7. Clique em **"Submit for Review"**

---

## ✅ CHECKLIST FINAL

Antes de submeter, certifique-se:

- [ ] Bundle ID correto: `com.companyname.medcalc`
- [ ] Versão: `2.0.0` (Build `1`)
- [ ] Ícones: Todos os tamanhos presentes
- [ ] Screenshots: 5-8 imagens de qualidade
- [ ] Descrição: Clara e completa
- [ ] Disclaimer médico na descrição
- [ ] Política de privacidade: URL válida
- [ ] Categoria: Medical
- [ ] Classificação: 17+

---

## 🎯 INFORMAÇÕES DO APP

**Nome:** Guide Dose  
**Bundle ID:** com.companyname.medcalc  
**Versão:** 2.0.0  
**Build:** 1  
**Categoria:** Medical  
**Classificação:** 17+ (Conteúdo médico profissional)

---

## 📝 SUGESTÃO DE DESCRIÇÃO

```
Guide Dose - Calculadora Médica e Farmacológica

Aplicativo médico profissional para cálculos clínicos, farmacológicos e 
atendimento de emergência.

FUNCIONALIDADES PRINCIPAIS:
• Cálculos fisiológicos (IMC, SC, etc)
• Farmacoteca com 134 medicamentos
• Doses por peso, idade e condição clínica
• Protocolos de indução anestésica
• Módulo completo de Parada Cardiorrespiratória (PCR)
• Timer de RCP com ritmo de 115 BPM
• Registro detalhado de eventos
• Geração e compartilhamento de relatórios PDF

IMPORTANTE:
Este aplicativo é uma ferramenta de suporte à decisão clínica e não 
substitui o julgamento médico profissional. Sempre verifique as doses 
e protocolos com as diretrizes atualizadas e literatura médica.

PÚBLICO-ALVO:
Médicos, enfermeiros e profissionais de saúde.
```

---

## 🎉 PRONTO!

Seu app está completamente preparado para publicação na Apple App Store!

**Boa sorte com o upload! 🚀**

