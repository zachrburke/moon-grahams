class Corpus
	-- Pattern to select words that don't begin with a number
	@TokenPattern: '([a-zA-Z]%w+)%W*'

	new: =>
		@tokens = {}
		@count = 0

	processTextLine: (line) =>
		for match in string.gmatch line, Corpus.TokenPattern
			@addToken match


	addToken: (rawPhrase) =>
		if (@tokens[rawPhrase])
			@tokens[rawPhrase] = @tokens[rawPhrase] + 1
		else
			@tokens[rawPhrase] = 1
			@count = @count + 1
			

class Filter
	new: =>
		@minScore = 0.011
		@maxScore = 0.99
		@goodTokenWeight = 2
		@minCountForInclusion = 0
		@interestingWordCount = 15
		@likelySpamScore = 0.9998
		@certainSpamScore = 0.9999
		@certainSpamCount = 10
		@probabilities = {}


	load: (good, bad) => 
		@good = good
		@bad = bad

		@calculateProbabilities!

	calculateProbabilities: () =>
		@probabilities = {}

		for token, score in pairs @good.tokens
			@calculateTokenProbability token

		remainingTokens = {k,v for k, v in pairs @bad.tokens when not @probabilities[k]}

		for token, score in pairs remainingTokens
			@calculateTokenProbability token


	calculateTokenProbability: (token) => 

		g = if @good.tokens[token] then @good.tokens[token] * @goodTokenWeight else 0
		b = if @bad.tokens[token] then @bad.tokens[token] else 0

		if (g + b > @minCountForInclusion)

			goodFactor = math.min 1, g / (if @good.count > 0 then @good.count else 1)
			badFactor = math.min 1, b / (if @bad.count > 0 then @bad.count else 1)

			prob = badFactor / (goodFactor + badFactor)
			prob = math.max @minScore, math.min(@maxScore, prob)

			if g == 0
				prob = if b > @certainSpamCount then @certainSpamScore else @likelySpamScore

			@probabilities[token] = prob

			return prob

	analyze: (message) =>

		probs = {}
		index = 0

		for token in string.gmatch message, Corpus.TokenPattern
			if @probabilities[token] 

				prob = @probabilities[token]

				-- here we're storing the 'interestingness' of the word as a key
				key = string.format '%.5f', tostring(0.5 - math.abs (0.5 - prob)) 
				key ..=  token 
				key ..= tostring(index + 1)
				index += 1 
				probs[key] = prob

		mult = 1 -- abc..n
		comb = 1 -- (1 - a)(1 - b)..(1 - n)
		index = 0

		-- sort the words of a message by how interesting they are, not probability
		probsSorted = {}
		for interest, probability in pairs probs
			table.insert probsSorted, {:interest, :probability}

		table.sort probsSorted, (a, b) -> return a.interest < b.interest

		words = {}
		for i, prob in ipairs probsSorted

			probability = prob.probability

			mult *= probability
			comb *= (1 - probability)

			word = string.match(prob.interest, Corpus.TokenPattern)

			table.insert words, {:word, :probability}

			index += 1

			if index > @interestingWordCount
				break


		return {
			probability: mult / (mult + comb)
			words: words
		}

return { :Corpus, :Filter }
