PKG_NAME = glibc
PKG_VERS = 2.28
PKG_EXT = tar.xz
PKG_DIR = $(PKG_NAME)-$(PKG_VERS)-build
PKG_DIST_NAME = $(PKG_NAME)-$(PKG_VERS).$(PKG_EXT)
PKG_DIST_SITE = http://ftpmirror.gnu.org/$(PKG_NAME)

DEPENDS =

#REQUIRE_KERNEL = 1

HOMEPAGE = https://www.gnu.org/software/libc/started.html
COMMENT  = The GNU C Library (glibc)
LICENSE  = GPLv3

CONFIGURE_ARGS += --prefix=$(INSTALL_PREFIX)
CONFIGURE_ARGS += --disable-sanity-checks
# CONFIGURE_ARGS += --with-headers=$(KERNAL_ROOT)

CONFIGURE_TARGET = glibc_config
INSTALL_TARGET = glibc_install

include ../../mk/spksrc.cross-cc.mk

.PHONY: glibc_config glibc_build glibc_install
glibc_config:
	mkdir -p $(WORK_DIR)/$(PKG_NAME)-$(PKG_VERS)-build
	@$(RUN) $(WORK_DIR)/$(PKG_NAME)-$(PKG_VERS)/configure $(CONFIGURE_ARGS)

glibc_install:
	@$(RUN) $(MAKE) install DESTDIR=$(INSTALL_DIR)
