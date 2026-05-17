# Używamy oficjalnego, stabilnego obrazu Node 22
FROM node:22-alpine AS build
WORKDIR /app

# Kopiujemy pliki konfiguracyjne
COPY package*.json ./

# 1. Instalujemy standardowe zależności projektu
RUN npm install

# 2. Wymuszamy stabilną, sprawdzoną wersję wtyczki Tailwinda v4, która nie ma błędu regresji
RUN npm install @tailwindcss/vite@4.0.3

# Kopiujemy resztę kodu (w tym nienaruszony astro.config.mjs)
COPY . .

# Budujemy aplikację przez standardowy proces Astro
RUN npm run build

# Etap serwowania strony statycznej przez NGINX
FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
