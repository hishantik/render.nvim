import fs from "fs";

export function injectRuntime(html) {
  const runtimeTag =
    '<script type="module" src="/live/runtime.js"></script>';

  if (
    html.includes("/live/runtime.js")
  ) {
    return html;
  }

  if (html.includes("</body>")) {
    return html.replace(
      "</body>",
      `${runtimeTag}\n</body>`
    );
  }

  return html + runtimeTag;
}

export function injectOverlay(html) {
  const overlayRoot =
    '<div id="__live_overlay_root"></div>';

  if (
    html.includes("__live_overlay_root")
  ) {
    return html;
  }

  if (html.includes("</body>")) {
    return html.replace(
      "</body>",
      `${overlayRoot}\n</body>`
    );
  }

  return html + overlayRoot;
}

export function transformHTML(html) {
  html = injectRuntime(html);
  html = injectOverlay(html);

  return html;
}

export function loadHTML(file) {
  return fs.readFileSync(
    file,
    "utf8"
  );
}

export function parseFile(file) {
  const html = loadHTML(file);

  return transformHTML(html);
}
