FROM node:20.19.0-alpine

# install dept
RUN apk update

RUN apk add python3 py3-pip py3-uv git

WORKDIR /opt

RUN git clone https://github.com/sda06407/browser-control-mcp

WORKDIR /opt/browser-control-mcp/mcp-server

# change host from localhost to 0.0.0.0 for port forward
RUN sed -i 's/localhost/0.0.0.0/g' ./browser-api.ts

RUN sed -i 's/localhost/0.0.0.0/g' ./util.ts
# extend timeout 
RUN sed -i 's/EXTENSION_RESPONSE_TIMEOUT_MS = 1000/EXTENSION_RESPONSE_TIMEOUT_MS = 200000/g' ./browser-api.ts

WORKDIR /opt/browser-control-mcp/

RUN npm install

RUN npm install --prefix mcp-server

RUN npm install --prefix firefox-extension

RUN npm install -g nx

RUN npm run build

RUN uv tool install mcp-proxy

WORKDIR /opt

#ARG EXTENSION_SECRET

ENV EXTENSION_SECRET=""

# please port forward 8081 8082 and 8083 out

ENTRYPOINT ["sh", "-c", "/root/.local/bin/mcp-proxy --sse-host 0.0.0.0 --sse-port 8083 --pass-environment -e EXTENSION_SECRET $EXTENSION_SECRET  -- node /opt/browser-control-mcp/mcp-server/dist/server.js"]
