(function(execJS) { execJS() })(function() {
  var source = #{::JSON.dump(source)};
  source = "(function(){"+ source + "})()";

  var output, print = function(string) {
    process.stdout.write('' + string);
  };
  try {
    var program = function(){
      var vm = require('vm');
      var context = vm.createContext();
      return vm.runInNewContext(source, context, "(execjs)");
    }
    result = program();
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
  __process__.exit(0);
});
