# CLAUDE.md — haybarn-go-bindings (2.0 line)

Guidance for Claude Code (and humans) working in this repository.

## What this repo is

Low-level cgo bindings for **Haybarn** (Query Farm LLC's independent derived
distribution of DuckDB). Hard fork of `duckdb/duckdb-go-bindings`. It links the
Haybarn static engine so the [`haybarn-go`](https://github.com/Query-farm-haybarn/haybarn-go)
driver — and anything else built on these bindings — gets the Haybarn extension
trust root and `haybarn-extensions.query.farm` repositories instead of DuckDB's.

Branches: `haybarn` is the 1.5 line (vendored `lib/<platform>` submodules);
`haybarn-2.0` is the 2.0 line (this file), a clean import of upstream
`v0.20000.0` plus a curated Haybarn stack.

The fork is deliberately a **thin diff** over upstream so it stays rebaseable:

- **Renamed:** the root module path; the native module paths
  (`haybarn-extensions.query.farm/go/libhaybarn/<platform>`); in brood, the
  release asset names (`haybarn-static-libs-*`, `libhaybarn-*.zip`), the
  engine archive `libhaybarn_static.a` / `-lhaybarn_static` and the shared
  `-lhaybarn`; docs/CI.
- **Preserved (do NOT rename):** the `duckdb_` C symbol surface, `duckdb.h`,
  `duckdb_static_extension.h`, `duckdb-release.json`, the internal Go package
  names, and every other `-l` archive name (extensions, capabilities).

## How the native libraries work (2.0)

Upstream moved the static archives out of git (`libhaybarn_static.a` is
~130 MB, over GitHub's file limit). `internal/cmd/brood` packages each
platform's archives from a Haybarn engine release into a Go module, and
`update_libs.yml` uploads them to the origin in `duckdb-release.json`
(`https://haybarn-extensions.query.farm/go`, the extensions R2 bucket under
`go/`), with go-import pages so the go command finds them. The root module
pins them in `go.mod`/`go.sum` and imports one per platform
(`prebuilt_<os>_<arch>.go`, generated).

Verify any staged module carries Haybarn:

```sh
strings -a "$LIB_WORK/native/<platform>/libhaybarn_static.a" | grep haybarn-extensions.query.farm
```

## Rolling to a new engine release

1. Edit `duckdb-release.json`: `version` (new native module version — never
   reuse a published one), `source` (engine commit), `time`, `base_url`
   (the Haybarn release download URL) and the per-platform checksums from the
   release's `SHA256SUMS`.
2. `make update.libs` (package + pin + packaged tests), or run the
   **Update Native Libraries** workflow on a branch (it also publishes).
3. If `duckdb.h` changed, reflect new types/functions in the Go bindings.
4. Once the modules are published and CI is green, tag the root module
   `v0.200NN.x` (Haybarn vX.Y.Z → `v0.XYYZZ.x`; `-rc.N` for engine RCs). Go
   requires bare semver tags, so the org-wide `haybarn-v*` convention does
   **not** apply. Native modules have no git tags.

windows-amd64 is not pinned: the engine release has no MinGW static-libs
archive yet. Re-add it to the manifest (with `static: windows-mingw`) once it
does.

## Trademark

Product name is always "Haybarn". DuckDB appears only descriptively. Keep
`LICENSE` (MIT) verbatim and `NOTICE` accurate.
