down-clean:
	docker compose -f docker-compose.yml down
	sudo rm -rf ../auth/node_modules ../user/node_modules ../pet/node_modules ../health/node_modules ../gateway/node_modules
	sudo rm -rf ../auth/dist ../user/dist ../pet/dist ../health/dist ../gateway/dist

up:
	docker compose -f docker-compose.yml up -d $(SERVICES)
