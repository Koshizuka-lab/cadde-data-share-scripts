#!/bin/bash -e
set -e
set -o pipefail

##########################################################################################
# 事前に設定する内容
##########################################################################################
source ./config.env

#########################################################################################
# 各種サービスに関するリポジトリのクローン、ディレクトリの作成
##########################################################################################
# CKAN
cd ${WORKDIR}
git clone https://github.com/ckan/ckan-docker.git
# 提供者、利用者、認可機能など
cd ${WORKDIR}
git clone https://github.com/Koshizuka-lab/klab-connector-v4.git
cd klab-connector-v4
git switch testbed
# 利用者WebApp
cd ${WORKDIR}
git clone https://github.com/Koshizuka-lab/ut-cadde_gui.git
cd ut-cadde_gui
git switch testbed
# プライベートHTTPサーバ
cd ${WORKDIR}
mkdir -p private-http-server
cd ${WORKDIR}/private-http-server
cat <<EOL > "${WORKDIR}/private-http-server/compose.yml"
services:
    nginx:
      image: nginx:alpine
      ports:
        - "8080:80"
      volumes:
        - ./data:/usr/share/nginx/html
EOL
# データを格納するディレクトリとデフォルト用のファイル作成
mkdir -p data
echo "Authorized data from CADDE." > ./data/authorized.txt
echo "Unauthorized data from CADDE." > ./data/unauthorized.txt



