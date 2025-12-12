# 📱 Guide Dose - Resumo de Publicação

## ✅ Status: PRONTO PARA PUBLICAR

---

## 🚀 Início Rápido

### Para Android (Google Play Store)

1. **Criar Keystore** (apenas uma vez):
   ```bash
   keytool -genkey -v -keystore android/upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

2. **Criar arquivo key.properties** (use o exemplo em `android/key.properties.example`)

3. **Build**:
   ```bash
   ./build_android.sh
   ```

4. **Upload**: 
   - Arquivo gerado: `build/app/outputs/bundle/release/app-release.aab`
   - Upload em: https://play.google.com/console

### Para iOS (App Store)

1. **Build**:
   ```bash
   ./build_app_store_final.sh
   ```
   
   OU via Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```
   Depois: Product > Archive > Distribute App

2. **Upload**: 
   - Será feito automaticamente via Xcode
   - Ou use o Transporter app

---

## 📚 Documentação Completa

- **`PREPARACAO_LOJAS_COMPLETA.md`** ⭐ - Guia completo passo a passo
- **`GUIA_KEYSTORE_ANDROID.md`** - Como criar o keystore do Android
- **`GOOGLE_PLAY_STORE_READY.md`** - Checklist Google Play
- **`APP_STORE_READY.md`** - Checklist App Store
- **`APP_STORE_INFO.md`** - Informações detalhadas

---

## 🔴 O Que Falta Fazer

### Android
1. [ ] Criar keystore (ver GUIA_KEYSTORE_ANDROID.md)
2. [ ] Criar arquivo key.properties
3. [ ] Executar ./build_android.sh
4. [ ] Criar capturas de tela (mínimo 2)
5. [ ] Criar feature graphic 1024x500
6. [ ] Fazer upload no Google Play Console

### iOS
1. [ ] Executar build via Xcode
2. [ ] Criar capturas de tela (mínimo 2)
3. [ ] Fazer upload para App Store Connect

### Geral
1. [ ] Criar e hospedar política de privacidade
2. [ ] Preparar descrições e textos (já estão nos docs)
3. [ ] Registrar nas lojas (US$ 99/ano iOS, US$ 25 único Android)

---

## ⚡ Comandos Rápidos

```bash
# Build Android
./build_android.sh

# Build iOS
./build_app_store_final.sh

# Limpar projeto
flutter clean && flutter pub get

# Verificar versão
grep version pubspec.yaml

# Testar localmente
flutter run --release
```

---

## 📞 Informações do App

- **Nome**: Guide Dose
- **Versão**: 2.0.0 (Build 1)
- **Bundle ID / Package**: com.companyname.medcalc
- **Categoria**: Medical / Saúde
- **Plataformas**: iOS 12.0+, Android 5.0+

---

## 🎯 Tempo Estimado

- **Configuração inicial**: 2-4 horas
- **Preparação de assets**: 2-3 horas
- **Upload e configuração**: 1-2 horas
- **Revisão das lojas**: 1-7 dias
- **Total até publicação**: 1-2 semanas

---

## 💡 Dicas Importantes

1. **Faça backup do keystore do Android** - Se perder, não poderá atualizar o app!
2. **Teste em dispositivos reais** antes de enviar
3. **Prepare capturas de tela atraentes** - aumentam downloads
4. **Leia os guias de revisão** das lojas para evitar rejeições
5. **Responda rapidamente** a solicitações das lojas

---

## 📖 Leia Primeiro

👉 **PREPARACAO_LOJAS_COMPLETA.md** - Contém TUDO que você precisa saber!

---

**Boa sorte com a publicação! 🚀**

