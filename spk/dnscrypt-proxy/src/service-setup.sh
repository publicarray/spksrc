# shellcheck disable=SC2148
SVC_CWD="${SYNOPKG_PKGDEST}"
DNSCRYPT_PROXY="${SYNOPKG_PKGDEST}/bin/dnscrypt-proxy"
PID_FILE="${SYNOPKG_PKGVAR}/dnscrypt-proxy.pid"
CFG_FILE="${SYNOPKG_PKGVAR}/dnscrypt-proxy.toml"
EXAMPLE_FILES="${SYNOPKG_PKGDEST}/example-*"
SYNOPKG_PKGHOME="${SYNOPKG_PKGHOME:=$SYNOPKG_PKGVAR}"

SERVICE_COMMAND="env HOME=${SYNOPKG_PKGHOME} ${DNSCRYPT_PROXY} --config ${CFG_FILE} --pidfile ${PID_FILE}"
SVC_BACKGROUND=y

echo "DSM Version: $SYNOPKG_DSM_VERSION_MAJOR.$SYNOPKG_DSM_VERSION_MINOR-$SYNOPKG_DSM_VERSION_BUILD"
# SRM 1.2 example: DSM Version: 5.2-7915
# DSM 6.2 example: DSM Version: 6.2-23739

migrate_files () { # from 2.0.44 to 2.0.45
    # we are already running as ${EFF_USER} user
    sed -i -e "s|^user_name\s*=.*|# user_name = '${EFF_USER:="nobody"}'|g" "${SYNOPKG_PKGVAR}/dnscrypt-proxy.toml"

    if [ -f "${SYNOPKG_PKGVAR}/blacklist.txt" ]; then
        mv "${SYNOPKG_PKGVAR}/blacklist.txt" "${SYNOPKG_PKGVAR}/domains-blocklist.txt"
    fi
    if [ -f "${SYNOPKG_PKGVAR}/domains-blacklist.conf" ]; then
        mv "${SYNOPKG_PKGVAR}/domains-blacklist.conf" "${SYNOPKG_PKGVAR}/domains-blocklist.conf"
    fi
    if [ -f "${SYNOPKG_PKGVAR}/generate-domains-blacklist.py" ]; then
        mv "${SYNOPKG_PKGVAR}/generate-domains-blacklist.py" "${SYNOPKG_PKGVAR}/generate-domains-blocklist.py"
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

    ## OLD
    # blacklist.txt               dnscrypt-proxy.toml                    forwarding-rules.txt           public-resolvers.md.minisig
    # cloaking-rules.txt          domains-blacklist.conf                 generate-domains-blacklist.py  relays.md
    # dnscrypt-proxy_install.log  domains-blacklist-local-additions.txt  ip-blacklist.txt               relays.md.minisig
    # dnscrypt-proxy.log          domains-time-restricted.txt                                           update-blocklist.sh
    # dnscrypt-proxy.pid          domains-whitelist.txt                  public-resolvers.md            whitelist.txt

    ## NEW
    # allowed-ips.txt      cloaking-rules.txt     domains-blocklist.conf                 public-resolvers.md
    # allowed-names.txt    dnscrypt-proxy.log     domains-blocklist-local-additions.txt  public-resolvers.md.minisig
    # blocked-ips.txt      dnscrypt-proxy.pid     domains-time-restricted.txt            relays.md
    # blocked-names.txt    dnscrypt-proxy.toml    forwarding-rules.txt                   relays.md.minisig
    # captive-portals.txt  domains-allowlist.txt  generate-domains-blocklist.py
}

blocklist_setup () {
    ## https://github.com/jedisct1/dnscrypt-proxy/wiki/Public-blocklists
    ## https://github.com/jedisct1/dnscrypt-proxy/tree/master/utils/generate-domains-blocklists
    echo "Install/Upgrade generate-domains-blocklist.py (requires python)"
    mkdir -p "${SYNOPKG_PKGDEST}/var"
    touch "${SYNOPKG_PKGVAR}"/ip-blocklist.txt
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

# restart_dhcpd () {
#     /etc/rc.network nat-restart-dhcp >> "${LOG_FILE}" 2>&1
# }

# forward_dns_dhcpd () {
#     echo "dns forwarding - $1" >> "${LOG_FILE}"
#     if [ "$1" = "no" ] && [ -f /etc/dhcpd/dhcpd-dnscrypt-dnscrypt.conf ]; then
#         if [ "$OS" = "dsm" ]; then
#             echo "enable=no" > /etc/dhcpd/dhcpd-dns-dns.info
#         else
#             echo "enable=no" > /etc/dhcpd/dhcpd-dnscrypt-dnscrypt.info
#         fi
#         restart_dhcpd
#     elif [ "$1" = "yes" ]; then
#         if pgrep "dhcpd.conf"; then  # if dhcpd (dnsmasq) is enabled and running
#             if [ "$OS" = "dsm" ]; then
#                 echo "server=127.0.0.1#${BACKUP_PORT}" > /etc/dhcpd/dhcpd-dns-dns.conf
#                 echo "enable=yes" > /etc/dhcpd/dhcpd-dns-dns.info
#                 # /etc/dhcpd/dhcpd-vendor.conf
#                 # /etc/dhcpd/dhcpd-dns-dns.conf
#             else # RSM
#                 echo "server=127.0.0.1#${BACKUP_PORT}" > /etc/dhcpd/dhcpd-dnscrypt-dnscrypt.conf
#                 echo "enable=yes" > /etc/dhcpd/dhcpd-dnscrypt-dnscrypt.info
#             fi
#             restart_dhcpd
#         else
#             echo "pgrep: no process with 'dhcpd.conf' found" >> "${LOG_FILE}"
#         fi
#     fi
# }

# service_prestart () {
#     if [ "$OS" = 'dsm' ] && [ "$SYNOPKG_DSM_VERSION_MAJOR" -lt 7 ] || [ "$OS" = 'srm' ]; then
#         blocklist_cron_install

#         forward_dns_dhcpd "yes"
#         cd "$SVC_CWD" || exit 1

#         # Limit num of processes https://golang.org/pkg/runtime/
#         #
#         # Fixes https://github.com/ksonnet/ksonnet/issues/298
#         #  until https://github.com/golang/go/commit/3a18f0ecb5748488501c565e995ec12a29e66966
#         #  is released.
#         # related https://github.com/golang/go/issues/14626
#         # https://github.com/golang/go/blob/release-branch.go1.11/src/os/user/lookup_stubs.go
#         #
#         # override community script from this point and launch the program ourselves
#         env GOMAXPROCS=1 USER=root HOME=/root "${DNSCRYPT_PROXY}" --config "${CFG_FILE}" --pidfile "${PID_FILE}" &
#         # su "${EFF_USER}" -s /bin/false -c "cd ${SVC_CWD}; ${DNSCRYPT_PROXY} --config ${CFG_FILE} --pidfile ${PID_FILE} --logfile ${LOG_FILE}" &
#     fi
# }

# service_poststop () {
#     if [ "$OS" = 'dsm' ] && [ "$SYNOPKG_DSM_VERSION_MAJOR" -lt 7 ] || [ "$OS" = 'srm' ]; then
#         blocklist_cron_uninstall
#         forward_dns_dhcpd "no"
#     fi
# }

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
        # if [ servicetool --conf-port-conflict-check --tcp 53]
        sed -i -e "s/listen_addresses = .*/listen_addresses = \['0.0.0.0:$SERVICE_PORT'\]/" \
                -e "s/require_dnssec = .*/require_dnssec = true/" \
                -e "s/netprobe_timeout = .*/netprobe_timeout = 2/" \
                -e "s/ipv6_servers = .*/ipv6_servers = false/" \
                "${CFG_FILE}"

        # allow synocommuity group access (synoedit)
        chmod g+rw -R "$SYNOPKG_PKGVAR"

    fi

    blocklist_setup
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
    cp -f "${SYNOPKG_PKGDEST}"/blocklist/generate-domains-blocklist.py "${SYNOPKG_PKGVAR}/"
}
