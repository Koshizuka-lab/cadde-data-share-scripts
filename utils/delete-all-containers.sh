### 稼働中を含む全Dockerコンテナを停止するスクリプト

### HTTPサーバ
cd ${WORKDIR}/private-http-server
docker compose down --volumes --rmi all

### CKAN
cd ${WORKDIR}/ckan-docker
docker compose down --volumes --rmi all

### 提供者コネクタ
cd ${WORKDIR}/klab-connector-v4/src/provider
docker compose down --volumes --rmi all

### 認可サーバ
cd ${WORKDIR}/klab-connector-v4/misc/authorization
docker compose down --volumes --rmi all

### 利用者コネクタ
cd ${WORKDIR}/klab-connector-v4/src/consumer
docker compose down --volumes --rmi all

### WebApp
cd ${WORKDIR}/ut-cadde_gui
docker compose down --volumes --rmi all
