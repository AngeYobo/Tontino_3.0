{
  description = "Tontino DApp Development Environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";  # A stable version
  };

  outputs = { self, nixpkgs }: let
    # Define a reusable function for fetching pkgs for the target system
    pkgsForSystem = system: import nixpkgs {
      inherit system;
    };
  in {
    # Define development shells for different systems
    devShells = {
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

      # Optional: If you are targeting additional platforms (e.g., aarch64, Darwin):
      # aarch64-linux = pkgsForSystem "aarch64-linux".mkShell {
      #   buildInputs = with pkgsForSystem "aarch64-linux"; [
      #     nodejs-18_x
      #     pnpm
      #     git
      #     aiken
      #   ];
      # };
    };
  };
}
