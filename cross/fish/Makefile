PKG_NAME = fish
PKG_VERS = 3.7.1
PKG_EXT = tar.xz
PKG_DIST_NAME = $(PKG_NAME)-$(PKG_VERS).$(PKG_EXT)
PKG_DIST_SITE = https://github.com/fish-shell/fish-shell/releases/download/$(PKG_VERS)
PKG_DIR = $(PKG_NAME)-$(PKG_VERS)

DEPENDS = cross/ncursesw cross/pcre2

HOMEPAGE = https://fishshell.com
COMMENT = fish is a smart and user-friendly command line shell for Linux, macOS, and the rest of the family.
LICENSE = GPL-2.0

# requirements: C++11 compiler (g++ 4.8 or later, or clang 3.3 or later)
UNSUPPORTED_ARCHS = $(ARMv5_ARCHS) $(OLD_PPC_ARCHS)

include ../../mk/spksrc.cross-cmake.mk

CMAKE_ARGS += -DCURSES_NCURSES_LIBRARY=$(INSTALL_DIR)$(INSTALL_PREFIX)/lib/libncursesw.so
CMAKE_ARGS += -DWITH_GETTEXT=OFF
