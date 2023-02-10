{
  description = "PostgreSQL upgrade tool";

  inputs.flake-utils.url = "flake:flake-utils";

  outputs = inputs@{ self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        removeOverride = xs: builtins.removeAttrs xs [ "override" "overrideDerivation" ];
        pkgs = nixpkgs.legacyPackages.${system};
        postgresqlPackages = pkgs.callPackage ./postgresql.nix {};
      in
      {
        packages = removeOverride (pkgs.callPackage ./packages.nix { inherit postgresqlPackages; });
        apps = builtins.listToAttrs (builtins.map (pg: { name = "initdb_${pg.psqlSchema}"; value = { type = "app"; program = "${pg}/bin/initdb"; }; }) postgresqlPackages);
        
      });
}
