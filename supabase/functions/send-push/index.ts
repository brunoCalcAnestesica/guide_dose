import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

// ---------------------------------------------------------------------------
// Google OAuth2 – get access token from service account for FCM v1
// ---------------------------------------------------------------------------

interface ServiceAccount {
  project_id: string;
  client_email: string;
  private_key: string;
}

function base64url(buf: ArrayBuffer): string {
  return btoa(String.fromCharCode(...new Uint8Array(buf)))
    .replace(/\+/g, "-")
    .replace(/\//g, "_")
    .replace(/=+$/, "");
}

async function getAccessToken(sa: ServiceAccount): Promise<string> {
  const now = Math.floor(Date.now() / 1000);
  const header = { alg: "RS256", typ: "JWT" };
  const payload = {
    iss: sa.client_email,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
    aud: "https://oauth2.googleapis.com/token",
    iat: now,
    exp: now + 3600,
  };

  const enc = new TextEncoder();
  const headerB64 = base64url(enc.encode(JSON.stringify(header)));
  const payloadB64 = base64url(enc.encode(JSON.stringify(payload)));
  const unsignedToken = `${headerB64}.${payloadB64}`;

  const pemBody = sa.private_key
    .replace(/-----BEGIN PRIVATE KEY-----/, "")
    .replace(/-----END PRIVATE KEY-----/, "")
    .replace(/\n/g, "");
  const binaryDer = Uint8Array.from(atob(pemBody), (c) => c.charCodeAt(0));

  const key = await crypto.subtle.importKey(
    "pkcs8",
    binaryDer,
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"]
  );

  const signature = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    key,
    enc.encode(unsignedToken)
  );

  const jwt = `${unsignedToken}.${base64url(signature)}`;

  const res = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: `grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=${jwt}`,
  });

  const data = await res.json();
  if (!res.ok) throw new Error(`OAuth2 error: ${JSON.stringify(data)}`);
  return data.access_token;
}

// ---------------------------------------------------------------------------
// Send a single FCM message
// ---------------------------------------------------------------------------

async function sendFcmMessage(
  accessToken: string,
  projectId: string,
  token: string,
  title: string,
  body: string,
  data?: Record<string, string>
): Promise<boolean> {
  const message: Record<string, unknown> = {
    message: {
      token,
      notification: { title, body },
      android: {
        priority: "high",
        notification: { channel_id: "push_notifications" },
      },
      apns: {
        payload: { aps: { sound: "default", badge: 1 } },
      },
      ...(data ? { data } : {}),
    },
  };

  const res = await fetch(
    `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${accessToken}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify(message),
    }
  );

  if (!res.ok) {
    const err = await res.text();
    console.error(`FCM send failed for token ${token.slice(0, 20)}…: ${err}`);
    return false;
  }
  return true;
}

// ---------------------------------------------------------------------------
// Main handler
// ---------------------------------------------------------------------------

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

    // Parse input
    const {
      target,
      title,
      body,
      link,
      source = "manual",
    }: {
      target: string | string[];
      title: string;
      body: string;
      link?: string;
      source?: string;
    } = await req.json();

    if (!title || !body || !target) {
      return new Response(
        JSON.stringify({ error: "title, body and target are required" }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // Verify caller is admin (skip for system/cron calls with service role key)
    const authHeader = req.headers.get("Authorization");
    const isServiceRole =
      authHeader === `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`;
    if (!isServiceRole && authHeader) {
      const token = authHeader.replace("Bearer ", "");
      const anonKey =
        Deno.env.get("SUPABASE_ANON_KEY") ?? SUPABASE_SERVICE_ROLE_KEY;
      const userClient = createClient(SUPABASE_URL, anonKey);
      const {
        data: { user },
        error,
      } = await userClient.auth.getUser(token);
      if (error || !user) {
        return new Response(JSON.stringify({ error: "Unauthorized" }), {
          status: 401,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }
      const { data: adminCheck } = await supabase.rpc("is_admin", {
        uid: user.id,
      });
      if (!adminCheck) {
        return new Response(JSON.stringify({ error: "Forbidden: admin only" }), {
          status: 403,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }
    }

    // Resolve FCM tokens based on target
    let targetType: string;
    let targetValue: string | null = null;
    let tokens: { token: string; user_id: string }[] = [];

    if (target === "all") {
      targetType = "all";
      const { data } = await supabase
        .from("fcm_tokens")
        .select("token, user_id");
      tokens = data ?? [];
    } else if (Array.isArray(target)) {
      targetType = "users";
      targetValue = target.join(",");
      const { data } = await supabase
        .from("fcm_tokens")
        .select("token, user_id")
        .in("user_id", target);
      tokens = data ?? [];
    } else {
      targetType = "user";
      targetValue = target;
      const { data } = await supabase
        .from("fcm_tokens")
        .select("token, user_id")
        .eq("user_id", target);
      tokens = data ?? [];
    }

    // Filter by user notification preferences
    if (tokens.length > 0) {
      const userIds = [...new Set(tokens.map((t) => t.user_id))];
      const { data: prefs } = await supabase
        .from("notification_preferences")
        .select("user_id, push_enabled, eve_shift_enabled, blocked_day_enabled, broadcast_enabled")
        .in("user_id", userIds);

      if (prefs && prefs.length > 0) {
        const prefsMap = new Map(prefs.map((p) => [p.user_id, p]));
        tokens = tokens.filter((t) => {
          const p = prefsMap.get(t.user_id);
          if (!p) return true; // no prefs row = all enabled
          if (!p.push_enabled) return false;
          if (source === "auto_eve" && !p.eve_shift_enabled) return false;
          if (source === "auto_blocked" && !p.blocked_day_enabled) return false;
          if (source === "broadcast" && !p.broadcast_enabled) return false;
          return true;
        });
      }
    }

    if (tokens.length === 0) {
      return new Response(
        JSON.stringify({ sent: 0, message: "No tokens found" }),
        {
          status: 200,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // Load Firebase service account from Supabase secret
    const saJson = Deno.env.get("FIREBASE_SERVICE_ACCOUNT");
    if (!saJson) {
      return new Response(
        JSON.stringify({ error: "FIREBASE_SERVICE_ACCOUNT secret not set" }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }
    const sa: ServiceAccount = JSON.parse(saJson);
    const accessToken = await getAccessToken(sa);

    // Build FCM data payload
    const fcmData: Record<string, string> = {};
    if (link) fcmData.url = link;
    if (source) fcmData.source = source;

    // Send to all tokens (batch, no Promise.all to avoid rate limits)
    let sent = 0;
    const invalidTokens: string[] = [];

    const BATCH_SIZE = 50;
    for (let i = 0; i < tokens.length; i += BATCH_SIZE) {
      const batch = tokens.slice(i, i + BATCH_SIZE);
      const results = await Promise.all(
        batch.map((t) =>
          sendFcmMessage(
            accessToken,
            sa.project_id,
            t.token,
            title,
            body,
            Object.keys(fcmData).length > 0 ? fcmData : undefined
          ).catch(() => false)
        )
      );
      results.forEach((ok, idx) => {
        if (ok) sent++;
        else invalidTokens.push(batch[idx].token);
      });
    }

    // Clean up invalid tokens
    if (invalidTokens.length > 0) {
      await supabase
        .from("fcm_tokens")
        .delete()
        .in("token", invalidTokens);
    }

    // Log notification
    await supabase.from("push_notifications").insert({
      target_type: targetType,
      target_value: targetValue,
      title,
      body,
      link,
      tokens_count: sent,
      source,
    });

    return new Response(
      JSON.stringify({ sent, total_tokens: tokens.length }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  } catch (err) {
    console.error("send-push error:", err);
    return new Response(
      JSON.stringify({ error: (err as Error).message }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});
