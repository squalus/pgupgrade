## pgupgrade

Convenience commands to upgrade PostgreSQL databases.

Refer to pgupgrade documentation for details: https://www.postgresql.org/docs/current/pgupgrade.html

### Example

To upgrade a database from PostgreSQL 13 to 15:

```console
nix run github:squalus/pgupgrade#initdb_15 -- ./new_data_dir [other options...]
nix run github:squalus/pgupgrade#pg_upgrade_13_15 -- -d ./old_data_dir -D ./new_data_dir [other options...]
```

### Outputs

- App: initdb for each schema version. initdb_11, initdb_12, etc.
- App: pg_upgrade_old_new for each schema version. pg_upgrade_11_12, pg_upgrade_11_13, etc.
- Package: postgresql_version for each schema version. postgresql_11, postgresql_12, etc.
