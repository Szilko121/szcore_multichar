# szcore_multichar

**SzCore Framework 1.4.0-rc1** · by **SzCode**

Multi-character selection and character creation frontend backed by SzCore character lifecycle.

## Installation

```bash
git clone https://github.com/Szilko121/szcore_multichar.git resources/[szcore]/szcore_multichar
```

Then start the resource after its dependencies:

```cfg
ensure szcore_multichar
```

**Declared dependencies:** `szcore`

For a complete server installation, use [`SzCore-Recipe`](https://github.com/Szilko121/SzCore-Recipe).

## What this resource provides

Multi-character selection and character creation frontend backed by SzCore character lifecycle.

The resource is designed to use SzCore's server-authoritative APIs and modular startup model. Do not rename the resource directory: other resources may reference it by its canonical name.

## Public exports detected

- No named export detected by the documentation scanner.

See [`docs/API.md`](docs/API.md) for the generated reference and the central [`SzCore-Framework`](https://github.com/Szilko121/SzCore-Framework) documentation for framework-wide API contracts.

## Network events detected

- No network event detected by the documentation scanner.

Network events are implementation surfaces, not automatically trusted public APIs. Server handlers validate state/permissions where applicable. Prefer documented exports for third-party integrations.

## Commands

- No direct `RegisterCommand` entry detected.

## Key mappings

- No direct key mapping detected.

## Database

- This resource does not directly reference an SzCore SQL table, or uses core storage APIs instead.

Fresh-install schema and migrations are owned by the `szcore` core resource unless this repository contains its own SQL file.

## Configuration

Read [`docs/CONFIGURATION.md`](docs/CONFIGURATION.md). Configuration is intentionally resource-local so optional modules can be restarted and maintained independently.

## Development

- Keep server-authoritative mutations on the server.
- Validate source, distance, permission and entity ownership for sensitive network actions.
- Prefer SzCore callbacks/exports over polling.
- Avoid permanent tight loops unless a FiveM native explicitly requires per-frame application.
- Keep backwards compatibility changes explicit and documented.

## Version

Current release candidate: **1.4.0-rc1**.

This is an RC build. Validate it on a staging FXServer/OneSync/MariaDB environment before production rollout.
