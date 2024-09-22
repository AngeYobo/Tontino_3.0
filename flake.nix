{
  description = "Tontino DApp Development Environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";  # Use the unstable channel
  };

  outputs = { self, nixpkgs }:
    {
      devShells = {
        default = nixpkgs.lib.mkShell {
          buildInputs = with nixpkgs; [
            nodejs-18_x      # Node.js 18.x version
            pnpm             # pnpm package manager
            git              # Git for version control
            aiken            # Aiken for smart contract development
          ];

          shellHook = ''
            echo "Welcome to the Tontino development environment!"
          '';
        };
      };
    };
}
