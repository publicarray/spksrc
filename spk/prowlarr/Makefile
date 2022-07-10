SPK_NAME = prowlarr_official
SPK_CONFLICT = prowlarr
SPK_VERS = 0.3.0.1730
SPK_ICON = src/prowlarr.png

REQUIRED_MIN_DSM = 6.0

# .NET is not supported on PPC, ARM5, ARM7L and x86
UNSUPPORTED_ARCHS = $(PPC_ARCHS) $(ARMv5_ARCHS) $(ARMv7L_ARCHS) $(i686_ARCHS)

DEPENDS = cross/prowlarr

MAINTAINER = Team Prowlarr
MAINTAINER_URL = https://prowlarr.com/
HELPURL    = https://wiki.servarr.com/Prowlarr
SUPPORTURL = https://prowlarr.audio/\#support

DESCRIPTION  = Prowlarr is an indexer manager/proxy built on the popular *arr .net/reactjs base stack to integrate with your various PVR apps. Prowlarr supports management of both Torrent Trackers and Usenet Indexers. It integrates seamlessly with Lidarr, Mylar3, Radarr, Readarr, and Sonarr offering complete management of your indexers with no per app Indexer setup required (we do it all).
STARTABLE = yes
DISPLAY_NAME = Prowlarr
CHANGELOG = "${DISPLAY_NAME} v$(SPK_VERS)"

HOMEPAGE = $(MAINTAINER_URL)
LICENSE  = GPLv3

SERVICE_USER = auto
SERVICE_SETUP = src/service-setup.sh
SERVICE_PORT = 9696
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
DEPENDS += cross/sqlite cross/prowlarr
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
	@echo "PackageVersion=$(PACKAGE_VERSION)\nPackageAuthor=$(PACKAGE_AUTHOR)" > $(STAGING_DIR)/usr/lib/prowlarr/package_info
