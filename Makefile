SHELL := /bin/bash
.PHONY: ci-tests

ci-tests:
	dart format --set-exit-if-changed . -l 120
	dart analyze
	flutter test -r expanded --coverage
	dart run covadge ./coverage/lcov.info ./

show-test-coverage:
	genhtml coverage/lcov.info -o coverage/html
	open coverage/html/index.html

cache-repair:
	flutter pub cache repair
	make clean

clean:
	flutter clean
	flutter pub get

adb-restart:
	adb kill-server
	adb start-server

apply-lint:
	dart fix --dry-run
	dart fix --apply
