// Usage: node test.js pattern [flags]
// Distributed under the MIT license
// (c) Retorillo
var process = require('process');
var argv = process.argv;
try {
	if (argv.length < 3)
		throw new Error("Too few arguments");
	if (argv.length > 4)
		throw new Error("Too many arguments")
	var pattern = argv[2];
	var flags = argv.length < 4 ? "" : argv[3];
	new RegExp(pattern, flags);
}
catch (e) {
	console.log(e.message);
}
