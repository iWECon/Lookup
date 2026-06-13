# Lookup — AGENTS.md

## Overview

Single-target Swift Package Manager library for ergonomic JSON access via `@dynamicMemberLookup`.  
Acceptable source: `Dictionary`, `Array`, `String` (JSON), `Data`, `Encodable`, or any struct/class (mirrored).  
Entrypoint: `Sources/Lookup/Lookup.swift` — the `Lookup` struct.

## Commands

```shell
swift build -v            # build
swift test -v             # run all tests
```

CI runs both on `macos-latest`. No lint, typecheck, or formatter is configured.

## Architecture

| File | Role |
|------|------|
| `Sources/Lookup/Lookup.swift` | Main struct, `@dynamicMemberLookup`, Codable, convert accessors, operators, filter |
| `Sources/Lookup/LookupEnum.swift` | `LookupEnum` protocol — default impl for `Int`/`String` raw-representable enums |
| `Sources/Lookup/LookupRawValue.swift` | `LookupRawValue` protocol — `Date` → `timeIntervalSince1970`, `UUID` → `uuidString` |
| `Sources/Lookup/LookupUnwrap.swift` | `LookupUnwrap` protocol — per-key custom unwrap hook |
| `Sources/Lookup/Mirrors.swift` | `mirrors(reflecting:)` — walks `Mirror` children + superclass chain |

## Testing

- Uses **Swift Testing** framework (`import Testing`, `@Test`, `#expect`), **not XCTest**.
- Single file: `Tests/LookupTests/LookupTests.swift`
- Some tests are platform-gated (`#if os(iOS)` for UIView).
- `Tests/LinuxMain.swift` and `Tests/LookupTests/XCTestManifests.swift` are **stale** (leftover from XCTest era) — ignore.

## Conventions & quirks

- `@unchecked Sendable` on `Lookup` — concurrency correctness not enforced by compiler.
- Dot-separated keys like `"data.list.0"` are supported via `subscript(dynamicMember:)` and string subscript.
- Initialization from `Any` tries String→JSON, Data→JSON, else runtime mirror.
- `Codable` support is full round-trip (encode/decode).
- `LookupRawValue` and `LookupEnum` let types customize their serialized form.
