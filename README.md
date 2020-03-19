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
example:
```bash
mkdir /opt/gocryptfs/cipher
# Initialize folder
gocryptfs -init /opt/gocryptfs/cipher
# create test secret in vault
vault kv put secrets/test password=myP@ssw0rd
docker run --privileged --device /dev/fuse -e "VAULT_URL=https://10.2.0.1:8200"  -v /opt/gocrypt/cipher:/opt/cipher -e "VAULT_TOKEN=s.OYX5xvipiXkskkglrMBhHzu2zuOe" -e "VAULT_KEY=password" -e "MOUNT_SRCPATH=/opt/cipher" -e "MOUNT_TRGPATH=/mnt" -e "IDLE_TIME=120s" -e "VAULT_SECRET=secrets/data/test" -e "VAULT_SKIP_VERIFY=1"  -it gocryptmnt sh
# once you are in the container run
gocryptmnt
# the folder will be mounted at /mnt
```
