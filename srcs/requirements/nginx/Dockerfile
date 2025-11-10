FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/nginx/ssl

COPY conf/nginx.conf /etc/nginx/nginx.conf

COPY tools/setup_ssl.sh /usr/local/bin/setup_ssl.sh
RUN chmod +x /usr/local/bin/setup_ssl.sh

CMD ["/bin/bash", "-c", "/usr/local/bin/setup_ssl.sh && nginx -g 'daemon off;'"]
