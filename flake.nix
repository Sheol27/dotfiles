{
  description = "My development shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/72841a4a8761d1aed92ef6169a636872c986c76d";  # pin to exact commit
  };

  outputs = { self, nixpkgs }:
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
    in {
      devShells.default = pkgs.mkShell {
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
    };
}

