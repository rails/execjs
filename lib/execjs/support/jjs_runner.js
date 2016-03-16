(function(program, execJS) { execJS(program) })(function() { #{source}
}, function(program) {
  try {
    result = program();
    if (typeof result === 'undefined') {
      print('["ok"]');
    } else {
      print(JSON.stringify(['ok', result]));
    }
  } catch (err) {
    stack = err.stack; msg = '' + err;
    if (typeof stack === 'string' && stack.startsWith(msg)) {
        stack = stack.substring(msg.length).trimLeft();
    }
    print(JSON.stringify(['err', msg, stack]));
  }
});