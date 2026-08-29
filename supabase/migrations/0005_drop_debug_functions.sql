-- Remove as funções de diagnóstico criadas em 0003 e 0004, agora que a
-- causa raiz do bug de RLS ao criar casa está identificada e corrigida
-- (ver commit "Corrigir RLS ao criar casa: parar de pedir RETURNING no
-- insert"). Não eram destinadas a ficar em produção.

drop function if exists debug_jwt();
drop function if exists debug_insert_test();
