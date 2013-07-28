require "lib.analyzer"

good = Corpus!
bad = Corpus!

io.input 'goodsentiment'
bad\ProcessTextLine io.read '*all'

io.input 'badsentiment'
good\ProcessTextLine io.read '*all'

filter = Filter!
filter\Load good, bad

print filter\Test arg[1] 