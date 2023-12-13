# Docker-LskyProEnterprise
兰空图床企业版Dockerfile

> 之前搭建博客图床使用的[LskyPro](https://github.com/lsky-org/lsky-pro)图床，发现已经有了企业版，本着支持一波儿的态度，发现没有Dockerfile，于是自己动手写了一个。面向小白，大佬勿喷。

## 背景交代

数据库使用的`MySql`也是通过docker安装的，所以图床的镜像不需要数据库。

## 步骤

1. 跳过在服务器安装Docker环境；

2. `clone` [Docker-LskyProEnterprise](https://github.com/WenkaiZhou/Docker-LskyProEnterprise) 仓库；

3. 官方下载企业版压缩包，重命名为lsky-pro.zip放在代码目录下；

4. 构建镜像，版本可以随意，建议和下载的LskyPro版本一致；

        docker build -t lsky-pro:1.5.1 .

5. 为了方便不同服务共享数据库服务，`MySql`也使用Docker容器的方式，首先创建网络；

        docker network create -d bridge --subnet=172.18.0.0/16 --gateway=172.18.0.1 web_network

6. 创建`MySql`容器，记得把两个密码参数换下；

        docker run -d \
            --name=mysql \
            --restart unless-stopped \
            --network=web_network \
            --ip=172.18.0.2 \
            -p 3306:3306 \
            -v /docker/mysql:/var/lib/mysql \
            -e MYSQL_ROOT_PASSWORD=ROOT密码 \
            -e MYSQL_USER=lsky-pro \
            -e MYSQL_PASSWORD=lsky-pro密码 \
            -e MYSQL_DATABASE=lsky-pro \
            mysql:5.7.9

7.  创建`lsky-pro`容器，记得把你的授权替换下：

        docker run -d \
            --name=lsky-pro \
            --restart unless-stopped \
            --network=web_network \
            --ip=172.18.0.3 \
            -p 80:80 \
            -e APP_SERIAL_NO=你的许可证编号 \
            -e APP_SECRET=你的许可证密钥 \
            -e APP_URL=你的站点域名 \
            -v /docker/lsky-pro:/var/www/html \
            lsky-pro:1.5.1

8. 访问站点，在管理后台进行设置。

如果觉得要配置网络和数据库容器麻烦，也可以直接使用`docker-compose`的方式；

当然，此时服务是`http`的，也可以再开一个`nginx`容器进行反向代理，为外部提供`https`服务。
