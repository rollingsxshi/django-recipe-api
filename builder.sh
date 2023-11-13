#!/bin/bash
# This helper file contains shortcuts for some commonly used docker and python commands.

TASK=$1
ARGS=${*:2}

# Check to see if script is being run within container
IS_CONTAINER=0
if [ "$(whoami)" = "django-user" ]
then
    IS_CONTAINER=1
fi

# Check compatiblity with Docker Compose v2
if [[ "$(docker compose version)" == *"v2"* ]]
then
    shopt -s expand_aliases
    alias docker-compose="docker compose"
fi

display_banner() {
    echo -e "\n"
    echo -e "                       .__ "
    echo -e " _______   ____   ____ |__|_____   ____ "
    echo -e " \_  __ \_/ __ \_/ ___\|  \____ \_/ __ \ "
    echo -e "  |  | \/\  ___/\  \___|  |  |_> >  ___/ "
    echo -e "  |__|    \_____>\_____>__|   __/ \_____> "
    echo -e "                          |__|        "
    echo -e "   D J A N G O    R E C I P E     A P I  "
    echo -e "\n"
}

check_container() {
    if [ "${IS_CONTAINER}" = "1" ]
    then
        echo -e "\n\xE2\x9D\x8C Please run this command from outside the container.\n"
        exit 0
    fi
}

options() {
    script_file=`basename "$0"`
    echo -e "\n\xF0\x9F\x9A\xA9 USAGE: ./$script_file <ACTION> [ARGS]\n"
    echo -e "AVAILABLE ACTIONS:\n"
    echo -e "\tbuild:\t\t\t Build container (Dev environment)"
    echo -e "\tbuild-prod:\t\t Build container (Prod environment)"
    echo -e "\trun:\t\t\t Run container"
    echo -e "\tshell:\t\t\t Enter container using bash shell"
    echo -e "\texec:\t\t\t Run a command in the container"
    echo -e "\tstop:\t\t\t Stop container (if running)"
    echo -e "\ttest:\t\t\t Run tests"
    echo -e "\tlint:\t\t\t Run linter and formatter checks"
}

# Show the banner
display_banner

case $TASK in
    build)
        # Build container for Development environment
        check_container
        docker-compose build --build-arg GIT_COMMIT_ID=$(git rev-parse HEAD) $ARGS
    ;;
    build-prod)
        # Build container for Production environment
        check_container
        docker build -t polaris-api-io-portside . $ARGS
    ;;
    run)
        # Run container
        check_container
        docker-compose up $ARGS
    ;;
    shell)
        # Enter container using bash shell
        check_container
        docker-compose run --rm app bash $ARGS
    ;;
    exec)
        # Run a command in the container
        check_container
        docker-compose run --rm app $ARGS
    ;;
    stop)
        # Stop container
        check_container
        docker-compose stop $ARGS
    ;;
    test)
        # Run tests
        if [ "${IS_CONTAINER}" = "1" ]
        then
            python manage.py wait_for_db && python manage.py test
        else
            docker-compose run --rm app bash -c "python manage.py wait_for_db && python manage.py test"
        fi
    ;;
    lint)
        # Run linter and formatter checks
        if [ "${IS_CONTAINER}" = "1" ]
        then
            flake8 . && black --check . && isort -c .
        else
            docker-compose run --rm app bash -c "flake8 . && black --check . && isort -c ."
        fi
    ;;
    makemigrations)
        # Run linter and formatter checks
        if [ "${IS_CONTAINER}" = "1" ]
        then
            python manage.py makemigrations
        else
            docker-compose run --rm app bash -c "python manage.py makemigrations"
        fi
    ;;
    migrate)
        # Run linter and formatter checks
        if [ "${IS_CONTAINER}" = "1" ]
        then
            python manage.py wait_for_db && python manage.py migrate
        else
            docker-compose run --rm app bash -c "python manage.py wait_for_db && python manage.py migrate"
        fi
    ;;
    help|*)
        # Help menu
        options
    ;;
esac