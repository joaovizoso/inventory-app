-- TEMPORÁRIO — diagnóstico. Testa um insert real em households, com o
-- mesmo mecanismo de RLS que um pedido direto do cliente usaria (função
-- security invoker, o padrão), e devolve o erro exato se falhar, incluindo
-- o estado de auth.uid() imediatamente antes do insert.

create or replace function debug_insert_test()
returns json
language plpgsql
as $$
declare
  new_id uuid;
  uid_before uuid;
begin
  uid_before := auth.uid();
  insert into households (name) values ('[debug_insert_test]') returning id into new_id;
  delete from households where id = new_id;
  return json_build_object(
    'uid_before_insert', uid_before,
    'insert_succeeded', true,
    'new_id', new_id
  );
exception when others then
  return json_build_object(
    'uid_before_insert', uid_before,
    'insert_succeeded', false,
    'error', SQLERRM,
    'sqlstate', SQLSTATE
  );
end;
$$;

grant execute on function debug_insert_test() to authenticated;
