.PHONY: setup
setup:
	cd client && npm install
	mix local.hex --force
	mix deps.get

.PHONY: run-client
run-client:
	@node client/index.js
