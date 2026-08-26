// Service worker mínimo — por agora só existe para tornar a app instalável
// no ecrã principal (pré-requisito do iOS para Web Push, adicionado numa
// fase seguinte). Ainda não faz cache offline nem lida com eventos "push".
self.addEventListener("install", function (event) {
  self.skipWaiting();
});

self.addEventListener("activate", function (event) {
  self.clients.claim();
});
