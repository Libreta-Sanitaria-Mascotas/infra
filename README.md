# Infraestructura de Libreta Sanitaria para Mascotas

Este directorio contiene la configuración de infraestructura para el proyecto de Libreta Sanitaria para Mascotas, implementado como una arquitectura de microservicios.

## Descripción General

El proyecto utiliza Docker Compose para orquestar múltiples servicios que trabajan juntos para proporcionar una plataforma completa de gestión de libretas sanitarias para mascotas.

## Servicios

La infraestructura incluye los siguientes servicios:

### Servicios de Aplicación

- **Auth Service** (Puerto: 3001)
  - Servicio de autenticación y autorización
  - Base de datos PostgreSQL dedicada (Puerto: 5433)

- **User Service** (Puerto: 3002)
  - Gestión de usuarios
  - Base de datos PostgreSQL dedicada (Puerto: 5434)

- **Pet Service** (Puerto: 3003)
  - Gestión de mascotas
  - Base de datos PostgreSQL dedicada (Puerto: 5435)

- **Health Service** (Puerto: 3004)
  - Gestión de registros de salud
  - Base de datos PostgreSQL dedicada (Puerto: 5436)

### Servicios de Infraestructura
- **Redis** (`redis_service`): Puerto 6379 - Almacenamiento en caché / sesiones
- **RabbitMQ** (`rabbitmq`): Puertos 5672 (AMQP) y 15672 (Management UI) - Message Broker
- **PgAdmin** (`pgadmin4`): Puerto 5050 - Administración de bases de datos PostgreSQL
  - Acceso: http://localhost:5050
  - Usuario: admin@admin.com
  - Contraseña: admin

## Redes

Todos los servicios están conectados a través de una red Docker llamada `app-network`, lo que permite la comunicación entre ellos.

## Volúmenes

Se utilizan los siguientes volúmenes para persistencia de datos:

- `auth_db_data`: Datos de la base de datos de autenticación
- `user_db_data`: Datos de la base de datos de usuarios
- `pet_db_data`: Datos de la base de datos de mascotas
- `health_db_data`: Datos de la base de datos de salud
- `media_db_data`: Datos de la base de datos de archivos
- `pgadmin_data`: Datos de configuración de PgAdmin

## Requisitos

- Docker y Docker Compose instalados en el sistema

## Instrucciones de Uso

### Iniciar los servicios

```bash
docker-compose up -d
```

### Detener los servicios

```bash
docker-compose down
```

### Ver logs de un servicio específico

```bash
docker-compose logs -f [nombre_del_servicio]
```

Ejemplo:
```bash
docker-compose logs -f auth
```

### Acceder a PgAdmin

1. Abra un navegador y vaya a `http://localhost:5050`
2. Inicie sesión con las credenciales:
   - Email: admin@admin.com
   - Contraseña: admin

## Estructura del Proyecto

Cada servicio tiene su propio directorio en la raíz del proyecto:

- `/auth`: Servicio de autenticación
- `/user`: Servicio de usuarios
- `/pet`: Servicio de mascotas
- `/health`: Servicio de salud
- `/infra`: Configuración de infraestructura (este directorio)

## Notas Adicionales

- Todos los servicios están configurados para el entorno de desarrollo (`NODE_ENV=development`)
- Los servicios de aplicación se reiniciarán automáticamente cuando se detecten cambios en el código
- Todas las bases de datos PostgreSQL utilizan el usuario `postgres` con contraseña `postgres`