FROM node:alpine AS builder
WORKDIR '/app'
COPY package.json .
COPY . .
RUN npm install
FROM node:alpine AS runner
WORKDIR '/app'
COPY --from=builder /app .
CMD ["npm", "start"]
