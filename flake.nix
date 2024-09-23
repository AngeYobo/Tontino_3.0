{
  description = "Tontino DApp Development Environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";  # Reference to the Nix packages
  };

  outputs = { self, nixpkgs }: let
    # Fetch packages for the system architecture
    pkgsForSystem = system: import nixpkgs { inherit system; };
  in {
    devShells = {
      # Define a shell for x86_64-linux
      x86_64-linux = pkgsForSystem "x86_64-linux".mkShell {
        buildInputs = with pkgsForSystem "x86_64-linux"; [
          nodejs-18_x   # Node.js 18.x version
          pnpm          # pnpm package manager
          git           # Git for version control
          aiken         # Aiken for smart contract development
        ];

        shellHook = ''
          echo "Welcome to the Tontino development environment!"
        '';
      };

      # Add any additional system architectures here if needed (e.g., aarch64-linux)
    };
  };
}
