DATA_DIR = /home/hkheired/data
COMPOSE = docker compose -f srcs/docker-compose.yml

all: build up

dirs:
	@mkdir -p $(DATA_DIR)/wordpress
	@mkdir -p $(DATA_DIR)/mariadb

build: dirs
	@$(COMPOSE) build --no-cache

up:
	@$(COMPOSE) up -d

down:
	@$(COMPOSE) down

clean: down
	@$(COMPOSE) down -v --rmi all

fclean: clean
	@sudo rm -rf $(DATA_DIR)/wordpress
	@sudo rm -rf $(DATA_DIR)/mariadb
	@mkdir -p $(DATA_DIR)/wordpress
	@mkdir -p $(DATA_DIR)/mariadb
	
re: fclean all

.PHONY: all build up down clean fclean re