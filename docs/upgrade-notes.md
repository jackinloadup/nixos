# Upgrade Notes

Service-specific upgrade procedures and notes.

## Nextcloud Upgrade

When upgrading Nextcloud major versions, the database needs to be prepared:

1. Connect to host
   ```bash
   ssh marulk
   ```

2. Connect to database
   ```bash
   sudo su - postgres -c psql
   ```

3. Copy database (replace version numbers as needed)
   ```sql
   CREATE DATABASE nextcloud30 WITH TEMPLATE nextcloud29;
   ```

4. Grant access
   ```sql
   GRANT ALL PRIVILEGES ON DATABASE nextcloud30 to nextcloud;
   ```

5. Update `currentDatabase` in `modules/nixos/nextcloud/default.nix`

6. Rebuild and switch
   ```bash
   nixos-rebuild switch --flake .#marulk
   ```

## NixOS Channel Upgrades

When upgrading NixOS versions (e.g., 24.11 to 25.05):

1. Update flake inputs in `flake.nix`:
   - `nixpkgs.url`
   - `nixpkgs-stable.url`
   - `home-manager.url` (match release)
   - `stylix.url` (match release)
   - `nixvim.url` (match release)

2. Update flake lock
   ```bash
   nix flake update
   ```

3. Check for breaking changes in release notes

4. Build and test
   ```bash
   nix flake check
   nixos-rebuild build --flake .#<machine>
   ```

5. Update `system.stateVersion` only for new installs (not existing machines)

## Home Assistant Upgrades

Home Assistant upgrades are typically automatic, but major version changes may require:

1. Backup the configuration
2. Check release notes for breaking changes
3. Rebuild the system
4. Verify integrations still work

## General Upgrade Tips

- Always run `nix flake check` before deploying
- Test in a VM when possible: `nixos-rebuild build-vm --flake .#<machine>`
- Keep the previous generation available for rollback
- Check service logs after upgrade: `journalctl -u <service> -f`
