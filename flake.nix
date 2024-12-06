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
            server_startup_delay=0.1 # delay in SECONDS, may need adjusted based on your nvim startup time

            start_server() {
              wezterm -e $(which nvim) --listen "$server_path"
            }

            open_file_in_remote_nvim() {
              # escape characters that nvim won't
              filename=$(printf %q "$1")
              wezterm -e $(which nvim) --server "$server_path" --remote-send "<C-\><C-n>:n $filename<CR>:call cursor($2)<CR>"
            }

            if ! [ -e "$server_path" ]; then
              # - start server FIRST then open the file
              start_server &
              sleep $server_startup_delay # - wait for the server to start 
              open_file_in_remote_nvim "$1" "$2"
            else
              open_file_in_remote_nvim "$1" "$2"
            fi
          '';
        in pkgs.mkShell {
          buildInputs = shellPackages ++ [
            pkgs.coreutils # make sure you can `nohup godot &`
            godot_nvim
          ];
        };
      });
}
