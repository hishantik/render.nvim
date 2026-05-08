function debounce(fn, delay = 100) {
  let timer = null;

  return function(...args) {
    clearTimeout(timer);

    timer = setTimeout(() => {
      fn.apply(this, args);
    }, delay);
  };
}

module.exports = debounce;
