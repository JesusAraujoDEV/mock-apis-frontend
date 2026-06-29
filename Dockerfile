# ============================================================
# Frontend: Panel de Control
# Build con Vite, servido con nginx
# ============================================================
FROM node:20-alpine AS builder

WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm ci
COPY . .
RUN npm run build

# ============================================================
# Producción: nginx
# ============================================================
FROM nginx:alpine AS production

# Eliminar la config default de nginx
RUN rm /etc/nginx/conf.d/default.conf

# Copiar el template de nginx
COPY nginx.conf.template /etc/nginx/templates/default.conf.template

# Copiar los archivos del build
COPY --from=builder /app/dist /usr/share/nginx/html

# Variable de entorno para el backend (se inyecta en el template al arrancar)
ENV BACKEND_URL=http://host.docker.internal:3000

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
