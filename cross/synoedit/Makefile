PKG_NAME = synoedit
PKG_VERS = 0.0.8
PKG_EXT = tar.gz
PKG_DIST_NAME = v$(PKG_VERS).$(PKG_EXT)
PKG_DIST_SITE = https://github.com/publicarray/$(PKG_NAME)/archive
PKG_DIST_FILE = $(PKG_NAME)-$(PKG_VERS).$(PKG_EXT)
PKG_DIR =  $(PKG_NAME)-$(PKG_VERS)

BUILD_DEPENDS = native/go native/nodejs

HOMEPAGE = https://github.com/publicarray/synoedit
COMMENT  = Synology package for editing files through a web interface using codemirror
LICENSE  =

POST_INSTALL_TARGET = synoedit_post_install

GO_SRC_DIR = $(WORK_DIR)/$(PKG_DIR)/package/src/$(PKG_NAME)
GO_BIN_DIR = $(GO_SRC_DIR)/index.cgi
GO_LDFLAGS = -s -w

ENV += NPM_CONFIG_USER=root
PATH := $(WORK_DIR)/../../../native/nodejs/work-native/node/bin:$(PATH)

include ../../mk/spksrc.cross-go.mk

synoedit_post_install:
	$(RUN) ./build.sh dependencies
	install -m 755 -d $(STAGING_INSTALL_PREFIX)/ui
	cp -r $(WORK_DIR)/$(PKG_DIR)/package/ui/* $(STAGING_INSTALL_PREFIX)/ui/
	install -m 755 $(GO_BIN_DIR) $(STAGING_INSTALL_PREFIX)/ui
