.PHONY: all test clean

fmt:
	find . -not \( -path .direnv -prune \) -not \( -path dist-newstyle -prune \) -name '*.hs' -type f -exec ormolu --mode inplace {} \;
	find . -not \( -path .direnv -prune \) -not \( -path dist-newstyle -prune \) -name '*.nix' -exec nixfmt {} \;
	-statix check
	-deadnix -f
spin-up-containers-local:
	docker-compose -f resources/docker/local-compose.yaml up -d
dev: fmt
	nix run . -- "./resources/config/run-local.toml"
run-production:
	nix run . -- "./resources/config/run-production.toml"
test:
	nix run .#test
push-cache:
	nix path-info --recursive | cachix push jdb-api
	nix flake --extra-experimental-features 'nix-command flakes' \
		--accept-flake-config archive --json | jq --raw-output '.path, (.inputs | to_entries [] .value.path)' | cachix push jdb-api
push-cache-arm:
	nix --system aarch64-linux path-info --recursive | cachix push jdb-api
	nix --system aarch64-linux flake --extra-experimental-features 'nix-command flakes' \
		--accept-flake-config archive --json | jq --raw-output '.path, (.inputs | to_entries [] .value.path)' | cachix push jdb-api

cabal-release:
	cabal sdist -o .

build:
	nix build --extra-experimental-features 'nix-command flakes' --accept-flake-config --system x86_64-linux
build-arm:
	nix build --extra-experimental-features 'nix-command flakes' --accept-flake-config --system aarch64-linux
