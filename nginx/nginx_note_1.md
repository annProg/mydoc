# Nginx笔记（一）

## 概念

- 高性能的HTTP和反向代理服务器软件
- IMAP/POP3/SMTP代理服务器
- 发音： `engine x`
- 作者：俄罗斯程序设计师Igor Sysoev
- 许可类型：类BSD
- 跨平台：UNIX、GNU/Linux、BSD、Mac OS X、Solaris以及Microsoft Windows等操作系统中
- 特点：稳定、高效

### 特性

- 静态编译
- Fcgi支持良好
- 支持epoll处理方式

> epoll是Linux内核为处理大批量文件描述符而作了改进的poll，是Linux下多路复用IO接口select/poll的增强版本，它能显著提高程序在大量并发连接中只有少量活跃的情况下的系统CPU利用率。

## 模块

### 结构划分

- 内核模块：HTTP，EVENT，MAIL等
- 基础模块：HTTP Access，HTTP FastCGI，HTTP Proxy，HTTP Rewrite等
- 第三方模块：HTTP Upstream Request Hash，Notice，HTTP Access Key等

### 功能划分

- Handlers，处理器模块，直接处理请求，一般只能有一个
- Filters，过滤器模块，对其他处理器模块输出的内容进行修改操作
- Proxies，代理类模块，与后段服务如FastCGI等交互，实现服务代理和负载均衡等


## 编译安装

编译命令

```
[root@lab1 nginx-1.9.3]# useradd www -d /home/www -m -s /sbin/nologin
[root@lab1 nginx-1.9.3]# yum install openssl-devel
[root@lab1 nginx-1.9.3]# yum install zlib-devel
[root@lab1 nginx-1.9.3]# yum install pcre-devel
[root@lab1 nginx-1.9.3]# yum install gperftools
[root@lab1 nginx-1.9.3]# ./configure --prefix=/usr/local/nginx --user=www --group=www --with-http_gunzip_module --with-http_gzip_static_module --with-http_stub_status_module --with-stream --with-google_perftools_module

...
...
Configuration summary
  + using system PCRE library
  + OpenSSL library is not used
  + md5: using system crypto library
  + sha1: using system crypto library
  + using system zlib library

  nginx path prefix: "/usr/local/nginx"
  nginx binary file: "/usr/local/nginx/sbin/nginx"
  nginx configuration prefix: "/usr/local/nginx/conf"
  nginx configuration file: "/usr/local/nginx/conf/nginx.conf"
  nginx pid file: "/usr/local/nginx/logs/nginx.pid"
  nginx error log file: "/usr/local/nginx/logs/error.log"
  nginx http access log file: "/usr/local/nginx/logs/access.log"
  nginx http client request body temporary files: "client_body_temp"
  nginx http proxy temporary files: "proxy_temp"
  nginx http fastcgi temporary files: "fastcgi_temp"
  nginx http uwsgi temporary files: "uwsgi_temp"
  nginx http scgi temporary files: "scgi_temp"
  
[root@lab1 nginx-1.9.3]# make && make install
...
[root@lab1 nginx-1.9.3]# /usr/local/nginx/sbin/nginx -V
nginx version: nginx/1.9.3
built by gcc 4.4.7 20120313 (Red Hat 4.4.7-11) (GCC) 
configure arguments: --prefix=/usr/local/nginx --user=www --group=www --with-http_gunzip_module --with-http_gzip_static_module --with
-http_stub_status_module --with-stream --with-google_perftools_module
```

## 配置文件

### 结构

- block形式组织，用 {} 表示
- main->events->http{'server1':'{location1,location2}', 'server2':'{location1,location2...}',...}

### 全局配置

```
[root@lab1 conf]# cat nginx.conf
user www www;           #指定nginx worker进程运行用户及用户组
worker_processes  1;    #指定nginx要开启的进程数，建议和cpu数量一样多

error_log  logs/error.log  notice;  #全局错误日志文件，级别有debug,info,notice,warn,error,crit

pid        logs/nginx.pid;    #指定进程id存储文件path
worker_rlimit_nofile 65535;   #用于绑定worker进程和CPU

#events用来指定nginx工作模式及连接上限
events {
    use epoll;             #工作模式，select,poll,kqueue,epoll等
    worker_connections  1024;  #nginx每个进程最大连接数，受Linux系统进程最大打开文件数限制(ulimit -n 设置)
}
```

### http设置

```
http {
    include       mime.types;   #配置文件包含
    default_type  application/octet-stream;   #HTTP核心模块指令，设置默认类型为二进制流

    #设置日志格式 main为此日志输出格式的名称，可以在access_log指令中引用
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';
    #引用main格式
    access_log  logs/access.log  main;
    
    client_max_body_size 20m;    #允许客户端请求的最大单个文件字节数
    client_header_buffer_size 32k;  #客户端请求头的headerbuffer大小，对于大多数请求，1KB缓冲区大小已经足够
    large_client_header_buffers 4 32k;  #客户端请求中较大的消息头的缓存最大数量和大小

    sendfile        on;   #开启高效文件传输模式
    tcp_nopush     on;    #防止网络阻塞
    tcp_nodelay on;       #防止网络阻塞

    keepalive_timeout  65;     #客户端连接保持活动的超时时间
    client_header_timeout 10;  #客户端请求头读取超时时间，超时返回"Request time out(408)"错误
    client_body_timeout 60;    #客户端请求主体读取超时时间，超时返回408错误
    send_timeout 10;           #响应客户端的超时时间
    ...
}
```

### Gzip设置

```
http {
    ....
    gzip  on;                #开启gzip
    gzip_min_length 1k;      #小于1k的不压缩
    gzip_buffers 4 16k;      #申请4个单位为16K的内存作为压缩结果流缓冲
    gzip_http_version 1.1;   #HTTP协议版本
    gzip_comp_level 2;       #压缩比，1-9压缩比增大
    gzip_types text/plain application/x-javascript text/css application/xml;    #压缩类型，text/html总是会被压缩
    gzip_vary on;            #让前端缓存服务器缓存经过压缩的页面
    ....
}
```

### server虚拟主机配置

为了便于维护和管理，最好将虚拟主机配置单独放置在一个文件，然后通过include指令包含。

例如，将server配置全部放在vhost目录下，然后用include指令包含，这样如果新增虚拟主机，直接在vhost目录下新增配置文件即可

```
http {
    ...
    include vhost/*.conf
    ...
}
```

配置实例：

```
http {
    ...
    server {
        listen       80;                        #指定服务器端口
        server_name  lab1;                      #指定IP地址或者域名
	index index.html index.htm index.php;   #默认首页地址
	root /home/wwwroot/default;             #虚拟主机根目录
        #charset koi8-r;

       access_log  /home/wwwlogs/default.access.log  main;   #日志路径 main是前面定义的日志格式
    }
    ...
}
```

### URL匹配

location block 用于URL匹配配置，支持正则表达式及条件判断，可以实现对动、静态网页的过滤处理。

```
server {
        #图片,swf交给nginx处理，文件过期时间为30天
        location ~ .*\.(gif|jpg|jpeg|png|bmp|swf)$
		{
			expires      30d;
		}
        error_page  404              /404.html;

        # redirect server error pages to the static page /50x.html
        error_page   500 502 503 504  /50x.html;

	#location下的root会重定义/404.html的路径
        location = /404.html {
            root   /home/wwwroot/error_pages/;
        }


        # proxy the PHP scripts to Apache listening on 127.0.0.1:80 动态网页的过滤处理
        location ~ \.php$ {
            proxy_pass   http://127.0.0.1;
        }
}
```

location中重定义root时最好用绝对路径，相对路径是相对于nginx安装目录的，如设置 `root html` 的 `error.log`

```
2015/08/07 15:31:32 [error] 17726#0: *4 open() "/usr/local/nginx/html/404.html" failed (2: No such file or directory), client: 192.168.60.1, server: lab1, request: "GET /5.t HTTP/1.1", host: "lab1"
```

动态网页没有响应的处理程序会被直接下载。

## Nginx管理

```
[root@lab1 conf]# /usr/local/nginx/sbin/nginx -h
nginx version: nginx/1.9.3
Usage: nginx [-?hvVtTq] [-s signal] [-c filename] [-p prefix] [-g directives]

Options:
  -?,-h         : this help
  -v            : show version and exit
  -V            : show version and configure options then exit
  -t            : test configuration and exit
  -T            : test configuration, dump it and exit
  -q            : suppress non-error messages during configuration testing
  -s signal     : send signal to a master process: stop, quit, reopen, reload
  -p prefix     : set prefix path (default: /usr/local/nginx/)
  -c filename   : set configuration file (default: conf/nginx.conf)
  -g directives : set global directives out of configuration file
```


## 参考资料

```
[1]. 高俊峰. 高性能Linux服务器构建实战：运维监控、性能调优与集群应用[M]// 北京华章图文信息有限公司, 2012.
[2]. lnmp.org. LNMP一键安装包
```