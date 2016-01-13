// Usage: node exec.js path encoding pattern replacement [flags]
// Distributed under the MIT license
// (c) Retorillo
var process = require("process");
var fs      = require("fs");
var argv    = process.argv;
if (argv.length < 6)
	throw new Error("Too few arguments");
if (argv.length > 7)
	throw new Error("Too many arguments")
var path    = argv[2];
var enc     = argv[3];
var pattern = argv[4];
var replace = argv[5];
var flags   = argv.length < 7 ? "" : argv[6];
var src = fs.openSync(path, "r");
var stext = fs.readFileSync(src, enc).replace(/\r/gm, "").replace(/\n$/, "");
var dtext = stext.replace(new RegExp(pattern, flags), replace);
fs.closeSync(src);
var dest = fs.openSync(path, "w");
fs.writeFileSync(dest, dtext, enc);
fs.closeSync(dest);
