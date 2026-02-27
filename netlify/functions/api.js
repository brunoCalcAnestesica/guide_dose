const SUPABASE_URL = process.env.SUPABASE_URL || "";
const SUPABASE_ANON_KEY = process.env.SUPABASE_ANON_KEY || "";

function jsonResponse(statusCode, payload) {
  return {
    statusCode,
    headers: {
      "Content-Type": "application/json",
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Headers": "Content-Type, Authorization",
      "Access-Control-Allow-Methods": "GET, POST, PATCH, DELETE, OPTIONS",
    },
    body: JSON.stringify(payload),
  };
}

async function validateToken(token) {
  const response = await fetch(`${SUPABASE_URL}/auth/v1/user`, {
    headers: {
      Authorization: `Bearer ${token}`,
      apikey: SUPABASE_ANON_KEY,
    },
  });
  if (!response.ok) return null;
  return response.json();
}

exports.handler = async (event) => {
  if (event.httpMethod === "OPTIONS") {
    return jsonResponse(200, {});
  }

  try {
    if (!SUPABASE_URL || !SUPABASE_ANON_KEY) {
      return jsonResponse(500, { error: "Supabase nao configurado no servidor." });
    }

    const authHeader = event.headers.authorization || "";
    const token = authHeader.replace("Bearer", "").trim();
    if (!token) {
      return jsonResponse(401, { error: "Token ausente." });
    }

    const user = await validateToken(token);
    if (!user) {
      return jsonResponse(401, { error: "Sessao invalida." });
    }

    const params = event.queryStringParameters || {};
    const { table, ...queryParams } = params;

    if (!table) {
      return jsonResponse(400, { error: "Parametro 'table' obrigatorio." });
    }

    const allowedTables = [
      "profiles",
      "patient_notes",
      "general_notes",
      "shifts",
      "feedback",
      "med_lists",
      "app_versions",
      "access_logs",
    ];

    if (!allowedTables.includes(table)) {
      return jsonResponse(403, { error: `Tabela '${table}' nao permitida.` });
    }

    const qs = new URLSearchParams(queryParams).toString();
    const url = `${SUPABASE_URL}/rest/v1/${table}${qs ? `?${qs}` : ""}`;

    const headers = {
      apikey: SUPABASE_ANON_KEY,
      Authorization: `Bearer ${token}`,
      "Content-Type": "application/json",
    };

    if (event.httpMethod === "POST") {
      headers["Prefer"] = "return=representation";
    }
    if (event.httpMethod === "PATCH") {
      headers["Prefer"] = "return=representation";
    }

    const fetchOptions = {
      method: event.httpMethod,
      headers,
    };

    if (event.body && (event.httpMethod === "POST" || event.httpMethod === "PATCH" || event.httpMethod === "DELETE")) {
      fetchOptions.body = event.body;
    }

    const response = await fetch(url, fetchOptions);
    const text = await response.text();

    let data;
    try {
      data = JSON.parse(text);
    } catch {
      data = text;
    }

    if (!response.ok) {
      return jsonResponse(response.status, {
        error: typeof data === "object" ? (data.message || data.error || "Erro na operacao.") : "Erro na operacao.",
      });
    }

    return jsonResponse(200, data);
  } catch (error) {
    return jsonResponse(500, { error: error.message || "Erro interno." });
  }
};
