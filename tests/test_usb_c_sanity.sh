#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLI="$ROOT_DIR/products/usb-c-cable-sanity-cli/usb-c-sanity.zsh"
if [[ ! -f "$CLI" && -f "$ROOT_DIR/usb-c-sanity.zsh" ]]; then
  CLI="$ROOT_DIR/usb-c-sanity.zsh"
fi

if [[ ! -f "$CLI" ]]; then
  echo "missing CLI: $CLI" >&2
  exit 1
fi

zsh -n "$CLI"

version_output="$(zsh "$CLI" --version)"
[[ "$version_output" == "usb-c-sanity 0.1.2" ]]

help_output="$(zsh "$CLI" help)"
[[ "$help_output" == *"read-only macOS USB-C negotiated-signal helper"* ]]
[[ "$help_output" == *"does NOT certify or guarantee cable capacity"* ]]
[[ "$help_output" == *"no sudo"* ]]
[[ "$help_output" == *"scan --no-ioreg"* ]]
[[ "$help_output" == *"scan --share-safe"* ]]

scan_output="$(zsh "$CLI" scan)"
[[ "$scan_output" == *"# usb-c-sanity report"* ]]
[[ "$scan_output" == *"claim_scope: observed negotiated speed/power/device signals only; no cable capacity guarantee"* ]]
[[ "$scan_output" == *"## interpretation"* ]]
[[ "$scan_output" == *"Absence of a field means macOS did not expose it"* ]]

privacy_output="$(zsh "$CLI" scan --no-ioreg)"
[[ "$privacy_output" == *"privacy_mode: ioreg section skipped (--no-ioreg)"* ]]
[[ "$privacy_output" != *"## ioreg IOUSB visible names"* ]]

share_safe_output="$(zsh "$CLI" scan --share-safe)"
[[ "$share_safe_output" == *"## system_profiler SPUSBDataType share-safe signals"* ]]
[[ "$share_safe_output" == *"device names and identifiers suppressed (--share-safe)"* ]]
[[ "$share_safe_output" != *"## ioreg IOUSB visible names"* ]]
[[ "$share_safe_output" != *"Manufacturer:"* ]]
[[ "$share_safe_output" != *"Product ID:"* ]]
[[ "$share_safe_output" != *"Vendor ID:"* ]]

if zsh "$CLI" scan --unsupported >/dev/null 2>&1; then
  echo "unsupported scan option unexpectedly succeeded" >&2
  exit 1
fi

raw_output="$(zsh "$CLI" raw-safe || true)"
if [[ "$raw_output" == *"Serial Number:"* && "$raw_output" != *"Serial Number: [redacted]"* ]]; then
  echo "raw-safe serial redaction check failed" >&2
  exit 1
fi
if [[ "$raw_output" == *"Location ID:"* && "$raw_output" != *"Location ID: [redacted]"* ]]; then
  echo "raw-safe location redaction check failed" >&2
  exit 1
fi

echo "ok usb-c-sanity smoke"
