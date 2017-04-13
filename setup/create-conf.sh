#!/bin/sh

# WARNING: the option '-e' disappear when the script is launched inside alpine OS (docker)

print_usage(){
	echo -e 
	echo -e "--long_argument=VALUE OR -sVALUE"
	echo -e
}

print_state(){
	echo -e 
	echo -e "#################################"
	echo -e "$1"
	echo -e "#################################"
}

import_repo(){
	cd ${WORKDIR}
	git clone -b ${TAG} ${REPO} repo
	echo -e "Repository imported!"
}

generate_file_env(){
	# TODO: implement new output type
	generate-file-env.py -t env -e ${ENV} -f ${OUT_DIR_DICT}/${OUTPUT_FILE_CONFIG_NAME} -r ${WORKDIR}/repo/dictionaries
	echo -e "File ${OUTPUT_FILE_CONFIG_NAME} generated!"
}

merge_data(){
	cd ${WORKDIR}/repo/data
	cp -v common/* ${OUT_DIR_DATA}/
	cp -v ${ENV}/* ${OUT_DIR_DATA}/
	echo -e "Data merged!"
}

###########################################################################################
# main
###########################################################################################

# clean last test
rm -rf tmp/repo
rm -r config/data/*
rm -r config/dictionaries/*

# default values
ENV=dev-local
APP_VERSION=v0.1.0
TAG=${APP_VERSION}_${ENV}
REPO="git@gitlab.com:cfurmaniak/guestbook-configuration-confd.git"
WORKDIR=$(pwd)/tmp
OUT_DIR=$(pwd)/config
OUT_DIR_DATA=${OUT_DIR}/data
OUT_DIR_DICT=${OUT_DIR}/dictionaries
OUTPUT_FILE_CONFIG_NAME=env.sh

# read the options
SHORT_OPTS="h::r::v::e::w::n::o::"
LONG_OPTS="help::,repository::,app-version::,environment::,working-directory::,config-file-name::,out-directory::"
TEMP=`getopt -o ${SHORT_OPTS} --long ${LONG_OPTS} -- "$@"`
eval set -- "${TEMP}"

# extract options and their arguments into variables.
while true ; do
    case "$1" in
        -r|--repository)
            case "$2" in
                "") REPO="git@gitlab.com:cfurmaniak/guestbook-configuration-confd.git" ; shift 2 ;;
                *) REPO=$2 ; shift 2 ;;
            esac ;;
        -v|--app-version)
            case "$2" in
                "") APP_VERSION=v0.1.0 ; shift 2 ;;
                *) APP_VERSION=$2 ; shift 2 ;;
            esac ;;
        -e|--environment)
            case "$2" in
                "") ENV=dev-local ; shift 2 ;;
                *) ENV=$2 ; shift 2 ;;
            esac ;;
        -w|--working-directory)
            case "$2" in
                "") WORKDIR=$(pwd)/tmp ; shift 2 ;;
                *) WORKDIR=$2 ; shift 2 ;;
            esac ;;
        -n|--config-file-name)
            case "$2" in
                "") OUTPUT_FILE_CONFIG_NAME=env.sh ; shift 2 ;;
                *) OUTPUT_FILE_CONFIG_NAME=$2 ; shift 2 ;;
            esac ;;
        -o|--out-directory)
            case "$2" in
                "") OUT_DIR=$(pwd)/config ; shift 2 ;;
                *) OUT_DIR=$2 ; shift 2 ;;
            esac ;;
        --)
            shift
            TAG=${APP_VERSION}_${ENV} ; OUT_DIR_DATA=${OUT_DIR}/data ; OUT_DIR_DICT=${OUT_DIR}/dictionaries
            break ;;
        -h|--help) print_usage ; exit 1 ;;
        *) print_usage ; exit 1 ;;
    esac
done

print_state "Configuration"
echo -e "\t ENV=${ENV}"
echo -e "\t APP_VERSION=${APP_VERSION}"
echo -e "\t TAG=${TAG}"
echo -e "\t REPO=${REPO}"
echo -e "\t WORKDIR=${WORKDIR}"
echo -e "\t OUTDIR=${OUT_DIR}"
echo -e "\t OUTDIR_DATA=${OUT_DIR_DATA}"
echo -e "\t OUTDIR_DICT=${OUT_DIR_DICT}"
echo -e "\t OUTPUT_FILE_CONFIG_NAME=${OUTPUT_FILE_CONFIG_NAME}"

print_state "Repository downloading…"
import_repo

print_state "Configuration generating…"
generate_file_env

print_state "Data merging…"
merge_data
