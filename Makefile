#----------------------
# Parse makefile arguments
#----------------------
RUN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
$(eval $(RUN_ARGS):;@:)

#----------------------
# Terminal
#----------------------

GREEN  := $(shell tput -Txterm setaf 2)
WHITE  := $(shell tput -Txterm setaf 7)
YELLOW := $(shell tput -Txterm setaf 3)
RESET  := $(shell tput -Txterm sgr0)

#------------------------------------------------------------------
# - Add the following 'help' target to your Makefile
# - Add help text after each target name starting with '\#\#'
# - A category can be added with @category
#------------------------------------------------------------------

HELP_FUN = \
	%help; \
	while(<>) { \
		push @{$$help{$$2 // 'options'}}, [$$1, $$3] if /^([a-zA-Z\-]+)\s*:.*\#\#(?:@([a-zA-Z\-]+))?\s(.*)$$/ }; \
		print "-----------------------------------------\n"; \
		print "| Welcome to EQEmu Docker!\n"; \
		print "-----------------------------------------\n"; \
		print "| usage: make [command]\n"; \
		print "-----------------------------------------\n\n"; \
		for (sort keys %help) { \
			print "${WHITE}$$_:${RESET \
		}\n"; \
		for (@{$$help{$$_}}) { \
			$$sep = " " x (32 - length $$_->[0]); \
			print "  ${YELLOW}$$_->[0]${RESET}$$sep${GREEN}$$_->[1]${RESET}\n"; \
		}; \
		print "\n"; \
	}

help: ##@other Show this help.
	@perl -e '$(HELP_FUN)' $(MAKEFILE_LIST)

#----------------------
# Init / Install
#----------------------

install: ##@init Install full application
	docker-compose build
	make up
	make init-server-directories
	make pull-eqemu-code
	make pull-peq-quests
	make pull-eqemu-server-script
	make pull-maps
	make init-build
	make build
	make pull-docker-config
	make init-peq-database
	make restart

init-server-directories: ##@init Initializes server directories
	mkdir -p ./code
	mkdir -p ./server
	mkdir -p ./server/export
	mkdir -p ./server/logs
	mkdir -p ./server/shared
	mkdir -p ./server/maps
	mkdir -p ./server/quests
	make chown-eqemu

init-peq-database: ##@init Sources fresh PEQ database (Warning: Will over-write existing)
	docker-compose exec workspace bash -c "./scripts/source-database.sh"
	docker-compose exec workspace bash -c "cd server && perl eqemu_server.pl source_peq_db"
	docker-compose exec workspace bash -c "cd server && perl eqemu_server.pl check_db_updates"

#----------------------
# Assets
#----------------------

pull-maps: ##@assets Pulls maps
	docker-compose exec workspace bash -c "cd server && wget https://codeload.github.com/Akkadius/EQEmuMaps/zip/master -O maps.zip && unzip maps.zip && rm ./maps -rf && mv EQEmuMaps-master maps && rm maps.zip"

pull-eqemu-code: ##@assets Pulls eqemu code
	docker-compose exec workspace bash -c "git -C ./code pull 2> /dev/null || git clone https://github.com/EQEmu/Server.git code"

pull-eqemu-server-script: ##@assets Pulls eqemu_server.pl
	docker-compose exec workspace bash -c 'cd server && wget --no-check-certificate https://raw.githubusercontent.com/EQEmu/Server/master/utils/scripts/eqemu_server.pl -O eqemu_server.pl && chmod 755 eqemu_server.pl'

pull-peq-quests: ##@assets Pulls ProjectEQ quests
	docker-compose exec workspace bash -c "cd server && git -C ./quests pull 2> /dev/null || git clone https://github.com/ProjectEQ/projecteqquests.git quests"

pull-docker-config: ##@assets Pulls default eqemu_config.json
	docker-compose exec workspace bash -c "cd server && wget --no-check-certificate https://raw.githubusercontent.com/Akkadius/EQEmuInstall/master/eqemu_config_docker.json -O eqemu_config.json"

pull-utility-scripts: ##@assets Pulls utility scripts (start/stop server)
	docker-compose exec workspace bash -c "cd server && perl eqemu_server.pl utility_scripts"
	make chown-eqemu

#----------------------
# Build
#----------------------

init-build: ##@build Initialize build
	docker-compose exec workspace bash -c "cd code && mkdir -p build && cd build && cmake -DEQEMU_BUILD_LOGIN=ON -DEQEMU_BUILD_LUA=ON -G 'Unix Makefiles' .."

build: ##@build Build EQEmu server
	docker-compose exec workspace bash -c 'cd code/build && make'

build-clean: ##@build Cleans build directory
	docker-compose exec workspace bash -c 'cd code/build && make clean'

build-with-cores: ##@build Build EQEmu server (make build-with-cores <number>)
	docker-compose exec workspace bash -c 'cd code/build && make -j$(RUN_ARGS)'

#----------------------
# Workflow
#----------------------

bash: ##@workflow Bash into workspace
	docker-compose exec workspace bash

mysql-console: ##@workflow Jump into the MySQL container console
	docker-compose exec workspace bash -c "mysql -u root -proot -h mariadb"

chown-eqemu: ##@workflow Sets eqemu user ownership over files inside container
	docker-compose exec workspace bash -c "sudo chown eqemu:eqemu * -R"
	docker-compose exec workspace bash -c "sudo chmod -f 755 ./scripts/* || :"
	docker-compose exec workspace bash -c "sudo chmod -f 755 ./server/*.sh || :"

#----------------------
# Docker
#----------------------

up: ##@docker Bring up the whole environment
	docker-compose up -d workspace mariadb

down: ##@docker Down all containers
	docker-compose down

restart: ##@docker Restart containers
	make down
	make up