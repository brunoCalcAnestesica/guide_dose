import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

// ---------------------------------------------------------------------------
// External API adapters
// ---------------------------------------------------------------------------

interface HospitalRow {
  name: string;
  country_code: string;
  source: string;
  external_id: string | null;
  cnpj: string | null;
  cnes_code: string | null;
  npi_number: string | null;
  address_street: string | null;
  address_number: string | null;
  address_city: string | null;
  address_state: string | null;
  address_zip: string | null;
  latitude: number | null;
  longitude: number | null;
  facility_type: string | null;
  phone: string | null;
}

async function searchCNES(query: string): Promise<HospitalRow[]> {
  try {
    const url = `https://apidadosabertos.saude.gov.br/cnes/estabelecimentos?nome_fantasia=${encodeURIComponent(query)}&status=1&limit=10`;
    const res = await fetch(url, { signal: AbortSignal.timeout(8000) });
    if (!res.ok) return [];
    const data = await res.json();
    const items = data?.estabelecimentos ?? data ?? [];
    if (!Array.isArray(items)) return [];

    return items.map((e: Record<string, unknown>) => ({
      name: (e.nome_fantasia as string) || (e.razao_social as string) || "",
      country_code: "BR",
      source: "cnes" as const,
      external_id: String(e.codigo_cnes ?? ""),
      cnpj: e.cnpj ? String(e.cnpj) : null,
      cnes_code: e.codigo_cnes ? String(e.codigo_cnes) : null,
      npi_number: null,
      address_street: (e.logradouro as string) ?? null,
      address_number: (e.numero as string) ?? null,
      address_city: (e.municipio as string) ?? (e.nome_municipio as string) ?? null,
      address_state: (e.uf as string) ?? null,
      address_zip: (e.cep as string) ?? null,
      latitude: e.latitude != null ? Number(e.latitude) : null,
      longitude: e.longitude != null ? Number(e.longitude) : null,
      facility_type: mapCNESType(e.tipo_unidade as string),
      phone: (e.telefone as string) ?? null,
    })).filter((h: HospitalRow) => h.name.length > 0);
  } catch {
    return [];
  }
}

function mapCNESType(tipo: string | undefined): string {
  if (!tipo) return "hospital";
  const t = tipo.toLowerCase();
  if (t.includes("upa") || t.includes("pronto")) return "upa";
  if (t.includes("básica") || t.includes("basica") || t.includes("ubs")) return "ubs";
  if (t.includes("clínica") || t.includes("clinica")) return "clinic";
  if (t.includes("laboratório") || t.includes("laboratorio")) return "laboratory";
  return "hospital";
}

async function searchNPI(query: string): Promise<HospitalRow[]> {
  try {
    const url = `https://npiregistry.cms.hhs.gov/api/?version=2.1&enumeration_type=NPI-2&organization_name=${encodeURIComponent(query)}&taxonomy_description=Hospital&limit=10`;
    const res = await fetch(url, { signal: AbortSignal.timeout(8000) });
    if (!res.ok) return [];
    const data = await res.json();
    const results = data?.results ?? [];
    if (!Array.isArray(results)) return [];

    return results.map((r: Record<string, unknown>) => {
      const basic = (r.basic ?? {}) as Record<string, unknown>;
      const addrs = (r.addresses ?? []) as Record<string, unknown>[];
      const primary = addrs.find((a) => a.address_purpose === "LOCATION") ?? addrs[0] ?? {};

      return {
        name: (basic.organization_name as string) ?? "",
        country_code: "US",
        source: "npi" as const,
        external_id: String(r.number ?? ""),
        cnpj: null,
        cnes_code: null,
        npi_number: r.number ? String(r.number) : null,
        address_street: (primary.address_1 as string) ?? null,
        address_number: null,
        address_city: (primary.city as string) ?? null,
        address_state: (primary.state as string) ?? null,
        address_zip: (primary.postal_code as string)?.slice(0, 5) ?? null,
        latitude: null,
        longitude: null,
        facility_type: "hospital",
        phone: (primary.telephone_number as string) ?? null,
      };
    }).filter((h: HospitalRow) => h.name.length > 0);
  } catch {
    return [];
  }
}

async function searchOSM(
  query: string,
  countryCode: string,
  lat?: number,
  lng?: number,
): Promise<HospitalRow[]> {
  try {
    const areaFilter = lat != null && lng != null
      ? `(around:50000,${lat},${lng})`
      : `["ISO3166-1"="${countryCode}"]`;

    // Overpass QL: search hospitals by name within area
    const overpassQuery = `
      [out:json][timeout:10];
      area${countryCode.length === 2 ? `["ISO3166-1"="${countryCode}"]` : ""}->.searchArea;
      (
        nwr["amenity"="hospital"]["name"~"${escapeOverpass(query)}",i]${lat != null ? `(around:80000,${lat},${lng})` : "(area.searchArea)"};
        nwr["amenity"="clinic"]["name"~"${escapeOverpass(query)}",i]${lat != null ? `(around:80000,${lat},${lng})` : "(area.searchArea)"};
      );
      out center 10;
    `;

    const res = await fetch("https://overpass-api.de/api/interpreter", {
      method: "POST",
      body: `data=${encodeURIComponent(overpassQuery)}`,
      headers: { "Content-Type": "application/x-www-form-urlencoded" },
      signal: AbortSignal.timeout(12000),
    });
    if (!res.ok) return [];
    const data = await res.json();
    const elements = data?.elements ?? [];
    if (!Array.isArray(elements)) return [];

    return elements.map((el: Record<string, unknown>) => {
      const tags = (el.tags ?? {}) as Record<string, string>;
      const elLat = (el.lat ?? (el.center as Record<string, number>)?.lat) as number | undefined;
      const elLng = (el.lon ?? (el.center as Record<string, number>)?.lon) as number | undefined;

      return {
        name: tags.name ?? "",
        country_code: countryCode,
        source: "osm" as const,
        external_id: String(el.id ?? ""),
        cnpj: null,
        cnes_code: null,
        npi_number: null,
        address_street: tags["addr:street"] ?? null,
        address_number: tags["addr:housenumber"] ?? null,
        address_city: tags["addr:city"] ?? null,
        address_state: tags["addr:state"] ?? null,
        address_zip: tags["addr:postcode"] ?? null,
        latitude: elLat ?? null,
        longitude: elLng ?? null,
        facility_type: tags.amenity === "clinic" ? "clinic" : "hospital",
        phone: tags.phone ?? tags["contact:phone"] ?? null,
      };
    }).filter((h: HospitalRow) => h.name.length > 0);
  } catch {
    return [];
  }
}

function escapeOverpass(s: string): string {
  return s.replace(/[\\."']/g, "\\$&");
}

// ---------------------------------------------------------------------------
// Upsert helpers
// ---------------------------------------------------------------------------

async function upsertExternal(
  supabase: ReturnType<typeof createClient>,
  rows: HospitalRow[],
): Promise<string[]> {
  const insertedIds: string[] = [];
  for (const row of rows) {
    try {
      const { data, error } = await supabase
        .from("hospitals")
        .upsert(
          {
            name: row.name,
            country_code: row.country_code,
            source: row.source,
            external_id: row.external_id,
            cnpj: row.cnpj,
            cnes_code: row.cnes_code,
            npi_number: row.npi_number,
            address_street: row.address_street,
            address_number: row.address_number,
            address_city: row.address_city,
            address_state: row.address_state,
            address_zip: row.address_zip,
            latitude: row.latitude,
            longitude: row.longitude,
            facility_type: row.facility_type,
            phone: row.phone,
          },
          {
            onConflict: "source,external_id",
            ignoreDuplicates: true,
          },
        )
        .select("id")
        .single();
      if (!error && data) insertedIds.push(data.id);
    } catch {
      // skip individual failures
    }
  }
  return insertedIds;
}

// ---------------------------------------------------------------------------
// Main handler
// ---------------------------------------------------------------------------

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const url = new URL(req.url);
    const query = url.searchParams.get("q")?.trim();
    const country = url.searchParams.get("country")?.toUpperCase() ?? "BR";
    const lat = url.searchParams.get("lat") ? Number(url.searchParams.get("lat")) : undefined;
    const lng = url.searchParams.get("lng") ? Number(url.searchParams.get("lng")) : undefined;

    if (!query || query.length < 2) {
      return new Response(
        JSON.stringify({ error: "Query 'q' must be at least 2 characters" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const authHeader = req.headers.get("Authorization");
    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

    // Verify the user is authenticated
    if (authHeader) {
      const token = authHeader.replace("Bearer ", "");
      const { data: { user }, error } = await createClient(
        SUPABASE_URL,
        Deno.env.get("SUPABASE_ANON_KEY") ?? SUPABASE_SERVICE_ROLE_KEY,
      ).auth.getUser(token);
      if (error || !user) {
        return new Response(
          JSON.stringify({ error: "Unauthorized" }),
          { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } },
        );
      }
    }

    // Step 1: local search with pg_trgm similarity
    const { data: localResults, error: dbError } = await supabase
      .from("hospitals")
      .select("id, name, source, country_code, address_city, address_state, latitude, longitude, facility_type, cnes_code, npi_number, cnpj")
      .eq("country_code", country)
      .or(`name.ilike.%${query}%`)
      .limit(20);

    const local = localResults ?? [];

    // Step 2: if local results are sparse, fetch from external API
    let externalResults: HospitalRow[] = [];
    if (local.length < 5) {
      if (country === "BR") {
        externalResults = await searchCNES(query);
      } else if (country === "US") {
        externalResults = await searchNPI(query);
      } else {
        externalResults = await searchOSM(query, country, lat, lng);
      }

      // Deduplicate against local results
      const localExtIds = new Set(local.map((r) => `${r.source}:${r.cnes_code ?? r.npi_number ?? ""}`));
      externalResults = externalResults.filter((r) => {
        const key = `${r.source}:${r.cnes_code ?? r.npi_number ?? r.external_id ?? ""}`;
        return !localExtIds.has(key);
      });

      // Step 3: upsert external results into hospitals table
      if (externalResults.length > 0) {
        await upsertExternal(supabase, externalResults);

        // Re-fetch to get proper IDs
        const extIds = externalResults
          .map((r) => r.external_id)
          .filter(Boolean);
        if (extIds.length > 0) {
          const { data: newRows } = await supabase
            .from("hospitals")
            .select("id, name, source, country_code, address_city, address_state, latitude, longitude, facility_type, cnes_code, npi_number, cnpj")
            .in("external_id", extIds)
            .limit(20);
          if (newRows) {
            const localIds = new Set(local.map((r) => r.id));
            for (const nr of newRows) {
              if (!localIds.has(nr.id)) local.push(nr);
            }
          }
        }
      }
    }

    return new Response(
      JSON.stringify({ results: local }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  } catch (err) {
    return new Response(
      JSON.stringify({ error: (err as Error).message }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }
});
