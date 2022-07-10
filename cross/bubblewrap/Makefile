PKG_NAME = bubblewrap
PKG_VERS = 0.6.2
PKG_EXT = tar.xz
PKG_DIST_NAME = $(PKG_NAME)-$(PKG_VERS).$(PKG_EXT)
PKG_DIST_SITE = https://github.com/containers/bubblewrap/releases/download/v$(PKG_VERS)
PKG_DIR = $(PKG_NAME)-$(PKG_VERS)

DEPENDS = cross/libcap

HOMEPAGE = https://github.com/containers/bubblewrap
LICENSE  = LGPLv2

GNU_CONFIGURE = 1

PRE_CONFIGURE_TARGET = bubblewrap_pre_configure

PATCHES_LEVEL = 1

include ../../mk/spksrc.cross-cc.mk

.PHONY: bubblewrap_pre_configure
bubblewrap_pre_configure:
	@$(RUN) ./autogen.sh $(REAL_CONFIGURE_ARGS)
