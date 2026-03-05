const path = require("path");
const fs = require("fs");

function loadEnvFromFile(filePath) {
  if (!filePath || !fs.existsSync(filePath)) return;
  const content = fs.readFileSync(filePath, "utf8").replace(/\r\n/g, "\n");
  content.split("\n").forEach((line) => {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith("#")) return;
    const eq = trimmed.indexOf("=");
    if (eq <= 0) return;
    const key = trimmed.slice(0, eq).trim();
    const value = trimmed.slice(eq + 1).trim().replace(/^["']|["']$/g, "");
    if (key && !process.env[key]) process.env[key] = value;
  });
}

function findEnvDir(startDir) {
  let dir = startDir;
  for (let i = 0; i < 10; i++) {
    if (fs.existsSync(path.join(dir, ".env"))) return dir;
    const parent = path.dirname(dir);
    if (parent === dir) break;
    dir = parent;
  }
  return null;
}

if (!process.env.SUPABASE_SERVICE_ROLE_KEY || !process.env.SUPABASE_URL) {
  try {
    loadEnvFromFile(path.join(__dirname, ".env"));
    const envDir = findEnvDir(__dirname) || findEnvDir(process.cwd());
    if (envDir) loadEnvFromFile(path.join(envDir, ".env"));
  } catch (_) {}
}

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
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Headers": "Content-Type, Authorization",
      "Access-Control-Allow-Methods": "POST, OPTIONS",
    },
    body: JSON.stringify(payload),
  };
}

async function validateAdmin(token) {
  const response = await fetch(`${SUPABASE_URL}/auth/v1/user`, {
    headers: {
      Authorization: `Bearer ${token}`,
      apikey: SUPABASE_ANON_KEY,
    },
  });
  if (!response.ok) return null;
  const user = await response.json();
  if (!user?.email || !ADMIN_EMAILS.includes(user.email.toLowerCase())) {
    return null;
  }
  return user;
}

exports.handler = async (event) => {
  if (event.httpMethod === "OPTIONS") {
    return jsonResponse(200, {});
  }

  if (event.httpMethod !== "POST") {
    return jsonResponse(405, { error: "Apenas POST permitido." });
  }

  try {
    if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY) {
      return jsonResponse(500, { error: "Supabase nao configurado." });
    }

    const authHeader = event.headers.authorization || "";
    const token = authHeader.replace("Bearer", "").trim();
    if (!token) {
      return jsonResponse(401, { error: "Token ausente." });
    }

    const admin = await validateAdmin(token);
    if (!admin) {
      return jsonResponse(403, { error: "Acesso restrito a administradores." });
    }

    const response = await fetch(
      `${SUPABASE_URL}/functions/v1/send-push`,
      {
        method: "POST",
        headers: {
          Authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
          "Content-Type": "application/json",
        },
        body: event.body,
      }
    );

    const text = await response.text();
    let data;
    try {
      data = JSON.parse(text);
    } catch {
      data = { message: text };
    }

    return jsonResponse(response.status, data);
  } catch (error) {
    return jsonResponse(500, { error: error.message || "Erro interno." });
  }
};
