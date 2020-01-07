SPK_NAME = bitwarden_rs
SPK_VERS = 1.13.1
SPK_REV = 1
SPK_ICON =

DEPENDS = cross/$(SPK_NAME)

MAINTAINER = publicarray
DESCRIPTION = This is a Bitwarden server API implementation written in Rust compatible with upstream Bitwarden clients*, Bitwarden is an open source, self-hosted password manager.
RELOAD_UI = no
DISPLAY_NAME = bitwarden_rs
STARTABLE = yes
CHANGELOG = "Initial release"
BETA = 1

HOMEPAGE   = https://bitwarden.com/
LICENSE    = GNUv3

INSTALLER_SCRIPT = src/installer.sh
SSS_SCRIPT       = src/dsm-control.sh

INSTALL_PREFIX = /usr/local/$(SPK_NAME)

POST_STRIP_TARGET = bitwarden_rs_install

include ../../mk/spksrc.spk.mk


.PHONY: bitwarden_rs_install
dnscrypt_extra_install:
	install -m 755 -d $(STAGING_DIR)/var
# 	install -m 644 $(STAGING_DIR)/etc/dnscrypt-proxy.conf $(STAGING_DIR)/var/
