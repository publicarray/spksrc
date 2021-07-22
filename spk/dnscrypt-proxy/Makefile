SPK_NAME = dnscrypt-proxy
SPK_VERS = 2.0.45
SPK_REV = 6
SPK_ICON = src/dnscrypt-proxy.png

DEPENDS = cross/$(SPK_NAME)
UNSUPPORTED_ARCHS = $(PPC_ARCHS)

MAINTAINER = publicarray
DESCRIPTION = A flexible DNS proxy, with support for modern encrypted DNS protocols such as DNSCrypt v2 and DNS-over-HTTPS. https://github.com/jedisct1/dnscrypt-proxy
DISPLAY_NAME = dnscrypt-proxy
HELPURL = https://github.com/jedisct1/dnscrypt-proxy/wiki
LICENSE = ISC
LICENSE_FILE = $(WORK_DIR)/src/github.com/$(SPK_NAME)/$(SPK_NAME)-$(SPK_VERS)/LICENSE
CHANGELOG = "Update dnscrypt-proxy to 2.0.45"

SERVICE_USER = auto
SERVICE_SETUP = src/service-setup.sh
SERVICE_PORT = 10053
SERVICE_PORT_TITLE = DNS
SERVICE_COMMAND=false
SPK_GROUP=synocommunity

include ../../mk/spksrc.spk.mk
