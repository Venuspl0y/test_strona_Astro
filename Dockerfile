# Używamy oficjalnego, stabilnego obrazu Node 22
FROM node:22-alpine AS build
WORKDIR /app

# Kopiujemy pliki konfiguracyjne
COPY package*.json ./

# 1. Brutalnie usuwamy zepsutą wtyczkę z pliku package.json przed instalacją
RUN sed -i '/"@tailwindcss\/vite"/d' package.json

# 2. Instalujemy czyste zależności projektu (bez zepsutej wtyczki)
RUN npm install

# 3. Instalujemy w 100% stabilną, oficjalną integrację PostCSS dla Tailwind v4
RUN npm install @tailwindcss/postcss postcss autoprefixer

# 4. Tworzymy w locie plik konfiguracyjny postcss.config.mjs
RUN echo "export default { plugins: { '@tailwindcss/postcss': {}, autoprefixer: {} } }" > postcss.config.mjs

# Kopiujemy resztę kodu
COPY . .

# 5. Czyścimy plik konfiguracyjny Astro z importów i wywołań starej wtyczki
RUN sed -i '/@tailwindcss\/vite/d' astro.config.mjs
RUN sed -i 's/tailwind()//g' astro.config.mjs

# Budujemy stronę przez stabilne PostCSS
RUN npm run build

# Etap serwowania strony statycznej przez NGINX
FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
