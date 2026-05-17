# Używamy oficjalnego, stabilnego obrazu Node 22
FROM node:22-alpine AS build
WORKDIR /app

# Kopiujemy pliki konfiguracyjne
COPY package*.json ./

# Sposób na zepsuty konflikt Rolldown/Tailwind: wymuszamy instalację najnowszych stabilnych wersji tych paczek
RUN npm install
RUN npm install @tailwindcss/vite@latest vite@latest rolldown@latest

# Kopiujemy resztę kodu i budujemy stronę
COPY . .
RUN npm run build

# Etap serwowania strony statycznej za pomocą lekkiego serwera NGINX
FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html

# Informujemy o porcie (standardowy port HTTP dla NGINX to 80)
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
