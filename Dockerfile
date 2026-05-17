# Używamy oficjalnego, stabilnego obrazu Node 22
FROM node:22-alpine AS build
WORKDIR /app

# Kopiujemy pliki konfiguracyjne
COPY package*.json ./

# 1. Instalujemy standardowe zależności
RUN npm install

# 2. Usuwamy wadliwą wtyczkę i instalujemy stabilną wersję PostCSS dla Tailwind v4
RUN npm uninstall @tailwindcss/vite
RUN npm install @tailwindcss/postcss postcss Autoprefixer

# 3. Tworzymy w locie plik konfiguracyjny postcss.config.mjs, aby Astro automatycznie przetworzyło CSS
RUN echo "export default { plugins: { '@tailwindcss/postcss': {}, autoprefixer: {} } }" > postcss.config.mjs

# Kopiujemy resztę kodu i budujemy stronę
COPY . .
RUN npm run build

# Etap serwowania strony statycznej za pomocą lekkiego serwera NGINX
FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
