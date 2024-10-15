FROM alpine AS build

RUN apk add --no-cache --update wget tzdata nodejs npm
RUN apk add --no-cache --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community hugo
RUN npm install -g postcss postcss-cli autoprefixer

WORKDIR /app
COPY . .

# Hugo base url
ARG HUGO_BASEURL="https://tvhsfrc.org"

RUN hugo --environment production

# Remove the entire BaseURL from all hrefs, srcs, and urls.
RUN find public -type f \( -name "*.html" -o -name "*.css" \) -print -exec sed -i "s|$HUGO_BASEURL||g" {} \;
# Extract the _path_ from the Base URL, `https://example.com/some/path` -> `/some/path`
RUN HUGO_BASEURL_PATH=$(echo $HUGO_BASEURL | sed -n 's|https://[^/]*\(.*\)|\1|p') && \
    echo $HUGO_BASEURL_PATH && \
    find public -type f \( -name "*.html" -o -name "*.css" \) -print -exec sed -i "s|$HUGO_BASEURL_PATH||g" {} \;
# Extract the scheme and domain from the Base URL, `https://example.com/path/` -> `https://example.com`
RUN HUGO_BASEURL_SCHEME_DOMAIN=$(echo $HUGO_BASEURL | sed -n 's|\(https://[^/]*\).*|\1|p') && \
    echo $HUGO_BASEURL_SCHEME_DOMAIN && \
    find public -type f \( -name "*.html" -o -name "*.css" \) -print -exec sed -i "s|$HUGO_BASEURL_SCHEME_DOMAIN||g" {} \;

# Add back the BaseURL to all hrefs, srcs, and urls
RUN find public -type f \( -name "*.html" -o -name "*.css" \) -exec sed -i "s|href=\"/|href=\"$HUGO_BASEURL/|g" {} \;
RUN find public -type f \( -name "*.html" -o -name "*.css" \) -exec sed -i "s|src=\"/|src=\"$HUGO_BASEURL/|g" {} \;
RUN find public -type f \( -name "*.html" -o -name "*.css" \) -exec sed -i "s|url(\"/|url(\"$HUGO_BASEURL/|g" {} \;

# Remove integrity attributes from script and link tags
RUN find public -type f -name "*.html" -exec sed -i "s| integrity=\"[^\"]*\"||g" {} \;

FROM nginx:alpine

COPY --from=build /app/public /usr/share/nginx/html
