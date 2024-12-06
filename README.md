# godot-toolchain.nix

WIP Godot 4 toolchain with Neovim integration with Nix Flakes.

## Godot External Editor Configuration

1. Launch Godot from terminal via `nohup godot4 &`
1. In Godot, go to Editor > Editor Settings... > (General Tab) > Text Editor > External
1. Check "Use External Editor"
1. Set Exec Path to `godot_nvim`, which is a script generated by the flake that wraps `nvim`
1. Set Exec Flags to `"{file}" "{line},{col}"`

## Usage

Since Godot projects are probably going to be quite large in terms of file size, and using
a Nix `devShell` requires copying the whole repo to the Nix store, the recommended way of
using this flake is to use it with [direnv](https://github.com/direnv/direnv) and
[nix-direnv](https://github.com/nix-community/nix-direnv), and use this flake to manage the
toolchain as an external repo. You can do this with a script like the following as your `.envrc`:

```bash
#!/usr/bin/env bash

set -e
set -o pipefail

# NOTE: This script is structured like this (pulling another repo for the toolchain flake)
# because Nix devShells require copying the entire repo to the Nix store. Since this is a
# Godot projet, that would be a big oof. Instead, we clone a separate toolchain repo and
# copy that repo to the Nix store instead.

# shellcheck disable=2155
export GITROOT=$(git rev-parse --show-toplevel)

echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo "@@ Pulling toolchain...  @@"
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@"

deps_path="$GITROOT/.direnv"
toolchain_dir="$deps_path/godot-toolchain"
if [ -d "$toolchain_dir" ]; then
  pushd "$toolchain_dir"
  git pull
  popd
else
  mkdir -p "$deps_path"
  pushd "$deps_path"
  git clone "git@github.com:mrjones2014/godot-toolchain.nix.git"
  popd
fi

use flake "$GITROOT/.direnv/godot-toolchain/.#default" -L
```
