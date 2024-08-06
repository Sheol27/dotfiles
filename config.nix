{
  packageOverrides = pkgs: with pkgs; {
    myPackages = pkgs.buildEnv {
      name = "tools";
      paths = [
        bash-completion
        neovim
        fd
        ripgrep
        fzf
        lazygit
        nodejs
        unzip
        python3.12
        python312Packages.pip
        gcc
      ];
    };
  };
}
