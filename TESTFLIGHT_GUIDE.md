# Guia para Upload no TestFlight - MedCalc (GuideDose)

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
- **Display Name**: `MedCalc`
- **Version**: `2.0.0 (1)`
- **Team ID**: `Z9CACSUCBA`
- **Arquivo de Privacidade**: Incluído (`PrivacyInfo.xcprivacy`)
- **Configurações de Segurança**: App Transport Security configurado
- **Criptografia**: Marcado como não usa criptografia não-isenta

## Processo de Build e Upload

### Método 1: Usando o Script Automatizado

```bash
./build_testflight.sh
```

### Método 2: Manual

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
   - Na janela do Organizer, clique em "Distribute App"
   - Selecione "App Store Connect"
   - Selecione "Upload"
   - Siga as instruções na tela

## Verificações Importantes

### Antes do Upload:
- [ ] Versão incrementada no `pubspec.yaml`
- [ ] Certificados válidos
- [ ] Provisioning profiles atualizados
- [ ] App Store Connect configurado

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

## Informações Técnicas

### Configurações do Info.plist:
- `CFBundleDisplayName`: MedCalc
- `CFBundleIdentifier`: com.companyname.medcalc
- `CFBundleShortVersionString`: $(FLUTTER_BUILD_NAME)
- `CFBundleVersion`: $(FLUTTER_BUILD_NUMBER)
- `ITSAppUsesNonExemptEncryption`: false
- `NSAppTransportSecurity`: Configurado para segurança

### Suporte a Dispositivos:
- iPhone e iPad
- iOS 12.0+
- Orientações: Portrait, Landscape Left, Landscape Right

## Contato

Para dúvidas sobre o processo de upload, consulte:
- [Documentação oficial da Apple](https://developer.apple.com/testflight/)
- [Guia do Flutter para iOS](https://docs.flutter.dev/deployment/ios)
