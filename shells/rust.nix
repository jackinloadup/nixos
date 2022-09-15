{ pkgs ? import <nixpkgs> {} }:

# look into for the future in rust projects
# https://github.com/mdevlamynck/nix-flake-templates/blob/master/bevy/flake.nix
with pkgs; mkShell rec {
    name = "rust";
    nativeBuildInputs = [
      pkgconfig
      llvmPackages_latest.bintools # To use lld linker
      llvmPackages_latest.lld
      llvmPackages_latest.llvm
    ];
    buildInputs = [
      zlib.out
      rustup
      rustfmt
      cargo-outdated
      xorriso
      grub2
      qemu
      python3

      vulkan-tools vulkan-headers vulkan-loader vulkan-validation-layers

      # added for bevy
      udev alsaLib
      xlibsWrapper xorg.libXcursor xorg.libXrandr xorg.libXi # To use x11 feature
      libGL libxkbcommon wayland # To use wayland feature

      bcc # added for nhealth, not needed if moved to native rust solution which now exits "aya"

      heaptrack # memory debugging
    ];
    LD_LIBRARY_PATH = lib.makeLibraryPath buildInputs;
    RUSTC_VERSION = lib.readFile ./rust-toolchain;
    # https://github.com/rust-lang/rust-bindgen#environment-variables
    LIBCLANG_PATH= lib.makeLibraryPath [ llvmPackages_latest.libclang.lib ];
    #HISTFILE=toString ./.history;
    shellHook = ''
      export PATH=$PATH:~/.cargo/bin
      export PATH=$PATH:~/.rustup/toolchains/$RUSTC_VERSION-x86_64-unknown-linux-gnu/bin/
      '';
    # Add libvmi precompiled library to rustc search path
    # NOTE: libvmi pulls in xen. xen-4.10 is marked insecure. need new version
    # https://github.com/NixOS/nixpull/121513
    RUSTFLAGS = (builtins.map (a: ''-L ${a}/lib'') [
      (libvmi.override { xenSupport = false; })
    ]);
    # Add libvmi, glibc, clang, glib headers to bindgen search path
    BINDGEN_EXTRA_CLANG_ARGS = 
    # Includes with normal include path
    (builtins.map (a: ''-I"${a}/include"'') [
      (libvmi.override { xenSupport = false; })
      glibc.dev
    ])
    # Includes with special directory paths
    ++ [
      ''-I"${pkgs.llvmPackages_latest.libclang.lib}/lib/clang/${pkgs.llvmPackages_latest.libclang.version}/include"''
      ''-I"${pkgs.glib.dev}/include/glib-2.0"''
      ''-I${pkgs.glib.out}/lib/glib-2.0/include/''
    ];

    # Certain Rust tools won't work without this
    # This can also be fixed by using oxalica/rust-overlay and specifying the rust-src extension
    # See https://discourse.nixos.org/t/rust-src-not-found-and-other-misadventures-of-developing-rust-on-nixos/11570/3?u=samuela. for more details.
    RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";

  }
