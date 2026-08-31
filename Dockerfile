# Static portfolio served by nginx. No application build step required.
# nginx:stable-alpine tracks the current stable branch of the official image.
FROM nginx:stable-alpine

# Project-local server config (replaces the stock default.conf).
COPY deploy/nginx.conf /etc/nginx/conf.d/default.conf

# Copy only the published site files. doc/, README and task files stay out of the image.
COPY index.html /usr/share/nginx/html/index.html
COPY css/ /usr/share/nginx/html/css/
COPY js/ /usr/share/nginx/html/js/
COPY assets/ /usr/share/nginx/html/assets/

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -q -O /dev/null http://127.0.0.1:80/ || exit 1
