#!/bin/bash

set -x

print_usage() {
    echo -e
    echo -e "Utilisation : create-conf.sh [OPTION]..."
    echo -e "Generate a file for export environment variables from dictionaries."
    echo -e "Merge files from data into one single folder"
    echo -e
    echo -e "\t -h, --help               print this help"
    echo -e "\t -r, --repository         url for the cloneable repository"
    echo -e "\t                          (default value: https://gitlab.com/cfurmaniak/guestbook-configuration-confd.git"
    echo -e "\t -v, --app-version        application version on the repository"
    echo -e "\t                          (default value: v0.1.0)"
    echo -e "\t -e, --environment        name of the environment"
    echo -e "\t                          (default value: dev-local)"
    echo -e "\t -w, --working-directory  specify the working directory"
    echo -e "\t                          (default value: ./tmp should be create before)"
    echo -e "\t -n, --config-file-name   name of the output file generated"
    echo -e "\t                          (default value: env.sh)"
    echo -e "\t -o, --out-directory      folder where the generated file will be"
    echo -e "\t                          (default value: ./config should be create before)"
    echo -e
    echo -e "Examples:"
    echo -e "  ./create-conf.sh -vv2.2.6 -rhttps://github.com/vuejs/vue will generate value for this version of VUE.JS"
    echo -e
}

print_state() {
    echo -e
    echo -e "#################################"
    echo -e "$1"
    echo -e "#################################"
}

import_repo() {
    cd "${WORKDIR}" || exit 1
    git clone -b "${TAG}" "${REPO}" repo
    echo -e "Repository imported!"
}

generate_file_env() {
    # TODO: implement new output type (--env option)
    generate-file-env.py \
        --type env \
        --env "${ENV}" \
        --file "${OUT_DIR_DICT}/${OUTPUT_FILE_CONFIG_NAME}" \
        --root-path "${WORKDIR}/repo/dictionaries" && \
    echo -e "File ${OUTPUT_FILE_CONFIG_NAME} generated!"
}

merge_data() {
    cd "${WORKDIR}/repo/data" || exit 1
    cp -v common/* "${OUT_DIR_DATA}/" && \
    cp -v "${ENV}/*" "${OUT_DIR_DATA}/" && \
    echo -e "Data merged!"
}

###########################################################################################
# main
###########################################################################################

# default values
ENV=dev-local
APP_VERSION=v0.1.0
TAG=${APP_VERSION}_${ENV}
REPO="https://gitlab.com/cfurmaniak/guestbook-configuration-confd.git"
WORKDIR=$(pwd)/tmp
OUT_DIR=$(pwd)/config
OUT_DIR_DATA=${OUT_DIR}/data
OUT_DIR_DICT=${OUT_DIR}/dictionaries
OUTPUT_FILE_CONFIG_NAME=env.sh

# read the options
SHORT_OPTS="h::r::v::e::w::n::o::"
LONG_OPTS="help::,repository::,app-version::,environment::,working-directory::,config-file-name::,out-directory::"
TEMP=$(getopt -o ${SHORT_OPTS} --long ${LONG_OPTS} -- "$@")
eval set -- "${TEMP}"

# extract options and their arguments into variables.
while true ; do
    case "$1" in
        -r|--repository)
            case "$2" in
                "") REPO="https://gitlab.com/cfurmaniak/guestbook-configuration-confd.git" ; shift 2 ;;
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
        -h|--help) print_usage ; exit 0 ;;
        *) print_usage ; exit 1 ;;
    esac
done

print_state "Configuration $0"
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
