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

const supabaseHeaders = (token) => ({
  apikey: SUPABASE_ANON_KEY,
  Authorization: `Bearer ${token}`,
  "Content-Type": "application/json",
  Prefer: "return=representation",
});

async function querySupabase(token, table, extraParams = "") {
  const url = `${SUPABASE_URL}/rest/v1/${table}?select=*${extraParams}`;
  const response = await fetch(url, {
    headers: { ...supabaseHeaders(token) },
  });
  if (!response.ok) return [];
  return response.json();
}

async function supabaseInsert(token, table, body) {
  const response = await fetch(`${SUPABASE_URL}/rest/v1/${table}`, {
    method: "POST",
    headers: supabaseHeaders(token),
    body: JSON.stringify(body),
  });
  const text = await response.text();
  if (!response.ok) return { error: text || "Erro ao inserir." };
  try {
    return { data: JSON.parse(text) };
  } catch {
    return { data: null };
  }
}

async function supabaseUpdate(token, table, id, body) {
  const response = await fetch(`${SUPABASE_URL}/rest/v1/${table}?id=eq.${id}`, {
    method: "PATCH",
    headers: supabaseHeaders(token),
    body: JSON.stringify(body),
  });
  if (!response.ok) {
    const text = await response.text();
    return { error: text || "Erro ao atualizar." };
  }
  return { data: "ok" };
}

async function supabaseDelete(token, table, id) {
  const response = await fetch(`${SUPABASE_URL}/rest/v1/${table}?id=eq.${id}`, {
    method: "DELETE",
    headers: supabaseHeaders(token),
  });
  if (!response.ok) {
    const text = await response.text();
    return { error: text || "Erro ao deletar." };
  }
  return { data: "ok" };
}

async function supabaseGetById(token, table, id) {
  const list = await querySupabase(token, table, `&id=eq.${id}`);
  return list && list[0] ? list[0] : null;
}

function buildPatientSummary(patients) {
  if (!patients || patients.length === 0) return "Nenhum paciente cadastrado.";
  return patients
    .map((p) => {
      const parts = [`id=${p.id} | ${p.initials}`];
      if (p.age != null) parts.push(`Idade: ${p.age} ${p.age_unit}`);
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
    .map((n) => `id=${n.id} | [${n.title}]: ${n.content}`)
    .join("\n");
}

const AI_TOOLS = [
  {
    type: "function",
    function: {
      name: "create_patient",
      description: "Cria um novo paciente ativo. Use quando o médico pedir para cadastrar ou criar um paciente.",
      parameters: {
        type: "object",
        properties: {
          initials: { type: "string", description: "Iniciais do paciente (obrigatório)" },
          bed: { type: "string", description: "Leito" },
          age: { type: "number", description: "Idade em anos" },
          age_unit: { type: "string", description: "Unidade da idade, ex: anos", default: "anos" },
          diagnosis: { type: "string", description: "Diagnóstico" },
          history: { type: "string", description: "História clínica" },
          devices: { type: "string", description: "Dispositivos" },
          antibiotics: { type: "string", description: "Antibióticos em uso" },
          vasoactive_drugs: { type: "string", description: "Drogas vasoativas" },
          exams: { type: "string", description: "Exames" },
          pending: { type: "string", description: "Pendências" },
          observations: { type: "string", description: "Observações" },
        },
        required: ["initials"],
      },
    },
  },
  {
    type: "function",
    function: {
      name: "update_patient",
      description: "Atualiza um paciente ativo existente. Use o id do paciente da lista de dados.",
      parameters: {
        type: "object",
        properties: {
          id: { type: "string", description: "ID do paciente (obrigatório)" },
          initials: { type: "string" },
          bed: { type: "string" },
          age: { type: "number" },
          diagnosis: { type: "string" },
          history: { type: "string" },
          devices: { type: "string" },
          antibiotics: { type: "string" },
          vasoactive_drugs: { type: "string" },
          exams: { type: "string" },
          pending: { type: "string" },
          observations: { type: "string" },
        },
        required: ["id"],
      },
    },
  },
  {
    type: "function",
    function: {
      name: "delete_patient",
      description: "Remove permanentemente um paciente ativo. Use com cuidado.",
      parameters: {
        type: "object",
        properties: { id: { type: "string", description: "ID do paciente" } },
        required: ["id"],
      },
    },
  },
  {
    type: "function",
    function: {
      name: "archive_patient",
      description: "Arquivar um paciente ativo (move para pacientes arquivados).",
      parameters: {
        type: "object",
        properties: { id: { type: "string", description: "ID do paciente" } },
        required: ["id"],
      },
    },
  },
  {
    type: "function",
    function: {
      name: "restore_patient",
      description: "Restaurar um paciente dos arquivados para ativos.",
      parameters: {
        type: "object",
        properties: { id: { type: "string", description: "ID do paciente arquivado" } },
        required: ["id"],
      },
    },
  },
  {
    type: "function",
    function: {
      name: "create_note",
      description: "Cria uma nova nota geral ativa.",
      parameters: {
        type: "object",
        properties: {
          title: { type: "string", description: "Título da nota (obrigatório)" },
          content: { type: "string", description: "Conteúdo da nota" },
        },
        required: ["title"],
      },
    },
  },
  {
    type: "function",
    function: {
      name: "update_note",
      description: "Atualiza uma nota ativa existente.",
      parameters: {
        type: "object",
        properties: {
          id: { type: "string", description: "ID da nota" },
          title: { type: "string" },
          content: { type: "string" },
        },
        required: ["id"],
      },
    },
  },
  {
    type: "function",
    function: {
      name: "delete_note",
      description: "Exclui permanentemente uma nota ativa.",
      parameters: {
        type: "object",
        properties: { id: { type: "string", description: "ID da nota" } },
        required: ["id"],
      },
    },
  },
  {
    type: "function",
    function: {
      name: "archive_note",
      description: "Arquivar uma nota ativa (move para notas arquivadas).",
      parameters: {
        type: "object",
        properties: { id: { type: "string", description: "ID da nota" } },
        required: ["id"],
      },
    },
  },
  {
    type: "function",
    function: {
      name: "restore_note",
      description: "Restaurar uma nota dos arquivadas para ativas.",
      parameters: {
        type: "object",
        properties: { id: { type: "string", description: "ID da nota arquivada" } },
        required: ["id"],
      },
    },
  },
];

const SYSTEM_PROMPT = `Você é a IA Médica do GuideDose, um assistente clínico inteligente para médicos.

SUAS CAPACIDADES:
- Você tem acesso aos dados dos pacientes e notas clínicas do médico (ativos e arquivados).
- Pode fazer CRUD completo: criar, editar, excluir e arquivar pacientes e notas; pode restaurar itens arquivados.
- Pode ajudar com análise de casos clínicos, sugestões de conduta, revisão de medicamentos e interações.
- Pode resumir informações e auxiliar em raciocínio clínico.

Quando o médico pedir para criar, editar, excluir, arquivar ou restaurar um paciente ou nota, use as ferramentas disponíveis.
Sempre confirme o que foi feito em português e seja conciso.

REGRAS:
- Responda sempre em português brasileiro.
- Use **negrito** para termos importantes.
- Para alterações, use o id correto dos dados disponíveis no contexto.
- Nunca invente ids; use apenas os que aparecem nos dados fornecidos.`;

async function runTool(name, args, token, userId) {
  const now = new Date().toISOString();
  try {
    switch (name) {
      case "create_patient": {
        const id = crypto.randomUUID();
        const body = {
          id,
          user_id: userId,
          initials: args.initials || "",
          bed: args.bed || "",
          age: args.age ?? null,
          age_unit: args.age_unit || "anos",
          admission_date: null,
          diagnosis: args.diagnosis || "",
          history: args.history || "",
          devices: args.devices || "",
          antibiotics: args.antibiotics || "",
          vasoactive_drugs: args.vasoactive_drugs || "",
          exams: args.exams || "",
          pending: args.pending || "",
          observations: args.observations || "",
          created_at: now,
          updated_at: now,
        };
        const r = await supabaseInsert(token, "patients", body);
        return r.error ? r.error : `Paciente criado com id ${id}: ${args.initials}`;
      }
      case "update_patient": {
        const body = {
          updated_at: now,
          ...(args.initials !== undefined && { initials: args.initials }),
          ...(args.bed !== undefined && { bed: args.bed }),
          ...(args.age !== undefined && { age: args.age }),
          ...(args.diagnosis !== undefined && { diagnosis: args.diagnosis }),
          ...(args.history !== undefined && { history: args.history }),
          ...(args.devices !== undefined && { devices: args.devices }),
          ...(args.antibiotics !== undefined && { antibiotics: args.antibiotics }),
          ...(args.vasoactive_drugs !== undefined && { vasoactive_drugs: args.vasoactive_drugs }),
          ...(args.exams !== undefined && { exams: args.exams }),
          ...(args.pending !== undefined && { pending: args.pending }),
          ...(args.observations !== undefined && { observations: args.observations }),
        };
        const r = await supabaseUpdate(token, "patients", args.id, body);
        return r.error ? r.error : "Paciente atualizado.";
      }
      case "delete_patient": {
        const r = await supabaseDelete(token, "patients", args.id);
        return r.error ? r.error : "Paciente excluído.";
      }
      case "archive_patient": {
        const p = await supabaseGetById(token, "patients", args.id);
        if (!p) return "Paciente não encontrado.";
        const ins = await supabaseInsert(token, "patients_archive", { ...p, archived_at: now });
        if (ins.error) return ins.error;
        const del = await supabaseDelete(token, "patients", args.id);
        return del.error ? del.error : "Paciente arquivado.";
      }
      case "restore_patient": {
        const p = await supabaseGetById(token, "patients_archive", args.id);
        if (!p) return "Paciente arquivado não encontrado.";
        const { archived_at, ...rest } = p;
        const ins = await supabaseInsert(token, "patients", { ...rest, updated_at: now });
        if (ins.error) return ins.error;
        await supabaseDelete(token, "patients_archive", args.id);
        return "Paciente restaurado para ativos.";
      }
      case "create_note": {
        const id = crypto.randomUUID();
        const body = {
          id,
          user_id: userId,
          title: args.title || "Sem título",
          content: args.content || "",
          created_at: now,
          updated_at: now,
        };
        const r = await supabaseInsert(token, "notes", body);
        return r.error ? r.error : `Nota criada: "${args.title}"`;
      }
      case "update_note": {
        const body = {
          updated_at: now,
          ...(args.title !== undefined && { title: args.title }),
          ...(args.content !== undefined && { content: args.content }),
        };
        const r = await supabaseUpdate(token, "notes", args.id, body);
        return r.error ? r.error : "Nota atualizada.";
      }
      case "delete_note": {
        const r = await supabaseDelete(token, "notes", args.id);
        return r.error ? r.error : "Nota excluída.";
      }
      case "archive_note": {
        const n = await supabaseGetById(token, "notes", args.id);
        if (!n) return "Nota não encontrada.";
        const ins = await supabaseInsert(token, "notes_archive", { ...n, archived_at: now });
        if (ins.error) return ins.error;
        const del = await supabaseDelete(token, "notes", args.id);
        return del.error ? del.error : "Nota arquivada.";
      }
      case "restore_note": {
        const n = await supabaseGetById(token, "notes_archive", args.id);
        if (!n) return "Nota arquivada não encontrada.";
        const { archived_at, ...rest } = n;
        const ins = await supabaseInsert(token, "notes", { ...rest, updated_at: now });
        if (ins.error) return ins.error;
        await supabaseDelete(token, "notes_archive", args.id);
        return "Nota restaurada para ativas.";
      }
      default:
        return "Função desconhecida.";
    }
  } catch (err) {
    return `Erro: ${err.message}`;
  }
}

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

    const userId = user.id;

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
      "=== PACIENTES ATIVOS (id para editar/arquivar) ===",
      buildPatientSummary(patients),
      "",
      "=== PACIENTES ARQUIVADOS (id para restaurar) ===",
      buildPatientSummary(patientsArchive),
      "",
      "=== NOTAS ATIVAS (id para editar/arquivar) ===",
      buildNotesSummary(notes),
      "",
      "=== NOTAS ARQUIVADAS (id para restaurar) ===",
      buildNotesSummary(notesArchive),
    ].join("\n");

    const systemMessage = `${SYSTEM_PROMPT}\n\n--- DADOS DO MÉDICO ---\nEmail: ${user.email || "N/A"}\n\n--- DADOS CLÍNICOS DISPONÍVEIS ---\n${contextBlock}`;

    let messages = [
      { role: "system", content: systemMessage },
      ...history.slice(-10).map((m) => ({
        role: m.role === "user" ? "user" : "assistant",
        content: m.content,
      })),
      { role: "user", content: message },
    ];

    let lastContent = null;
    let maxRounds = 5;
    let round = 0;

    while (round < maxRounds) {
      round++;
      const bodyRequest = {
        model: "gpt-4o-mini",
        messages,
        max_tokens: 1500,
        temperature: 0.4,
      };
      if (round === 1) bodyRequest.tools = AI_TOOLS;
      if (messages[messages.length - 1].role === "assistant" && messages[messages.length - 1].tool_calls) {
        bodyRequest.tools = AI_TOOLS;
      }

      const openaiRes = await fetch("https://api.openai.com/v1/chat/completions", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${OPENAI_API_KEY}`,
        },
        body: JSON.stringify(bodyRequest),
      });

      if (!openaiRes.ok) {
        const errData = await openaiRes.text();
        console.error("OpenAI error:", errData);
        return jsonResponse(502, { error: "Erro ao consultar a IA. Tente novamente." });
      }

      const openaiData = await openaiRes.json();
      const choice = openaiData.choices?.[0]?.message;
      if (!choice) {
        return jsonResponse(502, { error: "Resposta inválida da IA." });
      }

      messages.push({
        role: "assistant",
        content: choice.content || null,
        tool_calls: choice.tool_calls || undefined,
      });

      if (choice.content) lastContent = choice.content;

      if (!choice.tool_calls || choice.tool_calls.length === 0) {
        break;
      }

      for (const tc of choice.tool_calls) {
        const fn = tc.function;
        const name = fn.name;
        let args = {};
        try {
          args = JSON.parse(fn.arguments || "{}");
        } catch (_) {}
        const result = await runTool(name, args, token, userId);
        messages.push({
          role: "tool",
          tool_call_id: tc.id,
          content: String(result),
        });
      }
    }

    const reply = lastContent || "Operação concluída. Atualize a página para ver as alterações.";
    return jsonResponse(200, { reply });
  } catch (error) {
    console.error("ai-chat error:", error);
    return jsonResponse(500, { error: error.message || "Erro interno." });
  }
};
