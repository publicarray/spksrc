PKG_NAME = libstdc++
PARENT_PKG_NAME = gcc
PKG_VERS = 10.2.0
PKG_EXT = tar.xz
PKG_DIR = $(PARENT_PKG_NAME)-$(PKG_VERS)
PKG_DIST_NAME = $(PARENT_PKG_NAME)-$(PKG_VERS).$(PKG_EXT)
PKG_DIST_SITE = http://ftpmirror.gnu.org/$(PARENT_PKG_NAME)/$(PARENT_PKG_NAME)-$(PKG_VERS)

BUILD_DEPENDS = cross/gmp cross/mpfr cross/mpc

HOMEPAGE = https://gcc.gnu.org/
COMMENT  = This package contains an additional runtime library for C++ programs built with the GNU compiler.
LICENSE  = GPLv3


include ../../mk/spksrc.archs.mk
ifeq ($(findstring $(ARCH),$(ARMv5_ARCHS) $(ARMv7_ARCHS) $(ARMv7L_ARCHS) $(ARMv8_ARCHS)),$(ARCH))
BUILD_TARGET = arm-unknown-linux-gnueabi
endif
ifeq ($(findstring $(ARCH),$(i686_ARCHS)),$(ARCH))
BUILD_TARGET = i686-linux-gnu
endif
ifeq ($(findstring $(ARCH),$(x64_ARCHS)),$(ARCH))
BUILD_TARGET = x86_64-pc-linux-gnu
endif
ifeq ($(findstring $(ARCH),$(PPC_ARCHS)),$(ARCH))
BUILD_TARGET = powerpc-linux-gnu
endif

include ../../mk/spksrc.cross-cc.mk

GNU_CONFIGURE = 1
ADDITIONAL_CXXFLAGS += -std=c++11 -march=x86-64

CONFIGURE_ARGS += --target=$(BUILD_TARGET)
# CONFIGURE_ARGS += --build=$(BUILD_TARGET)
CONFIGURE_ARGS += --host=x86_64-pc-linux-gnu
CONFIGURE_ARGS += --with-gmp $(STAGING_INSTALL_PREFIX)
CONFIGURE_ARGS += --with-mpfr $(STAGING_INSTALL_PREFIX)
CONFIGURE_ARGS += --with-mpc $(STAGING_INSTALL_PREFIX)
CONFIGURE_ARGS += --prefix=$(INSTALL_PREFIX)
#CONFIGURE_ARGS += --enable-shared=libstdc++
CONFIGURE_ARGS += --enable-languages=c++
CONFIGURE_ARGS += --disable-nls
CONFIGURE_ARGS += --disable-multilib
# CONFIGURE_ARGS += --with-system-zlib
CONFIGURE_ARGS += --without-headers
# CONFIGURE_ARGS += --with-sysroot=/
# CONFIGURE_ARGS += --with-sysroot=$(TOOLKIT_ROOT)/$(BUILD_TARGET)/$(BUILD_TARGET)/sys-root
# CONFIGURE_ARGS += --with-native-system-header-dir=$(TOOLKIT_ROOT)/$(BUILD_TARGET)/$(BUILD_TARGET)/sys-root/usr/include
# CONFIGURE_ARGS += --with-native-system-header-dir=/usr/include/

COMPILE_TARGET = gcc_build
INSTALL_TARGET = gcc_install

## force newer system bintools
CONFIGURE_ARGS += --with-ld=/usr/bin/ld
CONFIGURE_ARGS += --with-as=/usr/bin/as
## force newer system compiler from host systemm since the gcc from the toolchain is too old,
## we can still cross compile by setting the target touple.
# env -u LDSHARED -u MAKEFLAGS -u PKG_CONFIG -u PKG_CONFIG_LIBDIR -u PKG_CONFIG_PATH
ENV += LD=
ENV += CPP=
ENV += NM=
ENV += CC=
ENV += RANLIB=
ENV += CXX=
ENV += AR=
ENV += STRIP=
ENV += OBJDUM=
ENV += READELF=
ENV += AS=
ENV += OBJDUMP=
ENV += CFLAGS="-I$(STAGING_INSTALL_PREFIX)/include -I/usr/include/ -march=x86-64"
ENV += CPPFLAGS="-I$(STAGING_INSTALL_PREFIX)/include -I/usr/include/"
ENV += CXXFLAGS="-I$(STAGING_INSTALL_PREFIX)/include -I/usr/include/ -std=c++11 -march=x86-64"
ENV += LDFLAGS=" -L$(STAGING_INSTALL_PREFIX)/lib -L/usr/lib -Wl,--rpath-link,$(STAGING_INSTALL_PREFIX)/lib -Wl,--rpath,/usr/local/libstdc++/lib "
#ENV += LD_LIBRARY_PATH=-L$(STAGING_INSTALL_PREFIX)/lib
.PHONY: gcc_build gcc_install
gcc_build:
	# quick hack to "fix missing commands for the "
	ln -s /usr/bin/gcc /usr/bin/x86_64-pc-linux-gnu-gcc
	ln -s /usr/bin/cc /usr/bin/x86_64-pc-linux-gnu-cc
	ln -s /usr/bin/ar /usr/bin/x86_64-pc-linux-gnu-ar
	@$(RUN) $(MAKE) all-target-libstdc++-v3
	rm /usr/bin/x86_64-pc-linux-gnu-gcc
	rm /usr/bin/x86_64-pc-linux-gnu-cc
	rm /usr/bin/x86_64-pc-linux-gnu-ar
gcc_install:
	@$(RUN) $(MAKE) install-target-libstdc++-v3 DESTDIR=$(INSTALL_DIR)
