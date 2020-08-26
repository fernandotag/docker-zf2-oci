# Docker ZF2 + OCI8
Docker Image for ZF2 built on Debian, with Apache2, PHP5.6, OCI8 extension and the Oracle Instant Client.

## Running your ZF2 application in Docker

Run your docker container and adjust `/home/user/your-zf2-app`
to match the local path to your ZF2 Application root.

```bash
cd /home/user/your-zf2-app
sudo docker run -d -p 8080:80 \
        -v $(pwd):/zf2-app codartbr/zf2-oci
```

### Options / environment variables to fine tune the config
```bash
docker run \
    -e DOCKER_ZF2_ENV="DEV" \ # DEV|PROD copies dev or prod config to /etc (default:DEV)
    -e PHP_MODS_DISABLE="xdebug sqlite" # explicitly disable php modules (space separated list of modules)
    -e PHP_MODS_ENABLE="mysql opcache" # explicitly enable php modules (space separated list of modules)

```

## Examples

### Example with ZF2 Skeleton Application

```bash
curl -s https://getcomposer.org/installer | php --
php composer.phar create-project \
        -sdev --repository-url="https://packages.zendframework.com" \
        zendframework/skeleton-application zend-framework-skeleton
cd zend-framework-skeleton
sudo docker run -d -p 8080:80 -v $(pwd):/zf2-app codartbr/zf2-oci
```

Now visit http://localhost:8080 and check out your running
Zend Skeleton Application.
