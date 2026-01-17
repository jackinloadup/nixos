# Secrets Management

This repository uses [ragenix](https://github.com/yaxitech/ragenix) (a Rust implementation of agenix) for managing encrypted secrets.

## How It Works

1. Secrets are encrypted with age using SSH public keys
2. Each machine has its own SSH host key for decryption
3. Secrets are decrypted at boot time and placed in `/run/agenix/`
4. Only machines with the corresponding private key can decrypt their secrets

## Directory Structure

```
secrets/
├── machines/           # Per-machine secrets
│   └── <hostname>/
│       └── sshd/       # SSH host keys (encrypted)
├── services/           # Service credentials
│   ├── vaultwarden/
│   ├── syncthing/
│   └── ...
├── system/             # System-level secrets
└── users/              # User passwords and keys
    └── <username>/
        └── hashed-password.age
```

## Key Files

| File | Purpose |
|------|---------|
| `secrets.nix` | Defines which keys can decrypt which secrets |
| `nixos-secrets.nix` | Declares secrets for NixOS (age.secrets) |
| `shells/secrets.nix` | Development shell with ragenix |

## Working with Secrets

### Enter the secrets shell

```bash
nix develop .#secrets
# or with direnv
cd shells && direnv allow
```

### View/Edit a secret

```bash
ragenix -e secrets/users/lriutzel/hashed-password.age
```

### Re-encrypt all secrets

After adding a new machine or changing keys:

```bash
./scripts/encrypt.sh
```

### Add a secret for a new machine

1. Generate SSH host keys for the machine
2. Add the public key to `secrets.nix`
3. Create the secret file
4. Re-encrypt with `./scripts/encrypt.sh`

## Adding a New Machine's Secrets

```bash
# 1. Create directory structure
mkdir -p secrets/machines/<hostname>/sshd

# 2. Generate host keys (or copy from existing machine)
ssh-keygen -t ed25519 -f secrets/machines/<hostname>/sshd/ssh_host_ed25519_key -N ""

# 3. Add public key to secrets.nix
# Edit secrets.nix and add the new machine's public key

# 4. Re-encrypt all secrets
./scripts/encrypt.sh
```

## Secret Declaration (nixos-secrets.nix)

```nix
{ config, ... }:
{
  age.secrets = {
    lriutzel-hashed-password = {
      file = ./secrets/users/lriutzel/hashed-password.age;
      owner = "root";
      group = "root";
      mode = "400";
    };

    vaultwarden-env = {
      file = ./secrets/services/vaultwarden/env.age;
      owner = "vaultwarden";
    };
  };
}
```

## Using Secrets in Configuration

```nix
{ config, ... }:
{
  users.users.lriutzel = {
    hashedPasswordFile = config.age.secrets.lriutzel-hashed-password.path;
  };

  services.vaultwarden = {
    environmentFile = config.age.secrets.vaultwarden-env.path;
  };
}
```

## Troubleshooting

### Secret not decrypting
- Verify the machine's SSH host key is in `secrets.nix`
- Check that `./scripts/encrypt.sh` was run after adding the key
- Ensure the machine has its private key at `/etc/ssh/ssh_host_ed25519_key`

### Permission denied
- Check the `owner`, `group`, and `mode` in the secret declaration
- Verify the service user exists before the secret is created

### Adding secrets for a new service
1. Create the secret file: `ragenix -e secrets/services/<name>/secret.age`
2. Declare it in `nixos-secrets.nix`
3. Reference it in your service configuration
