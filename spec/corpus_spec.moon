import Corpus from require 'moongrahams'

describe 'corpus', ->

	it 'should have 5 tokens', ->
		corpus = Corpus!

		corpus\processTextLine 'one two three four five 6 7'
		assert.are.same 5, corpus.count

	it 'should have 4 tokens and 2 records of the token "this"', ->
		corpus = Corpus!

		corpus\processTextLine 'this is where this ends'
		assert.are.same 4, corpus.count
		assert.are.same 2, corpus.tokens['this']

	it 'should have 7 tokens', ->
		corpus = Corpus!
		Corpus.TokenPattern = '([a-zA-Z0-9]%w+)%W*'

		corpus\processTextLine 'one two three four five 6 7'
		Corpus.TokenPattern = '([a-zA-Z]%w+)%W*'

		assert.are.same 5, corpus.count

	it 'is case sensitive', ->
		corpus = Corpus!

		corpus\processTextLine 'hi HI hi, hello heLLo'
		assert.are.same 4, corpus.count


