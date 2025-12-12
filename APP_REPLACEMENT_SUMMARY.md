# Resumo da Substituição do Aplicativo MedCalc

## 📋 Informações Extraídas do App Existente

### Identificação do App Original
- **Nome**: MedCalc
- **Tecnologia**: .NET MAUI
- **Android Package**: `com.companyname.medcalc.maui`
- **iOS Bundle ID**: `com.companyname.medcalc`
- **Team ID**: `Z9CACSUCBA` (MEDCALK LTDA)
- **Versão iOS**: 1.2.3
- **Versão Android**: 1.0

### Recursos Visuais Copiados
- ✅ Ícones do app (todas as resoluções para Android)
- ✅ Ícone principal para iOS
- ✅ Recursos de splash screen

## 🔄 Configurações Aplicadas no GuideDose

### Android
- **Package Name**: `com.companyname.medcalc.maui`
- **App Label**: "MedCalc"
- **Ícones**: Copiados do app original
- **Versão**: 2.0.0+1 (incrementada para substituição)

### iOS
- **Bundle ID**: `com.companyname.medcalc`
- **Display Name**: "MedCalc"
- **Team ID**: `Z9CACSUCBA`
- **Ícones**: Copiados do app original
- **Versão**: 2.0.0 (1)

### Flutter
- **Nome do Projeto**: `guidedose` (mantido internamente)
- **Versão**: 2.0.0+1
- **Código**: Atualizado para usar "MedCalc" na interface

## 🚀 Próximos Passos para Substituição

### 1. App Store Connect (iOS)
- O app será reconhecido como uma atualização do MedCalc existente
- Bundle ID: `com.companyname.medcalc`
- Team ID: `Z9CACSUCBA`

### 2. Google Play Store (Android)
- O app será reconhecido como uma atualização do MedCalc existente
- Package Name: `com.companyname.medcalc.maui`

### 3. Build e Upload
```bash
# Para iOS (TestFlight)
./build_testflight.sh

# Para Android
flutter build appbundle --release
```

## ⚠️ Considerações Importantes

1. **Certificados**: Usar os mesmos certificados do app original
2. **Provisioning Profiles**: Usar os profiles existentes
3. **App Store Connect**: O app aparecerá como atualização do MedCalc
4. **Google Play**: O app aparecerá como atualização do MedCalc
5. **Versão**: Incrementada para 2.0.0 para garantir substituição

## 📱 Resultado Final

O GuideDose agora está configurado para substituir completamente o MedCalc existente, mantendo:
- Mesmos identificadores de app
- Mesmos ícones e recursos visuais
- Mesma equipe de desenvolvimento
- Versão superior para garantir substituição

O usuário final receberá o GuideDose como uma atualização do MedCalc, mantendo todos os dados e configurações existentes.
