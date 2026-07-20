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

# migration
FROM node:22-alpine AS migrator
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY package.json drizzle.config.ts ./
COPY db ./db
COPY drizzle ./drizzle
CMD ["npx", "drizzle-kit", "migrate"]

# run
FROM node:22-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
RUN addgroup -S nodejs && adduser -S nextjs -G nodejs
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/public ./public
USER  nextjs
EXPOSE 3000
CMD ["node", "server.js"]

