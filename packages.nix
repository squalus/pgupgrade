{ stdenvNoCC
, lib
, makeWrapper
, postgresqlPackages
}:

let
  
  allSchemaVersions = builtins.map (x: x.psqlSchema) postgresqlPackages;

  firstSchemaVersion = builtins.elemAt allSchemaVersions 0;

  lastSchemaVersion = lib.last allSchemaVersions;

  futureSchemaVersions = schemaVersion: builtins.map builtins.toString (lib.range ((lib.strings.toInt schemaVersion) + 1) (lib.strings.toInt lastSchemaVersion));

  postgresqlBySchemaVersion = builtins.listToAttrs (builtins.map (x:
    { name = x.psqlSchema; value = x; }
  ) postgresqlPackages);

  mkPgUpgrade = oldPackage: newPackage: stdenvNoCC.mkDerivation {
    name = "pg_upgrade_${oldPackage.psqlSchema}_${newPackage.psqlSchema}";
    dontUnpack = true;
    dontBuild = true;
    nativeBuildInputs = [ makeWrapper ];
    installPhase = ''
      mkdir -p $out/bin
      makeWrapper ${newPackage}/bin/pg_upgrade $out/bin/pg_upgrade \
        --append-flags "-b ${oldPackage}/bin -B ${newPackage}/bin"
    '';
    meta.mainProgram = "pg_upgrade";
  };

  generateForOld = oldSchemaVersion:
    builtins.map (newSchemaVersion: {
      name = "pg_upgrade_${oldSchemaVersion}_${newSchemaVersion}";
      value = mkPgUpgrade postgresqlBySchemaVersion.${oldSchemaVersion} postgresqlBySchemaVersion.${newSchemaVersion};
    }) (futureSchemaVersions oldSchemaVersion);
      
in

(builtins.listToAttrs (lib.flatten (builtins.map generateForOld allSchemaVersions)))
//
builtins.listToAttrs (builtins.map (x: { name = "postgresql_${x.psqlSchema}"; value = x; } ) postgresqlPackages)

