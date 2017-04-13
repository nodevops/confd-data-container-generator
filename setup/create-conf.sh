#!/bin/sh

# WARNIND: the option '-e' disapear when the script is launched inside alpine OS (docker)

ENV=dev-local
APP_VERSION=v0.1.0
TAG=${APP_VERSION}_${ENV}
REPO="git@gitlab.com:cfurmaniak/guestbook-configuration-confd.git"
WORKDIR=$(pwd)/tmp
OUTDIR=$(pwd)/config
OUTDIR_DATA=${OUTDIR}/data
OUTDIR_DICT=${OUTDIR}/dictionaries
OUTPUT_FILE_CONFIG_NAME=env.sh

print_usage(){
	echo -e 
	echo -e ""
	echo -e
}

print_state(){
	echo -e 
	echo -e "#################################"
	echo -e "$1"
	echo -e "#################################"
}

manage_arguments(){
	echo -e "Arguemnts managed!"
}

import_repo(){
	cd ${WORKDIR}
	git clone -b ${TAG} ${REPO} repo
	echo -e "Repository imported!"
}

generate_file_env(){
	# TODO: implement new output type
	./generate-file-env.py -t env -e ${ENV} -f ${OUTDIR_DICT}/${OUTPUT_FILE_CONFIG_NAME} -r ${WORKDIR}/repo/dictionaries
	echo -e "File env.sh generated!"
}

merge_data(){
	cd ${WORKDIR}/repo/data
	cp -v common/* ${OUTDIR_DATA}/
	cp -v ${ENV}/* ${OUTDIR_DATA}/
	echo -e "Data merged!"
}

###########################################################################################
# main
###########################################################################################

rm -vrf tmp/*
rm -vr ${OUTDIR_DICT}/*
rm -vr ${OUTDIR_DATA}/*

print_state "Arguments checking…"
manage_arguments

print_state "Repository downlaoding…"
import_repo

print_state "configuration generating…"
generate_file_env

print_state "Data merging…"
merge_data
