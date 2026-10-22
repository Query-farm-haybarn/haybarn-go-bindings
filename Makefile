BROOD=GOWORK=off go run ./internal/cmd/brood

# Stage a custom build, install its header and select it through go.work.
use.libs:
	$(BROOD) use

# Restore the pinned header and stop selecting the staged native module.
unuse.libs:
	git restore -- include/duckdb.h
	rm -f go.work go.work.sum

update.libs:
	$(BROOD) package
	$(BROOD) pin
	./scripts/test.sh packaged

publish.libs:
	$(BROOD) upload

test:
	./scripts/test.sh

# Package the pinned native modules and test them through a local module proxy,
# for a pin that isn't published yet.
test.packaged:
	$(BROOD) package
	./scripts/test.sh packaged

test.static:
	./scripts/test.sh static

test.dynamic:
	./scripts/test.sh dynamic

.PHONY: use.libs unuse.libs update.libs publish.libs test test.packaged test.static test.dynamic
