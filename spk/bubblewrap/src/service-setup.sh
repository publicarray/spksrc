
# bwrap service setup

BWRAP="${SYNOPKG_PKGDEST}/bin/bwrap"

fix_permissions ()
{
    if [ ${SYNOPKG_DSM_VERSION_MAJOR} -lt 7 ]; then
        chown root:root "${BWRAP}"
        chmod u+s "${BWRAP}"
    fi
}

service_postinst ()
{
    fix_permissions
}

service_postupgrade ()
{
    fix_permissions
}
