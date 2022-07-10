APP_LOWER="readarr"
APP_UPPER="Readarr"

GROUP="sc-download"

USR_LIB="/usr/lib/${APP_LOWER}"
PID_FILE="${SYNOPKG_PKGVAR}/${APP_LOWER}.pid"

# If the bwrap binary is in this package, use it, otherwise use from standalone package.
BWRAP="${SYNOPKG_PKGDEST}/bin/bwrap"
if [ ! -f "${BWRAP}" ]; then
    BWRAP="/var/packages/bubblewrap/target/bin/bwrap"
fi

# Some versions include a rootfs to create a chroot container with newer libraries.
ROOTFS="${SYNOPKG_PKGDEST}/rootfs"
if [ -d "${ROOTFS}" ]; then
    APP="${USR_LIB}/bin/${APP_UPPER}"
    CONFIG_DIR="/var/lib/${APP_LOWER}"
    VOLUMES=$(mount -l | grep -E '/volume([0-9]{1,2}\b|USB[0-9]{1,2}/)' | awk '{ printf " --bind %s %s", $3, $3 }' | sort -V)

    SERVICE_COMMAND="${BWRAP} --bind ${ROOTFS} / --proc /proc --dev /dev --ro-bind /etc/resolv.conf /etc/resolv.conf --bind ${SYNOPKG_PKGDEST}${USR_LIB} ${USR_LIB} --bind ${SYNOPKG_PKGVAR} ${CONFIG_DIR} ${VOLUMES} --share-net --setenv HOME ${SYNOPKG_PKGVAR} ${APP} --nobrowser --data=${CONFIG_DIR}"
else
    APP="${SYNOPKG_PKGDEST}${USR_LIB}/bin/${APP_UPPER}"
    SERVICE_COMMAND="env HOME=${SYNOPKG_PKGVAR} LD_LIBRARY_PATH=${SYNOPKG_PKGDEST}/lib ${APP} --nobrowser --data=${SYNOPKG_PKGVAR}"
fi

SVC_BACKGROUND=y

fix_permissions ()
{
    if [ ${SYNOPKG_DSM_VERSION_MAJOR} -lt 7 ]; then
        if [ -f "${BWRAP}" ]; then
            chown root:root "${BWRAP}"
            chmod u+s "${BWRAP}"
        fi

        set_unix_permissions "${SYNOPKG_PKGVAR}"
    fi
}

service_postinst ()
{
    # Move config.xml to .config
    mv ${SYNOPKG_PKGDEST}/app/config.xml ${SYNOPKG_PKGVAR}

    fix_permissions
}

service_postupgrade ()
{
    # Do an update check on start to avoid possible
    # downgrade when synocommunity package is updated
    touch ${SYNOPKG_PKGVAR}/update_required

    fix_permissions
}
