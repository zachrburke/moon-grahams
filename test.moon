import Filter, Corpus from require "moongrahams.init"

good, bad = Corpus!, Corpus!

io.input 'goodsentiment'
good\processTextLine io.read '*all'

io.input 'badsentiment'
bad\processTextLine io.read '*all'

filter = Filter!
filter\load good, bad

result = filter\analyze arg[1] 

print "Results: of " .. arg[1]
print ""
print "Interesting Words:"
print ""

for i, pair in ipairs result.words
	print string.format('%-20s', pair.word), pair.probability

print ""
print "Score: " .. result.probability

if result.probability > 0.70
	print "Determination: NEGATIVE"
else
	print "Determination: POSITIVE"

print ""