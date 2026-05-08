const path = require("path");

function root() {
  return process.cwd();
}

function normalize(target) {
  return path.normalize(
    path.resolve(target)
  );
}

function resolveRequest(reqUrl) {
  if (reqUrl === "/") {
    return path.join(
      root(),
      "index.html"
    );
  }

  return path.join(
    root(),
    reqUrl
  );
}

function isSafe(target) {
  const normalized =
    normalize(target);

  return normalized.startsWith(
    root()
  );
}

function ext(filePath) {
  return path.extname(filePath);
}

function basename(filePath) {
  return path.basename(filePath);
}

function dirname(filePath) {
  return path.dirname(filePath);
}

function join(...parts) {
  return path.join(...parts);
}

function clientAsset(name) {
  return join(
    __dirname,
    "client",
    name
  );
}

module.exports = {
  root,
  normalize,
  resolveRequest,
  isSafe,
  ext,
  basename,
  dirname,
  join,
  clientAsset,
};
