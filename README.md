# Inventário — Dispensa & Frigorífico

App single-page (HTML/CSS/JS puro, sem build tools nem dependências) para gerir o
inventário da dispensa e do frigorífico em casa.

## Funcionalidades

- Leitura de código de barras de duas formas, via
  [`html5-qrcode`](https://github.com/mebjas/html5-qrcode) (carregada por CDN):
  - **Ao vivo** — deteção contínua a partir do preview de vídeo da câmara.
  - **Foto** — abre a app de câmara nativa do dispositivo (`<input capture>`),
    tira uma foto à resolução total do sensor e decodifica-a. Costuma ler
    códigos que a deteção ao vivo não consegue (mais resolução, melhor foco
    nativo), e é a única via para tirar partido de HDR/estabilização em
    iPhone, já que a API `ImageCapture` não existe no Safari.
  Ambas funcionam em qualquer browser moderno, incluindo Safari/iOS, desde
  que servido por HTTPS. Se a câmara não estiver disponível, cai para
  introdução manual.
- Consulta automática do nome e imagem do produto na
  [Open Food Facts](https://world.openfoodfacts.org/) a partir do código de barras.
- Inventário separado por **Dispensa** e **Frigorífico**, com contador de
  quantidade (+/–) por produto.
- Aviso visual de stock baixo (limite configurável por produto).
- Pesquisa por nome ou código de barras.
- Tudo guardado localmente no browser (`localStorage`) — não há backend nem conta.

## Como usar

Abre `index.html` num browser (idealmente no telemóvel, em Chrome/Android, para
teres acesso à câmara e ao leitor de código de barras automático). Pode
também ser publicado como página estática (ex. GitHub Pages) e adicionado ao
ecrã principal como PWA-like shortcut.

## Limitações atuais

- A leitura de código de barras exige **HTTPS** (ex. GitHub Pages) — não
  funciona a abrir o `index.html` localmente (`file://`) nem por `http://`
  simples, porque o Safari/iOS bloqueia o acesso à câmara fora de um
  contexto seguro. Nesses casos, o código pode sempre ser introduzido
  manualmente.
- Sem sincronização entre dispositivos — o inventário fica guardado apenas no
  browser onde foi criado.
- Sem datas de validade (ainda).
