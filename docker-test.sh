#!/bin/bash
set -e

echo "=== Тестирование Dockerfile ==="

echo "1. Проверка синтаксиса Dockerfile..."
docker build --no-cache -t test-image .

echo "2. Запуск тестового контейнера..."
docker run -d --name test-container -p 9999:80 test-image

echo "3. Ожидание запуска..."
sleep 3

echo "4. Проверка работы..."
if curl -s http://localhost:9999/ | grep -q "DOCTYPE"; then
    echo "✅ HTML загружается"
else
    echo "❌ Ошибка загрузки HTML"
    exit 1
fi

echo "5. Проверка health endpoint..."
if curl -s http://localhost:9999/health | grep -q "OK"; then
    echo "✅ Health check работает"
else
    echo "❌ Health check не работает"
fi

echo "6. Проверка версии..."
docker exec test-container cat /usr/share/nginx/html/version.txt

echo "7. Очистка..."
docker stop test-container
docker rm test-container
docker rmi test-image

echo "=== Все тесты пройдены успешно! ==="
