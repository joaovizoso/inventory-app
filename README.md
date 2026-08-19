# Inventário — Dispensa & Frigorífico

App single-page (HTML/CSS/JS puro, sem build tools nem dependências) para gerir o
inventário da dispensa e do frigorífico em casa.

## Funcionalidades

- Leitura de código de barras pela câmara do telemóvel (`BarcodeDetector` API —
  suportado em Chrome/Android; noutros browsers cai automaticamente para
  introdução manual do código).
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

- `BarcodeDetector` não é suportado no Safari/iOS — nesse caso, introduz o
  código de barras manualmente (o campo de nome pode sempre ser preenchido à mão).
- Sem sincronização entre dispositivos — o inventário fica guardado apenas no
  browser onde foi criado.
- Sem datas de validade (ainda).
