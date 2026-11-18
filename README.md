# FIFA 14 iOS Local Ultimate Team

Work-in-progress revival for the installed FIFA 14 iOS app on a jailbroken iOS 10.3.3 device.

## Requirements

- Keep all gameplay state and services on the iPhone.
- Do not depend on a PC, LAN host, or EA service.
- Use the PC FUT project only as a reference for protocol and data behavior.
- First pass: get past the retired Origin login and create a persistent local club.
- Later pass: add a local market and a large coin balance using the mobile title's own card data.

## Reverse-engineering notes

- The installed executable is a 32-bit ARMv7 Mach-O.
- The log reaches `accounts.ea.com/connect/upidtoken` and fails with HTTP 400; FUT REST requests are not reached yet.
- The binary contains the Nimble anonymous/origin authenticators and the FUT REST paths.
- The app bundle includes `data/cmn/fut.db` and `data/cmn/fifa.db`; these are EA's custom database format, not SQLite.
- Nimble persistence already has an anonymous ID, but that alone does not pass the legacy authentication flow.

## Build notes

The available Windows LLVM Mach-O linker does not emit ARMv7 outputs. Theos documents an iOS cross-toolchain for Linux that includes Apple's `ld64` and supports ARMv7; the next step is to use that toolchain in a private GitHub Actions build and produce an installable package.

No tweak or package is implemented yet. This repository will track source, reverse-engineering notes, and reproducible build artifacts only; proprietary FIFA app files and user logs will not be committed.
