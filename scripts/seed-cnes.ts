/**
 * seed-cnes.ts
 *
 * Importa estabelecimentos de saúde brasileiros do CNES (DataSUS)
 * para a tabela hospitals do Supabase.
 *
 * Uso:
 *   npx ts-node scripts/seed-cnes.ts
 *
 * Variáveis de ambiente necessárias:
 *   SUPABASE_URL
 *   SUPABASE_SERVICE_ROLE_KEY
 *
 * A API pública do CNES pagina de 20 em 20. O script percorre todas
 * as páginas disponíveis, fazendo upsert por cnes_code.
 * Total estimado: ~330k registros (pode levar 30-60 min).
 */

import { createClient } from "@supabase/supabase-js";
import * as dotenv from "dotenv";

dotenv.config({ path: "../.env" });

const SUPABASE_URL = process.env.SUPABASE_URL!;
const SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY!;
const BATCH_SIZE = 500;
const API_PAGE_SIZE = 20;
const API_BASE = "https://apidadosabertos.saude.gov.br/cnes/estabelecimentos";
const RATE_LIMIT_MS = 600;

if (!SUPABASE_URL || !SERVICE_ROLE_KEY) {
  console.error("Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY");
  process.exit(1);
}

const supabase = createClient(SUPABASE_URL, SERVICE_ROLE_KEY);

interface CNESEstabelecimento {
  codigo_cnes?: string;
  nome_fantasia?: string;
  razao_social?: string;
  cnpj?: string;
  logradouro?: string;
  numero?: string;
  bairro?: string;
  municipio?: string;
  nome_municipio?: string;
  uf?: string;
  cep?: string;
  latitude?: number | string;
  longitude?: number | string;
  tipo_unidade?: string;
  telefone?: string;
}

function mapFacilityType(tipo?: string): string {
  if (!tipo) return "hospital";
  const t = tipo.toLowerCase();
  if (t.includes("upa") || t.includes("pronto")) return "upa";
  if (t.includes("básica") || t.includes("basica") || t.includes("ubs")) return "ubs";
  if (t.includes("clínica") || t.includes("clinica")) return "clinic";
  if (t.includes("laboratório") || t.includes("laboratorio")) return "laboratory";
  return "hospital";
}

function toRow(e: CNESEstabelecimento) {
  const cnesCode = e.codigo_cnes ? String(e.codigo_cnes).trim() : null;
  if (!cnesCode) return null;

  const name = (e.nome_fantasia || e.razao_social || "").trim();
  if (!name) return null;

  return {
    name,
    country_code: "BR",
    source: "cnes",
    external_id: cnesCode,
    cnes_code: cnesCode,
    cnpj: e.cnpj ? String(e.cnpj).replace(/\D/g, "").slice(0, 14) || null : null,
    npi_number: null,
    address_street: e.logradouro?.trim() || null,
    address_number: e.numero?.trim() || null,
    address_neighborhood: e.bairro?.trim() || null,
    address_city: (e.municipio || e.nome_municipio || "").trim() || null,
    address_state: e.uf?.trim() || null,
    address_zip: e.cep ? String(e.cep).replace(/\D/g, "").slice(0, 8) || null : null,
    latitude: e.latitude != null ? Number(e.latitude) || null : null,
    longitude: e.longitude != null ? Number(e.longitude) || null : null,
    facility_type: mapFacilityType(e.tipo_unidade),
    phone: e.telefone?.trim() || null,
  };
}

async function fetchPage(offset: number): Promise<CNESEstabelecimento[]> {
  const url = `${API_BASE}?status=1&limit=${API_PAGE_SIZE}&offset=${offset}`;
  const res = await fetch(url, { signal: AbortSignal.timeout(15000) });
  if (!res.ok) {
    console.warn(`  API returned ${res.status} at offset ${offset}`);
    return [];
  }
  const data: any = await res.json();
  return data?.estabelecimentos ?? data ?? [];
}

async function upsertBatch(rows: ReturnType<typeof toRow>[]) {
  const valid = rows.filter(Boolean) as NonNullable<ReturnType<typeof toRow>>[];
  if (valid.length === 0) return 0;

  const { error, count } = await supabase
    .from("hospitals")
    .upsert(valid, { onConflict: "source,external_id", ignoreDuplicates: false, count: "exact" });

  if (error) {
    console.warn(`  Upsert error: ${error.message}`);
    return 0;
  }
  return count ?? valid.length;
}

async function main() {
  console.log("=== SEED CNES (Brasil) ===");
  console.log(`Supabase: ${SUPABASE_URL}`);

  let offset = 0;
  let totalInserted = 0;
  let emptyPages = 0;
  let batch: ReturnType<typeof toRow>[] = [];

  while (emptyPages < 3) {
    try {
      const items = await fetchPage(offset);
      if (items.length === 0) {
        emptyPages++;
        offset += API_PAGE_SIZE;
        continue;
      }
      emptyPages = 0;

      for (const item of items) {
        batch.push(toRow(item));
      }

      if (batch.length >= BATCH_SIZE) {
        const inserted = await upsertBatch(batch);
        totalInserted += inserted;
        console.log(`  offset=${offset} | batch=${batch.length} | total=${totalInserted}`);
        batch = [];
      }

      offset += API_PAGE_SIZE;

      // Rate limit
      await new Promise((r) => setTimeout(r, RATE_LIMIT_MS));
    } catch (err) {
      console.warn(`  Error at offset ${offset}: ${(err as Error).message}`);
      emptyPages++;
      offset += API_PAGE_SIZE;
      await new Promise((r) => setTimeout(r, 2000));
    }
  }

  // Flush remaining
  if (batch.length > 0) {
    const inserted = await upsertBatch(batch);
    totalInserted += inserted;
  }

  console.log(`\nDone! Total upserted: ${totalInserted}`);
}

main().catch((err) => {
  console.error("Fatal:", err);
  process.exit(1);
});
