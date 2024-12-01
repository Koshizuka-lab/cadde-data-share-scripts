#!/bin/bash -e
set -e
set -o pipefail
##########################################################################################
# 事前に設定する内容
##########################################################################################
source ../config.env

##########################################################################################
# WebAppの起動
##########################################################################################
cd ${WORKDIR}/ut-cadde_gui
git switch testbed

# 環境変数の設定
cp .env .env.local
tgt_path="${WORKDIR}/ut-cadde_gui/.env.local"
sed -i "s|^CLIENT_ID=.*|CLIENT_ID=\"${WEBAPP_CLIENT_ID}\"|" "$tgt_path"
sed -i "s|^CLIENT_SECRET=.*|CLIENT_SECRET=\"${WEBAPP_CLIENT_SECRET}\"|" "$tgt_path"
echo "WebApp用の環境変数を設定しました。"
echo "    - ${tgt_path}"

# WebAppの起動
echo "WebAppを起動しています..."
cd ${WORKDIR}/ut-cadde_gui
docker pull docker.io/library/node:18.12-alpine
docker compose build
docker compose up -d
docker compose ps
echo "WebAppの起動が完了しました。"
