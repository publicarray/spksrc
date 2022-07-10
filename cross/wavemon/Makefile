PKG_NAME = wavemon
PKG_VERS = 0.9.4
PKG_EXT = tar.gz
PKG_DIST_NAME = $(PKG_NAME)-$(PKG_VERS).$(PKG_EXT)
PKG_DIST_SITE = https://github.com/uoaerg/wavemon/archive/refs/tags/v$(PKG_VERS)
PKG_DIR = $(PKG_NAME)-$(PKG_VERS)

DEPENDS = cross/ncursesw cross/libnl

HOMEPAGE = https://github.com/uoaerg/wavemon
COMMENT  = wavemon is a wireless device monitoring application that allows you to watch signal and noise levels, packet statistics, device configuration and network parameters of your wireless network hardware. It should work (though with varying features) with all devices supported by the Linux kernel.
LICENSE  = GPL-3.0

ADDITIONAL_CPPFLAGS = -std=c99
GNU_CONFIGURE = 1

include ../../mk/spksrc.cross-cc.mk
