FROM node:alpine

WORKDIR /usr/src/app

COPY package.json ./
COPY package-lock.json ./

RUN npm install
# RUN npm ci --only=production

COPY . .

EXPOSE 8080
CMD ["node","server.js"]
