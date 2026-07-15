#!/usr/bin/env zsh
set -u

VERSION="0.1.0"
PROGRAM="usb-c-sanity"

usage() {
  cat <<'EOF'
usb-c-sanity — read-only macOS USB-C negotiated-signal helper

Usage:
  zsh usb-c-sanity.zsh help
  zsh usb-c-sanity.zsh --version
  zsh usb-c-sanity.zsh scan
  zsh usb-c-sanity.zsh raw-safe

What it reports:
  - macOS version and timestamp
  - visible USB device names/classes from system_profiler SPUSBDataType
  - observed negotiated USB speed strings when macOS exposes them
  - observed current/power fields when macOS exposes them
  - IOUSB/ioreg device names, with serial/location-like fields redacted

Safety:
  - read-only commands only: sw_vers, date, system_profiler, ioreg
  - no sudo, no kernel changes, no driver changes, no writes outside stdout
  - no network calls, telemetry, auth, payment, or data collection

Important limitation:
  This tool observes the current Mac + port + device + cable negotiation.
  It does NOT certify or guarantee cable capacity.
EOF
}

version() {
  print -- "$PROGRAM $VERSION"
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    print -- "missing required command: $1" >&2
    return 1
  }
}

redact_line() {
  # Keep report useful while avoiding obvious serial/location identifiers.
  sed -E \
    -e 's/(Serial Number:).*/\1 [redacted]/I' \
    -e 's/(USB Serial Number:).*/\1 [redacted]/I' \
    -e 's/(Location ID:).*/\1 [redacted]/I' \
    -e 's/(locationID" = )[^ ]+/\1[redacted]/I' \
    -e 's/(USB Address:).*/\1 [redacted]/I'
}

print_header() {
  print -- "# usb-c-sanity report"
  print -- "timestamp_utc: $(TZ=UTC date '+%Y-%m-%dT%H:%M:%SZ')"
  if command -v sw_vers >/dev/null 2>&1; then
    print -- "macos: $(sw_vers -productName) $(sw_vers -productVersion) ($(sw_vers -buildVersion))"
  else
    print -- "macos: unavailable (sw_vers missing)"
  fi
  print -- "claim_scope: observed negotiated speed/power/device signals only; no cable capacity guarantee"
  print -- ""
}

scan_system_profiler() {
  require_cmd system_profiler || return 1
  print -- "## system_profiler SPUSBDataType summary"
  system_profiler SPUSBDataType 2>/dev/null | awk '
    /^[[:space:]]{4,}[^ ].*:$/ { item=$0; gsub(/^[[:space:]]+/, "", item); gsub(/:$/, "", item); print "device: " item }
    /Speed:/ { gsub(/^[[:space:]]+/, "", $0); print "  " $0 }
    /Current Available \(mA\):/ { gsub(/^[[:space:]]+/, "", $0); print "  " $0 }
    /Current Required \(mA\):/ { gsub(/^[[:space:]]+/, "", $0); print "  " $0 }
    /Extra Operating Current \(mA\):/ { gsub(/^[[:space:]]+/, "", $0); print "  " $0 }
    /Sleep current \(mA\):/ { gsub(/^[[:space:]]+/, "", $0); print "  " $0 }
    /Manufacturer:/ { gsub(/^[[:space:]]+/, "", $0); print "  " $0 }
    /Product ID:/ { gsub(/^[[:space:]]+/, "", $0); print "  " $0 }
    /Vendor ID:/ { gsub(/^[[:space:]]+/, "", $0); print "  " $0 }
  ' | redact_line
  print -- ""
}

scan_ioreg() {
  require_cmd ioreg || return 1
  print -- "## ioreg IOUSB visible names (redacted)"
  ioreg -p IOUSB -l -w 0 2>/dev/null | awk '
    /\+-o / { line=$0; sub(/^.*\+-o /, "", line); sub(/  <.*$/, "", line); print "node: " line }
    /"USB Product Name" =/ { gsub(/^[[:space:]]+/, "", $0); print "  " $0 }
    /"USB Vendor Name" =/ { gsub(/^[[:space:]]+/, "", $0); print "  " $0 }
    /"USB Serial Number" =/ { gsub(/^[[:space:]]+/, "", $0); print "  USB Serial Number = [redacted]" }
    /"locationID" =/ { print "  locationID = [redacted]" }
  ' | head -n 160 | redact_line
  print -- ""
}

raw_safe() {
  require_cmd system_profiler || return 1
  system_profiler SPUSBDataType 2>/dev/null | redact_line
}

scan() {
  print_header
  scan_system_profiler
  scan_ioreg
  print -- "## interpretation"
  print -- "- If Speed is shown, treat it as the observed negotiated USB data speed for the current connection."
  print -- "- If current fields are shown, treat them as observed USB current/power hints for the current device/port state."
  print -- "- Absence of a field means macOS did not expose it in this view; it is not proof that a cable lacks support."
  print -- "- Re-test with the same device on a known-good cable/port before drawing practical conclusions."
}

case "${1:-help}" in
  help|-h|--help) usage ;;
  --version|version) version ;;
  scan) scan ;;
  raw-safe) raw_safe ;;
  *) print -- "unknown command: $1" >&2; usage >&2; exit 2 ;;
esac
