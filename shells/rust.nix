{ pkgs ? import <nixpkgs> { } }:
let
  lib = pkgs.lib;
  overrides = (builtins.fromTOML (builtins.readFile ./rust-toolchain.toml));
  libPath = with pkgs; lib.makeLibraryPath [
    # load external libraries that you need in your rust project here
    pkgs.zlib.out
    pkgs.rustup
    pkgs.rustfmt
    pkgs.cargo-outdated
    pkgs.xorriso
    pkgs.grub2
    pkgs.qemu
    pkgs.python3

    pkgs.vulkan-tools
    pkgs.vulkan-headers
    pkgs.vulkan-loader
    pkgs.vulkan-validation-layers

    # added for bevy
    pkgs.udev
    pkgs.alsa-lib
    #xlibsWrapper
    pkgs.xorg.libXcursor
    pkgs.xorg.libXrandr
    pkgs.xorg.libXi # To use x11 feature
    pkgs.libGL
    pkgs.libxkbcommon
    pkgs.wayland # To use wayland feature

    pkgs.bcc # added for nhealth, not needed if moved to native rust solution which now exits "aya"

    pkgs.heaptrack # memory debugging
  ];
in
# look into for the future in rust projects
  # https://github.com/mdevlamynck/nix-flake-templates/blob/master/bevy/flake.nix
  ## Real-time rust build visualizer
  # https://danielchasehooper.com/posts/syscall-build-snooping/
pkgs.mkShell rec {
  name = "rust";
  #nativeBuildInputs = [
  #  #pkgs.pkgconfig
  #  #pkgs.llvmPackages_latest.bintools # To use lld linker
  #  #pkgs.llvmPackages_latest.lld
  #  #pkgs.llvmPackages_latest.llvm
  #];
  buildInputs = [
    pkgs.clang
    # Replace llvmPackages with llvmPackages_X, where X is the latest LLVM version (at the time of writing, 16)
    pkgs.llvmPackages.bintools
    pkgs.rustup
  ];
  LD_LIBRARY_PATH = libPath;
  RUSTC_VERSION = overrides.toolchain.channel;
  # https://github.com/rust-lang/rust-bindgen#environment-variables
  LIBCLANG_PATH = lib.makeLibraryPath [ pkgs.llvmPackages_latest.libclang.lib ];
  #HISTFILE=toString ./.history;
  shellHook = ''
    export PATH=$PATH:~/.cargo/bin
    export PATH=$PATH:~/.rustup/toolchains/$RUSTC_VERSION-x86_64-unknown-linux-gnu/bin/
  '';
  # Add libvmi precompiled library to rustc search path
  # NOTE: libvmi pulls in xen. xen-4.10 is marked insecure. need new version
  # https://github.com/NixOS/nixpull/121513
  RUSTFLAGS = builtins.map (a: ''-L ${a}/lib'') [
    (pkgs.libvmi.override { xenSupport = false; })
  ];
  # Add libvmi, glibc, clang, glib headers to bindgen search path
  BINDGEN_EXTRA_CLANG_ARGS =
    # Includes with normal include path
    (builtins.map (a: ''-I"${a}/include"'') [
      (pkgs.libvmi.override { xenSupport = false; })
      pkgs.glibc.dev
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
