# ✅ Checklist Rápido - Publicação do Guide Dose

## 🔴 URGENTE - Faça Primeiro

### Android
- [ ] **Criar keystore** 
  ```bash
  keytool -genkey -v -keystore android/upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
  ```
- [ ] **Criar android/key.properties** (copie de android/key.properties.example)
- [ ] **Fazer backup do keystore** em local seguro
- [ ] **Executar build**
  ```bash
  ./build_android.sh
  ```

### iOS
- [ ] **Executar build no Xcode**
  ```bash
  open ios/Runner.xcworkspace
  # Product > Archive > Distribute App
  ```

---

## 📸 Assets Gráficos

### Capturas de Tela (mínimo 2)
- [ ] Tela inicial
- [ ] Farmacoteca
- [ ] Cálculo de dosagem
- [ ] Conversor de infusão
- [ ] Módulo PCR
- [ ] Indução anestésica

### Android Específico
- [ ] Feature Graphic: 1024 x 500 px
- [ ] Ícone: 512 x 512 px

### iOS Específico
- [ ] Ícone: 1024 x 1024 px (já configurado)
- [ ] Screenshots iPhone 6.7"
- [ ] Screenshots iPhone 6.5"
- [ ] Screenshots iPad (opcional)

---

## 📝 Textos e Informações

- [x] Nome: Guide Dose
- [x] Descrição curta: "Cálculos médicos precisos para profissionais da saúde"
- [x] Descrição longa: Ver PREPARACAO_LOJAS_COMPLETA.md
- [x] Palavras-chave: medicina, farmacologia, cálculos, dosagem, anestesia
- [ ] Política de privacidade hospedada (use POLITICA_PRIVACIDADE.md)
- [ ] Email de contato definido
- [ ] Website (opcional)

---

## 💰 Contas e Pagamentos

### Google Play Console
- [ ] Conta criada
- [ ] Taxa paga (US$ 25 - pagamento único)

### Apple Developer
- [ ] Conta criada  
- [ ] Assinatura ativa (US$ 99/ano)

---

## 🚀 Upload

### Google Play
- [ ] Aplicativo criado no console
- [ ] App Bundle (.aab) enviado
- [ ] Informações preenchidas
- [ ] Capturas de tela adicionadas
- [ ] Feature graphic adicionado
- [ ] Classificação de conteúdo completa
- [ ] Preços e distribuição configurados
- [ ] Enviado para revisão

### App Store
- [ ] App criado no App Store Connect
- [ ] Build enviado
- [ ] Informações preenchidas
- [ ] Capturas de tela adicionadas
- [ ] Preços e disponibilidade configurados
- [ ] Classificação etária definida
- [ ] Enviado para revisão

---

## ✅ Testes

- [ ] Testado no iPhone real
- [ ] Testado no iPad (opcional)
- [ ] Testado no Android (smartphone)
- [ ] Testado no Android (tablet - opcional)
- [ ] Todas as funcionalidades testadas
- [ ] Sem crashes
- [ ] Performance OK

---

## 📋 Arquivos Importantes

- [x] `pubspec.yaml` - Versão 2.0.0+1
- [x] `build_android.sh` - Script de build Android
- [x] `build_app_store_final.sh` - Script de build iOS
- [ ] `android/key.properties` - **CRIAR**
- [ ] `android/upload-keystore.jks` - **CRIAR**
- [x] `.gitignore` - Atualizado para proteger keystore

---

## ⏱️ Timeline Estimada

| Etapa | Tempo |
|-------|-------|
| Criar keystore + key.properties | 15 min |
| Build Android | 10 min |
| Build iOS | 15 min |
| Criar capturas de tela | 1-2 horas |
| Criar feature graphic | 30-60 min |
| Hospedar política de privacidade | 30 min |
| Upload e configuração Google Play | 1-2 horas |
| Upload e configuração App Store | 1-2 horas |
| **TOTAL** | **4-7 horas** |
| Revisão Google Play | 1-3 dias |
| Revisão App Store | 1-7 dias |
| **ATÉ PUBLICAÇÃO** | **1-2 semanas** |

---

## 🎯 Status Atual

### Pronto ✅
- Código do app
- Configurações iOS
- Configurações Android
- Ícones
- Documentação
- Scripts de build
- Metadados e textos

### Falta Fazer 🔴
- Criar keystore do Android
- Criar key.properties
- Fazer builds de release
- Criar capturas de tela
- Criar feature graphic
- Hospedar política de privacidade
- Registrar nas lojas
- Fazer uploads

---

## 📞 Ajuda

Se tiver dúvidas, consulte:
1. **PREPARACAO_LOJAS_COMPLETA.md** - Guia completo
2. **GUIA_KEYSTORE_ANDROID.md** - Como criar keystore
3. **GOOGLE_PLAY_STORE_READY.md** - Detalhes Google Play
4. **APP_STORE_READY.md** - Detalhes App Store

---

**Imprima este checklist e marque os itens conforme completa!**

✨ **Você consegue! O app está quase lá!** ✨

