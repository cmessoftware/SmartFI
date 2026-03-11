# Multi-stage build for Frontend

# Stage 1: Build the React app
FROM node:18-alpine AS builder

# Argument for commit hash (from docker-compose or Render)
ARG COMMIT_HASH
ARG RENDER_GIT_COMMIT

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy source code
COPY . .

# Use RENDER_GIT_COMMIT if available (Render.com), otherwise use COMMIT_HASH, default to 'dev'
ENV VITE_COMMIT_HASH=${RENDER_GIT_COMMIT:-${COMMIT_HASH:-dev}}
RUN echo "Building with version: $VITE_COMMIT_HASH"
RUN npm run build

# Stage 2: Serve with nginx
FROM nginx:alpine

# Install envsubst for runtime config replacement
RUN apk add --no-cache gettext

# Copy custom nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy built files from builder stage
COPY --from=builder /app/dist /usr/share/nginx/html

# Create runtime config template
RUN echo 'window.ENV = { VITE_API_URL: "${VITE_API_URL}" };' > /usr/share/nginx/html/env-config.js.template

# Create startup script
RUN echo '#!/bin/sh' > /docker-entrypoint.sh && \
    echo 'set -e' >> /docker-entrypoint.sh && \
    echo 'echo "Configuring API URL: ${VITE_API_URL:-http://localhost:8000}"' >> /docker-entrypoint.sh && \
    echo 'envsubst < /usr/share/nginx/html/env-config.js.template > /usr/share/nginx/html/env-config.js' >> /docker-entrypoint.sh && \
    echo 'nginx -g "daemon off;"' >> /docker-entrypoint.sh && \
    chmod +x /docker-entrypoint.sh

# Expose port
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost/ || exit 1

# Start with custom entrypoint
CMD ["/docker-entrypoint.sh"]
