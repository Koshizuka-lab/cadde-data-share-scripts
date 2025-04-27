#!/bin/bash -e
set -e
set -o pipefail
##########################################################################################
# 事前に設定する内容
##########################################################################################
source ../config.env

# 提供者の認可機能によるクライントID/シークレットの定義
read -rp "認可サーバのクライアントシークレット: " PROVIDER_CLIENT_SECRET_BY_AUTHZ

##########################################################################################
# 提供者認可機能の設定ファイルを更新
##########################################################################################
### 提供者コネクタの認可サーバへの接続設定
echo "提供者コネクタの認可サーバへの接続を設定"
tgt_path=${WORKDIR}/klab-connector-v4/src/provider/authorization/swagger_server/configs/authorization.json
echo "    - ${tgt_path}"
sed -i "s|<認可機能アクセスURL>|http://cadde-authz-${CADDE_USER_NUMBER}.${SITE_NAME}.dataspace.internal:5080|g" "$tgt_path"

### 提供者の認可サーバと提供者コネクタの連携
echo "提供者の認可サーバと提供者コネクタの連携を設定"
tgt_path=${WORKDIR}/klab-connector-v4/src/provider/connector-main/swagger_server/configs/connector.json
echo "    - ${tgt_path}"
sed -i "s|<CADDEユーザID>|${CADDE_USER_ID}|g" "$tgt_path"
sed -i "s|<提供者コネクタのクライアントID>|provider-${CADDE_USER_ID}|g" "$tgt_path"
sed -i "s|<提供者コネクタのクライアントシークレット>|${PROVIDER_CLIENT_SECRET_BY_AUTHZ}|g" "$tgt_path"

### 提供者コネクタの再起動
cd ${WORKDIR}/klab-connector-v4/src/provider
echo "認可サーバの設定を反映するため、提供者コネクタを再起動しています..."
sh ./stop.sh
sh ./start.sh
echo "提供者コネクタの再起動が完了しました。"


