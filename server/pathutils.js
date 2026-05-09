import path from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

export function root() {
  return process.cwd();
}

export function normalize(target) {
  return path.normalize(
    path.resolve(target)
  );
}

export function resolveRequest(reqUrl, root = process.cwd()) {
  if (reqUrl === "/") {
    return path.join(
      root,
      "index.html"
    );
  }

  return path.join(
    root,
    reqUrl
  );
}

export function isSafe(target) {
  const normalized =
    normalize(target);

  return normalized.startsWith(
    root()
  );
}

export function ext(filePath) {
  return path.extname(filePath);
}

export function basename(filePath) {
  return path.basename(filePath);
}

export function clientAsset(name) {
  return path.join(
    __dirname,
    "client",
    name
  );
}
