# Guia de Publicação na Apple App Store - Guide Dose

## Índice
1. [Informações do App](#informações-do-app)
2. [Pré-requisitos](#pré-requisitos)
3. [Processo de Build](#processo-de-build)
4. [Configuração no App Store Connect](#configuração-no-app-store-connect)
5. [Metadados Necessários](#metadados-necessários)
6. [Screenshots e Preview](#screenshots-e-preview)
7. [Revisão e Aprovação](#revisão-e-aprovação)
8. [Troubleshooting](#troubleshooting)

---

## Informações do App

| Campo | Valor |
|-------|-------|
| **Nome** | Guide Dose |
| **Bundle ID** | com.companyname.medcalc |
| **Versão** | 3.7.0 |
| **Build** | 1 |
| **Team ID** | Z9CACSUCBA |
| **Categoria** | Medical |
| **Plataforma Mínima** | iOS 15.5 |
| **Dispositivos** | iPhone e iPad |

---

## Pré-requisitos

### Conta Apple Developer
- [ ] Conta de desenvolvedor Apple ativa ($99/ano)
- [ ] Acesso ao App Store Connect
- [ ] Certificados de distribuição válidos

### Ferramentas Necessárias
- [ ] Xcode 15.0 ou superior
- [ ] Flutter SDK 3.0+
- [ ] CocoaPods instalado
- [ ] Acesso a um Mac

### Configurações do Projeto
- [x] Bundle ID registrado
- [x] App ID configurado no Apple Developer Portal
- [x] Provisioning Profile de distribuição
- [x] Info.plist configurado
- [x] PrivacyInfo.xcprivacy incluído
- [x] Ícones em todas as resoluções

---

## Processo de Build

### Método Automatizado (Recomendado)

```bash
# Na raiz do projeto
./build_app_store.sh
```

Este script irá:
1. Limpar builds anteriores
2. Instalar dependências
3. Compilar o app para release
4. Verificar arquivos de configuração
5. Abrir o Xcode (opcional)

### Método Manual

```bash
# 1. Limpar o projeto
flutter clean
rm -rf ios/Pods ios/.symlinks

# 2. Instalar dependências
flutter pub get

# 3. Instalar CocoaPods
cd ios && pod install --repo-update && cd ..

# 4. Build para iOS
flutter build ios --release --no-codesign

# 5. Abrir no Xcode
open ios/Runner.xcworkspace
```

### Archive no Xcode

1. Abra `ios/Runner.xcworkspace` no Xcode
2. Selecione **Any iOS Device (arm64)** como destino
3. Verifique o **Team** e **Signing** em Runner > Signing & Capabilities
4. Vá em **Product > Archive**
5. Aguarde o processo de archive

### Upload para App Store Connect

1. No Organizer (abre automaticamente após Archive):
   - Clique em **Distribute App**
   - Selecione **App Store Connect**
   - Escolha **Upload**
2. Verifique os avisos (se houver)
3. Aguarde o upload e processamento

---

## Configuração no App Store Connect

### 1. Criar o App (se ainda não existe)

1. Acesse [App Store Connect](https://appstoreconnect.apple.com)
2. Vá para **Meus Apps**
3. Clique em **+** > **Novo App**
4. Preencha:
   - **Plataformas**: iOS
   - **Nome**: Guide Dose
   - **Idioma Primário**: Português (Brasil)
   - **Bundle ID**: com.companyname.medcalc
   - **SKU**: GUIDEDOSE001

### 2. Configurar Informações do App

Na aba **App Information**:
- **Nome**: Guide Dose
- **Subtitle** (opcional): Calculadora Médica
- **Categoria Primária**: Medical
- **Categoria Secundária**: Health & Fitness (opcional)
- **Classificação de Conteúdo**: Preencher questionário
- **Licença de uso**: Sua licença

### 3. Configurar Preços e Disponibilidade

Na aba **Pricing and Availability**:
- **Preço**: Gratuito (ou selecione um preço)
- **Disponibilidade**: Todos os países/regiões

---

## Metadados Necessários

### Descrição do App (obrigatório)

```
Guide Dose é uma calculadora médica completa desenvolvida para profissionais de saúde. 
O aplicativo oferece cálculos precisos de doses de medicamentos, parâmetros clínicos 
e protocolos médicos essenciais.

PRINCIPAIS RECURSOS:
• Calculadora de doses de medicamentos
• Farmacoteca completa com informações detalhadas
• Protocolos de PCR e emergência
• Calculadora de indução anestésica
• Conversores de unidades médicas
• Cálculos de infusão contínua
• Condições clínicas e tratamentos

CARACTERÍSTICAS:
✓ Interface intuitiva e fácil de usar
✓ Funciona 100% offline
✓ Dados seguros armazenados localmente
✓ Atualizações regulares de conteúdo
✓ Suporte a múltiplos idiomas

AVISO IMPORTANTE:
Este aplicativo é uma ferramenta de apoio para profissionais da saúde. 
Não substitui o julgamento clínico profissional. Sempre consulte as 
diretrizes clínicas locais e use seu julgamento profissional ao tomar 
decisões clínicas.
```

### Palavras-chave (até 100 caracteres)

```
medicamentos,doses,calculadora,médico,farmácia,anestesia,PCR,emergência,clínico,saúde
```

### URLs Necessárias

| Campo | URL |
|-------|-----|
| **URL de Suporte** | https://seusite.com/suporte |
| **URL de Marketing** | https://seusite.com (opcional) |
| **Política de Privacidade** | https://seusite.com/privacidade |

### Notas para Revisão (opcional)

```
Guide Dose é um aplicativo para profissionais de saúde que auxilia 
em cálculos de doses de medicamentos e parâmetros clínicos.

O app funciona 100% offline e não requer login ou conta de usuário.
Não coletamos dados pessoais.

Para testar o aplicativo, navegue pelos diferentes módulos:
- Home > Calculadora de Doses
- Home > Farmacoteca
- Home > Protocolos PCR
```

---

## Screenshots e Preview

### Tamanhos Necessários

#### iPhone
| Tamanho | Dispositivo | Dimensões |
|---------|-------------|-----------|
| 6.7" | iPhone 14 Pro Max | 1290 x 2796 |
| 6.5" | iPhone 11 Pro Max | 1242 x 2688 |
| 5.5" | iPhone 8 Plus | 1242 x 2208 |

#### iPad
| Tamanho | Dispositivo | Dimensões |
|---------|-------------|-----------|
| 12.9" | iPad Pro (6th gen) | 2048 x 2732 |
| 11" | iPad Pro (4th gen) | 1668 x 2388 |

### Sugestões de Screenshots

1. **Tela Home** - Visão geral dos módulos
2. **Calculadora de Doses** - Exemplo de cálculo
3. **Farmacoteca** - Lista de medicamentos
4. **Detalhe do Medicamento** - Informações completas
5. **Protocolo PCR** - Interface do protocolo
6. **Configurações** - Opções do app

---

## Revisão e Aprovação

### Tempo Médio de Revisão
- **Primeira submissão**: 24-48 horas
- **Atualizações**: 24 horas
- **Apps médicos**: Pode levar mais tempo

### Motivos Comuns de Rejeição

1. **Bugs ou crashes**
   - Teste exaustivamente antes de submeter
   
2. **Metadados incompletos**
   - Preencha todos os campos obrigatórios
   
3. **Screenshots inadequadas**
   - Use screenshots reais do app
   
4. **Política de privacidade ausente**
   - Inclua URL válida para política de privacidade
   
5. **Funcionalidade incompleta**
   - Todas as funcionalidades devem estar funcionando

### Resposta a Rejeições

Se o app for rejeitado:
1. Leia cuidadosamente o motivo no Resolution Center
2. Faça as correções necessárias
3. Incremente o build number
4. Resubmeta o app
5. Responda no Resolution Center explicando as correções

---

## Troubleshooting

### Erro: "No signing certificate"
```bash
# Solução: Renovar certificados no Xcode
Xcode > Preferences > Accounts > Manage Certificates
```

### Erro: "Provisioning profile doesn't include signing certificate"
```bash
# Solução: Atualizar profiles
Xcode > Preferences > Accounts > Download Manual Profiles
```

### Erro: "Invalid Binary"
- Verifique se não há código de debug
- Verifique se não há frameworks de simulador
- Certifique-se de compilar para "Any iOS Device"

### Erro: "Missing Compliance"
- O app já declara `ITSAppUsesNonExemptEncryption: false` no Info.plist
- Se usar criptografia, preencha o formulário de compliance

### Build muito grande
```bash
# Otimizar tamanho do build
flutter build ios --release --split-debug-info=./debug-info
```

---

## Checklist Final

### Antes do Build
- [ ] Versão atualizada no pubspec.yaml
- [ ] Changelog atualizado
- [ ] Testes executados com sucesso
- [ ] Nenhum TODO ou código de debug

### Antes do Upload
- [ ] Archive criado com sucesso
- [ ] Certificados válidos
- [ ] Nenhum aviso crítico no Organizer

### No App Store Connect
- [ ] Metadados preenchidos
- [ ] Screenshots enviadas
- [ ] Política de privacidade configurada
- [ ] Preço/disponibilidade configurados
- [ ] Build selecionado

### Após Submissão
- [ ] Verificar status em "Meus Apps"
- [ ] Monitorar Resolution Center
- [ ] Responder rapidamente a questões

---

## Contatos Úteis

- **Apple Developer Support**: https://developer.apple.com/contact/
- **App Store Connect Help**: https://help.apple.com/app-store-connect/
- **Documentação Flutter iOS**: https://docs.flutter.dev/deployment/ios

---

*Última atualização: Fevereiro 2026*
