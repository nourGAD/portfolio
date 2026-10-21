# Static portfolio served by unprivileged NGINX (runs as non-root on port 8080)
FROM nginxinc/nginx-unprivileged:1.27-alpine

LABEL org.opencontainers.image.title="nourgad-portfolio" \
      org.opencontainers.image.source="https://github.com/nourGAD/portfolio" \
      org.opencontainers.image.authors="Nour Gad"

COPY deploy/docker/nginx.conf /etc/nginx/conf.d/default.conf
COPY --chown=101:101 docs/index.html docs/devops_portfolio.html /usr/share/nginx/html/

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
  CMD wget -qO- http://127.0.0.1:8080/healthz || exit 1
