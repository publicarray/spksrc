PKG_NAME = Jackett-dotnet
PKG_VERS = 0.16.1583
PKG_EXT = tar.gz
PKG_DIST_NAME = v$(PKG_VERS).$(PKG_EXT)
PKG_DIST_FILE = $(PKG_NAME)-$(PKG_VERS).$(PKG_EXT)
PKG_DIST_SITE = https://github.com/Jackett/Jackett/archive
PKG_DIR = Jackett-$(PKG_VERS)/src

DEPENDS = native/dotnet-sdk

HOMEPAGE = https://github.com/Jackett/Jackett
COMMENT  = Jackett works as a proxy server: it translates queries from apps into tracker-site-specific http queries, parses the html response, then sends results back to the requesting software. Jackett is a single repository of maintained indexer scraping & translation logic - removing the burden from other apps.
LICENSE  = GNU GPL v2

CONFIGURE_TARGET = nop
COMPILE_TARGET = nop
INSTALL_TARGET = jackett_install

include ../../mk/spksrc.cross-cc.mk

ifeq ($(findstring $(ARCH),$(ARM7_ARCHES)),$(ARCH))
DOTNET_ARCH = arm
endif
ifeq ($(findstring $(ARCH),$(ARM8_ARCHES)),$(ARCH))
DOTNET_ARCH = arm64
endif
ifeq ($(findstring $(ARCH),$(x86_ARCHES)),$(ARCH))
DOTNET_ARCH = x86
endif
ifeq ($(findstring $(ARCH),$(x64_ARCHES)),$(ARCH))
DOTNET_ARCH = x64
endif
ifeq ($(DOTNET_ARCH),)
$(error Unsupported ARCH $(ARCH))
endif

SET_VERSION = /p:AssemblyVersion=$(PKG_VERS) /p:FileVersion=$(PKG_VERS) /p:InformationalVersion=$(PKG_VERS) /p:Version=$(PKG_VERS)
NET_FRAMEWORK = netcoreapp3.1
BUILD_ARGS = --self-contained -r linux-$(DOTNET_ARCH) -c Release --output="$(STAGING_INSTALL_PREFIX)/share/jackett"

jackett_install:
	mkdir -p $(STAGING_INSTALL_PREFIX)/share/$(PKG_DIR)
	$(RUN) dotnet publish Jackett.Server -f $(NET_FRAMEWORK) $(BUILD_ARGS) $(SET_VERSION)
