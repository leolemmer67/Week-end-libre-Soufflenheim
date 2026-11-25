-- =====================================================================
-- Sécurité de la base Supabase — Week-End libre Soufflenheim
-- À exécuter UNE fois dans Supabase : SQL Editor → New query → Run.
--
-- Principe :
--  * Les visiteurs (rôle "anon") peuvent seulement :
--      - lire les sessions et la position des postes,
--      - voir quels postes sont pris (session + numéro, SANS nom/email/téléphone),
--      - créer une réservation.
--  * Seuls les administrateurs connectés (rôle "authenticated", créés dans
--    Authentication → Users) peuvent lire les coordonnées des clients,
--    supprimer une réservation, créer une session ou déplacer les postes.
-- =====================================================================

-- 1. Activer la Row Level Security sur les 3 tables
alter table public.sessions      enable row level security;
alter table public.reservations  enable row level security;
alter table public.postes_config enable row level security;

-- 2. Supprimer d'éventuelles anciennes règles du même nom (relance sans erreur)
drop policy if exists "public_lit_sessions"         on public.sessions;
drop policy if exists "admin_gere_sessions"         on public.sessions;
drop policy if exists "public_lit_postes"           on public.postes_config;
drop policy if exists "admin_gere_postes"           on public.postes_config;
drop policy if exists "public_voit_postes_pris"     on public.reservations;
drop policy if exists "public_cree_reservation"     on public.reservations;
drop policy if exists "admin_gere_reservations"     on public.reservations;

-- 3. Sessions : lecture publique, écriture admin
create policy "public_lit_sessions" on public.sessions
  for select to anon, authenticated using (true);
create policy "admin_gere_sessions" on public.sessions
  for all to authenticated using (true) with check (true);

-- 4. Position des postes : lecture publique, écriture admin
create policy "public_lit_postes" on public.postes_config
  for select to anon, authenticated using (true);
create policy "admin_gere_postes" on public.postes_config
  for all to authenticated using (true) with check (true);

-- 5. Réservations
--    Visiteurs : peuvent créer une réservation et voir les lignes...
create policy "public_cree_reservation" on public.reservations
  for insert to anon with check (true);
create policy "public_voit_postes_pris" on public.reservations
  for select to anon using (true);
--    ...mais seulement 2 colonnes : impossible de lire nom, email, téléphone.
revoke select on public.reservations from anon;
grant  select (session_id, poste_numero) on public.reservations to anon;
--    Visiteurs : jamais de modification ni de suppression
revoke update, delete on public.reservations from anon;

--    Administrateurs connectés : tout
create policy "admin_gere_reservations" on public.reservations
  for all to authenticated using (true) with check (true);

-- 6. Empêcher deux réservations sur le même poste pour la même session
--    (ignore l'erreur si la contrainte existe déjà)
do $$ begin
  alter table public.reservations
    add constraint reservations_poste_unique unique (session_id, poste_numero);
exception when duplicate_object or duplicate_table then null;
end $$;
