import Filter, Corpus from require 'moongrahams'

describe 'filter - calculate probabilities', ->

	setup ->
		export good = Corpus!
		export bad = Corpus!
		export filter = Filter!

	teardown ->
		good = nil
		bad = nil
		filter = nil

	it '"good" has minimum probability with no bad data', ->
		good\processTextLine 'good good good good good good good good good good good good good good'

		filter\load good, bad
		assert.are.same filter.minScore, filter.probabilities['good']

		filter.minScore = 0
		probability = filter\calculateTokenProbability 'good'

		assert.are.same filter.minScore, probability

	it 'returns a likely spam probability with all bad data', ->
		bad\processTextLine 'bad bad bad bad bad bad bad bad'

		filter\load good, bad
		assert.are.same filter.likelySpamScore, filter.probabilities['bad']

	it 'returns a certain spam probability with all bad data', ->
		bad\processTextLine 'bad bad bad bad bad bad bad bad bad bad bad'

		filter\load good, bad
		assert.are.same filter.certainSpamScore, filter.probabilities['bad']

describe 'filter - analyze', ->

	setup ->
		export good = Corpus!
		export bad = Corpus!
		export filter = Filter!

	teardown ->
		good = nil
		bad = nil
		filter = nil

	it 'scores negative for a post with negative sentiment', ->
		bad\processTextLine 'bad bad bad bad bad bad'

		filter\load good, bad
		result = filter\analyze 'bad'

		assert.is_true result.probability > 0.80

	it 'scores positive for a post with positive sentiment', ->
		good\processTextLine 'good good good good good'

		filter\load good, bad
		result = filter\analyze 'good'

		assert.is_true result.probability < 0.20

	it 'returns words in descending order of "interesting-ness"', ->
		bad\processTextLine 'you are stupid and i hate you get out'
		good\processTextLine 'you are awesome and i think you are cool'

		filter.minScore = 0.11
		filter.maxScore = 0.99
		filter\load good, bad

		result = filter\analyze 'you are the worst and i think you are stupid'

		assert.are_not.equal string.find(result.words[1].word, 'stupid'), nil



