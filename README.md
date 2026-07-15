# USB-C Cable Sanity CLI

Read-only macOS command-line helper for quickly checking the USB-C connection signals that macOS exposes for the current device, port, and cable combination.

## What problem it solves

USB-C cables often look identical while negotiating very different data speeds and power behavior. `usb-c-sanity` gives a Mac user a safe first-pass report from macOS’s own read-only device views before they blame the cable, port, hub, or device.

## Claim scope

The tool reports observed negotiated speed/power/device signals only.

It does **not** certify, benchmark, or guarantee cable capacity. A cable that negotiates at one speed in one setup may behave differently with another device, hub, port, charger, or host.

## Safety promise

`usb-c-sanity` is diagnostic-only:

- no `sudo`;
- no writes outside stdout;
- no kernel, driver, firmware, NVRAM, power-management, or system setting changes;
- no device resets;
- no network calls;
- no telemetry, auth, payment, or data collection;
- serial/location-like identifiers are redacted from the report where practical.

## Requirements

- macOS
- zsh
- built-in read-only Apple tools: `sw_vers`, `date`, `system_profiler`, `ioreg`

## Usage

From this repository:

```sh
zsh usb-c-sanity.zsh help
zsh usb-c-sanity.zsh --version
zsh usb-c-sanity.zsh scan
zsh usb-c-sanity.zsh raw-safe
```

Recommended practical flow:

1. Connect the USB-C device through the cable you want to sanity-check.
2. Run `scan` and save the output.
3. Repeat with a known-good cable and the same device/port.
4. Compare only observed fields such as `Speed`, `Current Available`, and `Current Required`.
5. Treat differences as clues, not proof.

## How to read the report

- `Speed`: the currently observed negotiated USB data speed string macOS exposes for that device path.
- `Current Available (mA)`: a USB current hint exposed by macOS for the current connection.
- `Current Required (mA)`: device current requirement exposed by macOS where available.
- `Vendor ID` / `Product ID`: device identifiers useful for recognizing what was connected.
- Redacted serial/location fields: intentionally not included in public/shared reports.

## Limitations

- macOS may not expose every USB-C or USB Power Delivery detail through `system_profiler` or `ioreg`.
- Thunderbolt/USB4, DisplayPort Alt Mode, charging wattage, and e-marker details may need specialized hardware or vendor tools.
- Hubs/docks can mask cable behavior.
- The same cable can negotiate differently depending on host, port, device, charger, and hub.
- This is not a compliance test and not a substitute for a certified cable tester.

## Files

- `usb-c-sanity.zsh` — read-only CLI prototype.
- `SAMPLE_OUTPUT.md` — illustrative sample report.
- `DEMO_TRANSCRIPT.md` — local smoke transcript.
- `SAFETY_POLICY.md` — safety and privacy boundaries.
- `RESPONSIBLE_USE.md` — responsible interpretation notes.
- `SECURITY.md` — security reporting and non-goals.
- `LICENSE` — MIT license placeholder for public packaging.

## Verification

```sh
zsh -n usb-c-sanity.zsh
zsh usb-c-sanity.zsh --version
zsh usb-c-sanity.zsh help
zsh usb-c-sanity.zsh scan
```

Before sharing reports publicly, review output for private device names or identifiers.
