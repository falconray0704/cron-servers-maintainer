#!/bin/bash

set -o nounset
set -o errexit
# trace each command execute, same as `bash -v myscripts.sh`
#set -o verbose
# trace each command execute with attachment infomations, same as `bash -x myscripts.sh`
#set -o xtrace

#set -o
set -e
#set -x

export SERVERS_ROOT_PATH="/mnt/cdd/servers"
export SERVERS_MAINTAIN_ROOT_PATH="$(dirname $(realpath $0))"
export TMP_DIR="tmp"

export LIBSHELL_ROOT_PATH="${SERVERS_MAINTAIN_ROOT_PATH}/libShell"

. ${LIBSHELL_ROOT_PATH}/echo_color.lib
. ${LIBSHELL_ROOT_PATH}/utils.lib
. ${LIBSHELL_ROOT_PATH}/sysEnv.lib


# Checking environment setup symbolic link and its file exists
if [ -L "${SERVERS_MAINTAIN_ROOT_PATH}/.env_setup" ] && [ -f "${SERVERS_MAINTAIN_ROOT_PATH}/.env_setup" ]
then
#    echoG "Symbolic .env_setup exists."
    . ${SERVERS_MAINTAIN_ROOT_PATH}/.env_setup
else
    echoR "Setup environment informations by making .env_setup symbolic link to specific .env_setup_xxx file(eg: .env_setup_amd64_ubt_1804) ."
    exit 1
fi

detective_servers()
{
    local DETECTIVED_SERVERS_DIR=""
    local LISTED_ITEMS=$(ls "${SERVERS_MAINTAIN_ROOT_PATH}/servers")
    for item in ${LISTED_ITEMS}
    do
        if [ -d "${SERVERS_MAINTAIN_ROOT_PATH}/servers/${item}" ] && \
            [ -f "${SERVERS_MAINTAIN_ROOT_PATH}/servers/${item}/run.sh" ]
        then
            DETECTIVED_SERVERS_DIR="${DETECTIVED_SERVERS_DIR} ${item}"
        fi
    done
    echo ${DETECTIVED_SERVERS_DIR}
}

confirm_backup_items()
{
    local target_servers=`echo $1 | tr "," " "`
    local DETECTIVED_SERVERS=$2


    for item in $target_servers
    do
        if ! exists_in_list "${DETECTIVED_SERVERS}" " " "${item}"
        then
            echoR "Target: ${item} is not in DETECTIVED_SERVERS: ${DETECTIVED_SERVERS}"
            exit 1
        fi
    done
}

SUPPORTED_CMD="backup"
SUPPORTED_TARGETS=$(detective_servers)

EXEC_CMD=""
EXEC_ITEMS_LIST=""

backup_server()
{
    echoY "Backuping server: $1"

    ./run.sh

    if [ $? -eq 0 ]
    then
        echoG "Backuped $1 successed!"
    else
        echoR "Backup $1 failed!!!"
    fi

}

backup_servers()
{
    echoY "Backuping servers: $1"

    local target_servers=`echo $1 | tr "," " "`

    for server in ${target_servers}
    do
        pushd ${SERVERS_MAINTAIN_ROOT_PATH}/servers/${server}
        backup_server $server
        popd
    done

    echoG "Backuped servers: $1 successfully!"

}

usage_func()
{

    echoY "Usage:"
    echoY './run.sh -c <cmd> -l "<item list>"'
    echoY "eg:\n./run.sh -c backup -l \"bookstack\""

    echoC "Supported cmd:"
    echo "${SUPPORTED_CMD}"
    echoC "Supported items:"
    echo "${SUPPORTED_TARGETS}"
    
}

no_args="true"
while getopts "c:l:" opts
do
    case $opts in
        c)
              # cmd
              EXEC_CMD=$OPTARG
              ;;
        l)
              # items list
              EXEC_ITEMS_LIST=$OPTARG
              ;;
        :)
            echo "The option -$OPTARG requires an argument."
            exit 1
            ;;
        ?)
            echo "Invalid option: -$OPTARG"
            usage_func
            exit 2
            ;;
        *)    #unknown error?
              echoR "unkonw error."
              usage_func
              exit 1
              ;;
    esac
    no_args="false"
done

[[ "$no_args" == "true" ]] && { usage_func; exit 1; }
#[ $# -lt 1 ] && echoR "Invalid args count:$# " && usage_func && exit 1

is_root_func


case ${EXEC_CMD} in
    "backup")
        confirm_backup_items "${EXEC_ITEMS_LIST}" "${SUPPORTED_TARGETS}"
        backup_servers ${EXEC_ITEMS_LIST}
        ;;
    "*")
        echoR "Unsupport cmd:${EXEC_CMD}"
        ;;
esac



