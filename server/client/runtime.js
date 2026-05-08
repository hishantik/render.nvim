import { patch } from "./dompatch.js";

import {
  showOverlay,
  clearOverlay,
  showStatus,
} from "./overlay.js";

(() => {
  const WS_PROTOCOL =
    location.protocol === "https:"
      ? "wss:"
      : "ws:";

  const WS_URL =
    `${WS_PROTOCOL}//${location.host}`;

  let socket = null;

  let reconnectTimer = null;
  let pingTimer = null;

  function log(...args) {
    console.log("[live]", ...args);
  }

  function connect() {
    cleanupSocket();

    socket = new WebSocket(WS_URL);

    socket.addEventListener(
      "open",
      handleOpen
    );

    socket.addEventListener(
      "close",
      handleClose
    );

    socket.addEventListener(
      "error",
      handleError
    );

    socket.addEventListener(
      "message",
      handleSocketMessage
    );
  }

  function handleOpen() {
    log("connected");

    clearTimeout(reconnectTimer);

    startPingLoop();

    showStatus("connected");
  }

  function handleClose() {
    log("disconnected");

    stopPingLoop();

    showStatus("disconnected");

    reconnect();
  }

  function handleError(err) {
    console.error(err);
  }

  function handleSocketMessage(event) {
    try {
      const data =
        JSON.parse(event.data);

      routeMessage(data);

    } catch (e) {
      console.error(e);
    }
  }

  function cleanupSocket() {
    if (!socket) {
      return;
    }

    try {
      socket.close();

    } catch (_) { }
  }

  function reconnect() {
    clearTimeout(reconnectTimer);

    reconnectTimer =
      setTimeout(() => {
        log("reconnecting");

        connect();

      }, 1000);
  }

  function startPingLoop() {
    stopPingLoop();

    pingTimer = setInterval(() => {
      if (
        socket &&
        socket.readyState ===
        WebSocket.OPEN
      ) {
        socket.send(
          JSON.stringify({
            type: "ping",
          })
        );
      }
    }, 5000);
  }

  function stopPingLoop() {
    clearInterval(pingTimer);
  }

  function routeMessage(data) {
    switch (data.type) {
      case "connected":
        log("server ready");
        break;

      case "reload":
        reloadPage();
        break;

      case "css":
        reloadCSS();
        break;

      case "html":
        patchHTML(data.content);
        break;

      case "overlay":
        showOverlay(
          data.message
        );
        break;

      case "clear_overlay":
        clearOverlay();
        break;

      default:
        console.log(data);
    }
  }

  function reloadPage() {
    location.reload();
  }

  function reloadCSS() {
    const links =
      document.querySelectorAll(
        'link[rel="stylesheet"]'
      );

    links.forEach((link) => {
      const url =
        new URL(link.href);

      url.searchParams.set(
        "_live",
        Date.now()
      );

      link.href =
        url.toString();
    });
  }

  function patchHTML(html) {
    try {
      const parser =
        new DOMParser();

      const next =
        parser.parseFromString(
          html,
          "text/html"
        );

      patchDocument(next);

    } catch (err) {
      console.error(err);

      reloadPage();
    }
  }

  function patchDocument(nextDoc) {
    patchHead(nextDoc);
    patchBody(nextDoc);
  }

  function patchHead(nextDoc) {
    const currentHead =
      document.head;

    const nextHead =
      nextDoc.head;

    if (
      currentHead.innerHTML !==
      nextHead.innerHTML
    ) {
      currentHead.innerHTML =
        nextHead.innerHTML;
    }
  }

  function patchBody(nextDoc) {
    const currentBody =
      document.body;

    const nextBody =
      nextDoc.body;

    if (
      currentBody.innerHTML !==
      nextBody.innerHTML
    ) {
      patch(
        currentBody,
        nextBody
      );
    }
  }

  connect();
})();
