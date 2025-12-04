# So you got a new piece of hardware eh?

## Make configuration
```bash
mkdir machines/<name>
cd machines/<name>
nix flake init --template github:jackinloadup/nixos#machine
# define type of machine
vim modules.nix
# define disk profile
vim hardware-configuration.nix
# Generate hostID
`head -c4 /dev/urandom | od -A none -t x4`
```

## Add relevant secrets

Warning: public key must be in place to allow ragenix to work
```
nix develop github:jackinloadup/nixos#secrets

ssh-keygen -f <name>

mkdir -p secrets/machines/<name>/sshd
cd !$
mkdir -p machines/<name>/sshd
```


## Add new machine
mkdir machines/<name>
cd machines/<name>
nix flake init --template github:jackinloadup/nixos#machine
```
Edit files to align with added machine

