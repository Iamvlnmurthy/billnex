# BillNex Backend (P5) — deploy runbook

The app runs fully offline today. This makes it multi-device, multi-branch, and
cloud-backed. Everything here is deployable by **you** with a Supabase project;
no code in the app changes — you swap `NoopSyncService` for `HttpSyncService`.

## Contents
| File | What it is |
|---|---|
| `schema.sql` | Postgres tables (multi-tenant by `business_id`) + indexes |
| `policies.sql` | Row-Level Security — tenant isolation (loaded by `schema.sql`) |
| `openapi.yaml` | `/sync/push`, `/sync/pull`, `/reports/summary` contract |

## 1. Create the project
1. Create a project at https://supabase.com (choose a region near your merchants).
2. Copy the **Project URL** and **anon/public** + **service_role** keys.

## 2. Apply the schema
In the Supabase **SQL Editor**, paste `schema.sql` (it `\i`-includes
`policies.sql`) and run. Or with the CLI:
```bash
supabase link --project-ref <ref>
supabase db push   # or: psql "$DATABASE_URL" -f backend/schema.sql
```
Verify: `select * from pg_policies;` shows the per-tenant policies.

## 3. Auth & membership
- Enable **Email OTP** (or phone) in Supabase Auth for owner/admin login.
- On first login, insert a `businesses` row and a `memberships` row
  (`role='owner'`) for the user — do this in a `handle_new_user` trigger or an
  onboarding Edge Function.

## 4. Sync endpoints — provided, just deploy
The Edge Functions are written in `backend/functions/`:
```bash
supabase functions deploy sync-push
supabase functions deploy sync-pull
# and run the sign-up trigger once:
psql "$DATABASE_URL" -f backend/functions/on-signup.sql
```
- `sync-push`: idempotent upsert on `idem_key` (safe replay, PRD §14).
- `sync-pull`: returns events after `?since=<rev>` for the caller's business.

## 5. Wire the app — client already implemented
`HttpSyncService` in `lib/services/sync_service.dart` is fully implemented
(unit-tested) and `AppState.syncNow()` POSTs the outbox when it's configured.
Just construct it after login and pass it in:
```dart
final sync = HttpSyncService(baseUrl: '<url>/functions/v1', jwt: session.accessToken);
final state = AppState(sync: sync); // syncNow() now pushes to your backend
```

## Security checklist
- RLS is **on** for every tenant table (never expose the service_role key to the app).
- Cost/margin fields are masked for `cashier` in the API/view layer (BNX-0277).
- Store the JWT in the device keystore (already used for the app-lock PIN).
- Rotate keys; enable Supabase's Point-in-Time Recovery for backups (PRD §14).
