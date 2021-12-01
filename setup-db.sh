#!/bin/sh

SERVER_ADDR=127.0.0.1
CB_USERNAME=Administrator
CB_PASSWORD=password

CURL_FLAGS='--silent --output /dev/null --show-error --fail'

printf 'Waiting for Couchbase Server to be reachable .'
until $(curl --output /dev/null --silent --head --fail http://${SERVER_ADDR}:8091/ui/index.html); do
    printf '.'
    sleep 1
done
echo ' OK Ready!'
echo ''

echo 'Initialise cluster and admin user'
curl ${CURL_FLAGS} http://${SERVER_ADDR}:8091/pools/default \
  -d memoryQuota=1024 -d indexMemoryQuota=512 \
&& echo ' ... OK'
curl ${CURL_FLAGS}  http://${SERVER_ADDR}:8091/node/controller/setupServices \
  -d services=kv%2cn1ql%2Cindex \
&& echo ' ... OK'
curl ${CURL_FLAGS}  http://${SERVER_ADDR}:8091/settings/web \
  -d port=8091 -d username=${CB_USERNAME} -d password=${CB_PASSWORD} \
&& echo ' ... OK'
curl ${CURL_FLAGS}  -u ${CB_USERNAME}:${CB_PASSWORD} http://${SERVER_ADDR}:8091/settings/indexes \
  -d storageMode=plasma \
&& echo ' ... OK'
echo ''



echo 'Initialise beer-sample bucket'
curl ${CURL_FLAGS}  -u ${CB_USERNAME}:${CB_PASSWORD} http://${SERVER_ADDR}:8091/sampleBuckets/install \
  -d '["beer-sample"]' \
&& echo '\n ... OK'
echo ''



echo 'Create the Sync Gateway App user'
curl -X PUT ${CURL_FLAGS} -u ${CB_USERNAME}:${CB_PASSWORD} http://${SERVER_ADDR}:8091/settings/rbac/users/local/sgw-app \
  -d password=hunter2 -d roles=mobile_sync_gateway[*] \
&& echo ' ... OK'
echo ''



echo 'Create bucket1, bucket2 and bucket3 for sg-legacy-config'
echo '--------------------------------------------------------'
curl ${CURL_FLAGS}  -u ${CB_USERNAME}:${CB_PASSWORD} http://${SERVER_ADDR}:8091/pools/default/buckets \
  -d name=bucket1 -d bucketType=couchbase -d ramQuotaMB=200 \
&& echo ' ... OK'
curl ${CURL_FLAGS}  -u ${CB_USERNAME}:${CB_PASSWORD} http://${SERVER_ADDR}:8091/pools/default/buckets \
  -d name=bucket2 -d bucketType=couchbase -d ramQuotaMB=200 \
&& echo ' ... OK'
curl ${CURL_FLAGS}  -u ${CB_USERNAME}:${CB_PASSWORD} http://${SERVER_ADDR}:8091/pools/default/buckets \
  -d name=bucket3 -d bucketType=couchbase -d ramQuotaMB=200 \
&& echo ' ... OK'
echo ''
