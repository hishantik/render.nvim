/*
 * Injected into served HTML pages
 */
(function() {
	var webSocket, lastSelection = '', errorIndicator;
	var endSession = false;

	function connectSocket() {
		webSocket = new WebSocket('ws://' + location.host);
		webSocket.onopen = () => {};
		webSocket.onclose = () => { if (!endSession) setTimeout(connectSocket, 10000); };
		webSocket.onerror = e => console.log('error:', e);
		webSocket.onmessage = e => {
			var msg = JSON.parse(e.data);
			switch (msg.command) {
				case 'select': setHighlighted(msg.index ? '[meta-render-element-index="' + msg.index + '"]' : msg.selector); break;
				case 'reload_page': location.reload(); break;
				case 'reload_css': reloadCSS(); break;
				case 'goto': location.href = msg.location; break;
				case 'edit': msg.changes.forEach(g => {
					var elem = g.element === 0 ? document : document.querySelector('[meta-render-element-index="' + g.element + '"]');
					g.changes.forEach(c => makeChange(elem, c));
				}); reHighlight(); break;
				case 'eval': eval.call(window, msg.js); break;
				case 'error': msg.action === 'show' ? showError(msg.message) : clearError(); break;
			}
		};
	}

	function showError(message) {
		if (!errorIndicator) { errorIndicator = document.createElement('div'); errorIndicator.className = 'render-error-indicator'; document.body.appendChild(errorIndicator); }
		var msg = errorIndicator.firstChild || errorIndicator.appendChild(document.createElement('div'));
		msg.textContent = message;
		selectorErrorState(true);
	}

	function clearError() {
		if (errorIndicator) { errorIndicator.remove(); errorIndicator = undefined; }
		selectorErrorState(false);
	}

	function selectorErrorState(state) { document.querySelectorAll('.render-currently-selected-highlight').forEach(el => el.classList[state ? 'add' : 'remove']('render-highlight-error')); }

	function makeChange(element, change) {
		switch (change.action) {
			case 'change':
				if (change.what === 'data') element.childNodes[change.index].nodeValue = change.value;
				else if (change.what === 'attribs') {
					element = element.childNodes[change.index];
					while (element.attributes.length > 1) element.removeAttribute(element.attributes[0].name !== 'meta-render-element-index' ? element.attributes[0].name : element.attributes[1].name);
					for (var a in change.value) element.setAttribute(a, change.value[a]);
				}
				break;
			case 'remove': element.removeChild(element.childNodes[change.index]); break;
			case 'add':
				var newElem = constructElem(change.value);
				element.childNodes.length ? element.insertBefore(newElem, element.childNodes[change.index]) : element.appendChild(newElem);
				break;
		}
	}

	function constructElem(data) {
		if (data.type === 'text') return document.createTextNode(data.data);
		var newElem = document.createElement(data.name);
		for (var a in data.attribs) newElem.setAttribute(a, data.attribs[a]);
		data.children.forEach(v => newElem.appendChild(constructElem(v)));
		return newElem;
	}

	function elementBox(element) {
		var box = element.getBoundingClientRect();
		var scrollTop = pageYOffset || document.documentElement.scrollTop;
		var scrollLeft = pageXOffset || document.documentElement.scrollLeft;
		return { top: box.top + scrollTop + 'px', left: box.left + scrollLeft + 'px', width: box.right - box.left + 'px', height: box.bottom - box.top + 'px' };
	}

	function removeHighlights() { document.querySelectorAll('.render-currently-selected-highlight').forEach(h => h.remove()); }

	function reHighlight() {
		document.querySelectorAll('.render-currently-selected-highlight').forEach(h => {
			var toHighlight = document.querySelector('[meta-render-element-index="' + h.getAttribute('highlighting') + '"]');
			if (!toHighlight) h.remove();
			else { var box = elementBox(toHighlight); Object.assign(h.style, box, { position: getComputedStyle(toHighlight).position }); }
		});
	}

	function setHighlighted(selector) {
		if (lastSelection === selector) return;
		lastSelection = selector;
		removeHighlights();
		document.querySelectorAll(selector).forEach(el => {
			var highlight = document.createElement('div');
			highlight.className = 'render-currently-selected-highlight';
			var box = elementBox(el);
			Object.assign(highlight.style, box, { position: getComputedStyle(el).position });
			highlight.setAttribute('highlighting', el.getAttribute('meta-render-element-index'));
			document.body.appendChild(highlight);
		});
	}

	function reloadCSS() {
		document.querySelectorAll('link[rel="stylesheet"]').forEach(link => {
			var href = link.getAttribute('data-href') || link.href;
			link.setAttribute('data-href', href);
			link.href = href + (href.includes('?') ? '&' : '?') + 'render-cache-buster=' + Date.now();
		});
		for (var trys = 0; trys < 5; trys++) setTimeout(reHighlight, 5 * Math.pow(4, trys));
	}

	connectSocket();
})();