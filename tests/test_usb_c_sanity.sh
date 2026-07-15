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
[[ "$version_output" == "usb-c-sanity 0.1.0" ]]

help_output="$(zsh "$CLI" help)"
[[ "$help_output" == *"read-only macOS USB-C negotiated-signal helper"* ]]
[[ "$help_output" == *"does NOT certify or guarantee cable capacity"* ]]
[[ "$help_output" == *"no sudo"* ]]

scan_output="$(zsh "$CLI" scan)"
[[ "$scan_output" == *"# usb-c-sanity report"* ]]
[[ "$scan_output" == *"claim_scope: observed negotiated speed/power/device signals only; no cable capacity guarantee"* ]]
[[ "$scan_output" == *"## interpretation"* ]]
[[ "$scan_output" == *"Absence of a field means macOS did not expose it"* ]]

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
