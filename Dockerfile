# Używamy oficjalnego, stabilnego obrazu Node 22
FROM node:22-alpine AS build
WORKDIR /app

# Kopiujemy pliki konfiguracyjne
COPY package*.json ./

# 1. Instalujemy standardowe zależności (w tym oryginalne paczki)
RUN npm install

# 2. Dogrywamy stabilny kompilator PostCSS dla Tailwind v4
RUN npm install @tailwindcss/postcss postcss autoprefixer

# 3. Tworzymy plik konfiguracyjny postcss.config.mjs
RUN echo "export default { plugins: { '@tailwindcss/postcss': {}, autoprefixer: {} } }" > postcss.config.mjs

# Kopiujemy kod projektu
COPY . .

# 4. Magiczny krok: Wyłączamy wadliwą wtyczkę w astro.config.mjs i zastępujemy ją pustą tablicą
RUN sed -i 's/tailwind()//g' astro.config.mjs

# Budujemy stronę (teraz Astro automatycznie użyje stabilnego PostCSS)
RUN npm run build

# Etap serwowania strony statycznej przez NGINX
FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
