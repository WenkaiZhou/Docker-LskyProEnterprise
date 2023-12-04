# Docker-LskyProEnterprise
兰空图床企业版Dockerfile

> 之前搭建博客图床使用的[LskyPro](https://github.com/lsky-org/lsky-pro)图床，发现已经有了企业版，本着支持一波儿的态度，发现没有Dockerfile，于是自己动手写了一个。面向小白，大佬勿喷。

## 背景交代

数据库使用的`MySql`也是通过docker安装的，所以图床的景象不需要数据库。

## 步骤

1. 在官方下载企业版压缩包，重命名为`lsky-pro.zip`放在代码目录下；
2. 构建镜像

```Shell
docker build -t lsky-pro:v1.5.1 .
```
3. 创建容器

```Shell
docker run -d \
    --name=lsky-pro \
    --restart unless-stopped \
    -p 80:80 \
    -e APP_SERIAL_NO=你的许可证编号 \
	-e APP_SECRET=你的许可证密钥 \
	-e APP_URL=你的站点域名 \
    -v /docker/lsky-pro:/var/www/html \
    lsky-pro:v1.5.1
```
4. 访问站点，在管理后台进行设置。