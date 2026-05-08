const WebSocket = require("ws");

class LiveWebSocket {
  constructor(server) {
    this.clients = new Set();

    this.wss = new WebSocket.Server({
      server,
    });

    this.setup();
  }

  setup() {
    this.wss.on(
      "connection",
      (ws) => {
        console.log(
          "[live] client connected"
        );

        this.clients.add(ws);

        this.send(ws, {
          type: "connected",
        });

        ws.on("close", () => {
          this.clients.delete(ws);

          console.log(
            "[live] client disconnected"
          );
        });

        ws.on(
          "message",
          (msg) => {
            this.handleMessage(
              ws,
              msg
            );
          }
        );

        ws.on("error", (err) => {
          console.error(err);
        });
      }
    );
  }

  handleMessage(ws, msg) {
    try {
      const data =
        JSON.parse(msg);

      switch (data.type) {
        case "ping":
          this.send(ws, {
            type: "pong",
          });
          break;

        default:
          console.log(
            "[browser]",
            data
          );
      }

    } catch (e) {
      console.error(e);
    }
  }

  send(ws, data) {
    if (
      ws.readyState ===
      WebSocket.OPEN
    ) {
      ws.send(
        JSON.stringify(data)
      );
    }
  }

  broadcast(data) {
    const payload =
      JSON.stringify(data);

    this.clients.forEach(
      (client) => {
        if (
          client.readyState ===
          WebSocket.OPEN
        ) {
          client.send(payload);
        }
      }
    );
  }

  broadcastHTML(content) {
    this.broadcast({
      type: "html",
      content,
    });
  }

  broadcastCSS() {
    this.broadcast({
      type: "css",
    });
  }

  reload() {
    this.broadcast({
      type: "reload",
    });
  }

  overlay(message) {
    this.broadcast({
      type: "overlay",
      message,
    });
  }

  clearOverlay() {
    this.broadcast({
      type: "clear_overlay",
    });
  }
}

module.exports = LiveWebSocket;
