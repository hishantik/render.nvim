export function patch(current, next) {
  if (!current || !next) {
    return;
  }

  // text node
  if (
    current.nodeType === Node.TEXT_NODE &&
    next.nodeType === Node.TEXT_NODE
  ) {
    if (current.textContent !== next.textContent) {
      current.textContent = next.textContent;
    }

    return;
  }

  // replace different tags
  if (current.nodeName !== next.nodeName) {
    current.replaceWith(next.cloneNode(true));
    return;
  }

  syncAttributes(current, next);

  patchChildren(current, next);
}

function syncAttributes(current, next) {
  // remove old attrs
  [...current.attributes].forEach((attr) => {
    if (!next.hasAttribute(attr.name)) {
      current.removeAttribute(attr.name);
    }
  });

  // set new attrs
  [...next.attributes].forEach((attr) => {
    if (
      current.getAttribute(attr.name) !== attr.value
    ) {
      current.setAttribute(attr.name, attr.value);
    }
  });
}

function patchChildren(current, next) {
  const currentChildren =
    [...current.childNodes];

  const nextChildren =
    [...next.childNodes];

  const max =
    Math.max(
      currentChildren.length,
      nextChildren.length
    );

  for (let i = 0; i < max; i++) {
    const currentChild =
      currentChildren[i];

    const nextChild =
      nextChildren[i];

    // add
    if (!currentChild && nextChild) {
      current.appendChild(
        nextChild.cloneNode(true)
      );

      continue;
    }

    // remove
    if (currentChild && !nextChild) {
      currentChild.remove();

      continue;
    }

    patch(currentChild, nextChild);
  }
}
