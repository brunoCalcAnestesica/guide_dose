const SUPABASE_URL = process.env.SUPABASE_URL || "";
const SUPABASE_ANON_KEY = process.env.SUPABASE_ANON_KEY || "";
const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY || "";
const ADMIN_EMAILS = (process.env.SUPABASE_ADMIN_EMAILS || "")
  .split(",")
  .map((email) => email.trim().toLowerCase())
  .filter(Boolean);

function jsonResponse(statusCode, payload) {
  return {
    statusCode,
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify(payload),
  };
}

async function getUserFromToken(token) {
  if (!SUPABASE_URL || !SUPABASE_ANON_KEY) {
    throw new Error("Supabase nao configurado no Netlify.");
  }
  const response = await fetch(`${SUPABASE_URL}/auth/v1/user`, {
    headers: {
      Authorization: `Bearer ${token}`,
      apikey: SUPABASE_ANON_KEY,
    },
  });

  if (!response.ok) {
    return null;
  }
  return response.json();
}

async function listUsers() {
  if (!SUPABASE_SERVICE_ROLE_KEY) {
    throw new Error("Service role key nao configurada.");
  }
  const response = await fetch(`${SUPABASE_URL}/auth/v1/admin/users`, {
    headers: {
      Authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
      apikey: SUPABASE_SERVICE_ROLE_KEY,
    },
  });

  const data = await response.json();
  if (!response.ok) {
    throw new Error(data?.msg || "Falha ao listar usuarios.");
  }
  return data.users || [];
}

async function listAccessStats() {
  if (!SUPABASE_SERVICE_ROLE_KEY) {
    throw new Error("Service role key nao configurada.");
  }
  const response = await fetch(
    `${SUPABASE_URL}/rest/v1/profiles?select=id,access_count`,
    {
      headers: {
        Authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
        apikey: SUPABASE_SERVICE_ROLE_KEY,
      },
    }
  );

  const data = await response.json();
  if (!response.ok) {
    throw new Error(data?.message || "Falha ao listar acessos.");
  }
  return data || [];
}

async function createUser(payload) {
  if (!SUPABASE_SERVICE_ROLE_KEY) {
    throw new Error("Service role key nao configurada.");
  }
  const response = await fetch(`${SUPABASE_URL}/auth/v1/admin/users`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
      apikey: SUPABASE_SERVICE_ROLE_KEY,
    },
    body: JSON.stringify({
      email: payload.email,
      password: payload.password,
      email_confirm: true,
    }),
  });

  const data = await response.json();
  if (!response.ok) {
    throw new Error(data?.msg || "Falha ao criar usuario.");
  }
  return data;
}

async function updateUser(userId, updates) {
  if (!SUPABASE_SERVICE_ROLE_KEY) {
    throw new Error("Service role key nao configurada.");
  }
  
  const updatePayload = {};
  
  if (updates.password) {
    updatePayload.password = updates.password;
  }
  
  if (updates.email_confirm !== undefined) {
    updatePayload.email_confirm = updates.email_confirm;
  }
  
  const response = await fetch(`${SUPABASE_URL}/auth/v1/admin/users/${userId}`, {
    method: "PUT",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
      apikey: SUPABASE_SERVICE_ROLE_KEY,
    },
    body: JSON.stringify(updatePayload),
  });

  const data = await response.json();
  if (!response.ok) {
    throw new Error(data?.msg || "Falha ao atualizar usuario.");
  }
  return data;
}

async function deleteUser(userId) {
  if (!SUPABASE_SERVICE_ROLE_KEY) {
    throw new Error("Service role key nao configurada.");
  }
  
  const response = await fetch(`${SUPABASE_URL}/auth/v1/admin/users/${userId}`, {
    method: "DELETE",
    headers: {
      Authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
      apikey: SUPABASE_SERVICE_ROLE_KEY,
    },
  });

  if (!response.ok) {
    const data = await response.json().catch(() => ({}));
    throw new Error(data?.msg || "Falha ao excluir usuario.");
  }
  
  return { ok: true };
}

exports.handler = async (event) => {
  try {
    if (!SUPABASE_URL || !SUPABASE_ANON_KEY) {
      return jsonResponse(500, {
        error: "Supabase nao configurado no Netlify.",
      });
    }

    if (!ADMIN_EMAILS.length) {
      return jsonResponse(403, {
        error: "Nenhum administrador configurado.",
      });
    }

    const authHeader = event.headers.authorization || "";
    const token = authHeader.replace("Bearer", "").trim();
    if (!token) {
      return jsonResponse(401, { error: "Token ausente." });
    }

    const user = await getUserFromToken(token);
    if (!user?.email || !ADMIN_EMAILS.includes(user.email.toLowerCase())) {
      return jsonResponse(403, { error: "Acesso negado." });
    }

    // GET - List users
    if (event.httpMethod === "GET") {
      const users = await listUsers();
      const accessStats = await listAccessStats();
      const accessMap = new Map(
        accessStats.map((item) => [item.id, item.access_count || 0])
      );
      const usersWithAccess = users.map((user) => ({
        ...user,
        access_count: accessMap.get(user.id) ?? 0,
      }));
      return jsonResponse(200, { users: usersWithAccess });
    }

    // POST - Create user
    if (event.httpMethod === "POST") {
      const body = event.body ? JSON.parse(event.body) : {};
      if (!body.email || !body.password) {
        return jsonResponse(400, { error: "Informe e-mail e senha." });
      }
      await createUser(body);
      return jsonResponse(200, { ok: true });
    }

    // PUT - Update user (confirm email or change password)
    if (event.httpMethod === "PUT") {
      const body = event.body ? JSON.parse(event.body) : {};
      if (!body.userId) {
        return jsonResponse(400, { error: "Informe o ID do usuario." });
      }
      
      const updates = {};
      
      if (body.action === "confirm") {
        updates.email_confirm = true;
      } else if (body.action === "update" && body.password) {
        updates.password = body.password;
      } else if (body.password) {
        updates.password = body.password;
      } else {
        // Default to confirm if no action specified (backwards compatibility)
        updates.email_confirm = true;
      }
      
      await updateUser(body.userId, updates);
      return jsonResponse(200, { ok: true });
    }

    // DELETE - Delete user
    if (event.httpMethod === "DELETE") {
      const body = event.body ? JSON.parse(event.body) : {};
      if (!body.userId) {
        return jsonResponse(400, { error: "Informe o ID do usuario." });
      }
      await deleteUser(body.userId);
      return jsonResponse(200, { ok: true });
    }

    return jsonResponse(405, { error: "Metodo nao suportado." });
  } catch (error) {
    return jsonResponse(500, { error: error.message || "Erro interno." });
  }
};
