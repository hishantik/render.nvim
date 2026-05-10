var csslint = require('csslint').CSSLint;
var cssparser = require('postcss');

function CssFile(source, path, callback) {
	this.path = path;
	this.setContent(source, callback || (() => {}));
}

CssFile.prototype.webSrc = function() {
	return this.source;
};

CssFile.prototype.selectorFromPosition = function(line, column) {
	for (const { selector, source } of this.parsed.nodes) {
		const { line: sl, column: sc } = source.start;
		const { line: el, column: ec } = source.end;
		if ((sl < line && el > line) ||
			(sl === line && el !== line && sc <= column) ||
			(sl !== line && el === line && ec >= column) ||
			(sl === line && el === line && sc <= column && ec >= column)) {
			return selector;
		}
	}
	return null;
};

CssFile.prototype.setContent = function(source, callback) {
	var errors = csslint.verify(source).messages.filter(m => m.type === 'error');
	if (errors.length > 0) { callback(errors); return; }

	var changed = this.source !== undefined && this.source !== source;
	this.source = source;

	try {
		this.parsed = cssparser.parse(source);
	} catch (err) {
		callback(err);
		return;
	}

	for (const rule of this.parsed.nodes) {
		rule.source.start.line--;
		rule.source.start.column--;
		rule.source.end.column++;
	}

	callback(null, changed ? null : null);
}

module.exports = CssFile;