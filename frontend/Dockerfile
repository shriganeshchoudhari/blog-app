# Build stage
FROM node:20-alpine AS builder
WORKDIR /build
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Runtime stage
FROM nginx:alpine
WORKDIR /app

# Create non-root user
RUN addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup

# Copy built assets
COPY --from=builder /build/dist /usr/share/nginx/html

# Copy custom nginx config
COPY nginx.conf /etc/nginx/nginx.conf

# Create directories writable by non-root user
RUN mkdir -p /var/cache/nginx /var/run /var/log/nginx && \
    chown -R appuser:appgroup /var/cache/nginx /var/run /var/log/nginx /usr/share/nginx/html && \
    touch /var/run/nginx.pid && chown appuser:appgroup /var/run/nginx.pid

# Expose port
EXPOSE 80

# Switch to non-root user
USER appuser

CMD ["nginx", "-g", "daemon off;"]
