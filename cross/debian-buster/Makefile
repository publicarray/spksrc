PKG_NAME = debian-$(PKG_VERS)
PKG_VERS = buster

DISTRIB_DIR = $(BASE_DISTRIB_DIR)/$(PKG_NAME)-$(PKG_DIST_ARCH)

PKG_EXT = tar.xz
PKG_DIST_NAME = rootfs.$(PKG_EXT)
PKG_DIST_SITE = https://raw.githubusercontent.com/debuerreotype/docker-debian-artifacts/$(PKG_SHA)/$(PKG_VERS)/slim

DEPENDS =

UNSUPPORTED_ARCHS = $(PPC_ARCHS) $(ARMv7L_ARCHS)

HOMEPAGE = https://www.debian.org/
COMMENT  = Debian base image
LICENSE  = GPLv3

CHECKSUM_TARGET = debian_checksum
INSTALL_TARGET = debian_install

EXTRACT_PATH=$(WORK_DIR)/rootfs

include ../../mk/spksrc.archs.mk

PKG_DIST_ARCH = x64
PKG_SHA = e8e26161d828d035f0eb2f06a57c7972375a769a
ifeq ($(findstring $(ARCH),$(ARMv7_ARCHS)),$(ARCH))
PKG_DIST_ARCH = arm
PKG_SHA = dac1fb21147a9d20e3234a90a83269c9ea02588e
else ifeq ($(findstring $(ARCH),$(ARMv8_ARCHS)),$(ARCH))
PKG_DIST_ARCH = arm64
PKG_SHA = 0cb2f80d1b5fc71d626a65a80bde83dff6be6278
else ifeq ($(findstring $(ARCH),$(i686_ARCHS)),$(ARCH))
PKG_DIST_ARCH = x86
PKG_SHA = 7b1476e024fa599a18949a449b6f73cb373e45a9
else ifeq ($(findstring $(ARCH),$(ARMv5_ARCHS)),$(ARCH))
PKG_DIST_ARCH = armv5
PKG_SHA = cdf4686a54ee2835b16dbb1cae620e5952667f88
else ifeq ($(findstring $(ARCH),$(ARMvv7L_ARCHS)),$(ARCH))
PKG_DIST_ARCH = armv5
PKG_SHA = cdf4686a54ee2835b16dbb1cae620e5952667f88
endif

include ../../mk/spksrc.install-resources.mk

.PHONY: debian_install debian_checksum
debian_checksum:

debian_install:
	mkdir -p $(STAGING_INSTALL_PREFIX)/rootfs
	tar -cf - -C $(WORK_DIR)/rootfs . | tar -xf - -C $(STAGING_INSTALL_PREFIX)/rootfs
	curl -so $(STAGING_INSTALL_PREFIX)/rootfs/debuerreotype-epoch https://raw.githubusercontent.com/debuerreotype/docker-debian-artifacts/$(PKG_SHA)/$(PKG_VERS)/slim/rootfs.debuerreotype-epoch
