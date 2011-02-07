ExecJS
======

ExecJS lets you run JavaScript code from Ruby. It automatically picks
the best runtime available to evaluate your JavaScript program, then
returns the result to you as a Ruby object.

ExecJS supports these runtimes:

* [therubyracer](https://github.com/cowboyd/therubyracer) - Google V8
  embedded within Ruby for exceptional performance
* [Google V8](http://code.google.com/p/v8/)
* [Node.js](http://nodejs.org/)
* Apple JavaScriptCore
* [Mozilla Spidermonkey](http://www.mozilla.org/js/spidermonkey/)
* [Mozilla Rhino](http://www.mozilla.org/rhino/)
* [Microsoft Windows Script Host](http://msdn.microsoft.com/en-us/library/9bbdkx3k.aspx) (JScript)

A short example:

    require "execjs"
    ExecJS.eval "'red yellow blue'.split(' ')"
    # => ["red", "yellow", "blue"]
