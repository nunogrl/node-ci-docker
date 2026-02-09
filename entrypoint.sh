#!/bin/sh

if [ `id -u` -ne 0 ]; then
	echo "Current user must be root";
	exit 1;
fi;

USER="root";
UID=0;
GID=0;

HOME=`getent passwd "$UID" | cut -d: -f6`;

echo "*** Running nci";
echo "USER: $USER, UID: $UID, GID: $GID, HOME: $HOME";
cat /var/nci/dependencies-info.txt;
echo "***";

cd /var/nci || exit 1;
exec node_modules/.bin/nci;
