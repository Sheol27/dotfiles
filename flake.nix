{
  description = "Flake for remote development";

  inputs = {
    nixpkgs.url    = "github:NixOS/nixpkgs/72841a4a8761d1aed92ef6169a636872c986c76d";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs  = import nixpkgs { inherit system; };
        shell = pkgs.mkShell {
          name = "dev";
          buildInputs = with pkgs; [
            neovim
            ripgrep
            fd
            fzf
            lazygit
            nodejs
            unzip
            python3
          ];
        };
      in {
        devShells.default = shell;
        defaultPackage    = shell;
        packages.default  = shell;
      }
    );
}

