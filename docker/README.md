# Custom Data Gateway Container Image

This container image improves the upstream image in two ways:

1. Runs SSH in verbose mode for visibility and troubleshooting.
2. Sends keep alive messages to keep the connection alive across firewalls.

This is achieved by modifying the provided `run.sh`:
```
--- run-orig.sh 2025-09-16 21:00:50.283573821 +1000
+++ run.sh      2025-09-16 20:55:53.515531592 +1000
@@ -14,4 +14,4 @@
 echo "--------------PUBLIC KEY--------------"
 cat bifrost.pub
 echo "------------END PUBLIC KEY------------"
-ssh -o StrictHostKeyChecking=accept-new -i bifrost -R 172.31.86.235:$HUB_PORT:$DEST_SERVER:$DEST_PORT -N datahub@datahub.informer.cloud
+ssh -v -o ServerAliveInterval=60 -o StrictHostKeyChecking=accept-new -i bifrost -R 172.31.86.235:$HUB_PORT:$DEST_SERVER:$DEST_PORT -N datahub@datahub.informer.cloud
```

## Building and publishing

```sh
# Log into the product-prod registry
aws-vault exec product-prod -- aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws

# Build the image
docker build -t public.ecr.aws/n9s1h1c1/informer-datahub-tunnel:latest .

# Push the image
docker push public.ecr.aws/n9s1h1c1/informer-datahub-tunnel:latest
```
