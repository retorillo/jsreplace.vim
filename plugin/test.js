var argv = process.argv;
try {
	var opt = require(argv[2]);
	new RegExp(opt.pattern, opt.flags || '');
}
catch (e) {
	console.log(e.message);
}
