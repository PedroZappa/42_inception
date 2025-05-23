# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: passunca <passunca@student.42porto.com>    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2024/12/14 12:26:53 by passunca          #+#    #+#              #
#    Updated: 2025/03/02 11:15:00 by passunca         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

#==============================================================================#
#                                  MAKE CONFIG                                 #
#==============================================================================#

MAKE	= make -C
SHELL	:= bash --rcfile ~/.bashrc

#==============================================================================#
#                                     NAMES                                    #
#==============================================================================#

NAME 			 	= Inception
USER				= passunca

### Message Vars
_SUCCESS 		= [$(GRN)SUCCESS$(D)]
_INFO 			= [$(BLU)INFO$(D)]
_SEP	 			= ===================================================

#==============================================================================#
#                                    PATHS                                     #
#==============================================================================#

TEMP_PATH		= .temp
SECRETS_PATH	= ./secrets
DOCKER_PATH = ./srcs/docker-compose.yml
DOCKER_BONUS_PATH = ./srcs/docker-compose_bonus.yml


#==============================================================================#
#                                COMMANDS                                      #
#==============================================================================#

### Core Utils
RM			= rm -rf
MKDIR_P	= mkdir -p

#==============================================================================#
#                                  RULES                                       #
#==============================================================================#

##@  Rules 🏗

all: setup ## Build project

setup: check
	./setup.sh

check: check_volumes ## Check Docker Status

check_volumes: ## Check Docker Volumes
	@echo "$(CYA)Checking Docker Volumes...$(D)"
	@if [ ! -d $(HOME)/data/db ] || [ ! -d $(HOME)/data/wp ]; then \
		echo " $(RED)$(D) [$(GRN)Creating Volumes!$(D)]"; \
		echo "* $(YEL)Creating $(CYA)$(HOME)/data/db$(D) & $(CYA)$(HOME)/data/wp$(D) folders:$(D) $(_SUCCESS)"; \
		$(MKDIR_P) $(HOME)/data/db $(HOME)/data/wp; \
	else \
	echo " $(RED)$(D) [$(GRN)Volumes are mounted at:$(D)]"; \
		echo "* $(YEL)$(HOME)/data/db$(D) & $(YEL)$(HOME)/data/wp$(D)"; \
	fi

check_volumes_bonus:
	@echo "$(CYA)Checking Docker Volumes (Bonus)...$(D)"
	@if [ ! -d "$HOME/data/backup" ] || [ ! -d "$HOME/data/ws" ]; then \
		echo " $(RED)$(D) [$(GRN)Creating Volumes!$(D)]"; \
		$(MKDIR_P) "$HOME/data/backup" "$HOME/data/ws"; \
	fi

check_host:		## Check Docker Hosts
	@if ! grep -q '127.0.0.1 $(USER).42.pt $(USER).42.fr' /etc/hosts; then \
		echo " $(RED)$(D) [$(GRN)Adding host entry!$(D)]"; \
		echo "127.0.0.1 $(USER).42.pt $(USER).42.fr" | sudo tee -a /etc/hosts; \
	else \
		echo " $(RED)$(D) [$(GRN)Host entry already exists!$(D)]"; \
		echo "* $(YEL)127.0.0.1$(D) $(USER).42.pt $(USER).42.fr"; \
	fi

up: setup ## Get Docker Networks up
	@echo "$(CYA)Docker Compose $(GRN)UP$(D)..."
	docker-compose -f $(DOCKER_PATH) up --build

start: setup ## Start Docker Network
	@echo "$(CYA)Docker Compose $(GRN)START$(D)..."
	docker compose -f $(DOCKER_PATH) start

stop: setup ## Stop Docker Network
	@echo "$(CYA)Docker Compose $(GRN)STOP$(D)..."
	docker compose -f $(DOCKER_PATH) stop

rm: stop ## Remove Docker Network
	@echo "$(CYA)Docker Compose $(GRN)RM$(D)..."
	docker compose -f $(DOCKER_PATH) rm

down: ## Bring down Docker Network
	@echo "$(CYA)Docker Compose $(GRN)DOWN$(D)..."
	docker compose -f $(DOCKER_PATH) down

## Bonus

bonus: up_bonus

up_bonus: setup
	@echo "$(CYA)Docker Compose Bonus $(GRN)UP$(D)..."
	docker compose -f $(DOCKER_BONUS_PATH) up --build

start_bonus: setup
	@echo "$(CYA)Docker Compose Bonus $(GRN)START$(D)..."
	docker compose -f $(DOCKER_BONUS_PATH) start

stop_bonus: check_host check_volumes check_volumes_bonus
	@echo "$(CYA)Docker Compose Bonus $(GRN)STOP$(D)..."
	docker compose -f $(DOCKER_BONUS_PATH) stop

rm_bonus: stop ## Remove Docker Network
	@echo "$(CYA)Docker Compose $(GRN)RM$(D)..."
	docker compose -f $(DOCKER_BONUS_PATH) rm

down_bonus: ## Bring down Docker Network
	@echo "$(CYA)Docker Compose $(GRN)DOWN$(D)..."
	docker compose -f $(DOCKER_BONUS_PATH) down


##@ Test Rules 🧪

doom: ## Run Doom container
	@if command -v ghostty >/dev/null 2>&1; then \
		ghostty -e docker exec -it doom /terminal-doom/zig-out/bin/terminal-doom; \
	elif command -v x-terminal-emulator >/dev/null 2>&1; then \
		x-terminal-emulator -e docker exec -it doom /terminal-doom/zig-out/bin/terminal-doom; \
	elif command -v gnome-terminal >/dev/null 2>&1; then \
		gnome-terminal -- docker exec -it doom /terminal-doom/zig-out/bin/terminal-doom; \
	elif command -v konsole >/dev/null 2>&1; then \
		konsole -e docker exec -it doom /terminal-doom/zig-out/bin/terminal-doom; \
	elif command -v xfce4-terminal >/dev/null 2>&1; then \
		xfce4-terminal -e "docker exec -it doom /terminal-doom/zig-out/bin/terminal-doom"; \
	elif command -v mate-terminal >/dev/null 2>&1; then \
		mate-terminal -e "docker exec -it doom /terminal-doom/zig-out/bin/terminal-doom"; \
	elif command -v terminator >/dev/null 2>&1; then \
		terminator -e "docker exec -it doom /terminal-doom/zig-out/bin/terminal-doom"; \
	elif command -v kitty >/dev/null 2>&1; then \
		kitty docker exec -it doom /terminal-doom/zig-out/bin/terminal-doom; \
	elif command -v alacritty >/dev/null 2>&1; then \
		alacritty -e docker exec -it doom /terminal-doom/zig-out/bin/terminal-doom; \
	elif [[ "$OSTYPE" == "darwin"* ]]; then \
		open -a Terminal "docker exec -it doom /terminal-doom/zig-out/bin/terminal-doom"; \
	else \
		echo "No supported terminal emulator found. Please open a terminal manually and run:"; \
		echo "docker exec -it doom /terminal-doom/zig-out/bin/terminal-doom"; \
	fi

ftp: ## Connect to FTP service
	ftp $(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ftp)

##@ Debug Rules 

status: ## Get Network Status
	@echo "$(CYA)Docker $(GRN)STATUS$(D)..."
	@echo "$(GRN)docker ps -a$(D)"
	docker ps -a
	@echo "$(GRN)docker image ls$(D)"
	docker image ls
	@echo "$(GRN)docker volume ls$(D)"
	docker volume ls
	@echo "$(GRN)docker network ls$(D)"
	docker network ls

##@ Clean-up Rules 󰃢


rmi: ## Remove Docker Network
	echo "$(CYA)Docker Compose $(GRN)RMI$(D): remove container images..."
	docker compose -f $(DOCKER_PATH) down --rmi all

rmv: ## Remove Docker Volumes
	echo "$(CYA)Docker Compose $(GRN)RMV$(D): remove volumes..."
	docker compose -f $(DOCKER_PATH) down --volumes

prune: fclean ## Prune Docker System
	echo "$(CYA)Docker Compose $(GRN)PRUNE$(D): prune system..."
	docker system prune -a

clean: 				## Remove object files
	@echo "*** $(YEL)Removing $(MAG)$(NAME)$(D)$(YEL) temporary files$(D)"
	@docker compose -f $(DOCKER_PATH) down --rmi all --volumes
	@if [ -d "$(SECRETS_PATH)" ]; then \
		if [ -d "$(SECRETS_PATH)" ]; then \
			$(RM) $(SECRETS_PATH); \
			$(RM) ~/secrets; \
			echo "* $(YEL)Removing $(CYA)$(TEMP_PATH)$(D) folder & files:$(D) $(_SUCCESS)"; \
		fi; \
	else \
		echo " $(RED)$(D) [$(GRN)Nothing to clean!$(D)]"; \
	fi

fclean: clean ## Remove All
	@echo "*** $(YEL)Removing $(MAG)$(NAME)$(YEL) files$(D)"
	sudo rm -fr ~/data

re: fclean all	## Purge & Recompile

re_bonus: fclean_bonus up_bonus ## Purge & Recompile

rmi_bonus: ## Remove Docker Network
	echo "$(CYA)Docker Compose $(GRN)RMI$(D): remove container images..."
	docker compose -f $(DOCKER_BONUS_PATH) down --rmi all

rmv_bonus: ## Remove Docker Volumes
	echo "$(CYA)Docker Compose $(GRN)RMV$(D): remove volumes..."
	docker compose -f $(DOCKER_BONUS_PATH) down --volumes

clean_bonus: 
	@echo "$(CYA)Docker Compose $(GRN)CLEAN$(D): remove unused images & volumes..."
	docker compose -f $(DOCKER_BONUS_PATH) down --rmi all --volumes

fclean_bonus: clean_bonus ## Prune Docker System
	echo "$(CYA)Docker Compose $(GRN)FCLEAN$(D): prune system..."
	sudo rm -fr ~/data

kill:  ## Kill all running containers
	docker stop $$(docker ps -qa); \
	docker rm $$(docker ps -qa); \
	docker rmi -f $$(docker images -qa); \
	docker volume rm $$(docker volume ls -q); \
	docker network rm $$(docker network ls -q) 2>/dev/null

##@ Help 󰛵

help: 			## Display this help page
	@awk 'BEGIN {FS = ":.*##"; \
			printf "\n=> Usage:\n\tmake $(GRN)<target>$(D)\n"} \
		/^[a-zA-Z_0-9-]+:.*?##/ { \
			printf "\t$(GRN)%-18s$(D) %s\n", $$1, $$2 } \
		/^##@/ { \
			printf "\n=> %s\n", substr($$0, 5) } ' Makefile

## Tweaked from source:
### https://www.padok.fr/en/blog/beautiful-makefile-awk

.PHONY: bonus clean fclean re help

#==============================================================================#
#                                  UTILS                                       #
#==============================================================================#

# Colors
#
# Run the following command to get list of available colors
# bash -c 'for c in {0..255}; do tput setaf $c; tput setaf $c | cat -v; echo =$c; done'
#
B  		= $(shell tput bold)
BLA		= $(shell tput setaf 0)
RED		= $(shell tput setaf 1)
GRN		= $(shell tput setaf 2)
YEL		= $(shell tput setaf 3)
BLU		= $(shell tput setaf 4)
MAG		= $(shell tput setaf 5)
CYA		= $(shell tput setaf 6)
WHI		= $(shell tput setaf 7)
GRE		= $(shell tput setaf 8)
BRED 	= $(shell tput setaf 9)
BGRN	= $(shell tput setaf 10)
BYEL	= $(shell tput setaf 11)
BBLU	= $(shell tput setaf 12)
BMAG	= $(shell tput setaf 13)
BCYA	= $(shell tput setaf 14)
BWHI	= $(shell tput setaf 15)
D 		= $(shell tput sgr0)
BEL 	= $(shell tput bel)
CLR 	= $(shell tput el 1)









