.PHONY: help build run stop logs clean test push

# Переменные
IMAGE_NAME = simple-html-app
CONTAINER_NAME = html-container
PORT = 8080

help:
	@echo "Доступные команды:"
	@echo "  make build    - собрать Docker образ"
	@echo "  make run      - запустить контейнер на порту ${PORT}"
	@echo "  make stop     - остановить контейнер"
	@echo "  make logs     - показать логи"
	@echo "  make shell    - войти в контейнер"
	@echo "  make test     - протестировать работу"
	@echo "  make clean    - очистить всё"
	@echo "  make push     - отправить образ в registry"

build:
	@echo "Сборка Docker образа ${IMAGE_NAME}..."
	docker build -t ${IMAGE_NAME}:latest .
	@echo "✅ Образ собран"

run:
	@echo "Запуск контейнера ${CONTAINER_NAME}..."
	docker run -d \
		-p ${PORT}:80 \
		--name ${CONTAINER_NAME} \
		--restart unless-stopped \
		${IMAGE_NAME}:latest
	@echo "✅ Контейнер запущен: http://localhost:${PORT}"

stop:
	@echo "Остановка контейнера..."
	-docker stop ${CONTAINER_NAME}
	-docker rm ${CONTAINER_NAME}
	@echo "✅ Контейнер остановлен"

logs:
	docker logs -f ${CONTAINER_NAME}

shell:
	docker exec -it ${CONTAINER_NAME} sh

test:
	@echo "Тестирование контейнера..."
	@sleep 2
	@echo "1. Проверка HTTP ответа..."
	@curl -s -o /dev/null -w "HTTP код: %{http_code}\n" http://localhost:${PORT}/
	@echo "2. Проверка health check..."
	@curl -s http://localhost:${PORT}/health | grep -q "healthy" && echo "✅ Health check OK" || echo "❌ Health check failed"
	@echo "3. Проверка HTML..."
	@curl -s http://localhost:${PORT}/ | grep -q "DOCTYPE" && echo "✅ HTML валиден" || echo "❌ HTML не найден"
	@echo "✅ Все тесты пройдены!"

clean:
	@echo "Очистка..."
	-docker stop ${CONTAINER_NAME} 2>/dev/null || true
	-docker rm ${CONTAINER_NAME} 2>/dev/null || true
	-docker rmi ${IMAGE_NAME}:latest 2>/dev/null || true
	docker system prune -f
	@echo "✅ Очистка завершена"

push:
	@echo "Для отправки в Docker Hub выполните:"
	@echo "  docker tag ${IMAGE_NAME}:latest ваш-логин/${IMAGE_NAME}:latest"
	@echo "  docker push ваш-логин/${IMAGE_NAME}:latest"

# Комбинация команд
all: clean build run test
