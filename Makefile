.PHONY: setup
setup:
	cd client && npm install
	protoc --js_out=import_style=commonjs,binary:./client messages.proto
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

.PHONY: format
format:
	mix format
	./client/node_modules/prettier/bin-prettier.js --single-quote --trailing-comma es5 --write "./client/*.js"
