const SUPABASE_URL = process.env.SUPABASE_URL || "";
const SUPABASE_ANON_KEY = process.env.SUPABASE_ANON_KEY || "";
const OPENAI_API_KEY = process.env.OPENAI_API_KEY || "";

function jsonResponse(statusCode, payload) {
  return {
    statusCode,
    headers: {
      "Content-Type": "application/json",
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Headers": "Content-Type, Authorization",
      "Access-Control-Allow-Methods": "POST, OPTIONS",
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

async function querySupabase(token, table, extraParams = "") {
  const url = `${SUPABASE_URL}/rest/v1/${table}?select=*${extraParams}`;
  const response = await fetch(url, {
    headers: {
      apikey: SUPABASE_ANON_KEY,
      Authorization: `Bearer ${token}`,
      "Content-Type": "application/json",
    },
  });
  if (!response.ok) return [];
  return response.json();
}

function buildPatientSummary(patients) {
  if (!patients || patients.length === 0) return "Nenhum paciente cadastrado.";
  return patients
    .map((p) => {
      const parts = [`Paciente: ${p.initials}`];
      if (p.age) parts.push(`Idade: ${p.age} ${p.age_unit}`);
      if (p.bed) parts.push(`Leito: ${p.bed}`);
      if (p.diagnosis) parts.push(`Diagnóstico: ${p.diagnosis}`);
      if (p.history) parts.push(`História: ${p.history}`);
      if (p.devices) parts.push(`Dispositivos: ${p.devices}`);
      if (p.antibiotics) parts.push(`Antibióticos: ${p.antibiotics}`);
      if (p.vasoactive_drugs) parts.push(`Drogas vasoativas: ${p.vasoactive_drugs}`);
      if (p.exams) parts.push(`Exames: ${p.exams}`);
      if (p.pending) parts.push(`Pendências: ${p.pending}`);
      if (p.observations) parts.push(`Observações: ${p.observations}`);
      return parts.join(" | ");
    })
    .join("\n");
}

function buildNotesSummary(notes) {
  if (!notes || notes.length === 0) return "Nenhuma nota registrada.";
  return notes
    .map((n) => `[${n.title}]: ${n.content}`)
    .join("\n");
}

const SYSTEM_PROMPT = `Você é a IA Médica do GuideDose, um assistente clínico inteligente para médicos.

SUAS CAPACIDADES:
- Você tem acesso aos dados dos pacientes e notas clínicas do médico que está conversando com você.
- Pode ajudar com análise de casos clínicos, sugestões de conduta, revisão de medicamentos e interações.
- Pode resumir informações de pacientes e notas.
- Pode auxiliar em raciocínio clínico baseado nos dados disponíveis.

REGRAS IMPORTANTES:
- Sempre responda em português brasileiro.
- Seja conciso e direto, mas completo quando necessário.
- Quando mencionar medicamentos, inclua doses e vias quando relevante.
- SEMPRE deixe claro que suas respostas são sugestões e que o médico deve usar seu julgamento clínico.
- Nunca faça diagnósticos definitivos — ofereça diagnósticos diferenciais e raciocínio clínico.
- Se não tiver informação suficiente, peça mais detalhes.
- Formate suas respostas de forma clara usando **negrito** para termos importantes.
- Quando o médico perguntar sobre um paciente específico, use os dados disponíveis.`;

exports.handler = async (event) => {
  if (event.httpMethod === "OPTIONS") {
    return jsonResponse(200, {});
  }

  if (event.httpMethod !== "POST") {
    return jsonResponse(405, { error: "Método não permitido." });
  }

  try {
    if (!SUPABASE_URL || !SUPABASE_ANON_KEY) {
      return jsonResponse(500, { error: "Supabase não configurado." });
    }

    if (!OPENAI_API_KEY) {
      return jsonResponse(500, { error: "API de IA não configurada." });
    }

    const authHeader = event.headers.authorization || "";
    const token = authHeader.replace("Bearer", "").trim();
    if (!token) {
      return jsonResponse(401, { error: "Token ausente." });
    }

    const user = await validateToken(token);
    if (!user) {
      return jsonResponse(401, { error: "Sessão inválida." });
    }

    const body = JSON.parse(event.body || "{}");
    const { message, history = [] } = body;

    if (!message || typeof message !== "string") {
      return jsonResponse(400, { error: "Mensagem é obrigatória." });
    }

    const [patients, patientsArchive, notes, notesArchive] = await Promise.all([
      querySupabase(token, "patients"),
      querySupabase(token, "patients_archive"),
      querySupabase(token, "notes"),
      querySupabase(token, "notes_archive"),
    ]);

    const contextBlock = [
      "=== PACIENTES ATIVOS ===",
      buildPatientSummary(patients),
      "",
      "=== PACIENTES ARQUIVADOS ===",
      buildPatientSummary(patientsArchive),
      "",
      "=== NOTAS ATIVAS ===",
      buildNotesSummary(notes),
      "",
      "=== NOTAS ARQUIVADAS ===",
      buildNotesSummary(notesArchive),
    ].join("\n");

    const systemMessage = `${SYSTEM_PROMPT}\n\n--- DADOS DO MÉDICO ---\nEmail: ${user.email || "N/A"}\n\n--- DADOS CLÍNICOS DISPONÍVEIS ---\n${contextBlock}`;

    const chatMessages = [
      { role: "system", content: systemMessage },
      ...history.slice(-10).map((m) => ({
        role: m.role === "user" ? "user" : "assistant",
        content: m.content,
      })),
      { role: "user", content: message },
    ];

    const openaiRes = await fetch("https://api.openai.com/v1/chat/completions", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${OPENAI_API_KEY}`,
      },
      body: JSON.stringify({
        model: "gpt-4o-mini",
        messages: chatMessages,
        max_tokens: 1500,
        temperature: 0.4,
      }),
    });

    if (!openaiRes.ok) {
      const errData = await openaiRes.text();
      console.error("OpenAI error:", errData);
      return jsonResponse(502, { error: "Erro ao consultar a IA. Tente novamente." });
    }

    const openaiData = await openaiRes.json();
    const reply = openaiData.choices?.[0]?.message?.content || "Sem resposta da IA.";

    return jsonResponse(200, { reply });
  } catch (error) {
    console.error("ai-chat error:", error);
    return jsonResponse(500, { error: error.message || "Erro interno." });
  }
};
