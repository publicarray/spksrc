PKG_NAME = bitwarden_rs
PKG_VERS = 1.13.1
PKG_EXT = tar.gz
PKG_DIST_NAME = $(PKG_VERS).$(PKG_EXT)
PKG_DIST_SITE = https://github.com/dani-garcia/bitwarden_rs/archive
PKG_DIR = $(PKG_VERS)
PKG_DIST_FILE = $(PKG_NAME)-$(PKG_VERS).$(PKG_EXT)

DEPENDS = native/rust cross/openssl cross/sqlite
# openssl-sys = 0.9.53 make arch-ipq806x-1.2
HOMEPAGE = https://github.com/dani-garcia/bitwarden_rs
COMMENT  = This is a Bitwarden server API implementation written in Rust compatible with upstream Bitwarden clients*, perfect for self-hosted deployment where running the official resource-heavy service might not be ideal.
LICENSE  = GNUv3

CONFIGURE_TARGET = nop
COMPILE_TARGET = bitwarden_rs_compile
INSTALL_TARGET = nop

include ../../mk/spksrc.cross-cc.mk
UNSUPPORTED_ARCHS = $(PPC_ARCHES)

ifeq ($(findstring $(ARCH),$(ARM5_ARCHES)),$(ARCH))
TAEGET_TRIPLE = armv5te-unknown-linux-gnueabi
endif
ifeq ($(findstring $(ARCH),$(ARM7_ARCHES)),$(ARCH))
TAEGET_TRIPLE = armv7-unknown-linux-gnueabihf
endif
ifeq ($(findstring $(ARCH),$(ARM8_ARCHES)),$(ARCH))
TAEGET_TRIPLE = armv7-unknown-linux-gnueabihf
endif
ifeq ($(findstring $(ARCH),$(x86_ARCHES)),$(ARCH))
TAEGET_TRIPLE = i686-unknown-linux-gnu
endif
ifeq ($(findstring $(ARCH),$(x64_ARCHES)),$(ARCH))
TAEGET_TRIPLE = x86_64-unknown-linux-gnu
endif
ifeq ($(findstring $(ARCH),$(PPC_ARCHES)),$(ARCH))
TAEGET_TRIPLE = powerpc-unknown-linux-gnu
endif
ifeq ($(TAEGET_TRIPLE),)
$(error Unsupported ARCH $(ARCH))
endif

DB=sqlite

ENV += RUSTUP_HOME=/spksrc/.rustup
ENV += CARGO_HOME=/spksrc/.cargo
ENV += CROSS_COMPILE="1"
ENV += TARGET_CC=$$CC
CARGO_BIN = /spksrc/.cargo/bin

.PHONY: bitwarden_rs_compile
bitwarden_rs_compile:
	$(RUN) $(CARGO_BIN)/rustup target add $(TAEGET_TRIPLE)
	$(RUN) $(CARGO_BIN)/cargo build --features $(DB) --release --target=$(TAEGET_TRIPLE)
