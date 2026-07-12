// Supabase Edge Function: POST /sync/push
// Idempotently ingests a batch of client outbox events. Deploy with:
//   supabase functions deploy sync-push --no-verify-jwt=false
//
// Auth: the caller's Supabase JWT is verified automatically; RLS + the
// memberships table scope every insert to the user's business_id.
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

Deno.serve(async (req) => {
  if (req.method !== "POST") return new Response("Method not allowed", { status: 405 });

  const authHeader = req.headers.get("Authorization") ?? "";
  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_ANON_KEY")!,
    { global: { headers: { Authorization: authHeader } } },
  );

  const { data: userData } = await supabase.auth.getUser();
  if (!userData?.user) return new Response("Unauthorized", { status: 401 });

  // Resolve the caller's business (first membership; extend for multi-business).
  const { data: mem } = await supabase.from("memberships").select("business_id").limit(1).single();
  if (!mem) return new Response("No business", { status: 403 });

  let body: { events?: Array<Record<string, unknown>> };
  try { body = await req.json(); } catch { return new Response("Bad JSON", { status: 400 }); }
  const events = body.events ?? [];

  const rows = events.map((e) => ({
    idem_key: e.idem_key ?? e.k,
    business_id: mem.business_id,
    kind: e.kind ?? e.t,
    ref: e.ref ?? e.r,
    payload: e.payload ?? {},
  }));

  // on conflict (idem_key) do nothing → idempotent replay (PRD §14).
  const { error, count } = await supabase
    .from("sync_events")
    .upsert(rows, { onConflict: "idem_key", ignoreDuplicates: true, count: "exact" });
  if (error) return new Response(error.message, { status: 500 });

  const { data: head } = await supabase
    .from("sync_events").select("rev").eq("business_id", mem.business_id)
    .order("rev", { ascending: false }).limit(1).single();

  return Response.json({
    accepted: count ?? rows.length,
    duplicates: rows.length - (count ?? rows.length),
    rev: head?.rev ?? 0,
  });
});
