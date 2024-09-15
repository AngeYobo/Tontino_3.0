{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixpkgs-unstable.tar.gz") {} }:

pkgs.mkShell {
  name = "tontine-dapp-dev-env";

  buildInputs = [
    pkgs.nodejs-18_x  # Node.js 18.x version
    pkgs.pnpm         # pnpm package manager
    pkgs.git          # Git for version control
    pkgs.aiken        # Aiken for smart contract development
  ];

  shellHook = ''
    echo "Welcome to the Tontine DApp development environment!"
  '';
}
