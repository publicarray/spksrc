PKG_NAME = navidrome
PKG_VERS = 0.47.0
PKG_EXT = tar.gz
PKG_DIST_NAME = v$(PKG_VERS).$(PKG_EXT)
PKG_DIST_SITE = https://github.com/navidrome/navidrome/archive/refs/tags
PKG_DIST_FILE = $(PKG_NAME)-$(PKG_VERS).$(PKG_EXT)
PKG_DIR = $(PKG_NAME)-$(PKG_VERS)

BUILD_DEPENDS = native/go native/nodejs
DEPENDS = cross/taglib

ENV += NPM_CONFIG_USER=root
PATH := $(WORK_DIR)/../../../native/nodejs/work-native/node/bin:$(PATH)

HOMEPAGE = https://www.navidrome.org/
COMMENT  = 🎧☁Modern Music Server and Streamer compatible with Subsonic/Airsonic
LICENSE  = GPL-3.0 License

CGO_ENABLED = 1
COMPILE_TARGET = navidrome_compile_target
GO_BIN_DIR = $(WORK_DIR)/$(PKG_DIR)/$(PKG_NAME)
include ../../mk/spksrc.cross-go.mk

ENV += LDFLAGS="-X 'main.Version=v$(PKG_VERS)'"

navidrome_compile_target:
	$(RUN) $(MAKE) setup
	$(RUN) $(MAKE) buildall
