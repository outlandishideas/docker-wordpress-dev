FROM outlandish/wordpress:8.0

COPY --from=composer /usr/bin/composer /usr/bin/composer

# Without `linux-headers`, the pecl installation failed 2/1/23 with:
#
##9 9.579 configure: error: rtnetlink.h is required, install the linux-headers package: apk add --update linux-headers
##9 9.594 ERROR: `/tmp/pear/temp/xdebug/configure --with-php-config=/usr/local/bin/php-config' failed
RUN apk update \
    && apk add --no-cache linux-headers $PHPIZE_DEPS \
    && pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && echo "xdebug.remote_enable=on" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_port=9001" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_connect_back=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_autostart=off" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.profiler_enable=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.profiler_enable_trigger=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.profiler_output_dir=/app/profiling" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "error_reporting = E_ALL" >> /usr/local/etc/php/conf.d/zz-custom.ini \
    && echo "display_errors = on" >> /usr/local/etc/php/conf.d/zz-custom.ini \
    && curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp \
    && curl -OL http://www.phpdoc.org/phpDocumentor.phar \
    && chmod +x phpDocumentor.phar \
    && mv phpDocumentor.phar /usr/local/bin/phpdoc \
    && curl -OL https://github.com/phpmetrics/PhpMetrics/releases/download/v2.3.2/phpmetrics.phar \
    && chmod +x phpmetrics.phar \
    && mv phpmetrics.phar /usr/local/bin/phpmetrics\
    && apk del $PHPIZE_DEPS

RUN apk update \
    && apk add --no-cache openssh git bash

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp
