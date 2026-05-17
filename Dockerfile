# Używamy oficjalnego, stabilnego obrazu Node 22
FROM node:22-alpine AS build
WORKDIR /app

# Kopiujemy pliki konfiguracyjne
COPY package*.json ./

# 1. Instalujemy standardowe zależności
RUN npm install

# 2. Nadpisujemy zbugowane wersje instalując stabilne, zsynchronizowane wersje z linii Vite 6.0
RUN npm install vite@6.0.11 @tailwindcss/vite@4.0.0 rolldown@1.0.0-beta.3

# Kopiujemy resztę kodu i budujemy stronę
COPY . .
RUN npm run build

# Etap serwowania strony statycznej za pomocą lekkiego serwera NGINX
FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
