{
  description = "Tontino DApp Development Environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }: let
    pkgs = import nixpkgs {
      system = "x86_64-linux"; # Your system architecture
    };
  in {
    # Define development shells for different platforms
    devShells = {
      x86_64-linux = pkgs.mkShell {
        buildInputs = with pkgs; [
          nodejs-18_x   # Node.js 18.x version
          pnpm          # pnpm package manager
          git           # Git for version control
          aiken         # Aiken for smart contract development
        ];

        shellHook = ''
          echo "Welcome to the Tontino development environment!"
        '';
      };
    };
  };
}
