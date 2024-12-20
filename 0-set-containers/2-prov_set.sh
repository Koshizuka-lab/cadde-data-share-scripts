#!/bin/bash -e
set -e
set -o pipefail
##########################################################################################
# 事前に設定する内容
##########################################################################################
source ../config.env

##########################################################################################
# Providerの設定ファイルを更新
##########################################################################################
### ブランチの変更
cd ${WORKDIR}/klab-connector-v4/
git switch testbed
echo "ブランチの変更を行いました。"
echo "    - main -> testbed"

### 共通ファイルの展開
cd ${WORKDIR}/klab-connector-v4/src/provider
sh setup.sh
echo "共通ファイルの展開を行いました(以下のスクリプトを実行しました)"
echo "    - ${WORKDIR}/klab-connector-v4/src/provider/setup.sh"

### リバースプロキシの設定
mkdir -p ${WORKDIR}/klab-connector-v4/src/provider/nginx/volumes/ssl
cp ${WORKDIR}/certs/server.key ${WORKDIR}/klab-connector-v4/src/provider/nginx/volumes/ssl/server.key
cp ${WORKDIR}/certs/server.crt ${WORKDIR}/klab-connector-v4/src/provider/nginx/volumes/ssl/server.crt
cp ${WORKDIR}/certs/cacert.pem ${WORKDIR}/klab-connector-v4/src/provider/nginx/volumes/ssl/cacert.pem
ls ${WORKDIR}/klab-connector-v4/src/provider/nginx/volumes/ssl
echo "リバースプロキシ用に秘密鍵(server.key)、サーバ証明書(server.crt、cacert.pem)を配置しました。"
echo "    - ${WORKDIR}/klab-connector-v4/src/provider/nginx/volumes/ssl/server.key"
echo "    - ${WORKDIR}/klab-connector-v4/src/provider/nginx/volumes/ssl/server.crt"
echo "    - ${WORKDIR}/klab-connector-v4/src/provider/nginx/volumes/ssl/cacert.pem"

### データカタログの接続設定
tgt_path=${WORKDIR}/klab-connector-v4/src/provider/connector-main/swagger_server/configs/provider_ckan.json
sed -i "s|<横断検索用カタログサイトURL>|https://cadde-catalog-${CADDE_USER_NUMBER}.${SITE_NAME}.dataspace.internal:8443|g" "$tgt_path"
sed -i "s|<詳細検索用カタログサイトURL>|https://cadde-catalog-${CADDE_USER_NUMBER}.${SITE_NAME}.dataspace.internal:8443|g" "$tgt_path"
echo "データカタログの接続設定を行いました。"
echo "    - ${tgt_path}"

### プライベートHTTPサーバのデフォルトファイルを設定
tgt_path=${WORKDIR}/klab-connector-v4/src/provider/connector-main/swagger_server/configs/http.json
sed -i "s|https://example1.com/data.txt|http://data-management.${SITE_NAME}.internal:8080/authorized.txt|g" "$tgt_path"
sed -i "s|https://example2.com/data.txt|http://data-management.${SITE_NAME}.internal:8080/unauthorized.txt|g" "$tgt_path"
echo "プライベートHTTPサーバのデフォルトファイルを設定しました。"
echo "   - ${tgt_path}"

### Dockerコンテナに独自ドメインを割り当てる
tgt_path=${WORKDIR}/klab-connector-v4/src/provider/docker-compose.yml
sed -i "s|siteXX|${SITE_NAME}|g" "$tgt_path"
echo "ポートフォワーディングの設定変更が完了しました。"
echo "    - ${tgt_path}"

### 提供者コネクタを起動
echo "提供者コネクタを起動しています..."
cd ${WORKDIR}/klab-connector-v4/src/provider
sh ./start.sh
