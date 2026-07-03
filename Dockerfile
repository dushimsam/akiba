FROM node:20-alpine AS builder
WORKDIR /app
COPY package.json ./
COPY server/package.json ./server/
COPY client/package.json ./client/
RUN npm install
COPY . .
RUN npm run build -w client
FROM node:20-alpine AS runner
ENV NODE_ENV=production
ENV PORT=3000
WORKDIR /app/server
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
COPY server/package.json ./
RUN npm install --omit=dev
COPY --from=builder /app/server/src ./src
COPY --from=builder /app/client/dist ./client/dist
RUN chown -R appuser:appgroup /app
USER appuser
EXPOSE 3000
CMD ["node", "src/index.js"]