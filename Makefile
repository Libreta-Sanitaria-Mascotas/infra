.PHONY: up down down-clean down-volumes logs ps app-logs gateway-logs

# Levantar todos los servicios
up:
	docker compose -f docker-compose.yml up -d $(SERVICES)

# Bajar todos los servicios sin eliminar volúmenes
down:
	docker compose -f docker-compose.yml down

# Bajar servicios y limpiar node_modules y dist
down-clean:
	docker compose -f docker-compose.yml down
	sudo rm -rf ../auth/node_modules ../user/node_modules ../pet/node_modules ../health/node_modules ../gateway/node_modules ../media/node_modules ../app/node_modules
	sudo rm -rf ../auth/dist ../user/dist ../pet/dist ../health/dist ../gateway/dist ../media/dist

# Bajar servicios y limpiar volúmenes (bases de datos)
down-volumes:
	docker compose -f docker-compose.yml down -v

# Ver logs de todos los servicios
logs:
	docker compose -f docker-compose.yml logs -f

# Ver estado de los servicios
ps:
	docker compose -f docker-compose.yml ps

# Ver logs específicos de la app web
app-logs:
	docker logs app_web --tail 100 -f

# Ver logs específicos del gateway
gateway-logs:
	docker logs gateway_service --tail 100 -f

# Reiniciar solo la app
restart-app:
	docker compose -f docker-compose.yml restart app

# Reiniciar solo el gateway
restart-gateway:
	docker compose -f docker-compose.yml restart gateway

