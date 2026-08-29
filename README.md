# Inventário — Dispensa & Frigorífico

App para gerir o inventário da dispensa, frigorífico e congelador de casa,
partilhada entre as pessoas do mesmo agregado. Frontend estático (HTML/CSS/JS
puro, sem build tools), backend em [Supabase](https://supabase.com) (Postgres
+ Auth + Storage).

## Funcionalidades

- **Login por magic link** (email, sem palavra-passe).
- **Casas partilhadas** — cria uma casa ou entra numa existente com um
  código de convite; todas as pessoas da mesma casa veem e editam o mesmo
  inventário.
- Leitura de código de barras de duas formas, via
  [`html5-qrcode`](https://github.com/mebjas/html5-qrcode) (carregada por CDN):
  - **Ao vivo** — deteção contínua a partir do preview de vídeo da câmara.
  - **Foto** — abre a app de câmara nativa do dispositivo (`<input capture>`),
    tira uma foto à resolução total do sensor e decodifica-a. Costuma ler
    códigos que a deteção ao vivo não consegue, e é a única via viável no
    Safari/iOS (a API `ImageCapture` não existe lá).
  Ambas funcionam em qualquer browser moderno desde que servido por HTTPS.
- **Itens sem código de barras** (produtos frescos, tupperwares no
  congelador) — nome livre + categoria + foto opcional tirada pelo
  telemóvel, guardada no Supabase Storage.
- Consulta automática do nome/imagem/categoria do produto na
  [Open Food Facts](https://world.openfoodfacts.org/) a partir do código de
  barras — os produtos ficam numa cache partilhada entre todas as casas
  (`products`), para que registar manualmente um produto desconhecido
  beneficie todos os utilizadores da app.
- Inventário separado por **Dispensa**, **Frigorífico** e **Congelador**,
  com contador de quantidade (+/–) por produto. **Mover** um item entre
  locais (botão ⇄) sem o recriar. Cada adição fica sempre como uma **linha
  nova** (um lote próprio) — nunca funde com uma linha existente do mesmo
  código de barras/local, para não perder o rasto de lotes com validades
  diferentes (ex. leite comprado em dias diferentes fica em duas linhas).
- Aviso visual de stock baixo (limite configurável por produto).
- **Data de validade obrigatória** ao adicionar um produto — mesmo que os
  dados venham automaticamente da Open Food Facts. A lista mostra "Expirado"
  ou "Expira em breve" (nos 3 dias seguintes) a vermelho.
- **Lista de compras** partilhada pela casa, independente do inventário.
- Histórico de eventos de consumo (`inventory_events`) — base para futuras
  sugestões de compras/receitas.
- Pesquisa por nome ou código de barras.
- Instalável como PWA no ecrã principal (manifest + service worker) —
  pré-requisito para as notificações push de validade, que ainda não estão
  implementadas (ver "Próximos passos").

## Arquitetura

```
Frontend estático (GitHub Pages)  →  Supabase (Postgres + Auth + Storage)
     index.html (Supabase JS via CDN)      RLS por household_id / user_id
```

Esquema da base de dados em `supabase/migrations/` — corre os ficheiros por
ordem no SQL Editor do projeto Supabase (`0001_init.sql`, depois
`0002_storage.sql`).

## Configuração necessária no Supabase

1. Correr as migrações em `supabase/migrations/` (SQL Editor → colar → Run).
2. **Auth → URL Configuration**: definir o Site URL / Redirect URLs para o
   URL onde a app está publicada (ex. `https://joaovizoso.github.io/inventory-app/`),
   para o magic link redirecionar corretamente.
3. `SUPABASE_URL` e a chave `sb_publishable_...` (segura para o frontend —
   protegida por Row Level Security, não por ser secreta) estão hardcoded
   no `index.html`.

## Limitações atuais / próximos passos

- **Notificações push de validade — ainda não implementadas.** Requer:
  gerar chaves VAPID, uma Edge Function no Supabase com Cron Trigger diário
  que verifica `inventory_items.expiry_date` e envia Web Push às
  `push_subscriptions`, e o service worker (`sw.js`, já existe mas ainda
  não trata eventos `push`) a mostrar a notificação. No iPhone só funciona
  com a app instalada no ecrã principal (iOS 16.4+).
- A leitura de código de barras exige **HTTPS** — não funciona a abrir
  `index.html` localmente (`file://`) nem por `http://` simples.
- Assume-se uma casa por utilizador (a primeira encontrada); não há UI para
  gerir pertencer a várias casas em simultâneo.
- Sem edição de um item já criado além de quantidade e local — decisão
  deliberada (ver commit), não uma limitação a corrigir: corrigir um erro
  é remover e voltar a adicionar.
