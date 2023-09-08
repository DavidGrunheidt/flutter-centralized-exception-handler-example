SHELL := /bin/bash
.PHONY: ci-tests

gen-code:
	dart run build_runner build --delete-conflicting-outputs
	dart format . -l 120

ci-tests:
	dart format --set-exit-if-changed . -l 120
	dart analyze

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
