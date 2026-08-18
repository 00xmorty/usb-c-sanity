.PHONY: help test demo verify-release

help:
	@printf '%s\n' 'make test            - run the read-only smoke suite' 'make demo            - print share-safe diagnostic output' 'make verify-release  - verify the local handoff file boundary and run tests'

test:
	@if [ -f tests/test_usb_c_sanity.sh ]; then \
		bash tests/test_usb_c_sanity.sh; \
	else \
		bash ../../tests/test_usb_c_sanity.sh; \
	fi

demo:
	@zsh ./usb-c-sanity.zsh scan --share-safe

verify-release: test
	@set -eu; \
	files='.github/workflows/smoke.yml Makefile usb-c-sanity.zsh README.md SAFETY_POLICY.md RESPONSIBLE_USE.md SECURITY.md SAMPLE_OUTPUT.md DEMO_TRANSCRIPT.md LICENSE SHA256SUMS'; \
	privacy_files='.github/workflows/smoke.yml usb-c-sanity.zsh README.md SAFETY_POLICY.md RESPONSIBLE_USE.md SECURITY.md SAMPLE_OUTPUT.md DEMO_TRANSCRIPT.md LICENSE'; \
	for file in $$files; do \
		test -f "$$file" && test ! -L "$$file" || { printf 'FAIL: invalid release file: %s\n' "$$file" >&2; exit 1; }; \
	done; \
	if [ -f tests/test_usb_c_sanity.sh ]; then smoke=tests/test_usb_c_sanity.sh; else smoke=../../tests/test_usb_c_sanity.sh; fi; \
	test -f "$$smoke" && test ! -L "$$smoke" || { printf 'FAIL: invalid smoke test: %s\n' "$$smoke" >&2; exit 1; }; \
	if grep -En '/Users/[^/[:space:]]+|-----BEGIN ([A-Z0-9 ]+ )?PRIVATE KEY-----|ghp_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,}|AKIA[0-9A-Z]{16}' $$privacy_files; then \
		printf '%s\n' 'FAIL: release files contain a private path or credential-like token' >&2; exit 1; \
	fi; \
	shasum -a 256 -c SHA256SUMS; \
	printf '%s\n' 'ok usb-c-sanity checksums'; \
	printf '%s\n' 'ok usb-c-sanity privacy scan'; \
	printf '%s\n' 'ok usb-c-sanity release boundary'
