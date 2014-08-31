require "moongrahams"

good = Corpus!
bad = Corpus!

io.input 'goodsentiment'
good\ProcessTextLine io.read '*all'

io.input 'badsentiment'
bad\ProcessTextLine io.read '*all'

filter = Filter!
filter\Load good, bad

probability, interestingWords = filter\Test arg[1] 

print "Results: of " .. arg[1]
print ""
print "Interesting Words:"
print ""

for i, pair in ipairs interestingWords
	print string.format('%-20s', pair.Word), pair.Probability

print ""
print "Score: " .. probability

if probability > 0.70
	print "Determination: NEGATIVE"
else
	print "Determination: POSITIVE"

print ""