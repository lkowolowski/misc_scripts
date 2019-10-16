#!/bin/sh

# things to collect for a dell hardware case
# getsysinfo
# getioinfo
# getdcinfo
# getpbinfo
# getsel
# getraclog
# racdump
# dumplogs
#
set -e

PATH="/bin:/usr/bin:/usr/local/bin"

while getopts "h:u:t" COMMAND_LINE_ARGUMENT ; do
        case "${COMMAND_LINE_ARGUMENT}" in
                u) USER=${OPTARG}
                        ;;
                h) HOST=${OPTARG}
                        ;;
                t) test_mode="YES"
                        ;;
                \?) echo "-h <host> is required, -u <user> is required"
                        exit 1
                        ;;
        esac
done

cmd_pfx=""
if [ "${test_mode}" = "YES" ]; then
        echo "Test Mode"
        cmd_pfx="echo Would issue"
fi

# Get password from user, we'll use this later
read -sp "Enter password for ${USER}: " password

# Create landing spot for all the logs
mkdir ${HOST}.logs

# Get all the logs and split them into 1 file each for easy viewing
for dump in getsysinfo getioinfo getdcinfo getpbinfo getsel getraclog racdump dumplogs ; do
	${cmd_pfx} script -q ${HOST}.logs/${HOST}.${dump}.log expect -c "spawn ssh ${USER}@${HOST} \"$dump\"; expect \"assword:\"; send \"$password\r\"; interact"
done

# tar up all the logs to make it easy to submit to TAC
tar -cvf ${HOST}.logs.tar ${HOST}.logs

# Cleanup after we're done
rm -rf ${HOST}.logs
