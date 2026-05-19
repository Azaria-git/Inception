GREEN	= \033[0;32m
RED		= \033[0;31m
YELLOW	= \033[0;33m
BLUE	= \033[0;34m
NC		= \033[0m

COMPOSE		= docker compose
COMPOSE_FILE	= ./srcs/docker-compose.yml
ENV_FILE	= ./.env
ENV_OPTIONS	= --env-file $(ENV_FILE)

# Load LOGIN from .env
LOGIN := $(shell awk -F= '/^LOGIN=/{print $$2}' $(ENV_FILE) 2>/dev/null)

# Validate
ifeq ($(strip $(LOGIN)),)
$(error LOGIN is missing in $(ENV_FILE). Add: LOGIN=your_login)
endif

WP_DATA_DIR	= /home/$(LOGIN)/data/wordpress_files
DB_DATA_DIR	= /home/$(LOGIN)/data/wordpress_db

all: build

# verification of .env file and display instructions if missing
check_env:
	@if [ ! -f $(ENV_FILE) ]; then \
		echo "$(RED)Error: .env file not found!$(NC)"; \
		echo "$(YELLOW)Please create a .env file with the following content:$(NC)"; \
		echo ""; \
		echo "DB_ROOT_PASSWORD=your_root_password"; \
		echo "DB_NAME=wordpress_db"; \
		echo "DB_USER=wordpress_user"; \
		echo "DB_PASSWORD=your_db_password"; \
		echo ""; \
		echo "$(YELLOW)Then run 'make up' to start the containers.$(NC)"; \
		exit 1; \
	fi

# build Docker images using .env variables
build: check_env
	@echo "$(BLUE)Building Docker images...$(NC)"
	@$(COMPOSE) $(ENV_OPTIONS) -f $(COMPOSE_FILE) build
	@echo "$(GREEN)Build complete!$(NC)"

# run containers in detached mode
up: build
	@echo "$(BLUE)Starting containers...$(NC)"
	mkdir -p $(DB_DATA_DIR)
	mkdir -p $(WP_DATA_DIR)
	@$(COMPOSE) $(ENV_OPTIONS) -f $(COMPOSE_FILE) up -d
	@echo "$(GREEN)Containers started!$(NC)"
	@echo "$(YELLOW)Website available at: https://$(LOGIN).42.fr$(NC)"
	
# run containers with logs
up-logs: build
	@echo "$(BLUE)Starting containers with logs...$(NC)"
	mkdir -p $(DB_DATA_DIR)
	mkdir -p $(WP_DATA_DIR)
	@$(COMPOSE) $(ENV_OPTIONS) -f $(COMPOSE_FILE) up

# stop containers
down:
	@echo "$(BLUE)Stopping containers...$(NC)"
	@$(COMPOSE) $(ENV_OPTIONS) -f $(COMPOSE_FILE) down
	@echo "$(GREEN)Containers stopped!$(NC)"

# stop containers and remove volumes (full cleanup)
clean: down
	@echo "$(BLUE)Removing volumes...$(NC)"
	@$(COMPOSE) $(ENV_OPTIONS) -f $(COMPOSE_FILE) down -v
	@echo "$(GREEN)Volumes removed!$(NC)"

# full cleanup + remove images
fclean: clean
	@echo "$(BLUE)Removing images...$(NC)"
	@$(COMPOSE) $(ENV_OPTIONS) -f $(COMPOSE_FILE) down --rmi all
	@echo "$(GREEN)Images removed!$(NC)"

# WARNING: This will delete ALL WordPress and database data!
clean-data:
	@echo "$(RED)WARNING: This will delete ALL WordPress and database data!$(NC)"
	@read -p "Are you sure? (y/N): " confirm; \
	if [ "$$confirm" = "y" ] || [ "$$confirm" = "Y" ]; then \
		echo "$(BLUE)Removing /home/$$(whoami)/data/...$(NC)"; \
		sudo rm -rf $(DB_DATA_DIR); \
		sudo rm -rf $(WP_DATA_DIR); \
		echo "$(GREEN)Data removed!$(NC)"; \
	else \
		echo "$(YELLOW)Cancelled.$(NC)"; \
	fi

restart: down up
	@echo "$(GREEN)Containers restarted!$(NC)"

re: fclean up
	@echo "$(GREEN)Rebuild complete!$(NC)"

status:
	@$(COMPOSE) $(ENV_OPTIONS) -f $(COMPOSE_FILE) ps

logs:
	@$(COMPOSE) $(ENV_OPTIONS) -f $(COMPOSE_FILE) logs -f

help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  build       Build Docker images"
	@echo "  up          Start containers in detached mode"
	@echo "  up-logs     Start containers with logs"
	@echo "  down        Stop containers"
	@echo "  clean       Stop containers and remove volumes"
	@echo "  fclean      Full cleanup (stop, remove volumes, remove images)"
	@echo "  clean-data  WARNING: Delete ALL WordPress and database data!"
	@echo "  restart      Restart containers"
	@echo "  re           Full rebuild (fclean + up)"
	@echo "  status       Show container status"
	@echo "  logs         Follow container logs"
	@echo "  help         Show this help message"



.PHONY: all check_env build up up-logs down clean fclean clean-all logs help