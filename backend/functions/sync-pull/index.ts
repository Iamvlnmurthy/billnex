// Supabase Edge Function: GET /sync/pull?since=<rev>
// Returns events created after `since` for the caller's business, ordered by
// rev, so other devices/branches converge. Deploy:
//   supabase functions deploy sync-pull
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

Deno.serve(async (req) => {
  const url = new URL(req.url);
  const since = Number(url.searchParams.get("since") ?? "0");

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_ANON_KEY")!,
    { global: { headers: { Authorization: req.headers.get("Authorization") ?? "" } } },
  );

  const { data: userData } = await supabase.auth.getUser();
  if (!userData?.user) return new Response("Unauthorized", { status: 401 });

  // RLS restricts rows to the caller's business automatically.
  const { data, error } = await supabase
    .from("sync_events")
    .select("idem_key, kind, ref, payload, rev")
    .gt("rev", since)
    .order("rev", { ascending: true })
    .limit(500);
  if (error) return new Response(error.message, { status: 500 });

  const events = (data ?? []).map((r) => ({
    idem_key: r.idem_key, kind: r.kind, ref: r.ref, payload: r.payload, rev: r.rev,
  }));
  const rev = events.length ? events[events.length - 1].rev : since;
  return Response.json({ rev, events });
});
