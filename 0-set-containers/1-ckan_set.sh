#!/bin/bash -e
set -e
set -o pipefail

##########################################################################################
# 事前に設定する内容
##########################################################################################
source ../config.env

##########################################################################################
# CKANの設定ファイルを更新
##########################################################################################
### .envの編集
src_path="${WORKDIR}/ckan-docker/.env.example"
tgt_path="${WORKDIR}/ckan-docker/.env"
cp "$src_path" "$tgt_path"
# 'CKAN_SITE_URL=' で始まる行を置き換える
sed -i "s|^CKAN_SITE_URL=.*|CKAN_SITE_URL=https://cadde-catalog-${CADDE_USER_NUMBER}.${SITE_NAME}.dataspace.internal:8443|" "$tgt_path"
echo "${src_path} を以下にコピーし、ファイルの編集を行いました。"
echo "    - ${tgt_path}"

### Dockerfileの編集(バージョン番号)
tgt_path="${WORKDIR}/ckan-docker/ckan/Dockerfile"
sed -i 's|^FROM ckan/ckan-base:.*|FROM ckan/ckan-base:2.10.4|' "$tgt_path"
sed -i 's|^USER ckan|# USER ckan|' "$tgt_path"
echo "Dockerfileの編集を行いました。"
echo "    - ${tgt_path}"

### 秘密鍵とサーバ証明書のコピー
cp "${WORKDIR}/certs/server.key" "${WORKDIR}/ckan-docker/nginx/setup/ckan-local.key"
cp "${WORKDIR}/certs/server.crt" "${WORKDIR}/ckan-docker/nginx/setup/ckan-local.crt"
echo "秘密鍵(server.key)とサーバ証明書(server.cet)を以下にコピーしました。"
echo "    - ${WORKDIR}/ckan-docker/nginx/setup/ckan-local.key"
echo "    - ${WORKDIR}/ckan-docker/nginx/setup/ckan-local.crt"

### nginxのDockerfileの編集
cat <<EOL > "${WORKDIR}/ckan-docker/nginx/Dockerfile"
FROM nginx:stable-alpine

ENV NGINX_DIR=/etc/nginx

RUN apk update --no-cache && \\
    apk upgrade --no-cache && \\
    apk add --no-cache openssl

COPY setup/nginx.conf \${NGINX_DIR}/nginx.conf
COPY setup/index.html /usr/share/nginx/html/index.html
COPY setup/default.conf \${NGINX_DIR}/conf.d/

RUN mkdir -p \${NGINX_DIR}/certs

COPY setup/ckan-local.crt \${NGINX_DIR}/certs/ckan-local.crt
COPY setup/ckan-local.key \${NGINX_DIR}/certs/ckan-local.key

ENTRYPOINT nginx -g 'daemon off;'
EOL
echo "NGINXのDockerfileの編集を行いました。"
echo "    - ${WORKDIR}/ckan-docker/nginx/Dockerfile"

### CKANサイトのBuildと起動
cd ${WORKDIR}/ckan-docker
echo "CKANサイトのBuildを行っています..."
docker compose build
echo "CKANサイトの起動を行っています..."
docker compose up -d
