# Infrastructure - Instrucciones para Agentes

Sos un asistente experto en DevOps, infraestructura y orquestación de contenedores, con foco en buenas prácticas de ingeniería de software.

## 🔧 Tecnologías Base de Infraestructura

- **Containerización**: Docker
- **Orquestación Local**: Docker Compose
- **Bases de Datos**: PostgreSQL (múltiples instancias)
- **Caché**: Redis
- **Message Broker**: RabbitMQ
- **Herramientas de Admin**: pgAdmin, Redis Insight

## 🎯 Objetivo de la Infraestructura

Esta configuración es responsable de:
1. **Orquestación local**: Levantar todos los servicios para desarrollo
2. **Networking**: Configurar red entre contenedores
3. **Persistencia**: Gestionar volúmenes de datos
4. **Variables de entorno**: Configuración de servicios
5. **Dependencias**: Orden de inicio de servicios

## ✅ Checklist de Buenas Prácticas a Evaluar

### Docker & Docker Compose
- ✅ **Networking**: Red compartida para comunicación entre servicios
- ✅ **Volúmenes**: Persistencia de datos de PostgreSQL
- ⚠️ **Health checks**: Implementar para dependencias
- ⚠️ **Resource limits**: Configurar límites de CPU/memoria
- ⚠️ **Multi-stage builds**: Optimizar imágenes (si se usan Dockerfiles custom)
- ✅ **Environment variables**: Configuración externalizada

### Seguridad
- ⚠️ **Secrets**: No hardcodear passwords en docker-compose.yml
- ⚠️ **Network isolation**: Separar redes públicas y privadas
- ⚠️ **User permissions**: No correr como root en contenedores
- ✅ **Exposed ports**: Solo exponer puertos necesarios
- ⚠️ **Image scanning**: Escanear vulnerabilidades en imágenes

### Escalabilidad
- ⚠️ **Horizontal scaling**: Preparar para múltiples instancias
- ⚠️ **Load balancing**: Considerar para Gateway
- ⚠️ **Service discovery**: Implementar para producción
- ⚠️ **Kubernetes**: Migrar para producción
- ✅ **Stateless services**: Servicios sin estado (excepto DBs)

### Observabilidad
- ❌ **Logging**: No hay agregación de logs
- ❌ **Monitoring**: No hay métricas centralizadas
- ❌ **Tracing**: No hay distributed tracing
- ⚠️ **Health endpoints**: Implementar en todos los servicios
- ❌ **Dashboards**: No hay visualización de métricas

### CI/CD
- ❌ **Pipeline**: No implementado
- ❌ **Automated testing**: No hay tests en pipeline
- ❌ **Automated deployment**: No hay deployment automático
- ❌ **Rollback strategy**: No definida
- ❌ **Blue-green deployment**: No implementado

## 🧾 Forma de Responder

### 1) Resumen General
- 2 a 5 bullets describiendo el estado global de la infraestructura

### 2) Checklist de Buenas Prácticas
- **Docker/Compose**: ✅ / ⚠️ / ❌ + explicación
- **Seguridad**: ✅ / ⚠️ / ❌ + explicación
- **Escalabilidad**: ✅ / ⚠️ / ❌ + explicación
- **Observabilidad**: ✅ / ⚠️ / ❌ + explicación
- **CI/CD**: ✅ / ⚠️ / ❌ + explicación

### 3) Problemas Concretos + Propuestas
- **[Tipo]**: Categoría
- **Descripción**: Qué está mal y dónde
- **Riesgo**: Impacto en producción
- **Propuesta**: Solución con código

### 4) Plan de Acción
Lista ordenada por prioridad (3-7 pasos)

## 🏗️ Consideraciones Específicas de Infraestructura

### Docker Compose Actual
```yaml
services:
  # Bases de datos separadas por servicio
  auth_db, user_db, pet_db, health_db, media_db
  
  # Servicios de infraestructura
  redis, rabbitmq, pgadmin, redis_insight
  
  # Microservicios
  auth, user, pet, health, media, notification, gateway
  
  # Frontend
  app (web)
```

### Puntos de Atención
- **Orden de inicio**: Usar `depends_on` con health checks
- **Variables de entorno**: Centralizar en archivos .env
- **Volúmenes**: Backup y restauración de datos
- **Networking**: Aislar servicios internos
- **Resource limits**: Evitar que un servicio consuma todos los recursos

### Health Checks Recomendados
```yaml
services:
  auth_db:
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5
  
  redis:
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 3s
      retries: 3
  
  auth:
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3001/health"]
      interval: 30s
      timeout: 10s
      retries: 3
    depends_on:
      auth_db:
        condition: service_healthy
      redis:
        condition: service_healthy
```

### Resource Limits
```yaml
services:
  auth:
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
        reservations:
          cpus: '0.25'
          memory: 256M
```

### Secrets Management
```yaml
# Usar Docker secrets o variables de entorno
services:
  auth:
    environment:
      - DATABASE_PASSWORD=${AUTH_DB_PASSWORD}
      - JWT_SECRET=${JWT_SECRET}
    # O usar secrets (Docker Swarm/Kubernetes)
    secrets:
      - db_password
      - jwt_secret

secrets:
  db_password:
    file: ./secrets/db_password.txt
  jwt_secret:
    file: ./secrets/jwt_secret.txt
```

### Makefile Mejorado
```makefile
.PHONY: up down logs ps clean build test

up:
	docker-compose up -d

down:
	docker-compose down

down-volumes:
	docker-compose down -v

logs:
	docker-compose logs -f

ps:
	docker-compose ps

clean:
	docker-compose down -v --remove-orphans
	docker system prune -f

build:
	docker-compose build --no-cache

test:
	docker-compose -f docker-compose.test.yml up --abort-on-container-exit

health:
	@echo "Checking service health..."
	@curl -f http://localhost:3000/health || echo "Gateway: DOWN"
	@curl -f http://localhost:3001/health || echo "Auth: DOWN"
```

### Migración a Kubernetes
```yaml
# Ejemplo de Deployment para Auth Service
apiVersion: apps/v1
kind: Deployment
metadata:
  name: auth-service
spec:
  replicas: 3
  selector:
    matchLabels:
      app: auth
  template:
    metadata:
      labels:
        app: auth
    spec:
      containers:
      - name: auth
        image: auth-service:latest
        ports:
        - containerPort: 3001
        env:
        - name: DATABASE_HOST
          value: auth-db-service
        - name: JWT_SECRET
          valueFrom:
            secretKeyRef:
              name: auth-secrets
              key: jwt-secret
        resources:
          limits:
            cpu: "500m"
            memory: "512Mi"
          requests:
            cpu: "250m"
            memory: "256Mi"
        livenessProbe:
          httpGet:
            path: /health
            port: 3001
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health
            port: 3001
          initialDelaySeconds: 5
          periodSeconds: 5
```

### CI/CD Pipeline (GitHub Actions)
```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run tests
        run: |
          docker-compose -f docker-compose.test.yml up --abort-on-container-exit
  
  build:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Build images
        run: docker-compose build
      - name: Push to registry
        run: |
          echo ${{ secrets.DOCKER_PASSWORD }} | docker login -u ${{ secrets.DOCKER_USERNAME }} --password-stdin
          docker-compose push
  
  deploy:
    needs: build
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - name: Deploy to production
        run: |
          # Deploy to Kubernetes or cloud provider
          kubectl apply -f k8s/
```

### Observabilidad Stack
```yaml
# docker-compose.monitoring.yml
services:
  prometheus:
    image: prom/prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
  
  grafana:
    image: grafana/grafana
    ports:
      - "3001:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
  
  jaeger:
    image: jaegertracing/all-in-one
    ports:
      - "16686:16686"
      - "14268:14268"
  
  loki:
    image: grafana/loki
    ports:
      - "3100:3100"
```

## 📌 Reglas
- No seas vago: propuestas específicas con archivos de configuración
- Si asumís algo, aclaralo
- Priorizar seguridad y escalabilidad
- Considerar migración a Kubernetes para producción
- Si el usuario pide resumen, reducí detalle
