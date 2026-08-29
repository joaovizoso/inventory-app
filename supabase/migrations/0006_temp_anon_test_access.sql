-- ⚠️ TEMPORÁRIO — bypass de autenticação só para testar no desktop enquanto
-- o login (SMTP/template de código) não está resolvido. Restringe o acesso
-- sem sessão (role anon) a UMA casa específica (household_id fixo abaixo),
-- não à base de dados toda nem a outras casas que venham a existir.
--
-- Enquanto isto estiver ativo, QUALQUER pessoa com o URL da app consegue
-- ver e editar o inventário desta casa sem fazer login.
--
-- REVERTER assim que possível com 0007_revert_temp_anon_test_access.sql.

create policy "TEMP anon read this household"
  on households for select
  to anon
  using (id = '4f550919-7df4-4b4e-9cf2-0371a134a62b');

create policy "TEMP anon manage this household inventory"
  on inventory_items for all
  to anon
  using (household_id = '4f550919-7df4-4b4e-9cf2-0371a134a62b')
  with check (household_id = '4f550919-7df4-4b4e-9cf2-0371a134a62b');

create policy "TEMP anon manage this household events"
  on inventory_events for all
  to anon
  using (household_id = '4f550919-7df4-4b4e-9cf2-0371a134a62b')
  with check (household_id = '4f550919-7df4-4b4e-9cf2-0371a134a62b');

create policy "TEMP anon manage this household shopping list"
  on shopping_list_items for all
  to anon
  using (household_id = '4f550919-7df4-4b4e-9cf2-0371a134a62b')
  with check (household_id = '4f550919-7df4-4b4e-9cf2-0371a134a62b');

-- products é uma cache partilhada sem dados sensíveis (nome/imagem/categoria
-- por barcode) — sem necessidade de restringir por casa.
create policy "TEMP anon read/write products"
  on products for all
  to anon
  using (true)
  with check (true);

-- Fotos de itens sem código de barras (o SELECT já é público para todos os
-- buckets item-photos; só falta o INSERT para quem não tem sessão).
create policy "TEMP anon upload photos for this household"
on storage.objects for insert
to anon
with check (
  bucket_id = 'item-photos'
  and (storage.foldername(name))[1] = '4f550919-7df4-4b4e-9cf2-0371a134a62b'
);
