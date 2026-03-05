# Guia de Setup: Push Notifications

## 1. Firebase (obrigatório para push no celular)

### 1.1 Criar projeto Firebase
1. Acesse https://console.firebase.google.com
2. Crie um novo projeto (ou use um existente)
3. Ative **Cloud Messaging** (FCM)

### 1.2 Android
1. No Firebase Console, adicione o app Android: `com.companyname.medcalc`
2. Baixe o `google-services.json`
3. Coloque em `android/app/google-services.json`

### 1.3 iOS
1. No Firebase Console, adicione o app iOS com o Bundle ID correto
2. Baixe o `GoogleService-Info.plist`
3. Coloque em `ios/Runner/GoogleService-Info.plist`
4. No Xcode: Runner > Signing & Capabilities > + Capability > Push Notifications
5. Configure APNs key no Firebase Console (Settings > Cloud Messaging > APNs)

### 1.4 Service Account (para Edge Functions)
1. No Firebase Console: Settings > Service Accounts > Generate new private key
2. Copie o JSON inteiro
3. No Supabase Dashboard: Settings > Edge Functions > Secrets
4. Adicione o secret `FIREBASE_SERVICE_ACCOUNT` com o conteúdo JSON do service account

---

## 2. Supabase

### 2.1 Rodar migration SQL
Execute o conteúdo de `supabase/migrations/push_notifications.sql` no SQL Editor do Supabase.

### 2.2 Marcar admin
No SQL Editor do Supabase, execute:
```sql
UPDATE profiles SET role = 'admin' WHERE id = '<SEU_USER_ID>';
```

### 2.3 Deploy Edge Functions
```bash
supabase functions deploy send-push
supabase functions deploy check-shift-notifications
```

### 2.4 Configurar cron (notificações automáticas)

Para as notificações automáticas (véspera de plantão e conflito com dia bloqueado), configure um cron job no Supabase (Database > Extensions > pg_cron) ou use um serviço externo.

**Opção A: pg_cron + pg_net (dentro do Supabase)**

Habilite as extensions `pg_cron` e `pg_net`, depois execute:

```sql
-- Rodar diariamente às 18h (horário UTC) para notificação de véspera
SELECT cron.schedule(
  'eve-shift-notifications',
  '0 21 * * *',  -- 21h UTC = 18h BRT
  $$
  SELECT net.http_post(
    url := '<SUPABASE_URL>/functions/v1/check-shift-notifications',
    headers := jsonb_build_object(
      'Authorization', 'Bearer <SUPABASE_SERVICE_ROLE_KEY>',
      'Content-Type', 'application/json'
    ),
    body := '{"mode": "eve"}'::jsonb
  );
  $$
);

-- Rodar diariamente às 7h (horário UTC = 10h BRT) para dias bloqueados
SELECT cron.schedule(
  'blocked-day-notifications',
  '0 10 * * *',  -- 10h UTC = 7h BRT
  $$
  SELECT net.http_post(
    url := '<SUPABASE_URL>/functions/v1/check-shift-notifications',
    headers := jsonb_build_object(
      'Authorization', 'Bearer <SUPABASE_SERVICE_ROLE_KEY>',
      'Content-Type', 'application/json'
    ),
    body := '{"mode": "blocked"}'::jsonb
  );
  $$
);

-- Rodar a cada minuto para processar agendamentos pendentes
SELECT cron.schedule(
  'process-push-schedules',
  '* * * * *',
  $$
  SELECT net.http_post(
    url := '<SUPABASE_URL>/functions/v1/check-shift-notifications',
    headers := jsonb_build_object(
      'Authorization', 'Bearer <SUPABASE_SERVICE_ROLE_KEY>',
      'Content-Type', 'application/json'
    ),
    body := '{"mode": "schedules"}'::jsonb
  );
  $$
);
```

Substitua `<SUPABASE_URL>` e `<SUPABASE_SERVICE_ROLE_KEY>` pelos valores reais.

**Opção B: Serviço externo (ex.: cron-job.org)**
Configure chamadas HTTP POST para a URL da Edge Function com os headers e body acima.

---

## 3. Teste

1. Faça login no app (Android ou iOS)
2. Verifique no Supabase Dashboard que um registro apareceu em `fcm_tokens`
3. Na versão web, faça login com o usuário admin
4. Vá em Configurações > Painel Admin
5. Envie uma notificação de teste para "Todos"
6. Verifique que a notificação chegou no celular
