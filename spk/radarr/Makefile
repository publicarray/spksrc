SPK_NAME = radarr
SPK_CONFLICT = radarr_official
SPK_VERS = $(shell date +%Y%m%d)
SPK_REV = 19
SPK_ICON = src/radarr.png

REQUIRED_MIN_DSM = 6.0

# .NET is not supported on PPC, ARM5, ARM7L and x86
UNSUPPORTED_ARCHS = $(PPC_ARCHS) $(ARMv5_ARCHS) $(ARMv7L_ARCHS) $(i686_ARCHS)

DEPENDS = cross/radarr

MAINTAINER = Team Radarr
MAINTAINER_URL = https://radarr.video/
HELPURL    = https://wiki.servarr.com/Radarr
SUPPORTURL = https://radarr.video/\#support

DESCRIPTION = Radarr is a movie collection manager for Usenet and BitTorrent users. It can monitor multiple RSS feeds for new movies and will interface with clients and indexers to grab, sort, and rename them. It can also be configured to automatically upgrade the quality of existing files in the library when a better quality format becomes available.
STARTABLE = yes
DISPLAY_NAME = Radarr
CHANGELOG = "${DISPLAY_NAME} v$(SPK_VERS)"

HOMEPAGE = $(MAINTAINER_URL)
LICENSE  = GPLv3

SERVICE_USER = auto
SERVICE_SETUP = src/service-setup.sh
SERVICE_PORT = 8310
SERVICE_PORT_TITLE = $(DISPLAY_NAME)

# Admin link for in DSM UI
ADMIN_PORT = $(SERVICE_PORT)

WIZARDS_DIR = src/wizard/

POST_STRIP_TARGET = app_extra_install

# DSM prevents executing from /tmp in 7.1
USE_ALTERNATE_TMPDIR = 1

include ../../mk/spksrc.common.mk

ifeq ($(call version_lt, ${TCVERSION}, 7.0),1)
DEPENDS += cross/bubblewrap cross/debian-buster
app_extra_install: rootfs_install
else ifeq ($(ARCH), comcerto2k)
DEPENDS += cross/debian-buster
SPK_DEPENDS = "bubblewrap>=0.6.1"
app_extra_install: rootfs_install
else
DEPENDS += cross/sqlite cross/radarr
endif

include ../../mk/spksrc.spk.mk

PACKAGE_VERSION = $(SPK_VERS)-spk$(SPK_REV)-$(SPK_NAME_ARCH)-$(SPK_TCVERS)
PACKAGE_AUTHOR = [$(MAINTAINER)]($(MAINTAINER_URL))

.PHONY: app_extra_install rootfs_install

rootfs_install:
	sudo debuerreotype-apt-get $(STAGING_DIR)/rootfs update; \
	sudo debuerreotype-apt-get $(STAGING_DIR)/rootfs install -y --no-install-recommends --no-install-suggests ca-certificates locales tzdata libicu63 libssl1.1 libstdc++6 zlib1g libsqlite3-0; \
	rm -rf $(STAGING_DIR)/tmp/* $(STAGING_DIR)/var/lib/apt/lists/* $(STAGING_DIR)/var/tmp/*; \

app_extra_install:
	@install -m 755 -d $(STAGING_DIR)/app
	@install -m 644 src/config.xml $(STAGING_DIR)/app/config.xml
	@echo "PackageVersion=$(PACKAGE_VERSION)\nPackageAuthor=$(PACKAGE_AUTHOR)" > $(STAGING_DIR)/usr/lib/radarr/package_info
