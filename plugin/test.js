try {
   var opt = require(process.argv[2]);
   new RegExp(opt.pattern, opt.flags || '');
}
catch (e) {
   console.log(e.message);
}
