#!/bin/bash -e 
#===============================================================================
#          FILE: package_kaltura-streaming-server.sh
#         USAGE: ./package_kaltura-streaming-server.sh
#   DESCRIPTION: 
#       OPTIONS: ---
# 	LICENSE: AGPLv3+
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Igor Shevach  (), <igor.shevach@kaltura.com>
#  ORGANIZATION: Kaltura, inc.
#       CREATED: 01/04/15 08:46:43 EST
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
SOURCES_RC=`dirname $0`/sources.rc
if [ ! -r $SOURCES_RC ];then
	echo "Could not find $SOURCES_RC"
	exit 1
fi
. $SOURCES_RC 
if [ ! -x "`which wget 2>/dev/null`" ];then
	echo "Need to install wget."
	exit 2
fi

#mkdir -p $RPM_SOURCES_DIR/$KALTURA_STREAMING_SERVER_RPM_NAME

if [ -x "`which rpmbuild 2>/dev/null`" ];then
	rpmbuild -ba $RPM_SPECS_DIR/$KALTURA_STREAMING_SERVER_RPM_NAME.spec
fi
