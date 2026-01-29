# ============================================
# Многоступенчатый Dockerfile для HTML проекта
# ============================================

# Этап 1: Сборка (если бы у нас были assets для обработки)
FROM node:18-alpine AS builder

WORKDIR /app

# Копируем файлы проекта
COPY . .

# Здесь могли бы быть команды сборки:
# RUN npm install
# RUN npm run build

# Этап 2: Продакшен
FROM nginx:alpine

# Метаданные
LABEL maintainer="Zelinsky68 <aktg1@mail.ru>"
LABEL version="1.0.0"
LABEL description="Simple HTML project container"

# Рабочая директория
WORKDIR /usr/share/nginx/html

# Копируем статические файлы из builder этапа
# COPY --from=builder /app/dist /usr/share/nginx/html

# Или копируем напрямую наши файлы
COPY index.html .
COPY README.md .

# Создаем health endpoint
RUN echo '{"status": "healthy", "service": "html-app", "timestamp": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}' > health.json

# Создаем версию файл
RUN echo "v1.0.0 - built on $(date)" > version.txt

# Настраиваем nginx
COPY nginx.conf /etc/nginx/nginx.conf

# Устанавливаем правильные права
RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chmod -R 755 /usr/share/nginx/html

# Открываем порт
EXPOSE 80

# Запускаем nginx
CMD ["nginx", "-g", "daemon off;"]
