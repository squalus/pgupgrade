{
  description = "PostgreSQL upgrade tool";

  inputs.flake-utils.url = "flake:flake-utils";

  outputs = inputs@{ self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        removeOverride = xs: builtins.removeAttrs xs [ "override" "overrideDerivation" ];
        pkgs = nixpkgs.legacyPackages.${system};
        postgresqlPackages = with pkgs; [
          (postgresql_11.overrideAttrs (old: { passthru = old.passthru // { psqlSchema = "11"; };}))
          postgresql_12
          postgresql_13
          postgresql_14
          postgresql_15
        ];
      in
      {
        packages = removeOverride (pkgs.callPackage ./packages.nix { inherit postgresqlPackages; });
        apps = builtins.listToAttrs (builtins.map (pg: { name = "initdb_${pg.psqlSchema}"; value = { type = "app"; program = "${pg}/bin/initdb"; }; }) postgresqlPackages);
      });
}
