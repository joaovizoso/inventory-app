-- Reverte 0006_temp_anon_test_access.sql — corre isto assim que o login
-- estiver a funcionar e deixares de precisar do modo de teste sem sessão.

drop policy if exists "TEMP anon read this household" on households;
drop policy if exists "TEMP anon manage this household inventory" on inventory_items;
drop policy if exists "TEMP anon manage this household events" on inventory_events;
drop policy if exists "TEMP anon manage this household shopping list" on shopping_list_items;
drop policy if exists "TEMP anon read/write products" on products;
drop policy if exists "TEMP anon upload photos for this household" on storage.objects;
