FROM composer:2 AS vendor

WORKDIR /app
COPY composer.json composer.lock ./
RUN composer install --no-dev --no-scripts --prefer-dist --no-interaction

FROM php:8.3-cli-alpine

RUN apk add --no-cache icu-dev oniguruma-dev ca-certificates \
    && docker-php-ext-install pdo pdo_mysql mbstring intl \
    && rm -rf /var/cache/apk/*

WORKDIR /app

COPY --from=vendor /app/vendor ./vendor
COPY . .

RUN chmod +x docker-entrypoint.sh \
    && php artisan package:discover --ansi || true

ENV PORT=10000
EXPOSE 10000

ENTRYPOINT ["./docker-entrypoint.sh"]
