#!/bin/bash

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

create_docker_image(){
	docker build -t test .
	echo -e "Docker image created!"
}

publish_docker_image(){
	echo -e "Docker image published!"
}

###########################################################################################
# main
###########################################################################################

print_state "Arguments checking…"
manage_arguments

print_state "Data image creating…"
create_docker_image

print_state "Data image publishing…"
publish_docker_image
