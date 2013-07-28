
config = {
	GoodTokenWeight: 2
	MinTokenCount: 0
	MinCountForInclusion: 5
	MinScore: 0.011
	MaxScore: 0.99
	LikelySpamScore: 0.9998
	CertainSpamScore: 0.9999
	CertainSpamCount: 10
	InterestingWordCount: 15
}

export class Corpus

	-- Pattern to select words that don't begin with a number
	@TokenPattern = '([a-zA-Z]%w+)%W*'

	new: =>
		@Tokens = {}
		@NumTokens = 0

	ProcessTextLine: (line) =>
		for match in string.gmatch line, @@TokenPattern
			@AddToken match


	AddToken: (rawPhrase) =>
		if (@Tokens[rawPhrase])
			@Tokens[rawPhrase] = @Tokens[rawPhrase] + 1
			@NumTokens = @NumTokens + 1
		else
			@Tokens[rawPhrase] = 1

export class Filter

	Load: (good, bad) => 
		@Good = good
		@Bad = bad

		@CalculateProbabilities!

	CalculateProbabilities: () =>
		@Probabilities = {}

		for token, score in pairs @Good.Tokens
			@CalculateTokenProbability token

		remainingTokens = {k,v for k, v in pairs @Bad.Tokens when not @Probabilities[k]}

		for token, score in pairs remainingTokens
			@CalculateTokenProbability token


	CalculateTokenProbability: (token) => 

		g = if @Good.Tokens[token] then @Good.Tokens[token] * config.GoodTokenWeight else 0
		b = if @Bad.Tokens[token] then @Bad.Tokens[token] else 0

		if (g + b > config.MinCountForInclusion)

			goodFactor = math.min 1, g / @Good.NumTokens
			badFactor = math.min 1, b / @Bad.NumTokens

			prob = math.max config.MinScore, math.min config.MaxScore, badFactor / (goodFactor + badFactor)
			
			if g == 0
				prob = if b > config.CertainSpamCount then config.CertainSpamScore else config.LikelySpamScore

			@Probabilities[token] = prob

	Test: (message) =>

		probs = {}
		index = 0

		for token in string.gmatch message, Corpus.TokenPattern
			if @Probabilities[token] 

				prob = @Probabilities[token]

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
		for Interest, Probability in pairs probs
			table.insert probsSorted, {:Interest, :Probability}

		table.sort probsSorted, (a, b) -> return a.Interest < b.Interest

		for i, prob in ipairs probsSorted

			print prob.Interest, '', prob.Probability

			mult *= prob.Probability
			comb *= (1 - prob.Probability)

			index += 1

			if index > config.InterestingWordCount
				break


		return mult / (mult + comb)


