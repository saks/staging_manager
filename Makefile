REPORTER=spec
TESTS=$(shell find ./test -type f -name "*.coffee")

test:
	@NODE_ENV=test ./node_modules/.bin/mocha $(TESTS)

.PHONY: test
