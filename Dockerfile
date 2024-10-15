FROM alpine AS build

RUN apk add --no-cache --update wget tzdata nodejs npm
RUN apk add --no-cache --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community hugo
RUN npm install -g postcss postcss-cli autoprefixer

WORKDIR /app
COPY . .

# Hugo base url
ARG HUGO_BASEURL="https://tvhsfrc.org"

RUN HUGO_BASEURL=$HUGO_BASEURL hugo --environment production

RUN find public -type f -name "*.html" -exec sed -i "s|src=.*/img/dragons.png|src=\"/img/dragons.png|g" {} \;
RUN find public -type f -name "*.html" -exec sed -i "s|src=.*/img/logo.png|src=\"/img/logo.png|g" {} \;
RUN find public -type f -name "*.html" -exec sed -i "s|class=\"logo-link\" href=\".*\"|class=\"logo-link\" href=\"$HUGO_BASEURL\"|g" {} \;
RUN find public -type f -name "*.html" -exec sed -i "s|href=.*/support|href=\"$HUGO_BASEURL/support|g" {} \;

RUN find public -type f -name "*.html" -exec sed -i "s|src=\"/img|src=\"$HUGO_BASEURL/img|g" {} \;
RUN find public -type f -name "*.html" -exec sed -i "s|href=\"/css|href=\"$HUGO_BASEURL/css|g" {} \;
RUN find public -type f -name "*.html" -exec sed -i "s|src=\"/js|src=\"$HUGO_BASEURL/js|g" {} \;
RUN find public -type f -name "*.html" -exec sed -i "s|href=\"/fonts|href=\"$HUGO_BASEURL/fonts|g" {} \;

RUN find public -type f -name "*.css" -exec sed -i "s|url(/img|url($HUGO_BASEURL/img|g" {} \;
RUN find public -type f -name "*.css" -exec sed -i "s|url(/fonts|url($HUGO_BASEURL/fonts|g" {} \;

FROM nginx:alpine

COPY --from=build /app/public /usr/share/nginx/html
