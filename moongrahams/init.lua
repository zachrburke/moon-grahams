local Corpus
do
  local _base_0 = {
    processTextLine = function(self, line)
      for match in string.gmatch(line, Corpus.TokenPattern) do
        self:addToken(match)
      end
    end,
    addToken = function(self, rawPhrase)
      if (self.tokens[rawPhrase]) then
        self.tokens[rawPhrase] = self.tokens[rawPhrase] + 1
      else
        self.tokens[rawPhrase] = 1
        self.count = self.count + 1
      end
    end
  }
  _base_0.__index = _base_0
  local _class_0 = setmetatable({
    __init = function(self)
      self.tokens = { }
      self.count = 0
    end,
    __base = _base_0,
    __name = "Corpus"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  local self = _class_0
  self.TokenPattern = '([a-zA-Z]%w+)%W*'
  Corpus = _class_0
end
local Filter
do
  local _base_0 = {
    load = function(self, good, bad)
      self.good = good
      self.bad = bad
      return self:calculateProbabilities()
    end,
    calculateProbabilities = function(self)
      self.probabilities = { }
      for token, score in pairs(self.good.tokens) do
        self:calculateTokenProbability(token)
      end
      local remainingTokens
      do
        local _tbl_0 = { }
        for k, v in pairs(self.bad.tokens) do
          if not self.probabilities[k] then
            _tbl_0[k] = v
          end
        end
        remainingTokens = _tbl_0
      end
      for token, score in pairs(remainingTokens) do
        self:calculateTokenProbability(token)
      end
    end,
    calculateTokenProbability = function(self, token)
      local g
      if self.good.tokens[token] then
        g = self.good.tokens[token] * self.goodTokenWeight
      else
        g = 0
      end
      local b
      if self.bad.tokens[token] then
        b = self.bad.tokens[token]
      else
        b = 0
      end
      if (g + b > self.minCountForInclusion) then
        local goodFactor = math.min(1, g / ((function()
          if self.good.count > 0 then
            return self.good.count
          else
            return 1
          end
        end)()))
        local badFactor = math.min(1, b / ((function()
          if self.bad.count > 0 then
            return self.bad.count
          else
            return 1
          end
        end)()))
        local prob = badFactor / (goodFactor + badFactor)
        prob = math.max(self.minScore, math.min(self.maxScore, prob))
        if g == 0 then
          if b > self.certainSpamCount then
            prob = self.certainSpamScore
          else
            prob = self.likelySpamScore
          end
        end
        self.probabilities[token] = prob
        return prob
      end
    end,
    analyze = function(self, message)
      local probs = { }
      local index = 0
      for token in string.gmatch(message, Corpus.TokenPattern) do
        if self.probabilities[token] then
          local prob = self.probabilities[token]
          local key = string.format('%.5f', tostring(0.5 - math.abs((0.5 - prob))))
          key = key .. token
          key = key .. tostring(index + 1)
          index = index + 1
          probs[key] = prob
        end
      end
      local mult = 1
      local comb = 1
      index = 0
      local probsSorted = { }
      for interest, probability in pairs(probs) do
        table.insert(probsSorted, {
          interest = interest,
          probability = probability
        })
      end
      table.sort(probsSorted, function(a, b)
        return a.interest < b.interest
      end)
      local words = { }
      for i, prob in ipairs(probsSorted) do
        local probability = prob.probability
        mult = mult * probability
        comb = comb * (1 - probability)
        local word = string.match(prob.interest, Corpus.TokenPattern)
        table.insert(words, {
          word = word,
          probability = probability
        })
        index = index + 1
        if index > self.interestingWordCount then
          break
        end
      end
      return {
        probability = mult / (mult + comb),
        words = words
      }
    end
  }
  _base_0.__index = _base_0
  local _class_0 = setmetatable({
    __init = function(self)
      self.minScore = 0.011
      self.maxScore = 0.99
      self.goodTokenWeight = 2
      self.minCountForInclusion = 0
      self.interestingWordCount = 15
      self.likelySpamScore = 0.9998
      self.certainSpamScore = 0.9999
      self.certainSpamCount = 10
      self.probabilities = { }
    end,
    __base = _base_0,
    __name = "Filter"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Filter = _class_0
end
return {
  Corpus = Corpus,
  Filter = Filter
}
