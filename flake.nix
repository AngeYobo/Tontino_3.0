{
  description = "Tontino DApp Development Environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";  # Use the unstable channel
  };

  outputs = { self, nixpkgs }: {
    devShells = {
      x86_64-linux = nixpkgs.mkDevShell {
        packages = [
          nixpkgs.nodejs-18_x      # Node.js 18.x version
          nixpkgs.pnpm             # pnpm package manager
          nixpkgs.git              # Git for version control
          nixpkgs.aiken            # Aiken for smart contract development
        ];

        shellHook = ''
          echo "Welcome to the Tontino development environment!"
        '';
      };
    };
  };
}
