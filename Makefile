.PHONY: all up down clean fclean re logs

all: up

up:
	mkdir -p /home/azaria/data
	docker-compose -f srcs/docker-compose.yml up -d

down:
	docker-compose -f srcs/docker-compose.yml down

clean: down
	docker system prune -f

fclean: clean
	docker volume rm $$(docker volume ls -q) 2>/dev/null || true
	rm -rf /home/azaria/data

re: fclean all

logs:
	docker-compose -f srcs/docker-compose.yml logs -f
