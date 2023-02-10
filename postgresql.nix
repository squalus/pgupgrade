{ postgresql_11
, postgresql_12
, postgresql_13
, postgresql_14
, postgresql_15
}:
[
  (postgresql_11.overrideAttrs (old: { passthru = old.passthru // { psqlSchema = "11"; };}))
  postgresql_12
  postgresql_13
  postgresql_14
  postgresql_15
]
