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

# 3. Kompilujemy CSS z global.css do osobnego pliku compiled.css
RUN npx tailwindcss -i ./src/style/global.css -o ./src/style/compiled.css --minify

# 4. Magiczny krok: Podmieniamy import w plikach projektu, aby Astro ładowało gotowy plik CSS
RUN find src/ -type f \( -name "*.astro" -o -name "*.ts" -o -name "*.js" \) -exec sed -i 's/global.css/compiled.css/g' {} +

# 5. Wycinamy wywołanie tailwindcss() z pliku konfiguracyjnego Astro, by Vite go nie dotykał
RUN sed -i 's/tailwindcss()//g' astro.config.mjs

# 6. Budujemy gotową statyczną stronę Astro
RUN npm run build

# Etap serwowania strony statycznej przez NGINX
FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
