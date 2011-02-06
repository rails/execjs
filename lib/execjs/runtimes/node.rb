module ExecJS
  module Runtimes
    class Node

    end
  end
end

__END__
(function(program, execJS) { execJS(program) })(function() { #{source}
}, function(program) {
  var result, output;
  try {
    result = program();
    try {
      output = JSON.stringify(result);
      sys.print('ok ');
      sys.print(output);
    } catch (err) {
      sys.print('err');
    }
  } catch (err) {
    sys.print('err ');
    sys.print(err);
  }
});
