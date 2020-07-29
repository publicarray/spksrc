PKG_NAME = jellyfin
PKG_VERS = 10.6.1
PKG_EXT = tar.gz
PKG_DIST_NAME = v$(PKG_VERS).$(PKG_EXT)
PKG_DIST_SITE = https://github.com/jellyfin/jellyfin/archive
PKG_DIST_FILE = $(PKG_NAME)-$(PKG_VERS).$(PKG_EXT)
PKG_DIR = $(PKG_NAME)-$(PKG_VERS)

HOMEPAGE = https://jellyfin.org
COMMENT  = The Free Software Media System. It is an alternative to the proprietary Emby and Plex.
LICENSE  = GPLv2

DEPENDS = native/nodejs native/dotnet-sdk

CONFIGURE_TARGET = none
COMPILE_TARGET = jellyfin_compile_target
INSTALL_TARGET = jellyfin_install_target

UNSUPPORTED_ARCHS = $(PPC_ARCHES) $(ARM5_ARCHES)

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

.PHONY: jellyfin_compile_target jellyfin_install_target
# PublishSingleFile better for packaging than multiple small dlls
# PublishReadyToRun improve the startup time of your .NET Core application
#   by compiling your application assemblies as ReadyToRun (R2R) format.
#   R2R is a form of ahead-of-time (AOT) compilation.
# PublishTrimmed reduce the size of apps by analyzing IL and trimming unused assemblies.
#   (not aware of reflection, needs testing, shaves ~10mb of binary)
# self-contained include .NET Runtime
jellyfin_compile_target:
	$(RUN) dotnet publish Jellyfin.Server --configuration Release --self-contained --runtime linux-$(DOTNET_ARCH) --output="$(STAGING_INSTALL_PREFIX)" "-p:GenerateDocumentationFile=false;DebugSymbols=false;DebugType=none;UseAppHost=true;PublishSingleFile=true;PublishReadyToRun=true;PublishReadyToRunShowWarnings=true"
	cd $(WORK_DIR) && curl -L https://github.com/jellyfin/jellyfin-web/archive/${PKG_DIST_NAME} | tar zxf -
	cd $(WORK_DIR)/$(PKG_NAME)-web-$(PKG_VERS) && npm install && npm run build:production

jellyfin_install_target:
	mkdir -p $(STAGING_INSTALL_PREFIX)/web
	cp -R $(WORK_DIR)/$(PKG_NAME)-web-$(PKG_VERS)/dist/* $(STAGING_INSTALL_PREFIX)/web
