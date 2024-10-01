FROM alpine AS build

RUN apk add --no-cache --update wget tzdata nodejs npm
RUN apk add --no-cache --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community hugo
RUN npm install -g postcss postcss-cli autoprefixer

WORKDIR /src
COPY ./ /src

RUN hugo --environment production

FROM nginx:alpine

COPY --from=build /src/public /usr/share/nginx/html
