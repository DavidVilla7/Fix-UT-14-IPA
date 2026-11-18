# FIFA 14 iOS Local Ultimate Team

Work-in-progress local revival for the installed FIFA 14 iOS app on a jailbroken iOS 10.3.3 device.

## Goal

- Keep gameplay state and services on the iPhone.
- Do not depend on a PC, LAN host, or EA service.
- Use the PC FUT project only as a protocol/data reference.
- First milestone: bypass the retired Origin/anonymous-login gate and preserve a local club.
- Later milestone: implement an on-device market and local coin/card inventory using FIFA 14's own mobile data.

## Reverse-engineering notes

- The supplied FIFA14 executable is a 32-bit ARMv7 Mach-O. The universal tweak contains ARMv7 and ARM64 slices so it can inject into the correct process on 64-bit hardware.
- The supplied Nimble.log reaches `accounts.ea.com/connect/upidtoken`; the retired endpoint responds HTTP 400 before any FUT REST requests are reached.
- Objective-C metadata in the supplied executable identifies `NimbleAuthenticatorAnonymous`, `NimbleIdentityAuthenticatorBase`, `NimbleOriginCore`, and `NimbleOriginWebController`. The previous 0.6 package mistakenly targeted a nonexistent `NimbleAuthenticatorOrigin` class.
- The 0.7 experiment suppresses the anonymous UPID login request, reports a local authenticated state, and adds low-level startup logging to app Documents plus fallback log paths. The device runtime result is still unverified.
- The app includes `data/cmn/fut.db` and `data/cmn/fifa.db`; these are EA custom database formats, not SQLite.
- The PC FUT project is a separate service/client restoration. This iOS project does not run or require that PC server.

## Build and release

The GitHub Actions workflow builds a universal ARMv7/ARM64 tweak using a pinned Theos/Linux toolchain, verifies the package architecture, and can publish an experimental pre-release when manually dispatched.

No release should be treated as a working revival until its runtime behavior has been verified on-device. The next device check is whether version 0.7 creates `Documents/FIFA14LocalUT.log` and whether the Origin screen advances. If it does not, fallback log output and runtime selector checks are included to separate Substrate injection failure from hook failure.

## Limitations

This project is experimental. It does not yet implement a local FUT service, a working market, a generated club save, or market inventory. It does not include proprietary FIFA app files or user logs.

Theos toolchain context: https://github.com/theos/theos/wiki/Installation
