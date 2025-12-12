# 🚀 COMECE AQUI - Guide Dose

## 👋 Bem-vindo!

Este é o **Guide Dose v2.0.0**, seu aplicativo médico para cálculos clínicos e farmacológicos.

O app está **PRONTO PARA SER PUBLICADO** na App Store (iOS) e Google Play Store (Android)!

---

## ⚡ Início Rápido - 3 Minutos

### ✅ O que está pronto:
- ✅ Código do aplicativo completo
- ✅ Configurações de iOS e Android
- ✅ Ícones e assets básicos
- ✅ Scripts de build automatizados
- ✅ Documentação completa

### ❌ O que você precisa fazer:
1. **Criar keystore do Android** (15 min) - [Ver como](#passo-1-android-keystore)
2. **Fazer builds de release** (30 min) - [Ver como](#passo-2-builds)
3. **Criar capturas de tela** (1-2 horas) - [Ver dicas](#passo-3-screenshots)
4. **Upload nas lojas** (2-3 horas) - [Ver processo](#passo-4-upload)

**Tempo total: 4-6 horas de trabalho**

---

## 📚 Navegação Rápida

<table>
<tr>
<td width="50%">

### 🎯 Para Começar AGORA
1. **README_PUBLICACAO.md** ⭐  
   _Comandos e início rápido_

2. **CHECKLIST_RAPIDO.md**  
   _Lista de tarefas_

3. **GUIA_KEYSTORE_ANDROID.md**  
   _Criar keystore (obrigatório)_

</td>
<td width="50%">

### 📖 Para Ler Depois
1. **PREPARACAO_LOJAS_COMPLETA.md**  
   _Guia completo detalhado_

2. **RESUMO_EXECUTIVO.md**  
   _Visão geral do projeto_

3. **INDICE_DOCUMENTACAO.md**  
   _Índice de todos os docs_

</td>
</tr>
</table>

---

## 🎯 Passo a Passo Detalhado

### Passo 1: Android Keystore

**Obrigatório para publicar no Google Play**

```bash
# Execute este comando:
keytool -genkey -v -keystore android/upload-keystore.jks \
  -storetype JKS -keyalg RSA -keysize 2048 \
  -validity 10000 -alias upload
```

**O que preencher:**
- Senha: `[escolha uma senha forte e GUARDE!]`
- Nome: `Bruno Daroz`
- Organização: `Guide Dose`
- Cidade, Estado, País: `[seus dados]`

**IMPORTANTE:** 
- ⚠️ Faça backup do arquivo `android/upload-keystore.jks`
- ⚠️ Guarde as senhas com segurança
- ⚠️ Se perder, não poderá atualizar o app!

**Depois:**
1. Copie `android/key.properties.example` para `android/key.properties`
2. Preencha com suas senhas

📖 **Detalhes completos em:** `GUIA_KEYSTORE_ANDROID.md`

---

### Passo 2: Builds

#### 🤖 Android
```bash
./build_android.sh
```
Arquivo gerado: `build/app/outputs/bundle/release/app-release.aab`

#### 🍎 iOS
```bash
./build_app_store_final.sh
```
OU
```bash
open ios/Runner.xcworkspace
# No Xcode: Product > Archive
```

---

### Passo 3: Screenshots

**Você precisa de:**

#### Mínimo (obrigatório):
- 2 capturas de tela para Android (1080 x 1920)
- 2 capturas de tela para iOS (tamanhos variados)
- 1 feature graphic para Android (1024 x 500)

#### Sugestões de telas para capturar:
1. 🏠 Tela inicial
2. 💊 Farmacoteca
3. 🧮 Cálculo de dosagem
4. 💉 Conversor de infusão
5. 🚑 Módulo PCR
6. 💤 Indução anestésica

**Dica:** Use um emulador ou dispositivo real e tire prints!

---

### Passo 4: Upload

#### 🤖 Google Play Store

1. **Acesse:** https://play.google.com/console
2. **Crie conta** (US$ 25 - pagamento único)
3. **Crie aplicativo**
4. **Upload do AAB:** `app-release.aab`
5. **Preencha informações:**
   - Nome: Guide Dose
   - Descrição: [copie de PREPARACAO_LOJAS_COMPLETA.md]
   - Screenshots
   - Feature graphic
   - Política de privacidade
6. **Envie para revisão**

📖 **Guia completo em:** `GOOGLE_PLAY_STORE_READY.md`

#### 🍎 App Store

1. **Acesse:** https://appstoreconnect.apple.com
2. **Verifique conta** Apple Developer (US$ 99/ano)
3. **No Xcode:** Product > Archive > Distribute App
4. **No App Store Connect:**
   - Crie o app
   - Selecione o build
   - Preencha informações
   - Adicione screenshots
   - Configure preços
5. **Envie para revisão**

📖 **Guia completo em:** `APP_STORE_READY.md`

---

## 📋 Informações Úteis

### App Info
```
Nome:        Guide Dose
Versão:      2.0.0
Build:       1
Bundle ID:   com.companyname.medcalc
Categoria:   Medical / Saúde
Preço:       Gratuito
```

### Descrição Curta
```
Cálculos médicos precisos para profissionais da saúde
```

### Palavras-chave
```
medicina, farmacologia, cálculos, dosagem, anestesia, 
hospital, médico, enfermeiro, saúde
```

---

## 💰 Custos

| Loja | Valor | Frequência |
|------|------:|:----------:|
| Google Play | US$ 25 | Única |
| App Store | US$ 99 | Anual |
| **TOTAL** | **US$ 124** | - |

---

## ⏱️ Timeline

```
HOJE (15 min)
└─ Criar keystore Android

HOJE (30 min)
└─ Fazer builds

AMANHÃ (2-3 horas)
├─ Criar screenshots
└─ Criar feature graphic

DIA 3 (3-4 horas)
├─ Registrar nas lojas
└─ Upload e configuração

DIAS 4-10 (1-7 dias)
└─ Aguardar revisão

PUBLICAÇÃO! 🎉
```

---

## 🆘 Precisa de Ajuda?

### Problemas Comuns

**"Não sei por onde começar"**
→ Leia `README_PUBLICACAO.md`

**"Como criar o keystore?"**
→ Leia `GUIA_KEYSTORE_ANDROID.md`

**"O que falta fazer?"**
→ Leia `CHECKLIST_RAPIDO.md`

**"Erro no build"**
→ Execute `flutter clean && flutter pub get`

**"Preciso de mais detalhes"**
→ Leia `PREPARACAO_LOJAS_COMPLETA.md`

---

## 📞 Recursos

- **Documentação Flutter:** https://flutter.dev/docs
- **Google Play Console:** https://play.google.com/console
- **App Store Connect:** https://appstoreconnect.apple.com

---

## ✅ Checklist Mínimo

Antes de publicar, certifique-se:

- [ ] Keystore do Android criado
- [ ] key.properties configurado
- [ ] Backup do keystore feito
- [ ] Build Android (.aab) gerado
- [ ] Build iOS (.ipa) gerado
- [ ] Mínimo 2 screenshots criados
- [ ] Feature graphic criado (Android)
- [ ] Política de privacidade hospedada
- [ ] Conta Google Play criada
- [ ] Conta Apple Developer ativa
- [ ] Testado em dispositivos reais
- [ ] Sem crashes conhecidos

---

## 🎯 Sua Missão

```
┌─────────────────────────────────────────┐
│                                         │
│   🎯 OBJETIVO: PUBLICAR GUIDE DOSE      │
│                                         │
│   📱 Status: 90% Pronto                 │
│   ⏱️  Tempo restante: 4-6 horas         │
│   📅 Publicação: 1-2 semanas            │
│                                         │
│   Próximo passo:                        │
│   👉 Ler README_PUBLICACAO.md           │
│                                         │
└─────────────────────────────────────────┘
```

---

## 🚀 Comece Agora!

1. **Abra:** `README_PUBLICACAO.md`
2. **Siga:** As instruções passo a passo
3. **Use:** `CHECKLIST_RAPIDO.md` como guia
4. **Consulte:** Outros documentos quando necessário

---

## 📚 Todos os Documentos

```
COMECE_AQUI.md                    ← Você está aqui
├── README_PUBLICACAO.md          ← Próximo passo
├── CHECKLIST_RAPIDO.md           ← Lista de tarefas
├── RESUMO_EXECUTIVO.md           ← Visão geral
├── PREPARACAO_LOJAS_COMPLETA.md  ← Guia completo
│
├── Android/
│   ├── GUIA_KEYSTORE_ANDROID.md
│   ├── GOOGLE_PLAY_STORE_READY.md
│   └── build_android.sh
│
├── iOS/
│   ├── APP_STORE_READY.md
│   ├── APP_STORE_INFO.md
│   └── build_app_store_final.sh
│
└── Outros/
    ├── POLITICA_PRIVACIDADE.md
    └── INDICE_DOCUMENTACAO.md
```

---

**Última atualização:** 30 de Outubro de 2025  
**Versão do app:** 2.0.0+1  
**Status:** ✅ Pronto para publicar

---

# 🎉 Boa sorte com a publicação!

**Você consegue!** 💪

O app está **excelente** e **bem configurado**.  
Falta apenas completar os passos finais.

📖 **Comece lendo:** `README_PUBLICACAO.md`

🚀 **Vamos publicar este app!**

---

