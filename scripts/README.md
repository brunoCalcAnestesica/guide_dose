# Scripts de Seed — Hospitais

Scripts para importar estabelecimentos de saúde de fontes externas para a tabela `hospitals` do Supabase.

## Pre-requisitos

1. Tabelas criadas no Supabase (executar `supabase_hospitals.sql` no SQL Editor)
2. Node.js 18+
3. Variáveis de ambiente configuradas (`.env` na raiz do projeto)

## Setup

```bash
cd scripts
npm install
```

## Variáveis de ambiente

O `.env` na raiz do projeto já deve conter:

```
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_SERVICE_ROLE_KEY=eyJ...
```

## Executar seeds

### Brasil (CNES) — ~330k estabelecimentos

```bash
npm run seed:cnes
```

Usa a API pública do DataSUS. Demora 30-60 minutos (rate-limited).
Faz upsert por `cnes_code` — seguro para re-executar.

### Mundo (WHO) — ~170k facilities

```bash
npm run seed:who
```

Baixa o CSV do Humanitarian Data Exchange (OMS).
Exclui automaticamente Brasil e EUA (cobertos por CNES e NPI).
Faz upsert por `(source, external_id)`.

### EUA (NPI Registry) — ~7-8k hospitais via API

```bash
npm run seed:npi
```

Busca na API do NPI Registry, estado por estado, filtrando por taxonomia hospitalar.
Faz upsert por `npi_number`.

### Todos de uma vez

```bash
npm run seed:all
```

## Edge Function: search-hospitals

### Deploy

```bash
# Na raiz do projeto, com Supabase CLI instalado:
supabase functions deploy search-hospitals
```

### Uso

```
GET https://<project>.supabase.co/functions/v1/search-hospitals?q=santa+maria&country=BR
```

Headers:
- `Authorization: Bearer <user_jwt>`

Parametros:
- `q` (obrigatorio) — texto de busca (min 2 chars)
- `country` (opcional, default "BR") — ISO 3166-1 alpha-2
- `lat` / `lng` (opcional) — coordenadas para busca geolocalizada (OSM)

Response:
```json
{
  "results": [
    {
      "id": "uuid",
      "name": "Hospital Santa Maria",
      "source": "cnes",
      "country_code": "BR",
      "address_city": "São Paulo",
      "address_state": "SP",
      "latitude": -23.55,
      "longitude": -46.63,
      "facility_type": "hospital"
    }
  ]
}
```

### Logica de busca

1. Busca local no banco (`hospitals` com `ILIKE`)
2. Se encontrou < 5 resultados, chama API externa:
   - Brasil → CNES API
   - EUA → NPI Registry API
   - Outros → OpenStreetMap Overpass
3. Resultados novos da API são salvos na tabela `hospitals`
4. Retorna lista mesclada (local + novos)

## Tabelas no Supabase

### `hospitals`
Tabela global compartilhada entre todos os usuarios. Campos principais:
- `name`, `country_code`, `source`, `external_id`
- `cnpj`, `cnes_code`, `npi_number` (chaves de dedup)
- Endereço estruturado + lat/lng

### `user_hospitals`
Vinculo N:N entre medico e hospital:
- `user_id`, `hospital_id` (PK composta)
- `nickname` — apelido pessoal do medico
- `color` — cor no calendario
- `is_favorite`

O app Flutter acessa `user_hospitals` diretamente via Supabase client (RLS ativo).

## Criacao manual de hospital

Via RPC no Supabase (Flutter):

```dart
final result = await Supabase.instance.client.rpc('create_manual_hospital', params: {
  'p_name': 'Meu Hospital',
  'p_country_code': 'BR',
  'p_address_city': 'São Paulo',
  'p_nickname': 'HU noturno',
  'p_color': 0xFF1A73E8,
});
```

Cria o hospital em `hospitals` com `source='manual'` e vincula ao usuario em `user_hospitals`.
