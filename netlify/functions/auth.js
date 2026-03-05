const SUPABASE_URL = process.env.SUPABASE_URL || "";
const SUPABASE_ANON_KEY = process.env.SUPABASE_ANON_KEY || "";

function jsonResponse(statusCode, payload) {
  return {
    statusCode,
    headers: {
      "Content-Type": "application/json",
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Headers": "Content-Type, Authorization",
      "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
    },
    body: JSON.stringify(payload),
  };
}

async function login(email, password) {
  const response = await fetch(
    `${SUPABASE_URL}/auth/v1/token?grant_type=password`,
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        apikey: SUPABASE_ANON_KEY,
      },
      body: JSON.stringify({ email, password }),
    }
  );

  const data = await response.json();
  if (!response.ok) {
    throw new Error(data?.error_description || data?.msg || "Falha ao autenticar.");
  }
  return {
    access_token: data.access_token,
    refresh_token: data.refresh_token,
    expires_in: data.expires_in,
    user: data.user,
  };
}

async function signup(email, password) {
  const response = await fetch(`${SUPABASE_URL}/auth/v1/signup`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      apikey: SUPABASE_ANON_KEY,
    },
    body: JSON.stringify({ email, password }),
  });

  const data = await response.json();
  if (!response.ok) {
    const msg =
      data?.message ||
      data?.error_description ||
      data?.msg ||
      data?.error ||
      "Falha ao criar conta.";
    if (
      typeof msg === "string" &&
      msg.toLowerCase().includes("database error saving new user")
    ) {
      throw new Error(
        "Erro ao criar conta: configuração do banco de dados. Execute o script supabase_profiles_table_and_trigger.sql no Supabase (SQL Editor) e tente novamente."
      );
    }
    throw new Error(typeof msg === "string" ? msg : "Falha ao criar conta.");
  }
  return { user: data.user || data, message: "Cadastro realizado. Verifique seu e-mail." };
}

async function resetPassword(email, redirectTo) {
  const response = await fetch(`${SUPABASE_URL}/auth/v1/recover`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      apikey: SUPABASE_ANON_KEY,
    },
    body: JSON.stringify({ email, redirect_to: redirectTo }),
  });

  if (!response.ok) {
    const data = await response.json().catch(() => ({}));
    throw new Error(data?.error_description || data?.msg || "Falha ao enviar e-mail de recuperacao.");
  }
  return { message: "Link de recuperacao enviado ao e-mail." };
}

async function refreshToken(refresh_token) {
  const response = await fetch(
    `${SUPABASE_URL}/auth/v1/token?grant_type=refresh_token`,
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        apikey: SUPABASE_ANON_KEY,
      },
      body: JSON.stringify({ refresh_token }),
    }
  );

  const data = await response.json();
  if (!response.ok) {
    throw new Error(data?.error_description || data?.msg || "Falha ao renovar sessao.");
  }
  return {
    access_token: data.access_token,
    refresh_token: data.refresh_token,
    expires_in: data.expires_in,
    user: data.user,
  };
}

async function getUser(token) {
  const response = await fetch(`${SUPABASE_URL}/auth/v1/user`, {
    headers: {
      Authorization: `Bearer ${token}`,
      apikey: SUPABASE_ANON_KEY,
    },
  });

  const data = await response.json();
  if (!response.ok) {
    throw new Error("Sessao invalida.");
  }
  return { user: data };
}

async function logout(token) {
  await fetch(`${SUPABASE_URL}/auth/v1/logout`, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${token}`,
      apikey: SUPABASE_ANON_KEY,
    },
  });
  return { message: "Sessao encerrada." };
}

async function updatePassword(token, newPassword) {
  const response = await fetch(`${SUPABASE_URL}/auth/v1/user`, {
    method: "PUT",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${token}`,
      apikey: SUPABASE_ANON_KEY,
    },
    body: JSON.stringify({ password: newPassword }),
  });

  const data = await response.json();
  if (!response.ok) {
    throw new Error(data?.error_description || data?.msg || "Falha ao atualizar senha.");
  }
  return { message: "Senha atualizada com sucesso." };
}

exports.handler = async (event) => {
  if (event.httpMethod === "OPTIONS") {
    return jsonResponse(200, {});
  }

  try {
    if (!SUPABASE_URL || !SUPABASE_ANON_KEY) {
      return jsonResponse(500, { error: "Supabase nao configurado no servidor." });
    }

    if (event.httpMethod === "GET") {
      const authHeader = event.headers.authorization || "";
      const token = authHeader.replace("Bearer", "").trim();
      if (!token) {
        return jsonResponse(401, { error: "Token ausente." });
      }
      const result = await getUser(token);
      return jsonResponse(200, result);
    }

    if (event.httpMethod !== "POST") {
      return jsonResponse(405, { error: "Metodo nao suportado." });
    }

    const body = event.body ? JSON.parse(event.body) : {};
    const { action } = body;

    switch (action) {
      case "login": {
        if (!body.email || !body.password) {
          return jsonResponse(400, { error: "Informe e-mail e senha." });
        }
        const result = await login(body.email, body.password);
        return jsonResponse(200, result);
      }

      case "signup": {
        if (!body.email || !body.password) {
          return jsonResponse(400, { error: "Informe e-mail e senha." });
        }
        const result = await signup(body.email, body.password);
        return jsonResponse(200, result);
      }

      case "logout": {
        const authHeader = event.headers.authorization || "";
        const token = authHeader.replace("Bearer", "").trim();
        if (token) {
          await logout(token);
        }
        return jsonResponse(200, { message: "Sessao encerrada." });
      }

      case "reset": {
        if (!body.email) {
          return jsonResponse(400, { error: "Informe o e-mail." });
        }
        const result = await resetPassword(body.email, body.redirectTo || "");
        return jsonResponse(200, result);
      }

      case "refresh": {
        if (!body.refresh_token) {
          return jsonResponse(400, { error: "Refresh token ausente." });
        }
        const result = await refreshToken(body.refresh_token);
        return jsonResponse(200, result);
      }

      case "update_password": {
        const authHeader = event.headers.authorization || "";
        const token = authHeader.replace("Bearer", "").trim();
        if (!token) {
          return jsonResponse(401, { error: "Token ausente." });
        }
        if (!body.password) {
          return jsonResponse(400, { error: "Informe a nova senha." });
        }
        const result = await updatePassword(token, body.password);
        return jsonResponse(200, result);
      }

      default:
        return jsonResponse(400, { error: `Acao desconhecida: ${action}` });
    }
  } catch (error) {
    return jsonResponse(500, { error: error.message || "Erro interno." });
  }
};
