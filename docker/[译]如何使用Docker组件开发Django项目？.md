# [译]如何使用Docker组件开发Django项目？
> 原文地址：[Django Development With Docker Compose and
> Machine](https://realpython.com/blog/python/django-development-with-docker-compose-and-machine/)

**以下为译文**

------------------------------------------------------------------------

Docker
是一个开源的应用容器引擎，让开发者可以打包他们的应用以及依赖包到一个可移植的容器中，然后发布到任何流行的
Linux 机器上，也可以实现虚拟化。自2013年发布以来，无论是从 Github
上的代码活跃度，还是 Redhat 在 RHEL6.5 中集成对 Docker 的支持, 就连
Google 的 Compute Engine 也支持 Docker 在其之上运行。火热程度可见一斑！

本篇文章详细介绍了如何通过 Docker Machine 「系统配置」和 Docker Compose
「多容器应用组装」 提供堆栈完成 Postgres, Redis 和 Django
项目相结合的开发。

而在最后，该堆栈将包括如下每个服务的单独的容器:

-   一个 Web/ Django 的容器
-   一个 Nginx 的容器
-   一个 Postgres 的容器
-   一个 Redis 的容器
-   一个 Data 容器

![用Docker组件开发Django项目](http://news.oneapm.com/content/images/2015/07/container-stack.png)

本地设置
--------

使用 Docker「v1.6.1」版本我们将使用到 Docker
Compose 「v1.2.0」编排一个多容器组成的应用程序，使用 Docker
Machine「v0.2.0」创建本地和云的 Docker 主机。  
 按照指示，分别安装 Docker Compose 和 Machine，然后测试安装结果：

    $ docker-machine --version 
    docker-machine version 0.2.0 (8b9eaf2) 
    $ docker-compose --version 
    docker-compose 1.2.0

接下来，根据以下项目结构从[`realpython/dockerizing-django`](https://github.com/realpython/dockerizing-django)克隆一份项目或自己创建项目：

    ├── docker-compose.yml 
    ├── nginx 
    │   ├── Dockerfile 
    │   └── sites-enabled 
    │   └── django_project 
    ├── production.yml 
    └── web 
    │   ├── Dockerfile 
    │   ├── docker_django 
    │   │   ├── __init__.py 
    │   │   ├── apps 
    │   │   │   ├── __init__.py 
    │   │   │   └── todo 
    │   │   │   ├── __init__.py 
    │   │   │   ├── admin.py 
    │   │   │   ├── models.py 
    │   │   │   ├── templates 
    │   │   │   │   ├── _base.html 
    │   │   │   │   └── home.html 
    │   │   │   ├── tests.py 
    │   │   │   ├── urls.py 
    │   │   │   └── views.py 
    │   │   ├── settings.py 
    │   │   ├── urls.py 
    │   └── wsgi.py 
    │   ├── manage.py 
    │   ├── requirements.txt 
    │   └── static 
    │   │   └── main.css</code>

现在我们准备容器运行……

Docker Machine
--------------

开启 Docker Machine，只需运行：

    $ docker-machine create -d virtualbox dev;
    INFO[0000] Creating CA: /Users/michael/.docker/machine/certs/ca.pem
    INFO[0000] Creating client certificate: /Users/michael/.docker/machine/certs/cert.pem
    INFO[0001] Downloading boot2docker.iso to /Users/michael/.docker/machine/cache/boot2docker.iso...
    INFO[0035] Creating SSH key...
    INFO[0035] Creating VirtualBox VM...
    INFO[0043] Starting VirtualBox VM...
    INFO[0044] Waiting for VM to start...
    INFO[0094] "dev" has been created and is now the active machine.
    INFO[0094] To point your Docker client at it, run this in your shell: eval "$(docker-machine env dev)"

这个 create 命令设置一个新的 Machine「开发环境」。实际上，它是下载
Boot2Docker 并开始运行 VM。现在只要在开发环境下指定 Docker：

    $ eval "$(docker-machine env dev)"

运行以下命令来查看当前正在运行的机器：

    $ docker-machine ls 
    NAME  ACTIVE  DRIVER  STATE  URL 
    dev * virtualbox Running tcp://192.168.99.100:2376

接下来，我们会让 Django，Postgres 和 Redis 的容器运行起来。

Docker Compose
--------------

让我们看一看 docker-compose.yml 文件：

    web: 
      restart: always 
      build: ./web 
      expose:
        - "8000" 
      links: 
        - postgres:postgres   
        - redis:redis 
      volumes: 
        - /usr/src/app/static
      env_file: .env
      command: /usr/local/bin/gunicorn docker_django.wsgi:application -w 2 -b :8000 

    nginx:
      restart: always
      build: ./nginx/
      ports: 
        - "80:80" 
      volumes: 
        - /www/static 
      volumes_from: 
        - web
      links: 
        - web:web 

    postgres: 
      restart: always
      image: postgres:latest 
      volumes_from: 
        - data
      ports: 
        - "5432:5432" 

    redis: 
      restart: always
      image: redis:latest 
      ports: 
        - "6379:6379" 

    data:   
      restart: always 
      image: postgres:latest 
      volumes: 
        - /var/lib/postgresql
      command: true

在这里，我们定义了五个服务： Web、Nginx、Postgres、Redis 和 Data。

-   Web 服务通过 「Web」 目录下的 Dockerfile 来进行构建，这里也设置了
    Python 环境设置，Django
    应用默认8000端口。这个端口之后转发到主机环境的80端口上–例如，Docker
    Machine。Web 服务还在容器 Restore.env 文件中增加了环境变量。
-   Nginx 服务用于反向代理,作用于 Django 或静态文件目录。
-   Postgres 服务是从 [Docker
    Hub](https://hub.docker.com/account/signup/) 的官方
    [PostgreSQL镜像](https://registry.hub.docker.com/_/postgres/)
    安装，安装 Postgres 后运行在默认的服务器的5432端口。
-   Redis 使用官方
    [Redis镜像](https://registry.hub.docker.com/u/library/redis/)
    安装，默认 Redis 服务是运行在6379端口。
-   最后，注意有一个单独的容器来存储数据库数据，即为
    Data。这有助于确保即使 Postgres 容器完全摧毁数据仍然存在。

现在，运行容器，构建镜像，然后开始服务：

    $ docker-compose build 
    $ docker-compose up -d

这时可以有时间喝一杯咖啡或走走路，因为你第一次运行它将需要一段时间，随后就可以从
Docker 缓存中建立运行更快的了。

一旦服务运行，我们就需要创建数据库迁移：

    $ docker-compose run web /usr/local/bin/python manage.py migrate

获得 Docker Machine 的相关 IP， – docker-machine
ip –，然后在您的浏览器中输入IP:

![用Docker组件开发Django项目](http://news.oneapm.com/content/images/2015/07/django-on-docker.png)

出现上图后刷新，您应该能看到页面更新。从本质上讲，我们使用 Redis INCR
来递增每个处理请求，查看 `web/docker_django/apps/todo/views.py`
代码以获得更多信息。

同样，这创造了五项服务，都在不同的容器中运行：

    $ docker-compose ps
                Name                          Command               State           Ports
    ----------------------------------------------------------------------------------------------
    dockerizingdjango_data_1       /docker-entrypoint.sh true       Up      5432/tcp
    dockerizingdjango_nginx_1      /usr/sbin/nginx                  Up      0.0.0.0:80->80/tcp
    dockerizingdjango_postgres_1   /docker-entrypoint.sh postgres   Up      0.0.0.0:5432->5432/tcp
    dockerizingdjango_redis_1      /entrypoint.sh redis-server      Up      0.0.0.0:6379->6379/tcp
    dockerizingdjango_web_1        /usr/local/bin/gunicorn do ...   Up      8000/tcp

要查看哪些环境变量可用于 Web 服务，运行：

    $ docker-compose run web env

要查看日志，运行：

    $ docker-compose logs

您也可以进入 Postgres Shell - - 因为我们已经通过 docker-compose.yml
文件设置在数据库中通过添加用户/角色，端口转发到主机环境中：

    $ psql -h 192.168.99.100 -p 5432 -U postgres --password

准备部署？先停止运行
`docker-compose stop`，然后让我们的应用程序在云中运行！

部署
----

与我们在本地运行应用程序一样，我们现在可以 push 到与 Docker Machine
环境完全相同的云托管服务提供商。现在让我们部署到 [Digital
Ocean](https://www.digitalocean.com/) 中。

您注册 Digital Ocean 之后，产生个人访问令牌 「Personal Access
Token」，然后运行以下命令：

    $ docker-machine create \ 
    -d digitalocean \ 
    --digitalocean-access-token=ADD_YOUR_TOKEN_HERE \
    Production 

这将需要几分钟时间来提供 droplet , 并设置一个新的 Docker Machine
产品环境：

    INFO[0000] Creating SSH key... 
    INFO[0001] Creating Digital Ocean droplet... 
    INFO[0133] "production" has been created and is now the active machine. 
    INFO[0133] To point your Docker client at it, run this in your shell: eval "$(docker-machine env production)"

现在我们有两台机器运行，一是在本地，一个在 Digital Ocean：

    $ docker-machine ls
    NAME         ACTIVE   DRIVER         STATE     URL
    dev          *        virtualbox     Running   tcp://192.168.99.100:2376
    production            digitalocean   Running   tcp://104.131.107.8:2376

设置 production 为激活机器并加载 Docker 环境到 shell：

    $ docker-machine active production 
    $ eval "$(docker-machine env production)"

最后，让我们在云上再次构建 Django
的应用程序。这时候我们就需要使用一个稍微不同的 Docker Compose
文件，不需要安装在容器里。为什么呢？因为容器本身非常适合本地开发，这样我们可以更新「Web」目录的本地代码，并且更改代码立刻对容器产生影响。在生产中，很明显没有这个必要。

    $ docker-compose build 
    $ docker-compose up -d -f production.yml 
    $ docker-compose run web /usr/local/bin/python manage.py migrate

获取与 Digital Ocean 帐户相关联的 IP
地址，并在浏览器中查看它。如果一切顺利，你应该可以看到你的应用程序在运行。

原文地址：[Django Development With Docker Compose and
Machine](https://realpython.com/blog/python/django-development-with-docker-compose-and-machine/)

**本文系
[OneAPM](http://oneapm.com/index.html?utm_source=Common&utm_medium=Articles&utm_campaign=TechnicalArticles&from=matefiseco)
工程师编译整理。想阅读更多技术文章，请访问 OneAPM
[官方博客](http://news.oneapm.com/?utm_source=TechCommunity&utm_medium=TechArticle&utm_campaign=JulSoftArti)。**


## 原文
http://segmentfault.com/a/1190000002989928
