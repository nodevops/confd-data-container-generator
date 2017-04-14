#!/bin/bash

print_usage() {
    echo -e
    echo -e "Utilisation : generate-data-image.sh [OPTION]..."
    echo -e "Generate a docker image with the configuration in a specific volume."
    echo -e "Publish with image on Docker Store"
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
    echo -e "\t -i, --image-name         docker image name"
    echo -e "\t                          (default value: data_config)"
    echo -e
    echo -e "Examples:"
    echo -e "  ./generate-data-image.sh -vv2.2.6 --image-name=data_config:v2.2.6"
    echo -e
}

print_state() {
    echo -e
    echo -e "#################################"
    echo -e "$1"
    echo -e "#################################"
}

create_docker_image() {
    docker build \
        -t "${IMAGE_NAME}" \
        --build-arg WORKDIR="${WORKDIR}" \
        --build-arg OUTDIR="${OUT_DIR}" \
        --build-arg REPOSITORY="${REPO}" \
        --build-arg VERSION="${APP_VERSION}" \
        --build-arg ENVIRONMENT="${ENV}" \
        --build-arg CONFIG_FILE_NAME="${OUTPUT_FILE_CONFIG_NAME}" \
        . && \
    echo -e "Docker image: ${IMAGE_NAME} created!"
}

publish_docker_image() {
    echo -e "Docker image published! (Not yet implemented)"
}

###########################################################################################
# main
###########################################################################################

# default values
ENV=dev-local
APP_VERSION=v0.1.0
REPO="https://gitlab.com/cfurmaniak/guestbook-configuration-confd.git"
WORKDIR=/var/tmp/
OUT_DIR=/config
OUTPUT_FILE_CONFIG_NAME=env.sh
IMAGE_NAME=data_config

# read the options
SHORT_OPTS="h::r::v::e::w::n::o::i::"
LONG_OPTS="help::,repository::,app-version::,environment::,working-directory::,config-file-name::,out-directory::image-name::"
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
                "") WORKDIR=/var/tmp/tmp ; shift 2 ;;
                 *) WORKDIR=$2 ; shift 2 ;;
            esac ;;
        -n|--config-file-name)
            case "$2" in
                "") OUTPUT_FILE_CONFIG_NAME=env.sh ; shift 2 ;;
                 *) OUTPUT_FILE_CONFIG_NAME=$2 ; shift 2 ;;
            esac ;;
        -o|--out-directory)
            case "$2" in
                "") OUT_DIR=/config ; shift 2 ;;
                 *) OUT_DIR=$2 ; shift 2 ;;
            esac ;;
        -i|--image-name)
            case "$2" in
                "") IMAGE_NAME=data_config ; shift 2 ;;
                 *) IMAGE_NAME=$2 ; shift 2 ;;
            esac ;;
        --) shift ; break ;;
        -h|--help) print_usage ; exit 0 ;;
        *) print_usage ; exit 1 ;;
    esac
done

print_state "Configuration $0"
echo -e "\t ENV=${ENV}"
echo -e "\t APP_VERSION=${APP_VERSION}"
echo -e "\t REPO=${REPO}"
echo -e "\t WORKDIR=${WORKDIR}"
echo -e "\t OUTDIR=${OUT_DIR}"
echo -e "\t OUTPUT_FILE_CONFIG_NAME=${OUTPUT_FILE_CONFIG_NAME}"
echo -e "\t IMAGE_NAME=${IMAGE_NAME}"

print_state "Data image creating…"
create_docker_image || exit

print_state "Data image publishing…"
publish_docker_image || exit
