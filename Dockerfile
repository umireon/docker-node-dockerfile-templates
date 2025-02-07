FROM node:bullseye-slim
WORKDIR /root
COPY package.json package-lock.json tsconfig.json ./
COPY src src
RUN npm install
RUN npm run build

FROM node:bullseye-slim
RUN apt-get update && apt-get install -y \
  tini \
  && apt-get clean && rm -rf /var/lib/apt/lists/*
ENTRYPOINT ["/usr/bin/tini", "--"]
USER node
WORKDIR /home/node
COPY --chown=node:node package.json package-lock.json ./
RUN npm install --production && npm cache clean --force
COPY --from=0 --chown=node:node /root/src src
CMD ["node", "src/index.js", "index.ts"]
EXPOSE 3000
