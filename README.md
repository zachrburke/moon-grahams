moon-grahams
============

A bayesion analyzer based on Paul Grahams essay on spam filtering found here http://www.paulgraham.com/spam.html

Written using Moonscript, a language that compiles in the Lua scripting language.  Can be found here http://moonscript.org/

Installation
------------

You can install the latest version using moonrocks

```
moonrocks install moongrahams
```

Usage
-----

Here is an example of how you might load data into a moon grahams filter

```lua
moongrahams = require('moongrahams')

local good, bad = moongrahams.Corpus(), moongrahams.Corpus()
local filter = moongrahams.Filter()

good:processTextLine("Hi there I'm Zach.  Nice to meet you!")
bad:processTextLine("Extreme weight loss buy this revolutionary new product")

filter:load(good, bad)
```

Then to test the content, you do the following:

```lua
result = filter:analyze('Extreme Zach, Nice to be revolutionary')

if result.probability > 0.80 then
    print('This is spam!') --probability is between 0.0 and 1.0
end
```

The result of an analyze call also has a table of the words used to calculate the overall probability, ordered by how "interesting" they are.  Interesting meaning how far each word's probability is from 0.5.

```lua
for i, pair in ipairs(result.words) do
    print(string.format('%-20s', pair.word), pair.probability)
end
```

See it in Action!
======

Bad sentiment contains tokens you want to filter against and good sentiment contains tokens you want to get through the filter.   By default the data just uses good and bad movie reviews for the good and bad sentiment respectively.  

To try it out, just run the test script provided in the repo, like so:

```
moon test.moon "the statement you are testing"
```

License (MIT)
=============

Copyright (c) 2014 Zach Burke

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.