# Private Docker registry (CNCF Distribution) for Railway: the official image, password
# login from service variables, and an entrypoint that maps it onto Railway's port and volume.
FROM registry:3.1.2
# htpasswd makes the bcrypt password file the registry's htpasswd auth reads.
RUN apk add --no-cache apache2-utils
# The image's example config logs at debug level, every request with its headers.
ENV REGISTRY_LOG_LEVEL=info
COPY railway-entrypoint.sh /railway-entrypoint.sh
RUN chmod 755 /railway-entrypoint.sh
ENTRYPOINT ["/railway-entrypoint.sh"]
