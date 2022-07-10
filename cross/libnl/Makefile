PKG_NAME = libnl
PKG_VERS = 3.7.0
PKG_EXT = tar.gz
PKG_DIST_NAME = $(PKG_NAME)-$(PKG_VERS).$(PKG_EXT)
PKG_VERS_NAME_ = $(PKG_NAME)$(subst .,_,$(PKG_VERS))
PKG_DIST_SITE = https://github.com/thom311/libnl/releases/download/$(PKG_VERS_NAME_)
PKG_DIR = $(PKG_NAME)-$(PKG_VERS)

HOMEPAGE = https://www.infradead.org/~tgr/libnl/
COMMENT  = netlink
LICENSE  = LGPL-2.1

GNU_CONFIGURE = 1
CONFIGURE_ARGS = --prefix=$(STAGING_INSTALL_PREFIX)

include ../../mk/spksrc.cross-cc.mk
