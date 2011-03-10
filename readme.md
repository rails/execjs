ExecJS
======

ExecJS lets you run JavaScript code from Ruby. It automatically picks
the best runtime available to evaluate your JavaScript program, then
returns the result to you as a Ruby object.

ExecJS supports these runtimes:

* [therubyracer](https://github.com/cowboyd/therubyracer) - Google V8
  embedded within MRI Ruby
* [therubyrhino](https://github.com/cowboyd/therubyrhino) - Mozilla
  Rhino embedded within JRuby
* [Node.js](http://nodejs.org/)
* Apple JavaScriptCore - Included with Mac OS X
* [Mozilla Spidermonkey](http://www.mozilla.org/js/spidermonkey/)
* [Microsoft Windows Script Host](http://msdn.microsoft.com/en-us/library/9bbdkx3k.aspx) (JScript)

A short example:

    require "execjs"
    ExecJS.eval "'red yellow blue'.split(' ')"
    # => ["red", "yellow", "blue"]
