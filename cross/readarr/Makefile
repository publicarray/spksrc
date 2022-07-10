PKG_NAME = Readarr
PKG_VERS = 0.1.0.1248
PKG_EXT = tar.gz
PKG_DIST_NAME = $(PKG_NAME).develop.$(PKG_VERS).linux-core-$(PKG_DIST_ARCH).$(PKG_EXT)
PKG_DIST_SITE = https://github.com/Readarr/Readarr/releases/download/v$(PKG_VERS)
PKG_DIR = Readarr

DEPENDS =

UNSUPPORTED_ARCHS = $(PPC_ARCHS) $(ARMv5_ARCHS) $(ARMv7L_ARCHS) $(i686_ARCHS)

HOMEPAGE = https://readarr.com/
COMMENT  = Readarr is an ebook and audiobook collection manager for Usenet and BitTorrent users. It can monitor multiple RSS feeds for new books from your favorite authors and will grab, sort, and rename them. Note that only one type of a given book is supported. If you want both an audiobook and ebook of a given book you will need multiple instances.

INSTALL_TARGET = readarr_install

# use digests with multiple files
PKG_DIST_ARCH_LIST = x64 arm arm64

include ../../mk/spksrc.archs.mk
PKG_DIST_ARCH = x64
ifeq ($(findstring $(ARCH),$(ARMv7_ARCHS)),$(ARCH))
PKG_DIST_ARCH = arm
else ifeq ($(findstring $(ARCH),$(ARMv8_ARCHS)),$(ARCH))
PKG_DIST_ARCH = arm64
endif

include ../../mk/spksrc.install-resources.mk

.PHONY: readarr_install
readarr_install:
	rm -rf $(WORK_DIR)/$(PKG_DIR)/Readarr.Update
	mkdir -p $(STAGING_INSTALL_PREFIX)/usr/lib/readarr/bin
	tar -cf - -C $(WORK_DIR)/$(PKG_NAME) . | tar -xf - -C $(STAGING_INSTALL_PREFIX)/usr/lib/readarr/bin
