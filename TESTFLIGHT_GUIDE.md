# Guia para Upload no TestFlight - Guide Dose

## Pré-requisitos

Antes de começar, certifique-se de que você tem:

1. ✅ Conta de desenvolvedor Apple ativa
2. ✅ App registrado no App Store Connect
3. ✅ Certificado de distribuição configurado
4. ✅ Provisioning profile atualizado
5. ✅ Xcode instalado e configurado

## Configurações do Projeto

O projeto já foi configurado com:

- **Bundle ID**: `com.companyname.medcalc`
- **Display Name**: `Guide Dose`
- **Version**: `3.6.3` (build vem do `pubspec.yaml`, ex.: `3.6.3+11` → versão 3.6.3, build 11; o Xcode usa `$(FLUTTER_BUILD_NAME)` e `$(FLUTTER_BUILD_NUMBER)` gerados pelo Flutter)
- **Team ID**: `Z9CACSUCBA`
- **iOS Mínimo**: `15.5`
- **Arquivo de Privacidade**: Incluído (`PrivacyInfo.xcprivacy`)
- **Configurações de Segurança**: App Transport Security configurado
- **Criptografia**: Marcado como não usa criptografia não-isenta

## Processo de Build e Upload

### Método 1: Script automatizado (recomendado)

O script faz o fluxo completo pela CLI (build, archive, export e opcionalmente upload), usando `ios/ExportOptions.plist` com `uploadSymbols = false`, evitando o erro "Upload Symbols Failed".

```bash
./build_testflight.sh
```

- **Sem variáveis de ambiente:** o script gera o IPA em `build/upload/` e exibe instruções para enviar com o app **Transporter** (Mac App Store) ou com `xcrun altool`.
- **Com upload automático:** defina `APPLE_ID` e `APPLE_APP_SPECIFIC_PASSWORD` (senha de app em appleid.apple.com) antes de rodar; o script envia o IPA para o App Store Connect ao final.

  ```bash
  export APPLE_ID="seu_email@appleid.com"
  export APPLE_APP_SPECIFIC_PASSWORD="xxxx-xxxx-xxxx-xxxx"
  ./build_testflight.sh
  ```

### Método 2: Manual (Xcode + Transporter ou CLI)

1. **Limpar o projeto**:
   ```bash
   flutter clean
   flutter pub get
   cd ios && pod install && cd ..
   ```

2. **Build para iOS**:
   ```bash
   flutter build ios --release --no-codesign
   ```

3. **Abrir no Xcode**:
   ```bash
   open ios/Runner.xcworkspace
   ```

4. **Configurar no Xcode**:
   - Selecione "Any iOS Device (arm64)" como destino
   - Vá em Product > Archive
   - Aguarde o processo de archive

5. **Upload para TestFlight**:
   - Em muitas versões do Xcode a opção de desmarcar envio de símbolos **não aparece** no fluxo "Distribute App" (especialmente em "TestFlight Internal Only"), e o upload falha com "Upload Symbols Failed". Por isso o **Método 1 (script)** é recomendado.
   - Se ainda assim usar o Xcode: na janela do Organizer, "Distribute App" → "App Store Connect" → "Upload". Se houver a opção, **desmarque** "Upload your app's symbols to App Store Connect".
   - **Alternativa após Archive no Xcode:** exportar pela CLI e enviar com Transporter (veja seção "Upload Symbols Failed" abaixo).

### Export e upload pela linha de comando (archive já criado)

Se você já criou o archive no Xcode e quer apenas exportar o IPA (sem enviar símbolos) e depois enviar:

```bash
xcodebuild -exportArchive -archivePath "<caminho-do-.xcarchive>" -exportOptionsPlist ios/ExportOptions.plist -exportPath ./build/upload
```

Depois envie o `.ipa` em `./build/upload` com o app **Transporter** ou com:

```bash
xcrun altool --upload-app -f ./build/upload/*.ipa -t ios -u "$APPLE_ID" -p "$APPLE_APP_SPECIFIC_PASSWORD"
```

## Verificações Importantes

### Antes do Upload:
- [ ] Versão e build únicos no `pubspec.yaml` (ex.: `3.6.3+11`); o Xcode usa `$(FLUTTER_BUILD_NAME)` e `$(FLUTTER_BUILD_NUMBER)`
- [ ] Certificados válidos (Xcode > Settings > Accounts)
- [ ] Provisioning profile (Xcode escolhe automaticamente com Code Signing = Automatic ao fazer Archive)
- [ ] App criado no App Store Connect com o mesmo Bundle ID `com.companyname.medcalc`
- [ ] Destino "Any iOS Device (arm64)" selecionado antes de Product > Archive

### Após o Upload:
- [ ] Build aparece no App Store Connect
- [ ] Nenhum erro de processamento
- [ ] TestFlight configurado para testers

## Solução de Problemas Comuns

### Erro de Certificado
- Verifique se o certificado de distribuição está válido
- Renove se necessário no Apple Developer Portal

### Erro de Provisioning Profile
- Atualize o provisioning profile no Xcode
- Certifique-se de que inclui o dispositivo de teste

### Erro de Bundle ID
- Verifique se o Bundle ID no Xcode corresponde ao registrado no App Store Connect

### Erro de Versão
- Certifique-se de que a versão/build number é única
- Incremente o build number se necessário

### "Upload Symbols Failed" (dSYM do objective_c.framework)
- O archive não inclui dSYM para o framework de sistema `objective_c.framework`, e o Xcode falha ao enviar símbolos no fluxo "Distribute App" (a opção de desmarcar símbolos muitas vezes não aparece).
- **Solução recomendada:** Use o **Método 1 (script)** `./build_testflight.sh`. Ele faz archive + export com `uploadSymbols = false` (via `ios/ExportOptions.plist`) e opcionalmente o upload; o erro não ocorre.
- **Se preferir o Xcode para o Archive:** depois de criar o archive no Organizer, use export pela CLI e Transporter: `xcodebuild -exportArchive -archivePath "<caminho-do-.xcarchive>" -exportOptionsPlist ios/ExportOptions.plist -exportPath ./build/upload`, depois envie o `.ipa` em `./build/upload` com o app **Transporter**.
- O projeto tem `uploadSymbols = false` em `ios/ExportOptions.plist`; o script e o export pela CLI respeitam isso.

## Informações Técnicas

### Versão e build
- Definidos no `pubspec.yaml` (ex.: `version: 3.6.3+11`). O Flutter gera `FLUTTER_BUILD_NAME` e `FLUTTER_BUILD_NUMBER` em `ios/Flutter/Generated.xcconfig`; o Xcode usa essas variáveis para `MARKETING_VERSION` e `CURRENT_PROJECT_VERSION`.

### Configurações do Info.plist:
- `CFBundleDisplayName`: Guide Dose
- `CFBundleIdentifier`: com.companyname.medcalc
- `CFBundleShortVersionString`: $(FLUTTER_BUILD_NAME)
- `CFBundleVersion`: $(FLUTTER_BUILD_NUMBER)
- `ITSAppUsesNonExemptEncryption`: false
- `NSAppTransportSecurity`: Configurado para segurança

### Suporte a Dispositivos:
- iPhone e iPad
- iOS 15.5+
- Orientações: Portrait, Landscape Left, Landscape Right

## Contato

Para dúvidas sobre o processo de upload, consulte:
- [Documentação oficial da Apple](https://developer.apple.com/testflight/)
- [Guia do Flutter para iOS](https://docs.flutter.dev/deployment/ios)
