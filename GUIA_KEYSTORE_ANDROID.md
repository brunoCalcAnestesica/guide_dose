# 🔐 Guia de Criação do Keystore para Android

## O que é um Keystore?

O keystore é um arquivo de certificado digital usado para assinar o aplicativo Android. Ele garante a autenticidade e integridade do seu app na Google Play Store.

## ⚠️ IMPORTANTE

- **NUNCA** compartilhe o arquivo keystore ou as senhas
- **FAÇA BACKUP** do keystore em local seguro
- Se perder o keystore, **não será possível** atualizar o app na Google Play

## Passo 1: Gerar o Keystore

Execute o seguinte comando no terminal (a partir da raiz do projeto):

```bash
keytool -genkey -v -keystore android/upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

### Informações Solicitadas:

Durante a criação, você será solicitado a fornecer:

1. **Senha do keystore** (mínimo 6 caracteres)
   - Guarde esta senha com segurança!
   
2. **Nome e sobrenome**: Bruno Daroz
3. **Unidade organizacional**: Desenvolvimento
4. **Organização**: Guide Dose
5. **Cidade**: [Sua cidade]
6. **Estado**: [Seu estado]
7. **Código do país** (2 letras): BR

8. **Senha da key** 
   - Pode ser a mesma senha do keystore
   - Ou pressione Enter para usar a mesma senha

## Passo 2: Criar o arquivo key.properties

Após gerar o keystore, crie o arquivo `android/key.properties` com o seguinte conteúdo:

```properties
storePassword=SUA_SENHA_DO_KEYSTORE
keyPassword=SUA_SENHA_DA_KEY
keyAlias=upload
storeFile=../upload-keystore.jks
```

**Substitua:**
- `SUA_SENHA_DO_KEYSTORE` pela senha que você definiu
- `SUA_SENHA_DA_KEY` pela senha da key (geralmente a mesma)

## Passo 3: Adicionar ao .gitignore

Certifique-se de que estes arquivos NÃO sejam versionados:

```
# No arquivo .gitignore
android/key.properties
android/*.keystore
android/*.jks
```

## Passo 4: Fazer Backup do Keystore

**CRÍTICO:** Faça backup do arquivo `upload-keystore.jks` e do arquivo `key.properties` em:
- Um drive na nuvem (Google Drive, iCloud, etc.)
- Um HD externo
- Um gerenciador de senhas seguro

## Verificar se foi criado corretamente

Execute:

```bash
keytool -list -v -keystore android/upload-keystore.jks -alias upload
```

Você verá informações sobre o certificado, incluindo:
- Nome do proprietário
- Data de validade
- Tipo de certificado

## Estrutura de Arquivos Esperada

```
guide_dose/
├── android/
│   ├── upload-keystore.jks     ← Arquivo criado
│   ├── key.properties           ← Arquivo criado
│   └── app/
│       └── build.gradle.kts     ← Já configurado
```

## Próximos Passos

Após criar o keystore e o key.properties:

1. Execute o build de release:
   ```bash
   flutter build appbundle --release
   ```

2. O arquivo AAB será gerado em:
   ```
   build/app/outputs/bundle/release/app-release.aab
   ```

3. Faça upload deste arquivo .aab na Google Play Console

## Resolução de Problemas

### Erro: "keytool: command not found"

O keytool faz parte do JDK. Certifique-se de ter o Java JDK instalado:

```bash
java -version
```

Se não estiver instalado, baixe em: https://www.oracle.com/java/technologies/downloads/

### Esqueci a senha do keystore

Infelizmente, **não há como recuperar** a senha de um keystore. Você precisará:
1. Criar um novo keystore
2. Criar um novo aplicativo na Google Play (novo package name)
3. Publicar como um novo app

Por isso é CRÍTICO fazer backup das senhas!

