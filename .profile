# prevent `pip install` outside virtualenv
export PIP_REQUIRE_VIRTUALENV=1
# https://www.docker.com/blog/faster-builds-in-compose-thanks-to-buildkit-support/
export COMPOSE_DOCKER_CLI_BUILD=1
export DOCKER_BUILDKIT=1
