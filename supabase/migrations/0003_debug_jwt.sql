-- TEMPORÁRIO — diagnóstico do bug de RLS/auth.uid(). Remover depois de
-- resolvido (ver 0004_drop_debug_jwt.sql quando esse dia chegar).
--
-- Mostra exatamente o que o Postgres vê de um pedido: as claims em bruto
-- (tal como PostgREST as definiu, se é que definiu alguma coisa), e o
-- resultado de auth.uid() / auth.role() para esse mesmo pedido.

create or replace function debug_jwt()
returns json
language sql
stable
as $$
  select json_build_object(
    'request_jwt_claims_raw', current_setting('request.jwt.claims', true),
    'request_jwt_claim_sub', current_setting('request.jwt.claim.sub', true),
    'request_jwt_claim_role', current_setting('request.jwt.claim.role', true),
    'auth_uid', auth.uid()::text,
    'auth_role', auth.role(),
    'current_user', current_user,
    'session_user', session_user
  );
$$;

grant execute on function debug_jwt() to authenticated, anon;
