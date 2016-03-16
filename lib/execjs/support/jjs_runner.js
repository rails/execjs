(function(program, execJS) { execJS(program) })(function() { #{source}
}, function(program) {
  try {
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
    stack = err.stack; msg = '' + err;
    if (typeof stack === 'string' && stack.startsWith(msg)) {
        stack = stack.substring(msg.length).trimLeft();
    }
    print(JSON.stringify(['err', msg, stack]));
  }
});