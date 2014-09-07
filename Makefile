REPORTER=spec
TESTS=$(shell find ./test -type f -name "*_spec.coffee")

test:
	@NODE_ENV=test ./node_modules/.bin/mocha test/spec_helper.coffee $(TESTS)

.PHONY: test
