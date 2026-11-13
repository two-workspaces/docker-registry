# Private Docker registry (CNCF Distribution) for Railway: the official image, password
# login from service variables, and an entrypoint that maps it onto Railway's port and volume.
FROM registry:3.1.2
# htpasswd makes the bcrypt password file the registry's htpasswd auth reads;
# python3 runs drop-file-cache.
RUN apk add --no-cache apache2-utils python3
# The image's example config logs at debug level, every request with its headers,
# and tags every line environment=development.
ENV REGISTRY_LOG_LEVEL=info REGISTRY_LOG_FIELDS_ENVIRONMENT=railway
COPY drop-file-cache /usr/local/bin/drop-file-cache
COPY railway-entrypoint.sh /railway-entrypoint.sh
RUN chmod 755 /usr/local/bin/drop-file-cache /railway-entrypoint.sh
ENTRYPOINT ["/railway-entrypoint.sh"]
