var csslint = require('csslint').CSSLint;
var cssparser = require('postcss');

// Default CSSLint rules (empty = all enabled, or specify rules to ignore)
var defaultCsslintRules = [];
var customValidators = [];

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
	var errors = [];

	// Run CSSLint with configured rules
	var csslintResult = csslint.verify(source, { 'rules': defaultCsslintRules });
	errors = csslintResult.messages.filter(m => m.type === 'error');

	// Run custom validators
	for (const validator of customValidators) {
		try {
			var customErrors = validator(source);
			if (customErrors && customErrors.length > 0) {
				errors = errors.concat(customErrors);
			}
		} catch (e) {
			// Skip invalid validators
		}
	}

	if (errors.length > 0) { callback(errors); return; }

	var changed = this.source !== undefined && this.source !== source;
	this.source = source;

	try {
		this.parsed = cssparser.parse(source);
	} catch (err) {
		callback(err);
		return;
	}

	// Convert from 1-based to 0-based indexing (end column is exclusive)
	for (const rule of this.parsed.nodes) {
		rule.source.start.line--;
		rule.source.start.column--;
		rule.source.end.column++;
	}

	callback(null, changed);
}

module.exports = CssFile;

// Export functions to configure CSS validation
module.exports.setRules = function(rules) {
	defaultCsslintRules = rules;
};

module.exports.addValidator = function(validatorFn) {
	if (typeof validatorFn === 'function') {
		customValidators.push(validatorFn);
	}
};

module.exports.clearValidators = function() {
	customValidators = [];
};