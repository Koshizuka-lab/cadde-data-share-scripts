# CADDEデータ共有ハンズオン(11/26)

## 0.前提

　[CADDEデータ共有環境の構築(11/26)](https://github.com/Koshizuka-lab/cadde-data-share-scripts/blob/main/doc/0-data-share-setup.md)が完了している。



## 1. 提供者カタログサイト(CKAN)、及び来歴管理サーバの操作

### 1.1. ユーザの作成、組織の作成、CKAN APIキーの作成

　[2.1.2 CKANの初期設定](https://github.com/Koshizuka-lab/klab-connector-v4/blob/testbed/doc_testbed/provider.md#212-ckanの初期設定)を参考に、
以下3つの手続きを終了させる。[CADDEデータ共有環境の構築](https://github.com/Koshizuka-lab/cadde-data-share-scripts/blob/main/doc/0-data-share-setup.md)に従って、CKAN環境構築を行っている場合、
CKANサイトのURLは、`https://cadde-catalog-<シリアル番号>.<サイト名>.dataspace.internal:8443`である。
例えば、CADDEユーザIDが`0001-koshizukalab`ならば、`https://cadde-catalog-0001.koshizukalab.dataspace.internal:8443`にアクセスすればよい。
また、管理者のユーザ名は`ckan_admin`、CKANサイト管理者のパスワードは`test1234`と設定されている。
- ユーザの作成
- 組織（Organization）の作成
- CKAN APIキーの作成
  - この値は来歴情報を登録する際に利用するため、メモに保存しておく。

```txt
CKAN APIキーの例: eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJqdGkiOiJRVjJuU2dBTlRab19pdnNHaGlLY21NSDJpNzY0MVJib05xVVJhN0d2cjRnIiwiaWF0IjoxNzMyODgyNjEzfQ.jj_VaTHsiYkFpygfnke92Wyn5qt61c2CDahc95je4kk
```


### 1.2. データカタログの作成

　[データカタログの作成](https://github.com/Koshizuka-lab/klab-connector-v4/blob/testbed/doc_testbed/handson.md#33-データカタログを作成する)を参考にする。
変更及び設定が必要な項目は以下であることに注意する。
 - `Title`、`Visibility`、`Custom Field`に2つ (最初の画面)
 - `リソースURL`、`Name` (次の画面)

　例えば、以下の値を選択・入力する。

```txt
Title -> Authorized Dataset # 任意の文字列
Visibility -> Public
caddec_dataset_id_for_detail -> authorized # Custom Field、データセットの識別子(任意の文字列)
caddec_provider_id -> 0001-koshizukalab # Custom Field、CADDEユーザIDを入力
```

```txt
Link -> http://data-management.koshizukalab.internal:8080/authorized.txt # 提供者データサーバのリソースURL
Name -> authorized txt data # データファイルを識別するための任意の文字列
```

　データカタログを作成した後の画面で、「Data and Resources」下のファイル名をクリックする。
Additional Informationの下のShow moreをクリックし、IDを確認する(以後、リソースIDと呼ぶ)。
この値は来歴情報を登録する際に利用するため、メモに保存しておく。

```bash
CKAN内のリソースIDの例: 5eb34609-365d-4474-957d-3676f514dfb2
```


### 1.3. データ原本情報の登録(来歴管理サーバ、及び提供者カタログサイト)、及び提供者コネクタへのリソースURL設定

　本手続きを実行して、来歴管理サーバと提供者カタログサイトにデータ原本情報を登録する。
また、その過程で提供者コネクタの接続設定ファイル(`${WORKDIR}/klab-connector-v4/src/provider/connector-main/swagger_server/configs/http.json`)に、提供者HTTPサーバのリソースURLの追加設定も自動的に行われる。

```bash
cd ${WORKDIR}/cadde-data-share-scripts/1-reg-new-data
bash 0-reg_data.sh
```

　設定項目`CKAN APIキー`、`プライベートHTTPサーバに配置したファイル名`、`リソースID`を対話的に入力する。

```bash 
CKAN APIキー: eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJqdGkiOiJRVjJuU2dBTlRab19pdnNHaGlLY21NSDJpNzY0MVJib05xVVJhN0d2cjRnIiwiaWF0IjoxNzMyODgyNjEzfQ.jj_VaTHsiYkFpygfnke92Wyn5qt61c2CDahc95je4kk
リソースID(提供者カタログサイトCKANより取得): 5eb34609-365d-4474-957d-3676f514dfb2
プライベートHTTPサーバに配置したファイル名: authorized.txt
```


　データ原本情報の登録に成功した場合、以下のように表示される。

```txt
...
提供者コネクタ上に、ファイルのURL設定を行いました。
    - ${WORKDIR}/klab-connector-v4/src/provider/connector-main/swagger_server/configs/http.json

来歴サーバに原本情報登録されたデータの情報です。
    - リソースURL: http://data-management.koshizukalab.internal:8080/authorized.txt
    - 来歴イベントID: fb38b323-bf9d-4439-a5b5-e52158257d78
```

## 2. 認可の設定
　
　[3.3. 認可の設定](https://github.com/Koshizuka-lab/klab-connector-v4/blob/testbed/doc_testbed/provider.md#33-認可の設定)を参考に設定を行う。
提供者認可サーバ管理サイト`http://cadde-authz-<シリアル番号>.<サイト名>.dataspace.internal:5080`にアクセスし、認可の設定を行う。
例えば、CADDEユーザIDが`0001-koshizukalab`で共有したいファイルが`authorized.txt`の場合、提供者認可サーバ管理サイト`http://cadde-authz-0001.koshizukalab.dataspace.internal:5080`にアクセスし、認可対象とするリソースURL`http://data-management.seike.internal:8080/authorized.txt`を入力することで設定可能である。



## 3. 利用者コネクタの設定
　
　[提供者コネクタの接続設定](https://github.com/Koshizuka-lab/klab-connector-v4/blob/testbed/doc_testbed/consumer.md#217-提供者コネクタの接続設定)を参考に、`connector_location`を追加する。
CADDEテストベッドはロケーションサービスを提供していないため、以下の設定ファイルを直接編集する必要がある。

```txt
${WORKDIR}/klab-connector-v4/src/consumer/connector-main/swagger_server/configs/location.json
```


## 4. WebAppを用いたデータの授受

　[4. CADDEでデータを取得する](https://github.com/Koshizuka-lab/klab-connector-v4/blob/testbed/doc_testbed/handson.md#4-caddeでデータを取得する)を参考にデータを取得する。
[CADDEデータ共有環境の構築](https://github.com/Koshizuka-lab/cadde-data-share-scripts/blob/main/doc/0-data-share-setup.md)に従って、WebApp環境構築を行っている場合、
WebAppのURLは、`http://cadde-webapp-<シリアル番号>.<サイト名>.dataspace.internal:3000`である。
つまり、CADDEユーザIDが`0001-koshizukalab`の場合、`http://cadde-webapp-0001.koshizukalab.dataspace.internal:3000`にアクセスすることでWebAppが使用可能となる。  

　また、[CADDEデータ共有環境の構築](https://github.com/Koshizuka-lab/cadde-data-share-scripts/blob/main/doc/0-data-share-setup.md)に従って、利用者コネクタの構築を行っている場合、
コネクタのURLは`https://cadde-consumer-<シリアル番号>.<サイト名>.dataspace.internal:1443`となっている。
つまり、CADDEユーザIDが`0001-koshizukalab`の場合、`https://cadde-consumer-0001.koshizukalab.dataspace.internal:1443`を指定することになる。

## 5. CADDE上のデータの来歴を確認する

　以下、コマンドを実行することで来歴を確認可能である。

```bash
cd ${WORKDIR}/cadde-data-share-scripts/1-reg-new-data
bash 1-check_history_of_data.sh
```

　この際、対話的に確認したい来歴イベントIDを入力することで、関連した来歴情報について取得できる。

```txt
確認したいイベントID: fb38b323-bf9d-4439-a5b5-e52158257d78
```