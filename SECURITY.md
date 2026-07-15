# Security

## Supported status

This repository is an early public release. Security fixes are handled on the default branch and release tags.

## Security model

The tool is designed to be read-only and local-only. It does not require credentials and does not make network calls.

## Sensitive data handling

USB serial numbers, USB address/location-like fields, and similar identifiers should be redacted before sharing reports publicly. The script includes simple redaction for common `system_profiler` and `ioreg` fields, but users should still review output before posting it.

## Reporting issues

Please report security or privacy issues via GitHub Issues on this repository, or contact NeuraByte Labs through the public profile. Do not publish private machine reports or unredacted device identifiers.
