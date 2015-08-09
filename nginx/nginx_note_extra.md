# Nginx笔记

## Location语法

<http://www.annhe.net/article-2415.html>

```
语法:location [=|~|~*|^~] /uri/ { … }
默认:否

上下文:server

这个指令随URL不同而接受不同的结构。你可以配置使用常规字符串和正则表达式。如果使用正则表达式，你必须使用 ~* 前缀选择不区分大小写的匹配或者 ~ 选择区分大小写的匹配。

确定 哪个location 指令匹配一个特定指令，常规字符串第一个测试。常规字符串匹配请求的开始部分并且区分大小写，最明确的匹配将会被使用（查看下文明白 nginx 怎么确定它）。然后正则表达式按照配置文件里的顺序测试。找到第一个比配的正则表达式将停止搜索。如果没有找到匹配的正则表达式，使用常规字符串的结果。

有两个方法修改这个行为。第一个方法是使用 “=”前缀，将只执行严格匹配。如果这个查询匹配，那么将停止搜索并立即处理这个请求。例子：如果经常发生”/”请求，那么使用 “location = /” 将加速处理这个请求。

第二个是使用 ^~ 前缀。如果把这个前缀用于一个常规字符串那么告诉nginx 如果路径匹配那么不测试正则表达式。

而且它重要在于 NGINX 做比较没有 URL 编码，所以如果你有一个 URL 链接’/images/%20/test’ , 那么使用 “images/ /test” 限定location。

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

## 更换域名重定向

<http://www.annhe.net/article-1860.html>

```
server {
server_name old;
rewrite ^/(.*) http://new/$1 permanent;
}
```

## 正确返回404

<http://www.annhe.net/article-1671.html>

```
这样的情况设置一般是这样的（网上的相关文章也是这样）
http{
.....
fastcgi_intercept_errors on;
.....
}
#----------------------------------------
server{
error_page 404 = /8c6f66dcfc8a3282/index.html; #只是转跳而已
}
正确的设置方法应该是这样（去掉等号）
http{
.....
fastcgi_intercept_errors on;
.....
}
#----------------------------------------
server{
error_page 404 /8c6f66dcfc8a3282/index.html;
}
平滑启动Nginx即可解决该问题
/usr/local/ws/nginx/sbin/nginx -s reload

```

## dokuwiki伪静态

<http://www.annhe.net/article-1344.html>

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


## 更换WordPress固定链接结构

<http://www.annhe.net/article-871.html>

rewrite实例

## 代理

<http://www.annhe.net/article-1132.html>

```
server
	{
    	listen          80;
    	server_name     yourdomain.com;
 
    	location / {
        	proxy_pass              http://smf.sinaapp.com/;
        	proxy_redirect          off;
        	proxy_set_header        X-Real-IP       $remote_addr;
        	proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
        	}
	}
```