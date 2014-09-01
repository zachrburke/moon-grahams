local Filter, Corpus
do
  local _obj_0 = require("moongrahams.init")
  Filter, Corpus = _obj_0.Filter, _obj_0.Corpus
end
local good, bad = Corpus(), Corpus()
io.input('goodsentiment')
good:processTextLine(io.read('*all'))
io.input('badsentiment')
bad:processTextLine(io.read('*all'))
local filter = Filter()
filter:load(good, bad)
local result = filter:analyze(arg[1])
print("Results: of " .. arg[1])
print("")
print("Interesting Words:")
print("")
for i, pair in ipairs(result.words) do
  print(string.format('%-20s', pair.word), pair.probability)
end
print("")
print("Score: " .. result.probability)
if result.probability > 0.70 then
  print("Determination: NEGATIVE")
else
  print("Determination: POSITIVE")
end
return print("")
