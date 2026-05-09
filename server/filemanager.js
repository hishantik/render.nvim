import fs from "fs";
import path from "path";

import { transformHTML as parseHTML } from "./parser.js";
import * as paths from "./pathutils.js";

const MIME_TYPES = {
  ".html": "text/html",
  ".css": "text/css",
  ".js": "application/javascript",
  ".json": "application/json",
  ".png": "image/png",
  ".jpg": "image/jpeg",
  ".jpeg": "image/jpeg",
  ".svg": "image/svg+xml",
  ".gif": "image/gif",
  ".ico": "image/x-icon",
  ".txt": "text/plain",
};

function exists(filePath) {
  return fs.existsSync(filePath);
}

function read(filePath) {
  return fs.readFileSync(filePath);
}

function readText(filePath) {
  return fs.readFileSync(
    filePath,
    "utf8"
  );
}

function getMimeType(filePath) {
  const ext =
    paths.ext(filePath);

  return (
    MIME_TYPES[ext] ||
    "application/octet-stream"
  );
}

function transformHTML(filePath) {
  const html =
    readText(filePath);

  return parseHTML(html);
}

export function load(requestUrl, root = process.cwd()) {
  let filePath =
    paths.resolveRequest(
      requestUrl,
      root
    );

  filePath =
    paths.normalize(filePath);

  if (
    !paths.isSafe(filePath)
  ) {
    return forbidden();
  }

  if (!exists(filePath)) {
    return notFound();
  }

  const ext =
    paths.ext(filePath);

  try {
    // html pipeline
    if (ext === ".html") {
      return {
        status: 200,
        type: "text/html",
        body: transformHTML(
          filePath
        ),
      };
    }

    return {
      status: 200,
      type: getMimeType(
        filePath
      ),
      body: read(filePath),
    };

  } catch (e) {
    return error(e);
  }
}

export function loadClientAsset(name) {
  try {
    const filePath =
      paths.clientAsset(name);

    if (!exists(filePath)) {
      return notFound();
    }

    return {
      status: 200,
      type: "application/javascript",
      body: read(filePath),
    };

  } catch (e) {
    return error(e);
  }
}

function notFound() {
  return {
    status: 404,
    type: "text/plain",
    body: "File not found",
  };
}

function forbidden() {
  return {
    status: 403,
    type: "text/plain",
    body: "Forbidden",
  };
}

export function error(err) {
  return {
    status: 500,
    type: "text/plain",
    body: err.toString(),
  };
}

export const filemanager = {
  load,
  loadClientAsset,
};
