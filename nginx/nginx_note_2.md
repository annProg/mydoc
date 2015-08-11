# Nginx笔记（二）

## location

### 语法

```
语法:location [=|~|~*|^~] /uri/ { … }
默认:否
上下文:server

~* : 正则表达式，不分区大小写
~  : 正则表达式，区分大小写
=  : 严格匹配
^~ : 不测试正则表达式

总结，指令按下列顺序被接受:
1. = 前缀的指令严格匹配这个查询。如果找到，停止搜索。
2. 剩下的常规字符串，长的在前。如果这个匹配使用 ^~ 前缀，搜索停止。
3. 正则表达式，按配置文件里的顺序。
4. 如果第三步产生匹配，则使用这个结果。否则使用第二步的匹配结果。

例子：

location = / {
# 只匹配 / 查询。
[ configuration A ]
}

location / {
# 匹配任何查询，因为所有请求都已 / 开头。但是正则表达式规则和长的块规则将被优先和查询匹配。
[ configuration B ]
}

location ^~ /images/ {
# 匹配任何已 /images/ 开头的任何查询并且停止搜索。任何正则表达式将不会被测试。
[ configuration C ]
}

location ~* \.(gif|jpg|jpeg)$ {
# 匹配任何已 gif、jpg 或 jpeg 结尾的请求。然而所有 /images/ 目录的请求将使用 Configuration C。
[ configuration D ]
}

例子请求:

/ -> configuration A

/documents/document.html -> configuration B

/images/1.gif -> configuration C

/documents/1.jpg -> configuration D

注意：按任意顺序定义这4个配置结果将仍然一样。

(location =) > (location 完整路径 ) >(location ^~ 路径) >(location ~*, ~ 正则) >(location 部分起始路径)
正则表达式根据配置文件中的前后顺序影响匹配, 前面的优先匹配. 其它则根据匹配长度来优先匹配.
```

### 匹配顺序实例

#### 正则表达式前后顺序影响匹配

以dokuwiki为例。dokuwiki需要配置某些目录禁止访问，如果以下面的顺序，则请求 conf data 等目录下的php文件仍然会返回200，原因是优先匹配了前面的正则。如果调换位置，则禁止目录下的php文件也会返回403。

```
location ~ .*\.(php|php5)?$
			{
				try_files $uri =404;
				fastcgi_pass  unix:/tmp/php-cgi.sock;
				fastcgi_index index.php;
				include fcgi.conf;
			}

location ~ /(conf|data|bin|inc)/ { deny all; }
```

另外一种方法是使用 `^~` 前缀严格限制目录访问，可以做到被禁目录下所有文件都返回403
```
location ^~ /conf/ { deny all; }
location ^~ /data/ { deny all; }
location ^~ /bin/  { deny all; }
location ^~ /inc/  { deny all; }
```

参考：<http://www.annhe.net/article-2415.html>

### 防盗链实例

```
server {
        listen 80;
        server_name b.lab1;
        root /home/wwwroot/b.lab1;

        location ~* \.(jpg|png|gif)$ {
                valid_referers none blocked *.lab1 *.baidu.com;
                if ($invalid_referer) {
                        return 504;
                }
        }
}
```

测试结果：

```
[root@lab1 doc]# r=(http://baidu.com http://www.baidu.com http://a.lab1/ http://a.lab2/ none);for id in ${r[*]};do code=`curl -s -w %
{http_code} http://b.lab1/doc/logo.png -e $id -o /dev/null`;echo "$code -- $id";done
504 -- http://baidu.com
200 -- http://www.baidu.com
200 -- http://a.lab1/
504 -- http://a.lab2/
200 -- none
[root@lab1 doc]# 
```



## rewrite

```
正则表达式匹配，其中：
* ~ 为区分大小写匹配
* ~* 为不区分大小写匹配
* !~和!~*分别为区分大小写不匹配及不区分大小写不匹配

文件及目录匹配，其中：
* -f和!-f用来判断是否存在文件
* -d和!-d用来判断是否存在目录
* -e和!-e用来判断是否存在文件或目录
* -x和!-x用来判断文件是否可执行

flag标记有：
* last 相当于Apache里的[L]标记，表示完成rewrite
* break 终止匹配, 不再匹配后面的规则
* redirect 返回302临时重定向 地址栏会显示跳转后的地址
* permanent 返回301永久重定向 地址栏会显示跳转后的地址
```

### 域名重定向

```
server {
server_name c.lab1;
rewrite ^/(.*) http://b.lab1/$1 permanent;
}
```

测试结果：

```
[root@HADOOP-215 doku]# curl -I http://c.lab1/
HTTP/1.1 301 Moved Permanently
Server: nginx/1.9.3
Date: Tue, 11 Aug 2015 07:36:32 GMT
Content-Type: text/html
Content-Length: 184
Connection: keep-alive
Location: http://b.lab1/
```

参考：<http://www.annhe.net/article-1860.html>

### dokuwiki伪静态

```
    rewrite ^(/)_media/(.*) $1lib/exe/fetch.php?media=$2 last;
    rewrite ^(/)_detail/(.*) $1lib/exe/detail.php?media=$2 last;
    rewrite ^(/)_export/([^/]+)/(.*) $1doku.php?do=export_$2&id=$3 last;
    location /
    {
        if (!-f $request_filename)
        {
            rewrite ^(/)(.*)?(.*)  $1doku.php?id=$2&$3 last;
            rewrite ^(/)$ $1doku.php last;
        }
    }
```

参考：<http://www.annhe.net/article-1344.html>

## error_page

```
error_page 404 = /404.html; #只是转跳而已，返回200
error_page 404 /8c6f66dcfc8a3282/index.html;  #正确的设置方法应该是这样（去掉等号），返回404
```

参考：<http://www.annhe.net/article-1671.html>

## proxy and upstream

用nginx代理访问Google。需要使用ngx_http_sub_module模块，编译选项--with-http_sub_module。

```
增加--with-http_sub_module重新编译nginx
./configure ............. --with-http_sub_module
make
不要make install，直接替换二进制文件即可
cp ./obj/nginx /usr/local/nginx/sbin/nginx
查看版本及编译选项
[gjc@server1 ~]$ nginx -V
nginx version: nginx/1.9.3
built by gcc 4.4.7 20120313 (Red Hat 4.4.7-16) (GCC) 
built with OpenSSL 1.0.1e-fips 11 Feb 2013
TLS SNI support enabled
configure arguments: --user=www --group=www --prefix=/usr/local/nginx --with-http_stub_status_module --with-http_ssl_module --with-htt
p_gzip_static_module --with-ipv6 --with-http_sub_module
```

```
upstream google {
                #server 74.125.239.112:80 max_fails=3;
                #server 74.125.239.113:80 max_fails=3;
                #server 74.125.239.114:80 max_fails=3;
                #server 74.125.239.115:80 max_fails=3;
                #server 74.125.239.116:80 max_fails=3;
		server www.google.com max_fails=3;
		server www.google.com.hk max_fails=3;
		server www.google.co.jp max_fails=3;
        }

        server {
                listen 80;
                server_name google.yourdomain.com;
                rewrite ^(.*) https://google.yourdomain.com$1 permanent;
        }

        server {
        listen 443;
        server_name google.yourdomain.com;
        ssl on;
        ssl_certificate /usr/local/nginx/conf/server.crt;
        ssl_certificate_key /usr/local/nginx/conf/server.key;
        location / {
		proxy_cache_key "$scheme://$host$request_uri";    #缓存key规则，用于自动清除缓存。
		proxy_cache cache_g4w; #缓存区名称，必须与前面定义的相同
		proxy_cache_valid  200 304 3h; #200 304状态缓存3小时
		proxy_cache_valid 301 3d;  #301状态缓存3天
		proxy_cache_valid any 1m;  #其他状态缓存（如502 404）1分钟
		proxy_cache_use_stale invalid_header error timeout http_502;  #当后端出现错误、超时、502状态时启用过期缓存
                proxy_redirect https://www.google.com/ /;     #修改从被代理服务器传来的应答头中的"Location"和"Refresh"字段
                proxy_cookie_domain google.com google.yourdomain.com;  #把cookie的作用域替换成我们的域名
                proxy_pass http://google;                                #指定代理的后端服务器地址和端口，可以是主机名或者IP地址，也可以是通过upstream指令设定的负载均衡组名称
		
		#proxy_set_header设置由后端的服务器获取用户的主机名或真实IP地址，以及代理者的真实IP地址。
                proxy_set_header Host "www.google.com";
                proxy_set_header Accept-Encoding "";
                proxy_set_header User-Agent $http_user_agent;
                proxy_set_header Accept-Language "zh-CN";
                proxy_set_header Cookie "PREF=ID=047808f19f6de346:U=0f62f33dd8549d11:FF=2:LD=zh-CN:NW=1:TM=1325338577:LM=1332142444:GM=1:SG=2:S=rE0SyJh2w1IQ-Maw";                
		sub_filter www.google.com google.yourdomain.com;    #把谷歌的域名替换成自己的域名
                sub_filter_once off;                                #字符串替换一次还是多次替换
                }
        access_log  /home/wwwlogs/p.google.log  access;
        }
```

参考：<http://www.annhe.net/article-1132.html>

## 参考资料

```
[1]. http://www.annhe.net/article-2415.html
[2]. http://www.annhe.net/article-1860.html
[3]. http://www.annhe.net/article-1344.html
[4]. http://www.annhe.net/article-1671.html
[5]. http://www.annhe.net/article-1132.html
```