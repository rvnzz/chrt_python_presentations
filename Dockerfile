# Dockerfile
FROM oven/bun:1-alpine AS builder

WORKDIR /app

# Копируем зависимости
COPY package.json bun.lockb* ./
RUN bun install --frozen-lockfile

# Копируем исходники
COPY slides/ ./slides/
COPY index-template.html ./
COPY build-slides.sh ./

# Делаем исполняемым
RUN chmod +x build-slides.sh

# Собираем
RUN ./build-slides.sh

# Финальный образ (только статика)
FROM nginx:alpine AS runner

# Копируем собранные файлы
COPY --from=builder /app/dist/ /usr/share/nginx/html/

# Nginx конфиг
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost/ || exit 1
