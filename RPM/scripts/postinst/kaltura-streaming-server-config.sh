#!/bin/bash
#===============================================================================
#          FILE: installer
#         USAGE: ./installer
#   DESCRIPTION: runs installation of KES
#       OPTIONS: ---
#       LICENSE: AGPLv3+
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Igor Shevach <igor.shevach@kaltura.com>
#  ORGANIZATION: Kaltura, inc.
#       CREATED: 22/02/15 09:23:34 EST
#      REVISION:  ---
#===============================================================================

SCRIPT_DIR=$(readlink -f $(dirname $0))

ECDN_PATH=$(dirname $SCRIPT_DIR/../app/configurations/ecdn/properties.ini)

. SCRIPT_DIR/common_functions
. $ECDN_PATH/properties.ini



setup_ecdn()
{
        [ -r "$KALTURA_ECDN_CONFIG_FILE_PATH" ] &&  mv -f $KALTURA_ECDN_CONFIG_FILE_PATH $KALTURA_ECDN_CONFIG_FILE_PATH.bak

	while [ -z "$PARTNER_ID" ]; do
		read -sp "${CYAN}Enter partner ID:
${NORMAL}" PARTNER_ID
	done

	while [ -z "$ADMIN_SECRET" ]; do
                read -sp "${CYAN}Enter admin secret:
${NORMAL}" ADMIN_SECRET
        done

        if [ -z "$BASE_DIR" ]; then
                BASE_DIR=/opt/kaltura
        fi

        if [ -z "$APP_DIR" ]; then
                APP_DIR=$BASE_DIR/app
        fi

    	if [ -z "$apphome_url" ];then
	    	apphome_url=http://www.kaltura.com
	    fi

        if [ -z "$LOG_DIR" ];then
                LOG_DIR=$BASE_DIR/media-server/logs
        fi


        if [ -z "$ASYNC_CLIENT_APP_DIR" ];then
            ASYNC_CLIENT_APP_DIR=$BASE_DIR/AsyncMediaServerProcessClientApp
            [ -r "$ASYNC_CLIENT_APP_DIR" ] || _S "ASYNC_CLIENT_APP_DIR does not exists!"
        fi

	    if [ -z "$UPLOAD_XML_DIR" ];then
            UPLOAD_XML_DIR=$ASYNC_CLIENT_APP_DIR/uploadXMLSavePath
        fi

        if [ ! -d $UPLOAD_XML_DIR ]; then
            mkdir -p $UPLOAD_XML_DIR || _S "mkdir -p $UPLOAD_XML_DIR"
        fi

        sudo getent group kaltura >/dev/null || sudo groupadd -g 613 -r kaltura

        sudo chown root:kaltura $UPLOAD_XML_DIR

       while [  -z $TIMEZONE ]; do
           read -p "
${WHITE} Timezone has not been set  Please enter timezone ${NORMAL}
" TIMEZONE
        done

echo "BASE_DIR=$BASE_DIR
LOG_DIR=$LOG_DIR
PARTNER_ID=$PARTNER_ID
ADMIN_SECRET=$ADMIN_SECRET
BIN_DIR=$BASE_DIR/bin
APP_DIR=$APP_DIR
apphome_url=$apphome_url
UPLOAD_XML_DIR=$UPLOAD_XML_DIR
ASYNC_CLIENT_APP_DIR=$ASYNC_CLIENT_APP_DIR
TIMEZONE=$TIMEZONE
" > $KALTURA_ECDN_CONFIG_FILE_PATH

. $KALTURA_ECDN_CONFIG_FILE_PATH

}

streaming_server_configure()
{
 	setup_ecdn

	 cd $BASE_DIR/media-server

	 export KALTURA_ECDN_CONFIG_FILE_PATH

 	 sudo $BIN_DIR/kaltura-media-server-config.sh $ANSFILE || _S "exec kaltura-media-server-config.sh"

	 sudo bash $BIN_DIR/kaltura-async-uploader-config.sh $KALTURA_ECDN_CONFIG_FILE_PATH || _S "sudo bash kaltura-async-uploader-config.sh"

	cd $ECDN_PATH

	ant || _S "ant"

echo "${CYAN}
    #######################################################################################################
    #           finished configuring ecdn.                                                                #
    #           please run $BIN_DIR/kaltura-streaming-server-configure-firewall.sh to setup firewall.             #
    #######################################################################################################
${NORMAL}"
	echo "${CYAN}ecdn: finished installing media-server${NORMAL}"
}

monit_configure()
{
    echo "${CYAN}ecdn: configure monit fir KSS${NORMAL}"

   sed -e "s#@WOWZA_STREAMING_ENGINE_PID_FILE@#/var/run/$WSE_NAME.pid#g" \
         -e "s#@WOWZA_STREAMING_ENGINE_SERVICE@#$WSE_NAME#g" \
         -e "s#@WOWZA_STREAMING_ENGINE_CONF_DIR@#/usr/local/$WSE_NA/conf#g" \
         $APP_DIR/configurations/ecdn/wowsase.template.rc > $APP_DIR/configurations/monit/monit.avail/wowsase.rc

   sed -e "s#@WOWZA_STREAMING_ENGINE_PID_FILE@#/var/run/$WSE_MANAGER_NAME.pid#g" \
         -e "s#@WOWZA_STREAMING_ENGINE_SERVICE@#$WSE_MANAGER_NAME#g" \
         $APP_DIR/configurations/ecdn/wowsasemanager.template.rc > $APP_DIR/configurations/monit/monit.avail/wowsasemanager.rc

   	service kaltura-monit restart 2>&1 | logger
}

if [ -z $ANSFILE ] && [ -r $1 ]; then
        ANSFILE=$1
fi

if [[ -r $ANSFILE ]] ;then
        . $ANSFILE
fi


streaming_server_configure

monit_configure

echo "finished configure KSS"

