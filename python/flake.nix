{
  description = "A Nix-flake-based Python development environment";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    mach-nix.url = "github:/DavHau/mach-nix";
    nixpkgs.url = "github:NixOS/nixpkgs";
  };

  outputs =
    { self
    , flake-utils
    , mach-nix
    , nixpkgs
    }:
    flake-utils.lib.eachDefaultSystem (system:
    let
      overlays = [
        (self: super: {
          machNix = mach-nix.defaultPackage.${system};
          python = super.python312;
        })
      ];

      pkgs = import nixpkgs { inherit overlays system; };
    in
    {
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [ python machNix virtualenv ] ++
          (with pkgs.python311Packages; [ pip ]);

        shellHook = ''
          echo "`${pkgs.python}/bin/python --version` is Ready"
          echo "`pip --version | cut -f1,2 -d" "` is Ready"
        '';
      };
    });
}