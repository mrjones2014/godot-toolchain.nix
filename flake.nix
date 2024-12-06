{
  description = "Godot flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        shellPackages = with pkgs; [ godot_4 gdtoolkit_4 ];
      in {
        devShells.default = pkgs.mkShell { buildInputs = shellPackages; };
        devShells.wezterm-and-nvim = let
          godot_nvim = pkgs.writeShellScript "godot_nvim" ''
            #!${pkgs.bash}/bin/bash

            server_path="$HOME/.cache/nvim/godot-server.sock";

            start_server() {
              wezterm -e $(which nvim) --listen "$server_path"
            }

            open_file_in_remote_nvim() {
              # escape characters that nvim won't
              filename=$(printf %q "$1")
              wezterm -e $(which nvim) --server "$server_path" --remote-send "<C-\><C-n>:n $filename<CR>:call cursor($2)<CR>"
            }
          '';
        in pkgs.mkShell {
          buildInputs = shellPackages ++ [
            pkgs.coreutils # make sure you can `nohup godot &`
            godot_nvim
          ];
          shellHook = ''
            echo "You can launch Godot GUI via \`nohup godot4 &\`"
          '';
        };
      });
}
