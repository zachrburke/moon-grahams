local Filter, Corpus
do
  local _obj_0 = require("moongrahams.init")
  Filter, Corpus = _obj_0.Filter, _obj_0.Corpus
end
local good = Corpus()
local bad = Corpus()
io.input('goodsentiment')
good:processTextLine(io.read('*all'))
io.input('badsentiment')
bad:processTextLine(io.read('*all'))
local filter = Filter()
filter:Load(good, bad)
local probability, interestingWords = filter:Test(arg[1])
print("Results: of " .. arg[1])
print("")
print("Interesting Words:")
print("")
for i, pair in ipairs(interestingWords) do
  print(string.format('%-20s', pair.Word), pair.Probability)
end
print("")
print("Score: " .. probability)
if probability > 0.70 then
  print("Determination: NEGATIVE")
else
  print("Determination: POSITIVE")
end
return print("")
