/**
 * seed-npi.ts
 *
 * Importa facilities hospitalares dos EUA do NPI Registry
 * para a tabela hospitals do Supabase.
 *
 * Uso:
 *   npx ts-node scripts/seed-npi.ts
 *
 * Variáveis de ambiente necessárias:
 *   SUPABASE_URL
 *   SUPABASE_SERVICE_ROLE_KEY
 *
 * A API pública do NPI Registry é paginada (máx 200 por request).
 * O script busca por taxonomia hospitalar, estado por estado,
 * fazendo upsert por npi_number.
 * Total estimado: ~7-8k hospitais (API retorna organizações, não o bulk).
 *
 * Para o dataset completo (~300k), baixe o NPPES bulk CSV de:
 *   https://download.cms.gov/nppes/NPI_Files.html
 * e use a variável NPI_CSV_PATH para apontar para o arquivo local.
 */

import { createClient } from "@supabase/supabase-js";
import * as dotenv from "dotenv";

dotenv.config({ path: "../.env" });

const SUPABASE_URL = process.env.SUPABASE_URL!;
const SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY!;
const BATCH_SIZE = 200;
const RATE_LIMIT_MS = 500;

const NPI_API_BASE = "https://npiregistry.cms.hhs.gov/api/";

const US_STATES = [
  "AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA",
  "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD",
  "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ",
  "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC",
  "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY",
  "DC", "PR", "VI", "GU",
];

if (!SUPABASE_URL || !SERVICE_ROLE_KEY) {
  console.error("Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY");
  process.exit(1);
}

const supabase = createClient(SUPABASE_URL, SERVICE_ROLE_KEY);

interface NPIResult {
  number?: number | string;
  basic?: {
    organization_name?: string;
    organizational_subpart?: string;
  };
  addresses?: Array<{
    address_purpose?: string;
    address_1?: string;
    city?: string;
    state?: string;
    postal_code?: string;
    telephone_number?: string;
  }>;
  taxonomies?: Array<{
    desc?: string;
    primary?: boolean;
  }>;
}

function toRow(r: NPIResult) {
  const npiNum = r.number ? String(r.number) : null;
  if (!npiNum) return null;

  const name = r.basic?.organization_name?.trim();
  if (!name) return null;

  const addr =
    r.addresses?.find((a) => a.address_purpose === "LOCATION") ??
    r.addresses?.[0];

  return {
    name,
    country_code: "US",
    source: "npi",
    external_id: npiNum,
    cnpj: null,
    cnes_code: null,
    npi_number: npiNum,
    address_street: addr?.address_1?.trim() || null,
    address_number: null,
    address_neighborhood: null,
    address_city: addr?.city?.trim() || null,
    address_state: addr?.state?.trim() || null,
    address_zip: addr?.postal_code?.trim()?.slice(0, 5) || null,
    latitude: null,
    longitude: null,
    facility_type: "hospital",
    phone: addr?.telephone_number?.trim() || null,
  };
}

async function fetchState(state: string, skip: number): Promise<NPIResult[]> {
  const url = `${NPI_API_BASE}?version=2.1&enumeration_type=NPI-2&state=${state}&taxonomy_description=Hospital&limit=200&skip=${skip}`;
  const res = await fetch(url, { signal: AbortSignal.timeout(15000) });
  if (!res.ok) return [];
  const data: any = await res.json();
  return data?.results ?? [];
}

async function upsertBatch(rows: NonNullable<ReturnType<typeof toRow>>[]) {
  if (rows.length === 0) return 0;

  const { error, count } = await supabase
    .from("hospitals")
    .upsert(rows, { onConflict: "source,external_id", ignoreDuplicates: false, count: "exact" });

  if (error) {
    console.warn(`  Upsert error: ${error.message}`);
    return 0;
  }
  return count ?? rows.length;
}

async function main() {
  console.log("=== SEED NPI (EUA) ===");
  console.log(`Supabase: ${SUPABASE_URL}`);

  let totalInserted = 0;

  for (const state of US_STATES) {
    let skip = 0;
    let stateCount = 0;
    let batch: NonNullable<ReturnType<typeof toRow>>[] = [];

    while (true) {
      try {
        const results = await fetchState(state, skip);
        if (results.length === 0) break;

        for (const r of results) {
          const row = toRow(r);
          if (row) batch.push(row);
        }

        if (batch.length >= BATCH_SIZE) {
          const inserted = await upsertBatch(batch);
          stateCount += inserted;
          batch = [];
        }

        skip += 200;
        if (results.length < 200) break;

        await new Promise((r) => setTimeout(r, RATE_LIMIT_MS));
      } catch (err) {
        console.warn(`  Error ${state} skip=${skip}: ${(err as Error).message}`);
        break;
      }
    }

    if (batch.length > 0) {
      const inserted = await upsertBatch(batch);
      stateCount += inserted;
    }

    totalInserted += stateCount;
    if (stateCount > 0) {
      console.log(`  ${state}: ${stateCount} hospitals`);
    }
  }

  console.log(`\nDone! Total upserted: ${totalInserted}`);
}

main().catch((err) => {
  console.error("Fatal:", err);
  process.exit(1);
});
