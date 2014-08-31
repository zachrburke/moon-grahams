local config = {
  GoodTokenWeight = 2,
  MinTokenCount = 0,
  MinCountForInclusion = 5,
  MinScore = 0.011,
  MaxScore = 0.99,
  LikelySpamScore = 0.9998,
  CertainSpamScore = 0.9999,
  CertainSpamCount = 10,
  InterestingWordCount = 15
}
do
  local _base_0 = {
    ProcessTextLine = function(self, line)
      for match in string.gmatch(line, self.__class.TokenPattern) do
        self:AddToken(match)
      end
    end,
    AddToken = function(self, rawPhrase)
      if (self.Tokens[rawPhrase]) then
        self.Tokens[rawPhrase] = self.Tokens[rawPhrase] + 1
      else
        self.Tokens[rawPhrase] = 1
        self.NumTokens = self.NumTokens + 1
      end
    end
  }
  _base_0.__index = _base_0
  local _class_0 = setmetatable({
    __init = function(self)
      self.Tokens = { }
      self.NumTokens = 0
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
do
  local _base_0 = {
    Load = function(self, good, bad)
      self.Good = good
      self.Bad = bad
      return self:CalculateProbabilities()
    end,
    CalculateProbabilities = function(self)
      self.Probabilities = { }
      for token, score in pairs(self.Good.Tokens) do
        self:CalculateTokenProbability(token)
      end
      local remainingTokens
      do
        local _tbl_0 = { }
        for k, v in pairs(self.Bad.Tokens) do
          if not self.Probabilities[k] then
            _tbl_0[k] = v
          end
        end
        remainingTokens = _tbl_0
      end
      for token, score in pairs(remainingTokens) do
        self:CalculateTokenProbability(token)
      end
    end,
    CalculateTokenProbability = function(self, token)
      local g
      if self.Good.Tokens[token] then
        g = self.Good.Tokens[token] * config.GoodTokenWeight
      else
        g = 0
      end
      local b
      if self.Bad.Tokens[token] then
        b = self.Bad.Tokens[token]
      else
        b = 0
      end
      if (g + b > config.MinCountForInclusion) then
        local goodFactor = math.min(1, g / self.Good.NumTokens)
        local badFactor = math.min(1, b / self.Bad.NumTokens)
        local prob = math.max(config.MinScore, math.min(config.MaxScore, badFactor / (goodFactor + badFactor)))
        if g == 0 then
          if b > config.CertainSpamCount then
            prob = config.CertainSpamScore
          else
            prob = config.LikelySpamScore
          end
        end
        self.Probabilities[token] = prob
      end
    end,
    Test = function(self, message)
      local probs = { }
      local index = 0
      for token in string.gmatch(message, Corpus.TokenPattern) do
        if self.Probabilities[token] then
          local prob = self.Probabilities[token]
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
      for Interest, Probability in pairs(probs) do
        table.insert(probsSorted, {
          Interest = Interest,
          Probability = Probability
        })
      end
      table.sort(probsSorted, function(a, b)
        return a.Interest < b.Interest
      end)
      local words = { }
      for i, prob in ipairs(probsSorted) do
        local Probability = prob.Probability
        mult = mult * Probability
        comb = comb * (1 - Probability)
        local Word = string.match(prob.Interest, Corpus.TokenPattern)
        table.insert(words, {
          Word = Word,
          Probability = Probability
        })
        index = index + 1
        if index > config.InterestingWordCount then
          break
        end
      end
      return mult / (mult + comb), words
    end
  }
  _base_0.__index = _base_0
  local _class_0 = setmetatable({
    __init = function() end,
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
