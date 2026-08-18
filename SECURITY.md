# Security

## Supported status

Security fixes are provided for the latest published release on the default branch.

## Security model

The tool is designed to be read-only and local-only. It does not require credentials and does not make network calls.

## Sensitive data handling

USB serial numbers, USB address/location-like fields, and similar identifiers should be redacted before sharing reports publicly. The script includes simple redaction for common `system_profiler` and `ioreg` fields, but users should still review output before posting it.

## Reporting issues

For suspected vulnerabilities, use GitHub's private vulnerability reporting or open a minimal issue without private machine output. Do not publish unredacted device identifiers, serials, or private machine reports.
