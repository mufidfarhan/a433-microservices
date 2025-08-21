# Menggunakan base image Node.js versi 14
FROM node:14-alpine

# Menentukan working directory
WORKDIR /app

# Menyalin seluruh source code ke working directory
COPY . /app

# Production mode dan host database item-db
ENV NODE_ENV=production DB_HOST=item-db

# Install dependencies untuk production dan build aplikasi
RUN npm install --production --unsafe-perm && npm run build

# Ekspos port 8080
EXPOSE 8080

# Jalankan server saat container diluncurkan
CMD ["npm", "start"]
