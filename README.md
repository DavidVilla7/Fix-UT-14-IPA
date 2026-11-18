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

- A pinned Theos/Linux ARMv7 toolchain successfully linked a minimal ARMv7 Mach-O dynamic library in GitHub Actions. The artifact was checked with `file` and reported `Mach-O armv7 dynamically linked shared library`.
- The Theos-patched 9.3 and 10.3 SDK archives contain simulator architecture metadata; the 9.3 link failed on a missing `liblaunch.dylib`. The smoke build now uses an older device SDK archive with traditional device libraries.
- The smoke artifact is only proof of a working linker path. It is not a FIFA tweak and has not been installed on the phone.
- Next build step is a small in-process hook to replace the dead Origin login result with a locally persisted club identity; no server will run on a separate computer.

Theos' Linux guide recommends SDK 9.2 or earlier: https://github.com/theos/theos/wiki/Installation. The upstream SDK issue records the simulator-stub problem: https://github.com/theos/sdks/issues/56. A recent ARMv7 device build documents the legacy SDK/ld64 approach: https://openrevive.org/guides/theos-ios6-apple-silicon.html.

No tweak or package is implemented yet. This repository tracks source, reverse-engineering notes, and reproducible build artifacts only; proprietary FIFA app files and user logs will not be committed.
