# CLAUDE.md — haybarn-go-bindings

Guidance for Claude Code (and humans) working in this repository.

## What this repo is

Low-level cgo bindings for **Haybarn** (Query Farm LLC's independent derived
distribution of DuckDB). Hard fork of `duckdb/duckdb-go-bindings`. It links the
Haybarn static engine so the [`haybarn-go`](https://github.com/Query-farm-haybarn/haybarn-go)
driver — and anything else built on these bindings — gets the Haybarn extension
trust root and `haybarn-extensions.query.farm` repositories instead of DuckDB's.

The fork is deliberately a **thin diff** over upstream so it stays rebaseable:

- **Renamed:** Go module paths (root + 5 `lib/<platform>` submodules); the
  `-lduckdb_static` → `-lhaybarn_static` cgo flag (the one renamed archive); the
  `Makefile` fetch source; docs/CI.
- **Preserved (do NOT rename):** the `duckdb_` C symbol surface, `duckdb.h`, the
  internal Go package names (`duckdb_go_bindings`, `duckdb_go_bindings_platform`,
  `include`), and every other `-l` archive name (extensions + third-party).
  Haybarn is ABI-compatible with upstream DuckDB by design.

## Where "Haybarn-ness" comes from

It is compiled **inside `libhaybarn_static.a`**, not in any Go source here. That
archive (built by `Query-farm-haybarn/haybarn`'s `BundleStaticLibs` workflow and
attached to its GitHub Release inside `static-libs-*.zip`) embeds the single
Haybarn RSA trust root and the core/community repo URLs. Verify any fetched
archive with:

```sh
strings -a lib/<platform>/libhaybarn_static.a | grep haybarn-extensions.query.farm
```

## Updating the vendored binaries (the main maintenance task)

The `.a` files are **not built here** — they are fetched from a Haybarn engine
release. After a new Haybarn engine release publishes its `static-libs-*.zip`:

1. Set `HAYBARN_VERSION` (and `HAYBARN_REPO`) in the `Makefile` to the release tag.
2. Run the `Fetch and Push Libs` workflow (`.github/workflows/fetch.yml`), or
   locally per platform:
   ```sh
   make fetch.static.libs PLATFORM=darwin-arm64 FILENAME=static-libs-osx-arm64 COPY_HEADER=1
   make fetch.static.libs PLATFORM=darwin-amd64 FILENAME=static-libs-osx-amd64
   make fetch.static.libs PLATFORM=linux-amd64  FILENAME=static-libs-linux-amd64
   make fetch.static.libs PLATFORM=linux-arm64  FILENAME=static-libs-linux-arm64
   make fetch.static.libs PLATFORM=windows-amd64 FILENAME=static-libs-windows-mingw
   ```
3. If `duckdb.h` changed, reflect new types/functions in the Go bindings.
4. Open a PR; once green, tag with `scripts/release.sh`.

## Versioning

Bare semver tags (required by the Go module proxy) mirroring upstream's scheme,
which encodes the engine version: DuckDB/Haybarn `v1.5.4` → bindings `v0.10504.x`.
Per-platform submodules tag as `lib/<platform>/v0.10504.x`; the root as
`v0.10504.x`. Use `-rc.N` pre-release suffixes to track engine release
candidates. NOTE: the org-wide `haybarn-v*` tag convention does **not** apply
here — Go requires bare `vMAJOR.MINOR.PATCH` tags.

## Trademark

Product name is always "Haybarn". DuckDB appears only descriptively. Keep
`LICENSE` (MIT) verbatim and `NOTICE` accurate. See the Haybarn engine repo's
trademark rules.
