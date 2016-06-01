(function(program, execJS) { execJS(program) })(function(global, module, exports, require, console, setTimeout, setInterval, clearTimeout, clearInterval, setImmediate, clearImmediate) { #{source}
}, function(program) {
  var output, print = function(string) {
    process.stdout.write('' + string);
  };
  try {
    var stdoutWrite = process.stdout.write;
    var stderrWrite = process.stderr.write;

    process.stdout.write = process.stderr.write = function () {}

    result = program();

    process.stdout.write = stdoutWrite;
    process.stderr.write = stderrWrite;

    if (typeof result == 'undefined' && result !== null) {
      print('["ok"]');
    } else {
      try {
        print(JSON.stringify(['ok', result]));
      } catch (err) {
        print(JSON.stringify(['err', '' + err, err.stack]));
      }
    }
  } catch (err) {
    print(JSON.stringify(['err', '' + err, err.stack]));
  }
});
