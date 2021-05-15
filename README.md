# Docker images for Rust cross-compilation

This project provides Docker images for cross-compiling your Rust projects.
Each image can be used on a Linux or macOS host and is dedicated to
cross-compiling to some target.

The Rust release is indicated by a tag attached to the image. For instance,

    u0xy/linux-armv5:rust-1.42.0

The images are derived from those of the awesome [Dockcross
project](https://github.com/dockcross/dockcross), simply adding `rustup` with
the "minimal" profile, `cargo`, and the cross-compile target configured and
ready to go.

All available targets are listed in the [table](#targets-table) below.

This was tested to run on linux-amd64, macOS with Docker for Mac on both Intel
and M1 platforms.


## Usage

Ensure your user has access to a running docker daemon, and determine your
cross-compiling target.


### Initial configuration

Assuming you want to cross-compile for `aarch64-unknown-linux-gnu`, execute the following in
order to create a bridging script.

    docker run --rm u0xy/linux-arm64 > ./xrs-aarch64-unknown-linux-gnu
    chmod u+x ./xrs-aarch64-unknown-linux-gnu

This script will act as a transparent bridge to the cross-compiling toolchain.
You can move it to any location.

There is nothing special about the name of the script, I just use it to remind
me of the [target
triple](https://doc.rust-lang.org/nightly/rustc/platform-support.html) brought
by the `u0xy/linux-arm64` image.

If you have other targets to cross-compile to, you can prepare other bridging
scripts, like for instance

    docker run --rm u0xy/linux-arm64-musl > ./xrs-aarch64-unknown-linux-musl


### How to cross-compile a Cargo project

Let's cross-compile a simple Cargo project such as

    cargo init --bin hello && cd hello

If you build it on a Intel-based macOS:

    cargo build --release

it yields the following `target` tree structure

    target
    ├── CACHEDIR.TAG
    └── release
        ├── build
        ├── deps
        │   ├── hello-2adbcecc085a4b9a
        │   └── hello-2adbcecc085a4b9a.d
        ├── examples
        ├── hello      <---- binary for your host platform
        ├── hello.d
        └── incremental

Of course, you can check the type of executable with

    $ file target/release/hello
    target/release/hello: Mach-O 64-bit executable x86_64

In order to cross-compile, you simply prepend a bridging script such as the one
created in the Initial configuration section above (that was for ARM64),

    /path/to/xrs-aarch64-unknown-linux-gnu cargo build --release

The above line adds the cross-compiled target to the `target` folder:

    target
    ├── CACHEDIR.TAG
    ├── aarch64-unknown-linux-gnu
    │   ├── CACHEDIR.TAG
    │   └── release
    │       ├── build
    │       ├── deps
    │       │   ├── hello-e2d5068318560224
    │       │   └── hello-e2d5068318560224.d
    │       ├── examples
    │       ├── hello
    │       ├── hello.d
    │       └── incremental
    └── release
        ├── build
        ├── deps
        │   ├── hello-2adbcecc085a4b9a
        │   └── hello-2adbcecc085a4b9a.d
        ├── examples
        ├── hello
        ├── hello.d
        └── incremental

You can check the resulting executable

    $ file target/aarch64-unknown-linux-gnu/release/hello
    target/aarch64-unknown-linux-gnu/release/hello: ELF 64-bit LSB pie executable, ARM aarch64, version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux-aarch64.so.1, stripped

As a reminder, this target is `aarch64-unknown-linux-gnu` because because the
bridging script uses the Docker image `u0xy/linux-arm64` which brings support
for `aarch64`. Other available targets are listed in a [table](#targets-table)
down below.

Behind the scenes, the current directory was mounted as a volume in a temporary
Docker container, and your Cargo project was cross-compiled using the target
configured in the Docker image.

Let's give an additional example; if you also have created the bridging script
for `aarch64-unknown-linux-musl`, and you run

    /path/to/xrs-aarch64-unknown-linux-musl cargo build --release

then the final `target` tree structure is

    target
    ├── CACHEDIR.TAG
    ├── aarch64-unknown-linux-gnu
    │   ├── CACHEDIR.TAG
    │   └── release
    │       ├── build
    │       ├── deps
    │       │   ├── hello-e2d5068318560224
    │       │   └── hello-e2d5068318560224.d
    │       ├── examples
    │       ├── hello
    │       ├── hello.d
    │       └── incremental
    ├── aarch64-unknown-linux-musl
    │   ├── CACHEDIR.TAG
    │   └── release
    │       ├── build
    │       ├── deps
    │       │   ├── hello-0df44d73016fd116
    │       │   └── hello-0df44d73016fd116.d
    │       ├── examples
    │       ├── hello
    │       ├── hello.d
    │       └── incremental
    └── release
        ├── build
        ├── deps
        │   ├── hello-2adbcecc085a4b9a
        │   └── hello-2adbcecc085a4b9a.d
        ├── examples
        ├── hello
        ├── hello.d
        └── incremental

And that's all.


## <a name="targets-table"></a>Available cross-compilation targets

Each image in this list exists for most Rust versions > 1.42.0. Check the
corresponding DockerHub page.


| Image name                                                                | target triple                  | dockcross base image        |
| ---                                                                       | ---                            | ---                         |
| [u0xy/linux-arm64](https://hub.docker.com/r/u0xy/linux-arm64)             | aarch64-unknown-linux-gnu      | dockcross/linux-arm64       |
| [u0xy/linux-arm64-musl](https://hub.docker.com/r/u0xy/linux-arm64-musl)   | aarch64-unknown-linux-musl     | dockcross/linux-arm64-musl  |
| [u0xy/linux-armv5-musl](https://hub.docker.com/r/u0xy/linux-armv5-musl)   | armv5te-unknown-linux-musleabi | dockcross/linux-armv5-musl  |
| [u0xy/linux-armv6-musl](https://hub.docker.com/r/u0xy/linux-armv6-musl)   | arm-unknown-linux-musleabihf   | dockcross/linux-armv6-musl  |
| [u0xy/linux-armv7l-musl](https://hub.docker.com/r/u0xy/linux-armv7l-musl) | armv7-unknown-linux-musleabihf | dockcross/linux-armv7l-musl |

All credits to the great [Dockcross project](https://github.com/dockcross/dockcross).

Below are currently unsupported images. You can test them, but `cargo` won't
link due to a linker search path issue I'm not yet capable of fixing.
Contributions are welcome!

| Image name                                                                | target triple                  | dockcross base image        |
| ---                                                                       | ---                            | ---                         |
| [u0xy/linux-armv5](https://hub.docker.com/r/u0xy/linux-armv5)             | armv5te-unknown-linux-gnueabi  | dockcross/linux-armv5       |
| [u0xy/linux-armv6](https://hub.docker.com/r/u0xy/linux-armv6)             | arm-unknown-linux-gnueabihf    | dockcross/linux-armv6       |
| [u0xy/linux-armv7](https://hub.docker.com/r/u0xy/linux-armv7)             | armv7-unknown-linux-gnueabihf  | dockcross/linux-armv7       |
| [u0xy/linux-mips](https://hub.docker.com/r/u0xy/linux-mips)               | mips-unknown-linux-gnu         | dockcross/linux-mips        |
| [u0xy/linux-mipsel](https://hub.docker.com/r/u0xy/linux-mipsel)           | mipsel-unknown-linux-gnu       | dockcross/linux-mipsel      |


## Building the image

If you want to derive this project, rebuild the images, etc, here is how to
build the images by yourself. If necessary, update the Rust version declared in
the `Makefile`:

    make linux-arm64 linux-arm64-musl ...

If you want to build an image with a specific version of Rust:

    make RUST_VERSION=1.42.0 linux-arm64


### Minimum versions

Here are the minimum Rust version per supported image (compilation will fail otherwise):

- `linux-arm64`: `1.41.0`
- `linux-arm64-musl`: `1.48.0`
- `linux-armv5-musl`: `1.30.0`
- `linux-armv6-musl`: `1.30.0`
- `linux-armv7l-musl`: `1.30.0`
