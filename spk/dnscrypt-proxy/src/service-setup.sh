# shellcheck disable=SC2148
SVC_CWD="${SYNOPKG_PKGDEST}"
DNSCRYPT_PROXY="${SYNOPKG_PKGDEST}/bin/dnscrypt-proxy"
PID_FILE="${SYNOPKG_PKGVAR}/dnscrypt-proxy.pid"
CFG_FILE="${SYNOPKG_PKGVAR}/dnscrypt-proxy.toml"
EXAMPLE_FILES="${SYNOPKG_PKGDEST}/example-*"
SYNOPKG_PKGHOME="${SYNOPKG_PKGHOME:=$SYNOPKG_PKGVAR}"

SERVICE_COMMAND="env HOME=${SYNOPKG_PKGHOME} ${DNSCRYPT_PROXY} --config ${CFG_FILE} --pidfile ${PID_FILE}"
SVC_BACKGROUND=y

# find OS
OS="dsm"
if echo "$UNAME" | grep -q -i 'rt1900ac\|rt2600ac\|mr2200ac'; then
    OS="srm"
fi
echo "OS detected: $OS"
## end

default_config () {
    # if [ servicetool --conf-port-conflict-check --tcp 53]
    sed -i -e "s/listen_addresses\s*=.*/listen_addresses = \['0.0.0.0:$SERVICE_PORT'\]/" \
        -e "s/netprobe_timeout\s*=.*/netprobe_timeout = 2/" \
        "${CFG_FILE}"
}

migrate_files () { # from 2.0.44_5 to 2.0.45_6
    # Override config file since there are too many changes to use sed to upgrade them.
    cp -vf "${SYNOPKG_PKGDEST}/example-dnscrypt-proxy.toml" "$CFG_FILE"
    default_config
    if [ -f "${SYNOPKG_PKGVAR}/dnscrypt-proxy_install.log" ]; then
        rm -vf "${SYNOPKG_PKGVAR}/dnscrypt-proxy_install.log"
    fi

    if [ -f "${SYNOPKG_PKGVAR}/blacklist.txt" ]; then
        mv -v "${SYNOPKG_PKGVAR}/blacklist.txt" "${SYNOPKG_PKGVAR}/blocked-names.txt"
    fi
    if [ -f "${SYNOPKG_PKGVAR}/domains-blacklist.conf" ]; then
        mv -v "${SYNOPKG_PKGVAR}/domains-blacklist.conf" "${SYNOPKG_PKGVAR}/domains-blocklist.conf"
    fi
    if [ -f "${SYNOPKG_PKGVAR}/generate-domains-blacklist.py" ]; then
        rm -v "${SYNOPKG_PKGVAR}/generate-domains-blacklist.py"
    fi
    if [ -f "${SYNOPKG_PKGVAR}/domains-blacklist-local-additions.txt" ]; then
        mv -v "${SYNOPKG_PKGVAR}/domains-blacklist-local-additions.txt" "${SYNOPKG_PKGVAR}/domains-blocklist-local-additions.txt"
        sed -i -e 's|file:domains-blacklist-local-additions.txt|file:domains-blocklist-local-additions.txt|g' "${SYNOPKG_PKGVAR}/domains-blocklist-local-additions.txt"
    fi
    if [ -f "${SYNOPKG_PKGVAR}/ip-blacklist.txt" ]; then
        mv -v "${SYNOPKG_PKGVAR}/ip-blacklist.txt" "${SYNOPKG_PKGVAR}/blocked-ips.txt"
    fi
    if [ -f "${SYNOPKG_PKGVAR}/domains-whitelist.txt" ]; then
        mv -v "${SYNOPKG_PKGVAR}/domains-whitelist.txt" "${SYNOPKG_PKGVAR}/allowed-names.txt"
    fi
}

# blocklist_cron_uninstall () {
#      # remove cron job
#      if [ "$OS" = "dsm" ]; then
#          rm -f /etc/cron.d/dnscrypt-proxy-update-blocklist
#      else
#          sed -i '/.*update-blocklist.sh/d' /etc/crontab
#      fi
#      synoservicectl --restart crond
# }

# blocklist_cron_install () {
#     # install cron job
#     Install daily cron job (3 minutes past midnight), to update the block list
#     if [ "$OS" = 'dsm' ] && [ "$SYNOPKG_DSM_VERSION_MAJOR" -lt 7 ]; then
#         mkdir -p /etc/cron.d
#         echo "3       0       *       *       *       root    /var/packages/dnscrypt-proxy/target/var/update-blocklist.sh" >> /etc/cron.d/dnscrypt-proxy-update-blocklist
#     elif [ "$OS" = 'srm' ]; then
#         echo "3       0       *       *       *       root    /var/packages/dnscrypt-proxy/target/var/update-blocklist.sh" >> /etc/crontab
#     fi
#     synoservicectl --restart crond
# }

pgrep () {
    if [ "$OS" = 'dsm' ]; then
        # shellcheck disable=SC2009,SC2153
        ps aux | grep "$1" >> "${LOG_FILE}" 2>&1
    else
        # shellcheck disable=SC2009,SC2153
        ps -w | grep "[^]]$1" >> "${LOG_FILE}" 2>&1
    fi
}

service_postinst () {

    if [ ! -e "${CFG_FILE}" ]; then
        # shellcheck disable=SC2086
        cp -f ${EXAMPLE_FILES} "${SYNOPKG_PKGVAR}/"
        cp -f "${SYNOPKG_PKGDEST}"/blocklist/* "${SYNOPKG_PKGVAR}/"
        # shellcheck disable=SC2231
        for file in ${SYNOPKG_PKGVAR}/example-*; do
            mv "${file}" "${file//example-/}"
        done
        default_config
    fi

    ## https://github.com/jedisct1/dnscrypt-proxy/wiki/Public-blocklists
    ## https://github.com/jedisct1/dnscrypt-proxy/tree/master/utils/generate-domains-blocklists
    touch "${SYNOPKG_PKGVAR}/blocked-ips.txt"
    if [ ! -e "${SYNOPKG_PKGVAR}/domains-blocklist.conf" ]; then
        wget -t 3 -O "${SYNOPKG_PKGVAR}/domains-blocklist.conf" \
            --https-only https://raw.githubusercontent.com/jedisct1/dnscrypt-proxy/master/utils/generate-domains-blocklist/domains-blocklist.conf
    fi

    # allow synocommuity group access (synoedit)
    chmod g+rw -R "$SYNOPKG_PKGVAR"
}

service_postuninst () {
    if [ "$OS" = 'dsm' ] && [ "$SYNOPKG_DSM_VERSION_MAJOR" -lt 7 ] || [ "$OS" = 'srm' ]; then
        # remove cron job
        if [ "$OS" = "dsm"  ] && [ -f /etc/cron.d/dnscrypt-proxy-update-blocklist ]; then
            rm -f /etc/cron.d/dnscrypt-proxy-update-blocklist
        else
            sed -i '/.*update-blocklist.sh/d' /etc/crontab
        fi
        synoservicectl --restart crond

        # shellcheck disable=SC2129
        if [ "$OS" = "dsm" ] && [ -f /etc/dhcpd/dhcpd-dns-dns.conf ]; then
            rm -f /etc/dhcpd/dhcpd-dns-dns.conf
            rm -f /etc/dhcpd/dhcpd-dns-dns.info
        elif [ -f /etc/dhcpd/dhcpd-dnscrypt-dnscrypt.conf ]; then
            rm -f /etc/dhcpd/dhcpd-dnscrypt-dnscrypt.conf
            rm -f /etc/dhcpd/dhcpd-dnscrypt-dnscrypt.info
        fi
    fi
}

service_postupgrade () {
    # from 2.0.44-5 to 2.0.45-6
    OLD_PKG_REVISION="$(echo "${SYNOPKG_OLD_PKGVER}" | sed 's|[\.\_\-]| |g;s|\d||g' | awk '{print $NF}')"
    echo SYNOPKG_OLD_PKGVER=$SYNOPKG_OLD_PKGVER
    echo OLD_PKG_REVISION=$OLD_PKG_REVISION
    if [ "${OLD_PKG_REVISION}" -lt "6" ]; then
        echo "Migrating files from ${SYNOPKG_OLD_PKGVER} to 2.0.45_6..."
        migrate_files
    fi
    # Upgrade generate-domains-blocklist.py script
    cp -vf "${SYNOPKG_PKGDEST}/blocklist/generate-domains-blocklist.py" "${SYNOPKG_PKGVAR}/"
}
