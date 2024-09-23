{
  description = "Tontino DApp Development Environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";  # Fetch from nixpkgs unstable
  };

  outputs = { self, nixpkgs }:
  let
    # Define the package set
    pkgs = import nixpkgs {
      system = "x86_64-linux";
    };
  in {
    devShells = {
      # Define dev shell for x86_64-linux
      x86_64-linux = pkgs.mkShell {
        buildInputs = with pkgs; [
          nodejs-18_x
          pnpm
          git
          aiken
        ];

        shellHook = ''
          echo "Welcome to the Tontino development environment!"
        '';
      };
    };
  };
}
