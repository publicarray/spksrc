SPK_NAME = readarr_official
SPK_CONFLICT = readarr
SPK_VERS = 0.1.0.1248
SPK_ICON = src/readarr.png

REQUIRED_MIN_DSM = 6.0

# .NET is not supported on PPC, ARM5, ARM7L and x86
UNSUPPORTED_ARCHS = $(PPC_ARCHS) $(ARMv5_ARCHS) $(ARMv7L_ARCHS) $(i686_ARCHS)

DEPENDS = cross/readarr

MAINTAINER = Team Readarr
MAINTAINER_URL = https://readarr.com/
HELPURL    = https://wiki.servarr.com/Readarr
SUPPORTURL = https://readarr.audio/\#support

DESCRIPTION  = Readarr is an ebook and audiobook collection manager for Usenet and BitTorrent users. It can monitor multiple RSS feeds for new books from your favorite authors and will grab, sort, and rename them. Note that only one type of a given book is supported. If you want both an audiobook and ebook of a given book you will need multiple instances.
STARTABLE = yes
DISPLAY_NAME = Readarr
CHANGELOG = "${DISPLAY_NAME} v$(SPK_VERS)"

HOMEPAGE = $(MAINTAINER_URL)
LICENSE  = GPLv3

SERVICE_USER = auto
SERVICE_SETUP = src/service-setup.sh
SERVICE_PORT = 8787
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
DEPENDS += cross/sqlite cross/readarr
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
	@echo "PackageVersion=$(PACKAGE_VERSION)\nPackageAuthor=$(PACKAGE_AUTHOR)" > $(STAGING_DIR)/usr/lib/readarr/package_info
