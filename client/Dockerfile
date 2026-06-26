FROM node:18-alpine

WORKDIR /app

COPY package.json package-lock.json ./

RUN npm install

COPY src ./src
COPY public ./public
COPY index.html vite.config.js ./

EXPOSE 5173

CMD ["npm", "run", "dev"]
