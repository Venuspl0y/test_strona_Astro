# Używamy oficjalnego, stabilnego obrazu Node 22
FROM node:22-alpine AS build
WORKDIR /app

# Kopiujemy pliki konfiguracyjne
COPY package*.json ./

# 1. Instalujemy zależności projektu
RUN npm install

# 2. Pobieramy oficjalne, samodzielne CLI Tailwinda v4 (wersja dla Linux x64)
RUN apk add --no-cache curl
RUN curl -sLO https://github.com/tailwindlabs/tailwindcss/releases/latest/download/tailwindcss-linux-x64 && \
    chmod +x tailwindcss-linux-x64 && \
    mv tailwindcss-linux-x64 /usr/local/bin/tailwindcss

# Kopiujemy resztę kodu źródłowego
COPY . .

# 3. Kompilujemy plik CSS za pomocą CLI bezpośrednio do katalogu wejściowego Astro
RUN tailwind -i ./src/style/global.css -o ./src/style/global.css --minify

# 4. Wyłączamy wtyczkę w astro.config.mjs, aby Vite nie próbował jej ponownie odpalać
RUN sed -i 's/tailwindcss()//g' astro.config.mjs

# 5. Budujemy czystą stronę Astro (teraz przejdzie bezbłędnie)
RUN npm run build

# Etap serwowania strony statycznej przez NGINX
FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
