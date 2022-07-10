SPK_NAME = bubblewrap
SPK_VERS = 0.6.2
SPK_ICON = src/bubblewrap.jpg

DEPENDS = cross/$(SPK_NAME)

REQUIRED_MIN_DSM = 7.0

UNSUPPORTED_ARCHS = $(PPC_ARCHS)

MAINTAINER = Servarr
DESCRIPTION = The goal of bubblewrap is to run an application in a sandbox, where it has restricted access to parts of the operating system or user data such as the home directory.
DISPLAY_NAME = Bubblewrap
STARTABLE = no
CHANGELOG = "${DISPLAY_NAME} v$(SPK_VERS)"

HOMEPAGE = https://github.com/containers/bubblewrap
LICENSE  = GPLv2

SERVICE_SETUP = src/service-setup.sh

WIZARDS_DIR = src/wizard/

SPK_COMMANDS = bin/bwrap

include ../../mk/spksrc.spk.mk
