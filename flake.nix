{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
  };

  outputs =
    {
      nixpkgs,
      systems,
      ...
    }:
    let
      eachSystem = nixpkgs.lib.genAttrs (import systems);
    in
    {
      devShells = eachSystem (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              xorg.libX11
              xorg.libXrandr
              xorg.libXi
              xorg.libXcursor
              xorg.libXinerama
              xorg.libXxf86vm
              libGL
            ];

            packages = with pkgs; [ pkg-config ];
          };
        }
      );
    };
}
