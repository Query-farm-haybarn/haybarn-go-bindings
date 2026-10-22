#!/usr/bin/env bash
# Seeds brood's download cache with static archives that no public Haybarn
# release carries yet. duckdb-release.json's optional "interim" map names, per
# platform, the GitHub Actions run and artifact that built the pinned archive;
# brood then finds it in LIB_WORK/downloads by its pinned SHA-256 and never
# requests the release URL. Needs gh with a token (GH_TOKEN). Removed from the
# manifest once a release publishes the archive.
# Usage: scripts/seed-interim.sh [repository root]
set -euo pipefail

root=${1:-.}
manifest="$root/duckdb-release.json"
platforms=$(jq -r '.interim // {} | keys[]' "$manifest")
[[ -n "$platforms" ]] || exit 0

# Keep the assignment separate from eval so a brood failure stops the script.
lib_env=$(cd "$root" && GOWORK=off go run ./internal/cmd/brood env)
eval "$lib_env"
work=$LIB_WORK
mkdir -p "$work/downloads"
for platform in $platforms; do
	repo=$(jq -r --arg p "$platform" '.interim[$p].repository' "$manifest")
	run=$(jq -r --arg p "$platform" '.interim[$p].run' "$manifest")
	artifact=$(jq -r --arg p "$platform" '.interim[$p].artifact' "$manifest")
	sha=$(jq -r --arg p "$platform" '.platforms[$p].static_sha256' "$manifest")
	dest="$work/downloads/$sha.tar.gz"
	[[ -f "$dest" ]] && continue
	tmp=$(mktemp -d)
	gh run download "$run" -R "$repo" -n "$artifact" -D "$tmp" >&2
	mv "$tmp"/*.tar.gz "$dest"
	rm -rf "$tmp"
	echo "seeded $platform from $repo run $run ($artifact)" >&2
done
