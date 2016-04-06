start: .env deps
	@$(shell cat .env | grep -v '^#' | xargs) iex -S mix

test:
	@$(shell cat .env | grep '^#\|^MIX_ENV' --invert-match | xargs) mix test

.env:
	@cp .env.example $@

clean:
	rm -rf _build deps

deps:
	@mix deps.get
	@mix deps.compile

.PHONY: clean test
