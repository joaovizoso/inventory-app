-- Storage: fotos de itens de inventário (ex. tupperwares no congelador,
-- produtos frescos sem código de barras).
--
-- Bucket público para simplificar a leitura (<img src> direto, sem URLs
-- assinados) — aceitável aqui porque são fotos pessoais de itens de casa,
-- não dados sensíveis. A escrita/remoção continua restrita aos membros da
-- respetiva casa através da convenção de caminho {household_id}/{ficheiro}.

insert into storage.buckets (id, name, public)
values ('item-photos', 'item-photos', true)
on conflict (id) do nothing;

create policy "household members can upload item photos"
on storage.objects for insert
with check (
  bucket_id = 'item-photos'
  and is_household_member((storage.foldername(name))[1]::uuid)
);

create policy "anyone can view item photos"
on storage.objects for select
using (bucket_id = 'item-photos');

create policy "household members can delete their item photos"
on storage.objects for delete
using (
  bucket_id = 'item-photos'
  and is_household_member((storage.foldername(name))[1]::uuid)
);
