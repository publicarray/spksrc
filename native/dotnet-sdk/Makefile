PKG_NAME = dotnet-sdk
# PKG_VERS = 3.1.103.2
PKG_VERS = 3.1.302
PKG_EXT = tar.gz
PKG_DIST_SITE = https://dotnetcli.azureedge.net/dotnet/Sdk/${PKG_VERS}
PKG_DIST_NAME = $(PKG_NAME)-$(PKG_VERS)-linux-x64.$(PKG_EXT)

# https://docs.microsoft.com/en-us/dotnet/core/install/linux
DEPENDS =

HOMEPAGE = https://dotnet.microsoft.com/
COMMENT  = A developer platform for building apps.
LICENSE  = MIT

CONFIGURE_TARGET = nop
COMPILE_TARGET = nop
INSTALL_TARGET = dotnet-install

include ../../mk/spksrc.native-cc.mk

# Supported architectures:
# https://github.com/dotnet/core/blob/master/release-notes/3.1/3.1-supported-os.md#linux
## UNSUPPORTED_ARCHS = $(PPC_ARCHES) $(ARM5_ARCHES) $(x86_ARCHES)

.PHONY: dotnet-install
dotnet-install:
	mkdir -p $(HOME)/.dotnet/
	$(RUN) cp -r ./* $(HOME)/.dotnet/
	$(RUN) ln -s $(HOME)/.dotnet/dotnet $(INSTALL_PREFIX)/bin
