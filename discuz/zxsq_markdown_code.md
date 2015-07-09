# 代码

## 行内代码
如果只想高亮正文中某个词，可以用两个反引号包裹起来

```
`行内代码`
```
这是`行内代码`

如果行内代码包含反引号，可以用多个反引号包裹

```
包含``反引号(`) `` 的行内代码
```

输出：包含``反引号(`)`` 的行内代码

如果行内代码开头就有反引号，需要起始端和结束端各一个空格

```
`` `反引号` ``
```
输出：`` `反引号` ``


## 普通代码

### 反引号包裹
用3个或以上的反引号包裹起来
~~~~~~~~~
```
# rewrite`s rules for wordpress pretty url 
LoadModule rewrite_module  modules/mod_rewrite.so
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . index.php [NC,L]
````
~~~~~~~~~~

### 波浪线包裹
使用3个及以上的波浪线包裹代码

`````
~~~
# rewrite`s rules for wordpress pretty url 
LoadModule rewrite_module  modules/mod_rewrite.so
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . index.php [NC,L]
~~~~
``````

### 缩进
4个空格或者一个制表符
```
	# rewrite`s rules for wordpress pretty url 
	LoadModule rewrite_module  modules/mod_rewrite.so
	RewriteCond %{REQUEST_FILENAME} !-f
	RewriteCond %{REQUEST_FILENAME} !-d
	RewriteRule . index.php [NC,L]
````
显示效果

```
# rewrite`s rules for wordpress pretty url
LoadModule rewrite_module  modules/mod_rewrite.so
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . index.php [NC,L]
````

### 特殊字符

当代码中有这些特殊字符时，可以缩进、波浪线、反引号嵌套使用，例如

	    ~~~
	    ```
		# rewrite`s rules for wordpress pretty url 
		LoadModule rewrite_module  modules/mod_rewrite.so
		RewriteCond %{REQUEST_FILENAME} !-f
		RewriteCond %{REQUEST_FILENAME} !-d
		RewriteRule . index.php [NC,L]
	    ````
	    ~~~~
输出效果如下：

    ~~~
    ```
	# rewrite`s rules for wordpress pretty url 
	LoadModule rewrite_module  modules/mod_rewrite.so
	RewriteCond %{REQUEST_FILENAME} !-f
	RewriteCond %{REQUEST_FILENAME} !-d
	RewriteRule . index.php [NC,L]
    ````
    ~~~~
    

## 指定语言
用以下方式指定语言，当有代码高亮解析器的时候将起作用

~~~~
```javascript
$(document).ready(function () {
    alert('hello world');
});
```
~~~~~~~

请用浏览器的审查元素观念观察结果

```javascript
$(document).ready(function () {
    alert('hello world');
});
```
test


# 数学公式

借助插件 [zxsq_mathjax]([url]http://addon.discuz.com/?@zxsq_mathjax.plugin[/url]) 可以实现论坛输入 $LaTeX$ 数理化公式


## 行内公式

~~~~
$ax^2+bx+c=55$
or
\\(ax^2+bx+c=55\\)
~~~~~~~~~~

效果如 $ax^2+bx+c=55$

## 跨行公式

~~~~
$$\int_1^{+\infty}\left[\ln\left(1+\frac1x\right)-\sin{\frac1x}\right]\,\mathrm dx$$
or
\\[\int_1^{+\infty}\left[\ln\left(1+\frac1x\right)-\sin{\frac1x}\right]\,\mathrm dx\\]
~~~~~~

显示如下

$$\int_1^{+\infty}\left[\ln\left(1+\frac1x\right)-\sin{\frac1x}\right]\,\mathrm dx$$
