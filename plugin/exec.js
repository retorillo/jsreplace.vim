var opt = require(process.argv[2])
opt.lines.forEach(function(line) {
   console.log(line.replace(new RegExp(opt.pattern, opt.flags || ''), opt.replacement))
});
