APP_LOWER="sonarr"
APP_UPPER="Sonarr"

GROUP="sc-download"

USR_LIB="/usr/lib/${APP_LOWER}"
PID_FILE="${SYNOPKG_PKGVAR}/${APP_LOWER}.pid"

# If the bwrap binary is in this package, use it, otherwise use from standalone package.
BWRAP="${SYNOPKG_PKGDEST}/bin/bwrap"
if [ ! -f "${BWRAP}" ]; then
    BWRAP="/var/packages/bubblewrap/target/bin/bwrap"
fi

# All sonarr packages include a rootfs
ROOTFS="${SYNOPKG_PKGDEST}/rootfs"

APP="${USR_LIB}/bin/${APP_UPPER}"
CONFIG_DIR="/var/lib/${APP_LOWER}"
VOLUMES=$(mount -l | grep -E '/volume([0-9]{1,2}\b|USB[0-9]{1,2}/)' | awk '{ printf " --bind %s %s", $3, $3 }' | sort -V)

SERVICE_COMMAND="${BWRAP} --bind ${ROOTFS} / --proc /proc --dev /dev --ro-bind /etc/resolv.conf /etc/resolv.conf --bind ${SYNOPKG_PKGDEST}${USR_LIB} ${USR_LIB} --bind ${SYNOPKG_PKGVAR} ${CONFIG_DIR} ${VOLUMES} --share-net --setenv HOME ${SYNOPKG_PKGVAR} mono --debug ${APP}.exe -nobrowser -data=${CONFIG_DIR}"

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
    fix_permissions
}

service_postupgrade ()
{
    # Do an update check on start to avoid possible
    # downgrade when synocommunity package is updated
    touch ${SYNOPKG_PKGVAR}/update_required

    fix_permissions
}
