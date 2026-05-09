import http from "http";
import path from "path";

import { debounce } from "./debounce.js";
import { filemanager } from "./filemanager.js";
import { LiveWebSocket } from "./websocket.js";

let PORT = 8080;
let ROOT = process.cwd();

// Parse command line args
const args = process.argv.slice(2);
for (let i = 0; i < args.length; i++) {
	if (args[i] === "--port" && args[i + 1]) {
		if (!isNaN(parseInt(args[i + 1]))) {
			i++;
		}
	} else if (args[i] === "--root" && args[i + 1]) {
		ROOT = args[i + 1];
		i++;
	}
}

const server = http.createServer((req, res) => handleRequest(req, res, ROOT));

const live = new LiveWebSocket(server);

const broadcastHTML = debounce(
  (content) => {
    live.broadcastHTML(content);
  },
  120
);

const broadcastCSS = debounce(
  () => {
    live.broadcastCSS();
  },
  80
);

function handleRequest(req, res, root) {
  try {
    // editor bridge
    if (
      req.method === "POST" &&
      req.url === "/__live"
    ) {
      return handleEditorRequest(
        req,
        res
      );
    }

    // runtime assets
    if (
      req.url.startsWith("/live/")
    ) {
      return serveClientAsset(
        req,
        res
      );
    }

    // static files
    return serveFile(req, res, root);

  } catch (e) {
    console.error(e);

    send(res, 500, {
      type: "text/plain",
      body: e.toString(),
    });
  }
}

function serveFile(req, res, root) {
  const result =
    filemanager.load(req.url, root);

  send(res, result.status, {
    type: result.type,
    body: result.body,
  });
}

function serveClientAsset(
  req,
  res
) {
  const asset =
    path.basename(req.url);

  try {
    const result =
      filemanager.loadClientAsset(
        asset
      );

    send(res, result.status, {
      type: result.type,
      body: result.body,
    });
  } catch (e) {
    console.error("[serveClientAsset]", e);
    send(res, 500, {
      type: "text/plain",
      body: e.toString(),
    });
  }
}

function handleEditorRequest(
  req,
  res
) {
  let body = "";

  req.on("data", (chunk) => {
    body += chunk;
  });

  req.on("end", () => {
    try {
      const data =
        JSON.parse(body);

      routeEditorMessage(data);

      send(res, 200, {
        type: "text/plain",
        body: "ok",
      });

    } catch (e) {
      console.error(e);

      send(res, 500, {
        type: "text/plain",
        body: e.toString(),
      });
    }
  });
}

function routeEditorMessage(data) {
  switch (data.type) {
    case "html":
      broadcastHTML(
        data.content
      );
      break;

    case "css":
      broadcastCSS();
      break;

    case "js":
      live.reload();
      break;

    case "reload":
      live.reload();
      break;

    case "overlay":
      live.overlay(
        data.message
      );
      break;

    case "clear_overlay":
      live.clearOverlay();
      break;

    default:
      console.log(
        "[editor]",
        data
      );
  }
}

function send(
  res,
  status,
  payload
) {
  res.writeHead(status, {
    "Content-Type":
      payload.type,
  });

  res.end(payload.body);
}

server.listen(PORT, () => {
  console.log(
    `[live] running at http://127.0.0.1:${PORT}`
  );
});
