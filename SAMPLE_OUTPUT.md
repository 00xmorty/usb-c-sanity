# Sample Output

Illustrative shape only. Device names and identifiers are examples.

```text
# usb-c-sanity report
timestamp_utc: 2026-06-26T18:00:00Z
macos: macOS 26.5 (25F01)
claim_scope: observed negotiated speed/power/device signals only; no cable capacity guarantee

## system_profiler SPUSBDataType summary
device: USB 3.1 Bus
device: Example USB-C SSD
  Product ID: 0x1234
  Vendor ID: 0xabcd
  Speed: Up to 10 Gb/s
  Current Available (mA): 900
  Current Required (mA): 896

## ioreg IOUSB visible names (redacted)
node: Example USB-C SSD
  "USB Product Name" = "Example USB-C SSD"
  "USB Vendor Name" = "Example Vendor"
  USB Serial Number = [redacted]
  locationID = [redacted]

## interpretation
- If Speed is shown, treat it as the observed negotiated USB data speed for the current connection.
- If current fields are shown, treat them as observed USB current/power hints for the current device/port state.
- Absence of a field means macOS did not expose it in this view; it is not proof that a cable lacks support.
- Re-test with the same device on a known-good cable/port before drawing practical conclusions.
```
