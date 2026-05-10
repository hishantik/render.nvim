var fs = require('fs');
var util = require('util');

const args = [
	{ short: 'p', long: 'port', value: true },
	{ short: 'w', long: 'web-address', value: true },
	{ short: 'a', long: 'allow-remote-web', value: false },
	{ short: 'e', long: 'editor-address', value: true },
	{ short: 'r', long: 'allow-remote-editor', value: false }
];

const settings = {};

for (let i = 2; i < process.argv.length; i++) {
	const arg = process.argv[i];
	if (!arg.startsWith('-')) continue;

	let targetArg = arg.startsWith('--') ? arg.slice(2) : arg.slice(1);
	const foundArg = args.find(a => targetArg === (arg.startsWith('--') ? a.long : a.short));
	if (foundArg) settings[foundArg.long] = foundArg.value ? process.argv[i + 1] : true;
}

settings.port = settings.port || 13378;
settings['web-address'] = settings['web-address'] || '127.0.0.1';
settings['editor-address'] = settings['editor-address'] || '127.0.0.1';

console.log = msg => process.stderr.write(`${util.format(msg)}\n`);

console.log('starting render with arguments:');
for (const key in settings) console.log(`${key}: ${settings[key]}`);

const server = require('./server.js');
new server(settings).start();