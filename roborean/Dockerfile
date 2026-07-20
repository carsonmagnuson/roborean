# dependencies
FROM node:22-alpine AS deps
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci

# build
FROM node:22-alpine AS builder
WORKDIR /app
copy --from=deps /app/node_modules ./node_modules
copy . .
run npm run build

# run
FROM node:22-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
RUN addgroup -S nodejs && adduser -S nextjs -G nodejs
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.nextx/static
COPY --from=builder /app/public ./public
USER  nextjs
EXPOSE 3000
CMD ["node", "server.js"]

