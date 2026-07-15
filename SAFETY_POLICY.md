# Safety Policy

`usb-c-sanity` is intentionally read-only.

Allowed operations:

- print help/version text;
- read macOS version via `sw_vers`;
- read timestamp via `date`;
- read USB device summaries via `system_profiler SPUSBDataType`;
- read IOUSB names via `ioreg -p IOUSB -l -w 0`;
- redact obvious serial/location-like fields before display.

Disallowed operations:

- `sudo` or privilege escalation;
- kernel extension, driver, firmware, NVRAM, power-management, or system setting changes;
- USB reset, mount/unmount, eject, kill, or service mutation;
- writing files automatically;
- network calls;
- telemetry, analytics, auth, payment, or data collection;
- claiming certification or guaranteed cable capacity.

The output should be framed as current observed negotiation evidence only.
