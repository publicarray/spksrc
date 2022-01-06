SPK_NAME = navidrome
SPK_VERS = 0.47.0
SPK_REV = 1
SPK_ICON = src/$(SPK_NAME).png

MAINTAINER = SynoCommunity
DESCRIPTION  = 🎧☁Modern Music Server and Streamer compatible with Subsonic/Airsonic
DISPLAY_NAME = Navidrome
CHANGELOG = "First release"

LICENSE = GPL-3.0 License

DEPENDS = cross/$(SPK_NAME)
SPK_DEPENDS = "ffmpeg"

SERVICE_USER         = auto
SERVICE_SETUP        = src/service-setup.sh
STARTABLE            = yes

SERVICE_PORT = 4533
SERVICE_PORT_TITLE = Navidrome (HTTP)
ADMIN_PORT = $(SERVICE_PORT)

include ../../mk/spksrc.spk.mk
