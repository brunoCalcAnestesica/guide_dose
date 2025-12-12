# 🚀 Guia Completo - Upload para App Store

## ✅ Pré-Requisitos Verificados

- ✅ **Bundle ID**: `com.companyname.medcalc`
- ✅ **Versão**: 2.0.0 (Build 1)
- ✅ **Nome do App**: Guide Dose
- ✅ **Copyright**: © 2025 Bruno Daroz
- ✅ **Build iOS**: Compilado com sucesso
- ✅ **Tamanho**: 36.9MB

---

## 📋 PASSO 1: Configurar Certificados e Provisioning Profiles

### 1.1 Acesse o Apple Developer Portal
```
https://developer.apple.com/account
```

### 1.2 Crie/Verifique os Certificados
1. Vá em **Certificates, Identifiers & Profiles**
2. Crie um **iOS Distribution Certificate** (se não tiver)
3. Baixe e instale no Keychain Access

### 1.3 Registre o App ID
1. Em **Identifiers**, verifique se `com.companyname.medcalc` está registrado
2. Se não estiver, crie um novo App ID:
   - **Description**: Guide Dose
   - **Bundle ID**: `com.companyname.medcalc`
   - **Capabilities**: Nenhuma especial necessária

### 1.4 Crie o Provisioning Profile
1. Em **Profiles**, crie um novo **App Store Distribution Profile**
2. Selecione o App ID: `com.companyname.medcalc`
3. Selecione o certificado de distribuição
4. Baixe e instale (duplo-clique)

---

## 📋 PASSO 2: Configurar App no App Store Connect

### 2.1 Acesse App Store Connect
```
https://appstoreconnect.apple.com
```

### 2.2 Criar Novo App
1. Clique em **"+ Nova App"**
2. Preencha:
   - **Plataforma**: iOS
   - **Nome**: Guide Dose
   - **Idioma Principal**: Português (Brasil)
   - **Bundle ID**: `com.companyname.medcalc`
   - **SKU**: `guidedose-2025` (ou outro único)
   - **Acesso Total**: Sim

### 2.3 Preencher Informações do App

#### **Informações Gerais**
- **Nome**: Guide Dose
- **Subtítulo**: Cálculos Médicos e PCR
- **Categoria Principal**: Medicina
- **Categoria Secundária**: Referência

#### **Descrição**
```
Guide Dose é o aplicativo essencial para profissionais da saúde, oferecendo:

🩺 FUNCIONALIDADES PRINCIPAIS
• Cálculos de dosagem de medicamentos
• Conversões de unidades médicas
• Cálculos de infusão
• Farmacoteca completa com informações detalhadas
• Protocolos de Indução Anestésica

❤️ PARADA CARDIORRESPIRATÓRIA (PCR)
• Assistente de RCP com timer automático
• Cálculos automáticos de medicações (Adrenalina, Amiodarona, Lidocaína)
• Modos ACLS e PALS
• Registro completo de eventos
• Geração de relatórios em PDF

📊 PARÂMETROS FISIOLÓGICOS
• IMC e Superfície Corporal
• Clearance de Creatinina
• Cálculos hemodinâmicos
• E muito mais!

Desenvolvido para médicos, enfermeiros, farmacêuticos e estudantes da área da saúde.
```

#### **Palavras-chave**
```
medicina,farmacologia,cálculos,dosagem,anestesia,hospital,médico,enfermeiro,pcr,rcp,acls,pals
```

#### **URL de Suporte**
```
https://seu-site.com/suporte
```

#### **URL de Marketing** (opcional)
```
https://seu-site.com
```

#### **Informações de Privacidade**
- **Política de Privacidade URL**: (você precisará criar uma)
- **Coleta de Dados**: Não (o app não coleta dados do usuário)

---

## 📋 PASSO 3: Preparar Capturas de Tela

### 3.1 Tamanhos Necessários

Você precisará de capturas de tela para:

1. **iPhone 6.7"** (iPhone 15 Pro Max, 14 Pro Max)
   - 1290 x 2796 pixels
   - 3-10 screenshots

2. **iPhone 6.5"** (iPhone 11 Pro Max, XS Max)
   - 1242 x 2688 pixels
   - 3-10 screenshots

3. **iPad Pro 12.9"** (6ª geração)
   - 2048 x 2732 pixels
   - 3-10 screenshots

### 3.2 Sugestões de Capturas de Tela
1. Tela de dados do paciente
2. Tela de cálculos fisiológicos
3. Tela de farmacoteca/medicamentos
4. Tela de indução anestésica
5. Tela de PCR/RCP
6. Tela de relatório de eventos

### 3.3 Como Tirar Screenshots no Simulador
```bash
# Abra o simulador iOS desejado
open -a Simulator

# Use Command + S para tirar screenshot
# Ou Window > Take Screenshot
```

---

## 📋 PASSO 4: Fazer Archive e Upload

### 4.1 Abrir no Xcode
```bash
cd /Users/brunodaroz/StudioProjects/guide_dose
open ios/Runner.xcworkspace
```

### 4.2 Configurar Signing & Capabilities
1. No Xcode, selecione o projeto **Runner**
2. Vá para a aba **Signing & Capabilities**
3. Em **Release**:
   - ✅ Marque **Automatically manage signing**
   - Selecione seu **Team**
   - Verifique se o **Bundle Identifier** é `com.companyname.medcalc`

### 4.3 Selecionar Dispositivo
1. No topo do Xcode, clique no seletor de dispositivo
2. Selecione **"Any iOS Device (arm64)"**

### 4.4 Fazer o Archive
1. Menu: **Product > Archive**
2. Aguarde a compilação (pode levar alguns minutos)
3. Quando terminar, o Organizer abrirá automaticamente

### 4.5 Upload para App Store Connect
1. No **Organizer**, selecione o archive que você acabou de criar
2. Clique em **Distribute App**
3. Selecione **App Store Connect**
4. Clique em **Upload**
5. Aceite as opções padrão:
   - ✅ Upload your app's symbols
   - ✅ Manage version and build number
6. Clique em **Next** e depois **Upload**
7. Aguarde o upload completar

---

## 📋 PASSO 5: Submeter para Revisão

### 5.1 Aguardar Processamento
Após o upload, aguarde 10-30 minutos para o App Store Connect processar o build.

### 5.2 Selecionar o Build
1. Volte para **App Store Connect**
2. Vá para seu app **Guide Dose**
3. Clique em **+ Versão** ou edite a versão existente
4. Em **Build**, clique em **Adicionar Build**
5. Selecione o build que você acabou de enviar

### 5.3 Informações de Classificação Etária
Responda ao questionário de conteúdo:
- Violência: Não
- Médico/Tratamento: **Sim** (informações médicas)
- Temas Adultos: Não
- etc.

### 5.4 Informações de Exportação
- **Criptografia**: Não (já configurado no Info.plist)

### 5.5 Submeter
1. Revise todas as informações
2. Clique em **Adicionar para Revisão**
3. Clique em **Submeter para Revisão**

---

## 📋 PASSO 6: Aguardar Aprovação

### 6.1 Tempo Médio
- ⏱️ Revisão: 24-48 horas
- ✅ Se aprovado: App vai ao ar automaticamente (ou na data agendada)
- ❌ Se rejeitado: Você receberá feedback com os motivos

### 6.2 Status Possíveis
- **Aguardando Revisão**: Seu app está na fila
- **Em Revisão**: Apple está revisando
- **Aprovado**: App foi aprovado e está disponível
- **Rejeitado**: Você precisa fazer ajustes e reenviar
- **Pronto para Venda**: App está disponível na App Store

---

## 🔄 Atualizações Futuras

### Para publicar uma atualização:

1. **Atualizar versão no pubspec.yaml**
```yaml
version: 2.0.1+2  # Incrementar versão e build number
```

2. **Fazer novo build**
```bash
flutter clean
flutter pub get
flutter build ios --release
```

3. **Repetir PASSO 4** (Archive e Upload)

4. **Criar nova versão no App Store Connect**
   - Descrever "O que há de novo"
   - Selecionar novo build
   - Submeter para revisão

---

## ✅ Checklist Final

Antes de submeter, verifique:

- [ ] Testou o app em dispositivo real iOS
- [ ] Testou todas as funcionalidades principais
- [ ] Testou o módulo PCR completo
- [ ] Capturas de tela preparadas (todos os tamanhos)
- [ ] Descrição e palavras-chave revisadas
- [ ] Ícone do app está correto (1024x1024)
- [ ] Certificados e profiles configurados
- [ ] Build fez upload com sucesso
- [ ] Política de Privacidade criada (se necessário)
- [ ] Informações de contato corretas

---

## 📞 Suporte

Em caso de dúvidas:
- Apple Developer Support: https://developer.apple.com/support
- App Store Connect Help: https://developer.apple.com/app-store-connect

---

## 🎉 Boa Sorte!

Seu app está pronto para ser publicado na App Store! 🚀

