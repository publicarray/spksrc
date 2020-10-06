SPK_NAME = jackett-dotnet
SPK_VERS = 0.16.1583
SPK_REV = 11
SPK_ICON = src/jackett.png
DSM_UI_DIR = app

DEPENDS = cross/$(SPK_NAME)

MAINTAINER = m4tt075
DESCRIPTION = "Jackett works as a proxy server. It translates queries from apps into tracker-site-specific http queries, parses the html response, then sends results back to the requesting software. Jackett is a single repository of maintained indexer scraping and translation logic - removing the burden from other apps."
RELOAD_UI = yes
DISPLAY_NAME = Jackett
STARTABLE = yes
CHANGELOG = "Compile using .NET"
HOMEPAGE = https://github.com/Jackett/Jackett
LICENSE = GPLv2

# 'auto' reserved value grabs SPK_NAME
SERVICE_USER = auto
SERVICE_SETUP = src/service-setup.sh

# Service configuration
SERVICE_PORT = 9117
SERVICE_PORT_TITLE = Jackett(HTTP)

# Admin link
ADMIN_PORT = $(SERVICE_PORT)

POST_STRIP_TARGET = jackett_extra_install

REQUIRED_DSM = 5.0
# no PPC/ARM5/x86 support for .net, see native/dotnet/Makefile for details
UNSUPPORTED_ARCHS = $(PPC_ARCHES) $(ARM5_ARCHES) $(x86_ARCHES)

include ../../mk/spksrc.spk.mk

.PHONY: jackett_extra_install
jackett_extra_install:
	install -m 755 -d $(STAGING_DIR)/var
	install -m 755 -d $(STAGING_DIR)/var/.config
	install -m 755 -d $(STAGING_DIR)/var/.config/Jackett
	install -m 755 -d $(STAGING_DIR)/app
	install -m 644 src/app/config $(STAGING_DIR)/app/config
