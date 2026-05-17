# Używamy oficjalnego, stabilnego obrazu Node 22
FROM node:22-alpine AS build
WORKDIR /app

# Kopiujemy pliki konfiguracyjne
COPY package*.json ./

# 1. Instalujemy zależności projektu
RUN npm install

# 2. Instalujemy oficjalne, stabilne CLI dla Tailwind v4 jako narzędzie deweloperskie
RUN npm install -D @tailwindcss/cli

# Kopiujemy całą resztę kodu
COPY . .

# 3. Kompilujemy CSS za pomocą lokalnego CLI bezpośrednio nadpisując plik wejściowy
RUN npx tailwindcss -i ./src/style/global.css -o ./src/style/global.css --minify

# 4. Wycinamy wywołanie tailwindcss() z pliku konfiguracyjnego Astro, by Vite go nie dotykał
RUN sed -i 's/tailwindcss()//g' astro.config.mjs

# 5. Budujemy gotową statyczną stronę Astro
RUN npm run build

# Etap serwowania strony statycznej przez NGINX
FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
