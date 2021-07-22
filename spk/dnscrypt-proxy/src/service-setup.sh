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

migrate_files () { # from 2.0.44 to 2.0.45
    echo SYNOPKG_OLD_PKGVER=$SYNOPKG_OLD_PKGVER
    # check if files where already migrated
    if [ ! -f "${SYNOPKG_PKGVAR}/domains-blocklist.conf" ]; then
        # Override config file since there are too many changes to use sed to upgrade them.
        cp -f "${SYNOPKG_PKGDEST}/example-dnscrypt-proxy.toml" "$CFG_FILE"
        default_config

        if [ -f "${SYNOPKG_PKGVAR}/blacklist.txt" ]; then
            mv "${SYNOPKG_PKGVAR}/blacklist.txt" "${SYNOPKG_PKGVAR}/blocked-names.txt"
        fi
        if [ -f "${SYNOPKG_PKGVAR}/domains-blacklist.conf" ]; then
            mv "${SYNOPKG_PKGVAR}/domains-blacklist.conf" "${SYNOPKG_PKGVAR}/domains-blocklist.conf"
        fi
        if [ -f "${SYNOPKG_PKGVAR}/generate-domains-blacklist.py" ]; then
            rm "${SYNOPKG_PKGVAR}/generate-domains-blacklist.py"
        fi
        if [ -f "${SYNOPKG_PKGVAR}/domains-blacklist-local-additions.txt" ]; then
            mv "${SYNOPKG_PKGVAR}/domains-blacklist-local-additions.txt" "${SYNOPKG_PKGVAR}/domains-blocklist-local-additions.txt"
        fi
        if [ -f "${SYNOPKG_PKGVAR}/ip-blacklist.txt" ]; then
            mv "${SYNOPKG_PKGVAR}/ip-blacklist.txt" "${SYNOPKG_PKGVAR}/blocked-ips.txt"
        fi
        if [ -f "${SYNOPKG_PKGVAR}/domains-whitelist.txt" ]; then
            mv "${SYNOPKG_PKGVAR}/domains-whitelist.txt" "${SYNOPKG_PKGVAR}/allowed-names.txt"
        fi
    fi
}

blocklist_setup () {
    ## https://github.com/jedisct1/dnscrypt-proxy/wiki/Public-blocklists
    ## https://github.com/jedisct1/dnscrypt-proxy/tree/master/utils/generate-domains-blocklists
    echo "Install/Upgrade generate-domains-blocklist.py (requires python)"
    touch "${SYNOPKG_PKGVAR}/blocked-ips.txt"
    if [ ! -e "${SYNOPKG_PKGVAR}/domains-blocklist.conf" ]; then
        wget -t 3 -O "${SYNOPKG_PKGVAR}/domains-blocklist.conf" \
            --https-only https://raw.githubusercontent.com/jedisct1/dnscrypt-proxy/master/utils/generate-domains-blocklist/domains-blocklist.conf
    fi
}

# blocklist_cron_uninstall () {
#     # remove cron job
#     if [ "$OS" = "dsm" ]; then
#         rm -f /etc/cron.d/dnscrypt-proxy-update-blocklist
#     else
#         sed -i '/.*update-blocklist.sh/d' /etc/crontab
#     fi
#     synoservicectl --restart crond
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
        cp -f "${SYNOPKG_PKGDEST}"/offline-cache/* "${SYNOPKG_PKGVAR}/"
        cp -f "${SYNOPKG_PKGDEST}"/blocklist/* "${SYNOPKG_PKGVAR}/"
        # shellcheck disable=SC2231
        for file in ${SYNOPKG_PKGVAR}/example-*; do
            mv "${file}" "${file//example-/}"
        done
        default_config
    fi

    blocklist_setup

    # allow synocommuity group access (synoedit)
    chmod g+rw -R "$SYNOPKG_PKGVAR"
}

service_postuninst () {
    if [ "$OS" = 'dsm' ] && [ "$SYNOPKG_DSM_VERSION_MAJOR" -lt 7 ] || [ "$OS" = 'srm' ]; then
        blocklist_cron_uninstall

        # shellcheck disable=SC2129
        echo "Uninstall Help files"
        pkgindexer_del "${SYNOPKG_PKGDEST}/ui/helptoc.conf"
        pkgindexer_del "${SYNOPKG_PKGDEST}/ui/index.conf"
        disable_dhcpd_dns_port "no"
        if [ "$OS" = "dsm" ]; then
            rm -f /etc/dhcpd/dhcpd-dns-dns.conf
            rm -f /etc/dhcpd/dhcpd-dns-dns.info
        else
            rm -f /etc/dhcpd/dhcpd-dnscrypt-dnscrypt.conf
            rm -f /etc/dhcpd/dhcpd-dnscrypt-dnscrypt.info
        fi
    fi
}

service_postupgrade () {
    migrate_files # from 2.0.44 to 2.0.45
    # upgrade script
    cp -f "${SYNOPKG_PKGDEST}/blocklist/generate-domains-blocklist.py" "${SYNOPKG_PKGVAR}/"
}
