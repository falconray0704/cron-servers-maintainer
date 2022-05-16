#!/bin/bash

#set -x

#. $(pwd)/.env

SERVER_NAME=bookstack
BACKUP_PATH=$(pwd)/backups
BACKUP_TMP_PATH=$(pwd)/tmp
LOGS_PATH=$(pwd)/logs

export SERVERS_ROOT_PATH="${SERVERS_ROOT_PATH:-/opt}"
export SERVERS_MAINTAIN_ROOT_PATH="${SERVERS_MAINTAIN_ROOT_PATH:-$(realpath ../../)}"
export TMP_DIR="${TMP_DIR:-tmp}"

. ${SERVERS_MAINTAIN_ROOT_PATH}/libShell/time.lib

TIMESTAMP=$(timestamp)

BACKUP_FILE_TMP=${BACKUP_TMP_PATH}/${SERVER_NAME}-${TIMESTAMP}.tar.bz2

mkdir -p ${BACKUP_PATH}
mkdir -p ${BACKUP_TMP_PATH}
mkdir -p ${LOGS_PATH}

echo "Servers root path: ${SERVERS_ROOT_PATH}"
echo "Servers maintain root path: ${SERVERS_MAINTAIN_ROOT_PATH}"
echo "${SERVER_NAME} backup path: ${BACKUP_PATH}"
echo "${SERVER_NAME} backup tmp path: ${BACKUP_TMP_PATH}"
echo "${SERVER_NAME} logs path: ${LOGS_PATH}"
echo "BACKUP_FILE_TMP: ${BACKUP_FILE_TMP}"
echo "PWD: ${PWD}"
#exit 1

pushd ${SERVERS_ROOT_PATH}/${SERVER_NAME}


docker compose down

if [ $? -ne 0 ]
then
    echo "Bookstack down fail:${TIMESTAMP}" >> ${LOGS_PATH}/${TIMESTAMP}.log
    exit 1
fi

popd

tar -jcf ${BACKUP_FILE_TMP} ${SERVERS_ROOT_PATH}/${SERVER_NAME}

if [ $? -ne 0 ]
then
    echo "Bookstack try backup fail:${TIMESTAMP}" >> ${LOGS_PATH}/${TIMESTAMP}.log
    rm -rf ${BACKUP_FILE_TMP}
    exit 1
fi

tar -jtf ${BACKUP_FILE_TMP}

if [ $? -ne 0 ]
then
    echo "Bookstack check backup file fail:${TIMESTAMP}" >> ${LOGS_PATH}/${TIMESTAMP}.log
    rm -rf ${BACKUP_FILE_TMP}
    exit 1
fi

cp ${BACKUP_FILE_TMP} ${BACKUP_PATH}/${SERVER_NAME}.tar.bz2

if [ $? -ne 0 ]
then
    echo "Bookstack copy backup file fail:${TIMESTAMP}" >> ${LOGS_PATH}/${TIMESTAMP}.log
    exit 1
else
    rm -rf ${BACKUP_FILE_TMP}
    echo "Bookstack backup success:${TIMESTAMP}" >> ${LOGS_PATH}/${TIMESTAMP}.log
fi

pushd ${SERVERS_ROOT_PATH}/bookstack

docker compose up -d

if [ $? -ne 0 ]
then
    echo "Server ${SERVER_NAME} up fail:${TIMESTAMP}" >> ${LOGS_PATH}/${TIMESTAMP}.log
    exit 1
else
    echo "Server ${SERVER_NAME} up success:${TIMESTAMP}" >> ${LOGS_PATH}/${TIMESTAMP}.log
fi

popd


