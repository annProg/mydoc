# Nginx�ʼ�

## Location�﷨

<http://www.annhe.net/article-2415.html>

```
�﷨:location [=|~|~*|^~] /uri/ { �� }
Ĭ��:��

������:server

���ָ����URL��ͬ�����ܲ�ͬ�Ľṹ�����������ʹ�ó����ַ�����������ʽ�����ʹ��������ʽ�������ʹ�� ~* ǰ׺ѡ�����ִ�Сд��ƥ����� ~ ѡ�����ִ�Сд��ƥ�䡣

ȷ�� �ĸ�location ָ��ƥ��һ���ض�ָ������ַ�����һ�����ԡ������ַ���ƥ������Ŀ�ʼ���ֲ������ִ�Сд������ȷ��ƥ�佫�ᱻʹ�ã��鿴�������� nginx ��ôȷ��������Ȼ��������ʽ���������ļ����˳����ԡ��ҵ���һ�������������ʽ��ֹͣ���������û���ҵ�ƥ���������ʽ��ʹ�ó����ַ����Ľ����

�����������޸������Ϊ����һ��������ʹ�� ��=��ǰ׺����ִֻ���ϸ�ƥ�䡣��������ѯƥ�䣬��ô��ֹͣ������������������������ӣ��������������/��������ôʹ�� ��location = /�� �����ٴ����������

�ڶ�����ʹ�� ^~ ǰ׺����������ǰ׺����һ�������ַ�����ô����nginx ���·��ƥ����ô������������ʽ��

��������Ҫ���� NGINX ���Ƚ�û�� URL ���룬�����������һ�� URL ���ӡ�/images/%20/test�� , ��ôʹ�� ��images/ /test�� �޶�location��

�ܽᣬָ�����˳�򱻽���:
1. = ǰ׺��ָ���ϸ�ƥ�������ѯ������ҵ���ֹͣ������
2. ʣ�µĳ����ַ�����������ǰ��������ƥ��ʹ�� ^~ ǰ׺������ֹͣ��
3. ������ʽ���������ļ����˳��
4. �������������ƥ�䣬��ʹ��������������ʹ�õڶ�����ƥ������

���ӣ�

location = / {
# ֻƥ�� / ��ѯ��
[ configuration A ]
}

location / {
# ƥ���κβ�ѯ����Ϊ���������� / ��ͷ������������ʽ����ͳ��Ŀ���򽫱����ȺͲ�ѯƥ�䡣
[ configuration B ]
}

location ^~ /images/ {
# ƥ���κ��� /images/ ��ͷ���κβ�ѯ����ֹͣ�������κ�������ʽ�����ᱻ���ԡ�
[ configuration C ]
}

location ~* \.(gif|jpg|jpeg)$ {
# ƥ���κ��� gif��jpg �� jpeg ��β������Ȼ������ /images/ Ŀ¼������ʹ�� Configuration C��
[ configuration D ]
}

��������:

/ -> configuration A

/documents/document.html -> configuration B

/images/1.gif -> configuration C

/documents/1.jpg -> configuration D

ע�⣺������˳������4�����ý������Ȼһ����

(location =) > (location ����·�� ) >(location ^~ ·��) >(location ~*, ~ ����) >(location ������ʼ·��)
������ʽ���������ļ��е�ǰ��˳��Ӱ��ƥ��, ǰ�������ƥ��. ���������ƥ�䳤��������ƥ��.
```

## ���������ض���

<http://www.annhe.net/article-1860.html>

```
server {
server_name old;
rewrite ^/(.*) http://new/$1 permanent;
}
```

## ��ȷ����404

<http://www.annhe.net/article-1671.html>

```
�������������һ���������ģ����ϵ��������Ҳ��������
http{
.....
fastcgi_intercept_errors on;
.....
}
#----------------------------------------
server{
error_page 404 = /8c6f66dcfc8a3282/index.html; #ֻ��ת������
}
��ȷ�����÷���Ӧ����������ȥ���Ⱥţ�
http{
.....
fastcgi_intercept_errors on;
.....
}
#----------------------------------------
server{
error_page 404 /8c6f66dcfc8a3282/index.html;
}
ƽ������Nginx���ɽ��������
/usr/local/ws/nginx/sbin/nginx -s reload

```

## dokuwikiα��̬

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


## ����WordPress�̶����ӽṹ

<http://www.annhe.net/article-871.html>

rewriteʵ��

## ����

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