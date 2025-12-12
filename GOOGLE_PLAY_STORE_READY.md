# 🤖 Google Play Store - Checklist Completo

## Status: PRONTO PARA CONFIGURAR

O aplicativo **Guide Dose** está configurado e pronto para ser enviado para a Google Play Store após a criação do keystore.

---

## ✅ Configurações Concluídas

### 1. **Identificação do App**
- ✅ Application ID: `com.companyname.medcalc`
- ✅ Nome do app: "Guide Dose"
- ✅ Versão: 2.0.0 (versionCode: 1)

### 2. **Configurações Técnicas**
- ✅ minSdkVersion: 21 (Android 5.0)
- ✅ targetSdkVersion: 36 (Android 14)
- ✅ compileSdk: 36
- ✅ Arquitetura: arm64-v8a, armeabi-v7a, x86_64

### 3. **Build Configuration**
- ✅ Build de release configurado
- ✅ Minificação habilitada (minifyEnabled)
- ✅ Recursos reduzidos (shrinkResources)
- ✅ ProGuard configurado
- ✅ Assinatura configurada (falta keystore)

### 4. **Ícones e Assets**
- ✅ Ícones configurados para todas as densidades:
  - mipmap-mdpi (48x48)
  - mipmap-hdpi (72x72)
  - mipmap-xhdpi (96x96)
  - mipmap-xxhdpi (144x144)
  - mipmap-xxxhdpi (192x192)

### 5. **Permissões**
- ✅ INTERNET (para futuras funcionalidades)
- ✅ WRITE_EXTERNAL_STORAGE (legado, maxSdk 32)
- ✅ READ_EXTERNAL_STORAGE (legado, maxSdk 32)

### 6. **Metadados**
- ✅ Nome de exibição configurado
- ✅ AndroidManifest.xml otimizado
- ✅ Tema configurado

---

## 📋 Informações do App para Google Play Console

### Informações Básicas

| Campo | Valor |
|-------|-------|
| **Nome do App** | Guide Dose |
| **Título Curto** | Guide Dose - Cálculos Médicos |
| **Descrição Curta** | Aplicativo médico para cálculos clínicos e farmacológicos precisos |
| **Package Name** | com.companyname.medcalc |
| **Categoria** | Medical |
| **Classificação de Conteúdo** | Livre (Everyone) |
| **Países** | Brasil (expandir conforme necessário) |

### Descrição Completa (até 4000 caracteres)

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

### Descrição Curta (até 80 caracteres)

```
Cálculos médicos precisos para profissionais da saúde
```

---

## 📸 Capturas de Tela Necessárias

### Smartphone (Obrigatório)
- **Tamanho**: 1080 x 1920 (portrait) ou 1920 x 1080 (landscape)
- **Quantidade**: Mínimo 2, máximo 8
- **Formato**: PNG ou JPEG (24-bit, sem alpha)

### Tablet 7" (Opcional)
- **Tamanho**: 1200 x 1920 (portrait)
- **Quantidade**: Mínimo 2, máximo 8

### Tablet 10" (Opcional)
- **Tamanho**: 1800 x 2560 (portrait)
- **Quantidade**: Mínimo 2, máximo 8

### Sugestões de Telas para Capturar:
1. Tela inicial (Home)
2. Tela de cálculo de dosagem
3. Farmacoteca
4. Conversor de infusão
5. Módulo de indução anestésica
6. Módulo PCR

---

## 🎨 Recursos Gráficos

### Ícone do App (Obrigatório)
- ✅ **Tamanho**: 512 x 512 px
- ✅ **Formato**: PNG (32-bit, com alpha)
- ✅ **Status**: Configurado

### Feature Graphic (Obrigatório)
- **Tamanho**: 1024 x 500 px
- **Formato**: PNG ou JPEG (24-bit, sem alpha)
- **Status**: ❌ Precisa criar

### Banner Promocional (Opcional)
- **Tamanho**: 180 x 120 px
- **Formato**: PNG ou JPEG (24-bit, sem alpha)

### Vídeo Promocional (Opcional)
- Link do YouTube
- Duração: até 30 segundos

---

## 🔐 Checklist de Assinatura

- [ ] Keystore criado (siga GUIA_KEYSTORE_ANDROID.md)
- [ ] Arquivo key.properties criado
- [ ] Backup do keystore feito em local seguro
- [ ] Senhas guardadas com segurança

---

## 🚀 Passos para Upload

### 1. Criar Keystore (se ainda não criou)

```bash
# Siga o guia em GUIA_KEYSTORE_ANDROID.md
keytool -genkey -v -keystore android/upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

### 2. Criar key.properties

Crie o arquivo `android/key.properties` com base no exemplo `android/key.properties.example`

### 3. Build do App Bundle

```bash
# Execute o script de build
./build_android.sh

# Ou manualmente:
flutter clean
flutter pub get
flutter build appbundle --release
```

### 4. Localizar o App Bundle

O arquivo estará em:
```
build/app/outputs/bundle/release/app-release.aab
```

### 5. Acessar Google Play Console

1. Acesse: https://play.google.com/console
2. Clique em "Criar aplicativo"
3. Preencha as informações básicas

### 6. Upload do App Bundle

1. Vá em "Produção" > "Criar nova versão"
2. Faça upload do arquivo `app-release.aab`
3. Preencha as notas de versão

### 7. Configurar Informações da Loja

- Nome do app
- Descrição curta e longa
- Capturas de tela
- Ícone
- Feature graphic
- Categoria: Medical
- Email de contato
- Política de privacidade (URL)

### 8. Classificação de Conteúdo

- Preencha o questionário
- Para app médico, geralmente será "Livre"

### 9. Preços e Distribuição

- Definir como gratuito ou pago
- Selecionar países
- Aceitar termos

### 10. Revisar e Publicar

- Revisar todas as informações
- Enviar para análise
- Aguardar aprovação (geralmente 1-7 dias)

---

## 📝 Informações Legais

### Política de Privacidade

Você precisará criar uma política de privacidade e hospedar em um site acessível. Conteúdo sugerido:

```
Política de Privacidade - Guide Dose

O Guide Dose não coleta, armazena ou compartilha dados pessoais dos usuários.

1. Coleta de Dados
   - Não coletamos informações pessoais
   - Não rastreamos atividades dos usuários
   - Não utilizamos cookies ou tecnologias de rastreamento

2. Armazenamento de Dados
   - Todos os dados são armazenados localmente no dispositivo
   - Não sincronizamos dados com servidores externos

3. Compartilhamento de Dados
   - Não compartilhamos dados com terceiros
   - Não vendemos informações de usuários

4. Contato
   - Email: [seu-email]
   - Desenvolvedor: Bruno Daroz

Última atualização: 30 de Outubro de 2025
```

---

## ✅ Checklist Final

### Antes de Enviar
- [ ] App testado em dispositivos reais Android
- [ ] Todas as funcionalidades funcionando
- [ ] Sem crashes ou bugs conhecidos
- [ ] Keystore criado e backup feito
- [ ] App bundle (.aab) gerado com sucesso
- [ ] Capturas de tela preparadas (mínimo 2)
- [ ] Feature graphic criado (1024x500)
- [ ] Ícone 512x512 pronto
- [ ] Descrições escritas (curta e longa)
- [ ] Política de privacidade criada e hospedada
- [ ] Email de contato definido

### Durante o Upload
- [ ] Conta Google Play Console criada
- [ ] Taxa de registro paga (US$ 25, pagamento único)
- [ ] Aplicativo criado no console
- [ ] App bundle enviado
- [ ] Informações da loja preenchidas
- [ ] Classificação de conteúdo completa
- [ ] Preços e distribuição configurados

### Após o Upload
- [ ] Todas as informações revisadas
- [ ] Enviado para análise
- [ ] Acompanhar status da análise
- [ ] Responder solicitações da Google (se houver)

---

## 🎯 Status Atual: AGUARDANDO KEYSTORE

Após criar o keystore seguindo o guia `GUIA_KEYSTORE_ANDROID.md`, você estará pronto para:

1. Executar `./build_android.sh`
2. Fazer upload do app para Google Play Console
3. Publicar o app

---

## 📞 Suporte

Se tiver problemas durante o processo:

1. Consulte a [documentação oficial do Flutter](https://flutter.dev/docs/deployment/android)
2. Consulte a [documentação do Google Play](https://support.google.com/googleplay/android-developer)
3. Verifique os logs de build em `build/app/outputs/`

---

**Tamanho estimado do APK**: ~30-40MB
**Tamanho estimado do AAB**: ~25-30MB
**Status**: ✅ Pronto para criação do keystore e build

