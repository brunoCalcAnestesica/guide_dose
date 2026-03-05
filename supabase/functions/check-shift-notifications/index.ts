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
// Helper: call the send-push Edge Function
// ---------------------------------------------------------------------------

async function callSendPush(
  target: string | string[],
  title: string,
  body: string,
  source: string,
  link?: string
): Promise<number> {
  const res = await fetch(`${SUPABASE_URL}/functions/v1/send-push`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
    },
    body: JSON.stringify({ target, title, body, link, source }),
  });
  if (!res.ok) {
    console.error(`send-push returned ${res.status}: ${await res.text()}`);
    return 0;
  }
  const data = await res.json();
  return data.sent ?? 0;
}

// ---------------------------------------------------------------------------
// Helper: format date as YYYY-MM-DD in São Paulo timezone
// ---------------------------------------------------------------------------

function dateSP(offsetDays = 0): string {
  const now = new Date();
  const sp = new Date(
    now.toLocaleString("en-US", { timeZone: "America/Sao_Paulo" })
  );
  sp.setDate(sp.getDate() + offsetDays);
  const y = sp.getFullYear();
  const m = String(sp.getMonth() + 1).padStart(2, "0");
  const d = String(sp.getDate()).padStart(2, "0");
  return `${y}-${m}-${d}`;
}

// ---------------------------------------------------------------------------
// 1. Eve-of-shift: push for each user who has shifts TOMORROW
// ---------------------------------------------------------------------------

async function processEveOfShift(
  supabase: ReturnType<typeof createClient>
): Promise<number> {
  const tomorrow = dateSP(1);

  const { data: shifts, error } = await supabase
    .from("shifts")
    .select("user_id, hospital_name, start_time, date")
    .eq("date", tomorrow);

  if (error) {
    console.error("Error fetching shifts for eve:", error.message);
    return 0;
  }
  if (!shifts || shifts.length === 0) return 0;

  // Group by user
  const byUser = new Map<
    string,
    { hospital_name: string; start_time: string }[]
  >();
  for (const s of shifts) {
    const list = byUser.get(s.user_id) ?? [];
    list.push({
      hospital_name: s.hospital_name,
      start_time: s.start_time,
    });
    byUser.set(s.user_id, list);
  }

  let totalSent = 0;

  for (const [userId, userShifts] of byUser) {
    for (const shift of userShifts) {
      const hour = shift.start_time.slice(0, 5); // "07:00"
      const hospital = shift.hospital_name || "hospital";
      const body = `Olá, você tem um plantão no ${hospital} amanhã às ${hour}.`;

      totalSent += await callSendPush(
        userId,
        "Lembrete de plantão",
        body,
        "auto_eve",
        "guidedose://escala"
      );
    }
  }

  return totalSent;
}

// ---------------------------------------------------------------------------
// 2. Blocked-day conflict: push for users with shifts on blocked days
// ---------------------------------------------------------------------------

async function processBlockedDayConflicts(
  supabase: ReturnType<typeof createClient>
): Promise<number> {
  // Fetch all blocked days (future or today)
  const today = dateSP(0);

  const { data: blockedDays, error: bdErr } = await supabase
    .from("blocked_days")
    .select("user_id, date")
    .gte("date", today);

  if (bdErr) {
    console.error("Error fetching blocked_days:", bdErr.message);
    return 0;
  }
  if (!blockedDays || blockedDays.length === 0) return 0;

  // Group blocked dates by user
  const blockedByUser = new Map<string, Set<string>>();
  for (const bd of blockedDays) {
    const set = blockedByUser.get(bd.user_id) ?? new Set();
    set.add(bd.date);
    blockedByUser.set(bd.user_id, set);
  }

  let totalSent = 0;

  for (const [userId, dates] of blockedByUser) {
    const dateArray = [...dates];
    const { data: conflictShifts } = await supabase
      .from("shifts")
      .select("id")
      .eq("user_id", userId)
      .in("date", dateArray)
      .limit(1);

    if (conflictShifts && conflictShifts.length > 0) {
      totalSent += await callSendPush(
        userId,
        "Plantões em dia bloqueado",
        "Você tem plantão(ões) em dia bloqueado na agenda. Lembre-se de repassar.",
        "auto_blocked",
        "guidedose://escala"
      );
    }
  }

  return totalSent;
}

// ---------------------------------------------------------------------------
// 3. Process scheduled notifications (push_schedules)
// ---------------------------------------------------------------------------

async function processSchedules(
  supabase: ReturnType<typeof createClient>
): Promise<number> {
  const now = new Date().toISOString();

  const { data: schedules, error } = await supabase
    .from("push_schedules")
    .select("*")
    .eq("is_active", true)
    .lte("scheduled_at", now);

  if (error) {
    console.error("Error fetching schedules:", error.message);
    return 0;
  }
  if (!schedules || schedules.length === 0) return 0;

  let totalSent = 0;

  for (const sched of schedules) {
    const target =
      sched.target_type === "all"
        ? "all"
        : sched.target_type === "users"
        ? sched.target_value.split(",")
        : sched.target_value;

    totalSent += await callSendPush(
      target,
      sched.title,
      sched.body,
      "schedule",
      sched.link
    );

    if (sched.recurrence) {
      // Compute next run
      const nextRun = computeNextRun(sched.scheduled_at, sched.recurrence);
      await supabase
        .from("push_schedules")
        .update({ scheduled_at: nextRun, last_run_at: now })
        .eq("id", sched.id);
    } else {
      await supabase
        .from("push_schedules")
        .update({ is_active: false, last_run_at: now })
        .eq("id", sched.id);
    }
  }

  return totalSent;
}

function computeNextRun(current: string, recurrence: string): string {
  const d = new Date(current);
  switch (recurrence) {
    case "daily":
      d.setDate(d.getDate() + 1);
      break;
    case "weekly":
      d.setDate(d.getDate() + 7);
      break;
    case "monthly":
      d.setMonth(d.getMonth() + 1);
      break;
    default:
      d.setDate(d.getDate() + 1);
  }
  return d.toISOString();
}

// ---------------------------------------------------------------------------
// Main handler – intended to be called by pg_cron or external cron
// ---------------------------------------------------------------------------

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // Only allow service-role or cron calls
    const authHeader = req.headers.get("Authorization");
    const isServiceRole =
      authHeader === `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`;
    if (!isServiceRole) {
      return new Response(
        JSON.stringify({ error: "Service role key required" }),
        {
          status: 403,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

    // Determine which checks to run (default: all)
    let mode = "all";
    try {
      const body = await req.json();
      if (body.mode) mode = body.mode;
    } catch {
      // no body = run all
    }

    const results: Record<string, number> = {};

    if (mode === "all" || mode === "eve") {
      results.eve_of_shift = await processEveOfShift(supabase);
    }
    if (mode === "all" || mode === "blocked") {
      results.blocked_day = await processBlockedDayConflicts(supabase);
    }
    if (mode === "all" || mode === "schedules") {
      results.schedules = await processSchedules(supabase);
    }

    return new Response(JSON.stringify({ ok: true, results }), {
      status: 200,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (err) {
    console.error("check-shift-notifications error:", err);
    return new Response(
      JSON.stringify({ error: (err as Error).message }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});
