start: .env deps
	@iex -S mix

deps:
	@mix deps.get
	@mix deps.compile

test: deps
	@mix test

.env:
	@cp .env.example $@

clean:
	@mix clean

.PHONY: clean test
