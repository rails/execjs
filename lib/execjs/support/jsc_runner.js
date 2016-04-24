(function(program, execJS) { execJS(program) })(function() { #{source}
}, function(program) {
  #{encode_error_source}
  var output;
  try {
    result = program();
    if (typeof result == 'undefined' && result !== null) {
      print('["ok"]');
    } else {
      try {
        print(JSON.stringify(['ok', result]));
      } catch (err) {
        print(JSON.stringify(['err', encodeError(err)]));
      }
    }
  } catch (err) {
    print(JSON.stringify(['err', encodeError(err)]));
  }
});
