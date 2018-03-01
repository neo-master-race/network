.PHONY: setup
setup:
	cd client && npm install
	mix local.hex --force
	mix deps.get

.PHONY: run-client
run-client:
	@node client/index.js

.PHONY: run-server
run-server:
	@mix run --no-halt

.PHONY: run-dev-server
run-dev-server:
	@iex -S mix
