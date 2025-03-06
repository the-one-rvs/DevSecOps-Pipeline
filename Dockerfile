FROM node:alpine AS builder
WORKDIR '/app'
COPY package.json .
RUN npm install
COPY . .
FROM node:alpine AS runner
WORKDIR '/app'
COPY --from=builder /app .
CMD ["npm", "start"]
