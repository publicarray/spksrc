WEB_DIR="/var/services/web_packages"
if [ $SYNOPKG_DSM_VERSION_MAJOR -lt 7 ];then
SYNOPKG_TEMP_UPGRADE_FOLDER="${SYNOPKG_PKGDEST}/../../@tmp/${SYNOPKG_PKGNAME}"
WEB_DIR="/var/services/web"
fi

PHP="/usr/local/bin/php74"
MYSQL="/var/packages/MariaDB10/target/usr/local/mariadb10/bin/mysql"
MYSQLDUMP="/var/packages/MariaDB10/target/usr/local/mariadb10/bin/mysqldump"

CFG_FILE="${WEB_DIR}/${SYNOPKG_PKGNAME}/app/config/parameters.yml"
MYSQL_USER=${SYNOPKG_PKGNAME}
MYSQL_DATABASE=${SYNOPKG_PKGNAME}

service_preinst ()
{
    # make sure the logfiles can log
    mkdir -p ${WEB_DIR}/${SYNOPKG_PKGNAME}
    # Check database
    if [ "${SYNOPKG_PKG_STATUS}" == "INSTALL" ]; then
        if ! ${MYSQL} -u root -p"${wizard_mysql_password_root}" -e quit > /dev/null 2>&1; then
            echo "Incorrect MySQL root password"
            exit 1
        fi
        # if ${MYSQL} -u root -p"${wizard_mysql_password_root}" mysql -e "SELECT User FROM user" | grep ^${MYSQL_USER}$ > /dev/null 2>&1; then
        #     echo "MySQL user ${MYSQL_USER} already exists"
        #     exit 1
        # fi
        # if ${MYSQL} -u root -p"${wizard_mysql_password_root}" -e "SHOW DATABASES" | grep ^${MYSQL_DATABASE}$ > /dev/null 2>&1; then
        #     echo "MySQL database ${MYSQL_DATABASE} already exists"
        #     exit 1
        # fi
    fi
    exit 0
}

service_postinst ()
{
    # 'rand-pw' is not fully implemented on DSM 6 it requires 'user-pw' (mariadb10-db)
    # $ cat /var/log/messages
    # > dsm6 synoscgi_SYNO.Core.Package.Installation_1_install[27600]: synomariadbworker.cpp:483 Illegal field [grant-user][user-pw].
    # > dsm6 synoscgi_SYNO.Core.Package.Installation_1_install[27600]: resource_api.cpp:190 Acquire mariadb10-db for wallabag when 0x0001 (fail)
    # > dsm6 synoscgi_SYNO.Core.Package.Installation_1_install[27600]: resource_api.cpp:205 Rollback mariadb10-db for wallabag when 0x0001 (done)
    # > dsm6 synoscgi_SYNO.Core.Package.Installation_1_install[26609]: pkginstall.cpp:735 Failed to acquire resource before install wallabag [0xD900 manager.cpp:204]

    # if [ -z $SYNOPKG_DB_USER_RAND_PW ]; then
    #     echo "error with install wizard, no db password" 1>&2;
    #     #exit 1
    # fi

    if [ $SYNOPKG_DSM_VERSION_MAJOR -lt 7 ]; then
        # Install the web interface
        cp -pR ${SYNOPKG_PKGDEST}/share/${SYNOPKG_PKGNAME} ${WEB_DIR}
    fi

    if [ "${SYNOPKG_PKG_STATUS}" == "INSTALL" ]; then
        # create wallabag database and user
        # if [ $SYNOPKG_DSM_VERSION_MAJOR -lt 5 ];then
        #     ${MYSQL} -u root -p"${wizard_mysql_password_root}" -e "CREATE DATABASE ${MYSQL_DATABASE}; GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'localhost' IDENTIFIED BY '${wizard_mysql_database_password}';"
        # fi

        # render properties
        sed -i -e "s|@database_password@|${wizard_wallabag_password_root}|g" \
            -e "s|@database_name@|${MYSQL_DATABASE}|g" \
            -e "s|@database_port@|${wizard_database_port}|g" \
            -e "s|@protocoll_and_domain_name@|${wizard_protocoll_and_domain_name}/wallabag/web|g" \
            -e "s|@wallabag_secret@|$(cat /dev/urandom 2>/dev/null| env LC_ALL=C tr -dc 'a-zA-Z0-9' 2>/dev/null | head -c 30 | head -n 1)|g" ${CFG_FILE}

        # install wallabag
        if ! ${PHP} ${WEB_DIR}/${SYNOPKG_PKGNAME}/bin/console wallabag:install --env=prod --reset -n -vvv > ${WEB_DIR}/${SYNOPKG_PKGNAME}/install.log 2>&1; then
            echo "Failed to install wallabag. Please check the log: ${WEB_DIR}/${SYNOPKG_PKGNAME}/install.log"
            exit 1
        fi
    fi

    if [ $SYNOPKG_DSM_VERSION_MAJOR -lt 7 ];then
        # permissions
        chown -R http:http ${WEB_DIR}/${SYNOPKG_PKGNAME}
    fi
    exit 0
}

service_preuninst ()
{
    # Check database
    # if [ "${SYNOPKG_PKG_STATUS}" == "UNINSTALL" ] && ! ${MYSQL} -u root -p"${wizard_mysql_password_root}" -e quit > /dev/null 2>&1; then
    #     echo "Incorrect MySQL root password"
    #     exit 1
    # fi

    # Check database export location
    if [ "${SYNOPKG_PKG_STATUS}" == "UNINSTALL" -a -n "${wizard_dbexport_path}" ]; then
        if [ -f "${wizard_dbexport_path}" -o -e "${wizard_dbexport_path}/${MYSQL_DATABASE}.sql" ]; then
            echo "File ${wizard_dbexport_path}/${MYSQL_DATABASE}.sql already exists. Please remove or choose a different location"
            exit 1
        fi
    fi

    exit 0
}

service_postuninst ()
{
    # Export and remove database
    # if [ "${SYNOPKG_PKG_STATUS}" == "UNINSTALL" ]; then
    #     if [ -n "${wizard_dbexport_path}" ]; then
    #         mkdir -p ${wizard_dbexport_path}
    #         ${MYSQLDUMP} -u root -p"${wizard_mysql_password_root}" ${MYSQL_DATABASE} > ${wizard_dbexport_path}/${MYSQL_DATABASE}.sql
    #     fi
    #     # if [ $SYNOPKG_DSM_VERSION_MAJOR -lt 5 ]; then
    #     #     ${MYSQL} -u root -p"${wizard_mysql_password_root}" -e "DROP DATABASE ${MYSQL_DATABASE}; DROP USER '${MYSQL_USER}'@'localhost';"
    #     # fi
    # fi

    if [ $SYNOPKG_DSM_VERSION_MAJOR -lt 7 ]; then
        # Remove the web interface
        rm -rf ${WEB_DIR}/${SYNOPKG_PKGNAME}
    fi
    exit 0
}

service_preupgrade ()
{
    mkdir -p ${SYNOPKG_TEMP_UPGRADE_FOLDER}
    mv -f ${CFG_FILE} ${SYNOPKG_TEMP_UPGRADE_FOLDER}/
    mv -f ${WEB_DIR}/${SYNOPKG_PKGNAME}/data/db ${SYNOPKG_TEMP_UPGRADE_FOLDER}/
    exit 0
}

service_postupgrade ()
{
    mv -f ${SYNOPKG_TEMP_UPGRADE_FOLDER}/parameters.yml ${CFG_FILE}
    mv -f ${SYNOPKG_TEMP_UPGRADE_FOLDER}/db ${WEB_DIR}/${SYNOPKG_PKGNAME}/data/db

    # Add new parameters to parameters.yml for new version
    if ! grep -q '^    server_name:' ${CFG_FILE}; then
        echo '    server_name: "wallabag"' >> ${CFG_FILE}
    fi

    # migrate database
    if ! ${PHP} ${WEB_DIR}/${SYNOPKG_PKGNAME}/bin/console doctrine:migrations:migrate --env=prod -n -vvv > ${WEB_DIR}/${SYNOPKG_PKGNAME}/migration.log 2>&1; then
        echo "Unable to migrate database schema. Please check the log: ${WEB_DIR}/${SYNOPKG_PKGNAME}/migration.log"
        exit 1
    fi

    if [ $SYNOPKG_DSM_VERSION_MAJOR -lt 7 ];then
        # permissions after upgrade
        chown -R ${USER} ${WEB_DIR}/${SYNOPKG_PKGNAME}
    fi

    rm -rf ${SYNOPKG_TEMP_UPGRADE_FOLDER}/
    exit 0
}
