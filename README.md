# gocryptmnt

gocryptmnt uses gocryptfs and vault to mount a gocryptfs encrypted folder

## Install
```bash
make
```
## Uninstall
```bash
make uninstall
```

## Initialize gocryptfs folder
```bash
mkdir cipher plain
gocrpytfs - init cipher
```

in vault create a secret
for instance
```bash
vault kv put secrets/gocryptfs password=v3ryS3cure
```

also create a token
```bash
vault token create -display-name=gocryptfs
```

### use env vars
```bash
export VAULT_URL=<url>
export VAULT_TOKEN=<your token>
export VAULT_SECRET=secrets/data/gocryptfs
export VAULT_KEY=password
export IDLE_TIME=120s
export MOUNT_SRCPATH=/tmp/cipher
export MOUNT_TRGPATH=/tmp/plain
```

### use cli params
```bash
gocryptmnt -u <url> -s <token> -l secrets/data/gocryptfs -i 120s -f password -p /tmp/cipher -t /tmp/plain
```

## Build docker image
```bash
docker build -t gocryptmnt .
```
### run docker container
```bash
docker run --privileged --device /dev/fuse -it gocryptmnt sh
mkdir cipher plain
gocryptfs -init cipher
gocryptfs cipher plain
```
run container with env variables
```bash
docker run --privileged --device /dev/fuse -e "VAULT_URL=<url>" -e "VAULT_TOKEN=<token>" -e "VAULT_KEY=password" -e "MOUNT_SRCPATH=/mnt/t" -e ... -it gocryptmnt sh
```
